---
name: agy-subagents
description: >-
  Orchestrate steerable CLI subagents, persistent stream-json sessions, or
  custom model/effort/sandbox workers using agy and run_command.
disable-slash-command: true
---

# `agy-subagents`: CLI-Driven Subagent Orchestration

Prefer `run_workflow` for parallel fan-out, staged pipelines, isolated worktrees, and structured aggregation. Use this skill when you specifically need CLI-level controls: explicit model slugs (`--model`), reasoning effort overrides (`--effort`), `--sandbox`, `--settings`, or persistent multi-turn CLI sessions (`--conversation` / `--input-format stream-json`).

Target `--agent bare` for self-contained subtasks (~2k Turn-0 tokens) or `--agent clean` when the worker needs project rules/skills.

---

## 1. CLI Capability & Parameter Matrix (`agy v1.5.17`)

### Invocation & Session State
- `-p, --print "<prompt>"`: Run a single prompt non-interactively to completion.
- `--agent <name>`: Target agent persona (`bare` for ultra-lean leaf workers; `clean` for rules/skills-aware workers).
- `-r, --resume, --conversation <id>`: Continue an existing session by `conversation_id`, retaining accumulated context.
- `-c, --continue`: Continue the most recent session.

### Output, Streaming & Observability
- `--output-format text | json | stream-json`: Response format (`json` for single-shot parsing; `stream-json` for NDJSON events).
- `--input-format text | stream-json`: `stream-json` reads NDJSON `{"event":"user","message":{"content":"..."}}` turns over stdin in one long-lived process (requires `--output-format stream-json`; omit `-p`).
- `--json-schema <schema|path>`: Enforce a JSON Schema object on the final `structured_output` field.
- `--log-file "<path>"`: Redirect verbose telemetry away from parent context.
- `--disable-slash-commands`: Prevent prompts starting with `/` from triggering slash commands or skill expansion.

### Execution, Model & Safety Constraints
- `--mode auto | accept-edits | plan`: Execution mode (`auto` is default in `v1.5.7+`; `plan` for read-only; `accept-edits` to auto-apply workspace edits).
- `--model <slug>`: Pin an exact model slug (run `agy models` to list).
- `--effort low | medium | high | xhigh | max`: Set reasoning effort level.
- `--sandbox`: Run worker commands inside the OS terminal sandbox.
- `--print-timeout <dur>`: Optional deadline for print mode (default `0s` = unlimited).
- `--dangerously-skip-permissions`: Auto-approve tool permission requests in automated runs.
- `--settings <json|path>`: Session-only `settings.json` overrides (never saved).

### Workspace Scoping
- `cd "<path>" && agy ...`: Anchor execution directory (e.g., an isolated git worktree).
- `--add-dir <path>`: Mount auxiliary directories into the worker's workspace (repeatable).

---

## 2. Composable Orchestration Patterns

### Single-Shot Bare Worker (JSON + Schema)
```bash
agy --agent bare --mode plan --effort low --output-format json \
  -p "Inspect /abs/path/to/file.py and list any unhandled edge cases."
```

### Background Asynchronous Worker
Launch with `WaitMsBeforeAsync: 500` (and optionally `NotificationTimeoutSeconds` for a stalled-run check-in) in `run_command` for long builds or multi-step runs; `run_command` backgrounds the process and wakes you automatically on completion (never poll `manage_task`).

### Multi-Turn Steerable Continuation
Capture `conversation_id` from the initial `--output-format json` response and pass `-r <id>` / `--conversation <id>` on follow-up turns, or hold one warm process open with `--input-format stream-json --output-format stream-json`.

### Isolated Git Worktree Worker
```bash
git worktree add /tmp/wt-task -b task-branch && \
  (cd /tmp/wt-task && agy --agent bare --mode accept-edits --output-format json \
    -p "Run pwd to confirm worktree root, implement X, run tests, and summarize the diff.")
```

---

## 3. Observability & Context Shielding

- **Isolate Noisy Output**: Pass `--log-file "scratch/<task>.log"` and redirect bulky stdout when needed so intermediate tool traces stay on disk.
- **Inspect Defensively**: Read logs only on non-zero exit or failure using `read_file` or bounded `tail`.
- **Synthesize**: Report concise results and file links—never dump raw worker logs into the parent context.
