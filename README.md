# agent-machines

Run Claude Code agents with permissions off, one disposable OrbStack machine per task, and review their
work like a colleague's: a diff, the running app, a PR you push yourself.

- **No limits, little risk.** Each agent owns a full clone of a prepared base machine: repo, databases, dev
  server, tests. Whatever it breaks dies with the machine. No permission prompts to approve at 2 pm on a
  Wednesday; the control point is the diff at the end.
- **No GitHub, no keys.** Machines have no GitHub access and no SSH keys. The Mac pushes refs in, fetches
  the task branch out, and pushes and opens PRs itself, after you confirm. (The machine does hold the
  Claude token the agent runs on.)
- **Better than worktrees** when a task needs a running app: no shared database, ports or test runs
  between tasks. The cost is RAM (2–4 GB per running task) and a base machine to keep current.
- **Done means green.** A Stop hook runs the project's CI on the agent's commits; the agent can't finish
  until it passes.

Requires macOS with [OrbStack](https://orbstack.dev), `gh` logged in, `jq`. Setting up a project: see
[BUILD.md](BUILD.md) (a prompt for Claude Code).

## Use

    ./task new 12 fix/12-report-totals --issue 12    # clone the base, prepare the branch, start the agent
    ./task watch                                     # own terminal: dashboard + notifications
    ./task tmux                                      # inside tmux: a window per task, Mac shell over the agent
    ./task attach 12                                 # watch or talk to the agent (tmux)
    ./task say 12 "use the existing helper"          # answer a blocked agent
    ./task diff 12                                   # review
    ./task view 12                                   # open the app running in the machine
    ./task code 12                                   # VS Code over SSH into the machine
    ./task push 12                                   # confirm, push, open a draft PR (in a real terminal)
    ./task sync 12 --nudge                           # hand PR review comments to the agent
    ./task pull-main 12 --rebase                     # main moved on: push it in, agent rebases
    ./task rm 12                                     # once the work is on GitHub

`./task` alone lists every command.

## Layout

- `task` — the Mac-side CLI; `config.sh` — project settings.
- `vm/` — installed into machines as `/opt/task-agent` (`./task install-vm`): `agent-prepare`,
  `agent-start`, `agent-status` (state the Mac reads), `agent-ci-gate` (Stop hook), `agent-refresh`
  (base), `agent-devstack`, plus the project-specific `agent-setup`, `agent-ci`, `Procfile`, `env.sh`
  and `task-preamble.md` (what every agent is told before its task).
- `tasks/<id>/` — per task on the Mac: `prompt.md`, `issue.md`, `pr-comments.md`, `images/`, `RESULT.md`.

Machine states: `starting → ready → working ⇄ idle/needs_input → done | blocked | failed`, set by Claude
Code hooks, the agent itself and the CI gate.
