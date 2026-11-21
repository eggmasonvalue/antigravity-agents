---
name: run-workflow
description: >-
  Write and run Python workflow scripts with run_workflow using type_name="worker"
  for parallel fan-out, staged pipelines, isolated worktree edits, and structured aggregation.
disable-slash-command: true
---

# Dynamic Workflows (`run_workflow`)

A workflow is a Python script executed by `run_workflow` (using Python bundled with `agy`). Use it whenever orchestration is code: parallel fan-out across files/modules/checks, sequential pipelines, multi-turn review-and-fix loops, or structured aggregation.

## Critical Rules for `clean`

1. **Always pass `type_name="worker"`**: Built-in `"self"` is unavailable on custom agents and will fail with `subagent "self" not found`. Every `agent(...)` call **must** specify `type_name="worker"` (the bundled bare leaf worker, ~2k Turn-0 tokens per child).
2. **Brief workers explicitly**: `worker` runs with `excludeDefaultComponents: true` and `inheritMcp: false`—it does **not** inherit `AGENTS.md`/`GEMINI.md` rules, skills, or `<user_information>`. Include:
   - Exact absolute paths (for `workspace="inherit"`), or let it anchor itself via `pwd` in `workspace="branch"`.
   - Any repo conventions or constraints relevant to its slice (e.g., test runner, linter, forbidden files).
   - The exact path to any `SKILL.md` it needs to follow.

## Invocation

Pass inline Python via `Script`, or save a file (e.g. in scratch) and pass `ScriptPath`, with a concise `Description`. Set `Args` (a JSON object, exposed as `args` in the script) when parameterizing. Workflows run asynchronously in the background and wake you on completion; set `WaitMsBeforeAsync` (up to `10000`) only for fast scripts.

## Primitives

Top-level `await` and `async def` helpers are supported. `CONVERSATION_ID`, `STEP_INDEX`, `WORKSPACES` (tuple, primary first), and `args` (dict) are injected.

| Primitive | Behavior |
| :--- | :--- |
| `phase(name)` | Starts a named UI phase grouping subsequent logs and agent cards. |
| `log(*args)` | Appends a line to the workflow UI and tool result `Logs:`. |
| `agent(prompt=None, schema=None, role=None, type_name="worker", workspace="inherit", model=None)` | Defines a lazy worker. `await agent(...)` runs once and returns the parsed `finish` value matching `schema`. `a = agent(...)` then `await a(prompt, schema)` runs sequential turns keeping conversation state (`del a` ends it). |
| `parallel(items, fn)` | Runs `fn(item)` concurrently and returns results in item order (cancels siblings if one fails). |
| `pipeline(items, fn)` | Runs `fn(item)` sequentially in item order. |
| `await trajectory(last=None, types=None, tools=None, min_index=None, max_index=None)` | Reads earlier parent conversation steps before `run_workflow` started (`step.index`, `.type`, `.status`, `.text`, `.tool`, `.args`, `.output`). |

### Key `agent(...)` Arguments
- `type_name`: **`"worker"`** (required on `clean`; any other custom subagent name also works).
- `schema` *(required)*: JSON Schema dict/string enforced via the child's `finish` tool (use `{"type": "string"}` for free-form text).
- `workspace`: `"inherit"` (shared workspace), `"branch"` (isolated Git worktree—use whenever parallel workers edit files or run conflicting builds), or `"share"`.
- `model`: `"inherit"` (default), `"flash_lite"`, `"flash"`, or `"pro"`. Use lighter tiers for high-volume mechanical fan-out.
- `role`: Short UI card title (e.g. `f"Review {path}"`).

## Patterns

### Parallel Fan-Out & Aggregation
```python
phase("Discover")
files = await agent(
    f"In {WORKSPACES[0]}, list all *.py files changed since main. Return absolute paths only.",
    schema={"type": "array", "items": {"type": "string"}},
    type_name="worker",
    role="Discover changed files",
    model="flash",
)

phase("Review")
verdicts = await parallel(
    files,
    lambda f: agent(
        f"Inspect {f} for error-handling bugs. Reply in <=3 bullets or 'OK'.",
        schema={"type": "string"},
        type_name="worker",
        role=f"Review {f.split('/')[-1]}",
        model="flash",
    ),
)
for f, v in zip(files, verdicts):
    log(f"{f}: {v}")
```

### Multi-Turn Reviewer + Isolated Parallel Fixers
```python
reviewer = agent(
    f"You review code in {WORKSPACES[0]}. Be terse and cite exact file:line locations.",
    type_name="worker",
    role="Reviewer",
)
bugs = await reviewer(
    "List concrete bugs in src/parser.py.",
    schema={"type": "array", "items": {"type": "string"}},
)
fixes = await parallel(
    bugs,
    lambda b: agent(
        f"Run pwd to locate your worktree, fix this bug, run pytest, and summarize the diff: {b}",
        schema={"type": "string"},
        type_name="worker",
        workspace="branch",
        role=f"Fix: {b[:40]}",
    ),
)
ok = await reviewer(f"Proposed fixes:\n{fixes}\nAre all bugs addressed?", schema={"type": "boolean"})
del reviewer
log("Verified:", ok)
```
