# How the factory runs here

The factory's skills assume one agent claims an issue, implements it, verifies it and
opens the PR. Here those stages are split across three agents in tmux session `trio`, and
the factory's cloud routines are not used. The contract and charter still apply in full.

| Stage | Who | Notes |
|---|---|---|
| Triage, spec | Planner (Claude Code) | Runs `factory-triage` and `factory-spec`; spec gates wait for the human. Gate 1 mockups are drafted with OpenUI (`docs/factory/MOCKUPS.md`). |
| Claim | Planner | Pushes the `claude/fq-<n>` claim branch and moves the label to `factory:in-progress`. |
| Implement | Worker (local model via Claude Code) | Gets one small, explicit task at a time from the planner through `ask-worker`. No network and no `gh`; it runs only `pnpm` commands. |
| Gates, negative-test proof | Planner | Runs `gates.sh` and `prove-test.sh`; the worker cannot run them. |
| Verify | Reviewer (Codex, read-only sandbox) | The fresh context the contract requires. Reads the diff cold through `git -C <path>`; it never sees the worker's report. |
| PR | Planner | Opens a draft PR with the verbatim `FACTORY_GATES:` line and Codex's verdict. |
| Merge | Human | Always. |

Limits that follow from this setup:

- **Agents share the human's GitHub identity.** The planner uses the human's `gh` login,
  so GitHub cannot tell an agent's merge from the human's. The ruleset still forces every
  change through a PR with green gates, but only the hooks and the contract stop an agent
  from merging. A separate bot account would close that gap.
- **The worker is offline.** A dependency that is not in the local pnpm store has to be
  installed by the human (`pnpm add ...`) before the worker can use it.
- **Codex verifies in a temporary copy.** Its sandbox cannot write to the repo, and both
  `gates.sh` (build output) and `prove-test.sh` (a temporary revert) need to write. Codex
  clones the branch into a temporary directory and runs both there, so its gate and proof
  lines are its own, not pasted from the planner.
