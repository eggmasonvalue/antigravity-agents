---
name: agy-subagents
description: Orchestrate isolated, multi-turn, or background CLI subagents and parallel workers using agy and run_command.
---

# `agy-subagents`: CLI-Driven Subagent Orchestration

This skill provides the operational parameters and composable primitives for dispatching, steering, and isolating subagent tasks via `run_command` and the `agy` CLI binary.

---

## 1. CLI Capability & Parameter Matrix

Select and combine flags dynamically when constructing `run_command` invocations:

### Invocation & Session State
- `-p, --print "<prompt>"`: Run prompt non-interactively to completion.
- `--agent <name>`: Target agent persona (e.g. `better-agy`, `lean-agy`).
- `--conversation <id>`: Continue an existing subagent session, retaining its accumulated context.
- `-c, --continue`: Continue the most recent session.

### Output & Observability Controls
- `--output-format json | text | stream-json`: Response format. Prefer `json` for programmatic parsing.
- `--json-schema <schema|path>`: Enforce a structured JSON output schema on the final result.
- `--log-file "<path>"`: Redirect worker telemetry, tool calls, and noisy output away from parent context.

### Cognitive & Execution Constraints
- `--mode plan | accept-edits`: Constrain capabilities (`plan` for read-only; `accept-edits` for auto-applying changes).
- `--model <name>`: Override model selection for the worker session.
- `--effort low | medium | high`: Set reasoning effort level.
- `--sandbox`: Run worker in a restricted terminal sandbox.
- `--print-timeout <dur>`: Execution timeout (default `5m0s`).
- `--dangerously-skip-permissions`: Auto-approve tool calls in automated subagent runs.

### Workspace Scoping
- `Cwd` *(via `run_command`)*: Set root execution directory (e.g. git worktree).
- `--add-dir <path>`: Mount auxiliary directories into the worker's workspace.

---

## 2. Composable Orchestration Primitives

Treat these patterns as modular building blocks. Combine them freely based on task requirements:

### Lifecycle: Synchronous vs. Asynchronous
- **Synchronous Execution (`-p`)**: For fast lookups, deep research, or single-shot evaluations where the parent waits for the result before proceeding.
- **Asynchronous Task (`WaitMsBeforeAsync: 500`)**: For long builds, large test suites, or multi-step tasks. `run_command` automatically detaches the process to a background task and reactively wakes up the parent upon completion.

### State: Ephemeral vs. Stateful Continuation
- **Ephemeral Single-Shot**: Launch a fresh subagent with zero prior state.
- **Multi-Turn Continuation (`--conversation <id>`)**: Capture the conversation ID from a worker's initial run and pass `--conversation <id>` on subsequent turns to steer the worker while preserving its loaded context.

### Workspace: Scoped & Worktree Isolation
- **Branch / Worktree Isolation**: Create a git worktree (`git worktree add <path> -b <branch>`) and dispatch the worker with `Cwd: "<path>"` and `--mode accept-edits`. Inspect the diff from root before merging or discarding.

### Cognitive & Mode Shaping
- **Read-Only Analysis**: Pair `--mode plan` with `--output-format json` to ensure zero file mutation risk during architecture reviews.
- **Cognitive & Effort Tiering**: Route lightweight scanning or research with lower reasoning effort (`--effort low`), while allocating higher reasoning effort (`--effort high`) or specialized models to complex architectural refactoring.

---

## 3. Observability & Context Shielding

- **Isolate Noisy Output**: Always supply `--log-file "scratch/<task_name>.log"` for tasks that produce heavy logs. Intermediate tool calls and searches stay on disk.
- **Inspect Defensively**: Read subagent logs only when necessary (e.g. failure diagnosis via non-zero exit codes) using `view_file` or tail filtering.
- **Synthesize for the User**: Return concise summaries and links to modified files or logs. Never dump raw subagent logs directly into the parent conversation.
