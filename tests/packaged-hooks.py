"""Exercise registered hook commands after an unpacker strips execute bits."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import uuid


source = Path(__file__).resolve().parents[1]
bash = os.environ.get("BATON_TEST_BASH") or shutil.which("bash")
assert bash, "Bash must be available to run the plugin hooks"

with tempfile.TemporaryDirectory(prefix="fable baton packaging ") as temporary:
    root = Path(temporary) / "installed plugin with spaces"
    root.mkdir()
    for directory in ("hooks", "policy", ".claude-plugin", "agents", "skills"):
        shutil.copytree(source / directory, root / directory)
    state = Path(temporary) / "state"
    state.mkdir()
    for script in (root / "hooks").glob("*.sh"):
        script.chmod(0o644)
        if os.name != "nt":
            assert script.stat().st_mode & 0o111 == 0

    hooks = json.loads((root / "hooks/hooks.json").read_text())["hooks"]
    environment = os.environ.copy()
    environment.update(
        CLAUDE_PLUGIN_ROOT=root.as_posix(),
        TMPDIR=state.as_posix(),
        TEMP=state.as_posix(),
        TMP=state.as_posix(),
        FABLE_BATON_TRIPWIRE="2",
    )
    session = "packaging-" + uuid.uuid4().hex

    def invoke(event, payload):
        command = hooks[event][0]["hooks"][0]["command"]
        result = subprocess.run(
            [bash, "-c", command],
            input=json.dumps(payload),
            text=True,
            capture_output=True,
            env=environment,
            cwd=root,
            timeout=15,
        )
        assert result.returncode == 0, (event, result.stderr)
        return result.stdout

    startup = invoke("SessionStart", {"session_id": session, "model": "claude-sonnet-5"})
    assert "Orchestration policy" in startup, "Startup policy missing"
    assert "Session model adaptation: Sonnet" in startup, "Startup tier adaptation missing"
    assert (state / ("fable-baton-tier-" + session)).read_text().strip() == "sonnet"
    prompt = invoke("UserPromptSubmit", {"session_id": session})
    assert "Sonnet session" in prompt
    assert not invoke("PostToolUse", {"session_id": session, "tool_name": "Bash"}).strip()
    notice = json.loads(invoke("PostToolUse", {"session_id": session, "tool_name": "Read"}))
    context = notice["hookSpecificOutput"]["additionalContext"]
    assert "2 consecutive" in context and "Sonnet session" in context
    assert not invoke("PostToolUse", {"session_id": session, "tool_name": "Agent"}).strip()
    assert not invoke("PostToolUse", {"session_id": session, "tool_name": "Read"}).strip()
    print("PASS: all registered hooks work with mode 644 and spaces in the installed path")
