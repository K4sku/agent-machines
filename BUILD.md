# Build prompt

Give this file to Claude Code, started in this directory: *"Read BUILD.md and set this up for my project at
<path>."* It adapts the skeleton to one project and builds the base machine with you. Steps marked
**(user)** need you; Claude stops and asks for them.

---

You are setting up agent-machines for one project: per-task OrbStack machines cloned from a base machine,
each running Claude Code with permissions off, orchestrated from the Mac by `./task`. Read `README.md` and
every file in this repo before changing anything.

## Ground rules

- Machines never get GitHub access: no `gh` login, no tokens, no SSH keys, `forward_ssh_agent` stays off.
  The Mac moves code in and out with git over `ssh://<machine>@orb/...`.
- Never handle the Claude token yourself; the user writes it into the base (step 7).
- Your own Bash sandbox may not reach OrbStack machines over the network. Check services from inside the
  machine (`orb run -m <m> curl localhost:<port>`) and ask the user to check from the Mac.
- Keep the skeleton's shape. Project-specific changes belong in `config.sh`, `vm/env.sh`, `vm/Procfile`,
  `vm/bin/agent-setup`, `vm/bin/agent-ci` and the project notes in `vm/task-preamble.md`.

## 1. Learn the project

From the project's checkout on the Mac: GitHub repo (and whether the user pushes to a fork), how the dev
server starts and on which port, dependencies and databases, language versions, how CI checks a change
(`.github/workflows/`), seed data and test users. Run its CI on `main` if you can: tasks need a green
baseline, otherwise every agent fights failures it didn't cause. If `main` is red, tell the user first.

## 2. Fill in `config.sh`

## 3. Create and provision the base **(user confirms)**

    orb create --isolated --isolate-network ubuntu <BASE>
    orb run -m <BASE> bash < vm/provision.sh

Then install the project's runtime and services in the base (apt packages, a version manager, databases
enabled at boot), so `agent-setup` only has to install the project's own dependencies. Machines are arm64 on Apple Silicon: watch for tools that download x86-64 binaries (e.g.
Selenium Manager fetching Chrome) and for old native gems/packages that don't build with the distro's
compiler.

## 4. Adapt the project files

- `vm/env.sh`: runtime PATH, and whatever lets the dev server accept requests for `<machine>.orb.local`
  (Rails: `RAILS_DEVELOPMENT_HOSTS=.orb.local`).
- `vm/Procfile`: the dev stack, bound to `0.0.0.0` on `$APP_PORT`.
- `vm/bin/agent-setup`: install dependencies, prepare dev and test databases. Idempotent.
- `vm/bin/agent-ci`: the full check, as close to GitHub CI as possible.
- `vm/task-preamble.md`: add project notes the agent needs (seed users, URLs, how to log in).

## 5. Put the repo into the base

    orb run -m <BASE> bash -c 'git init -q -b main ~/<REPO_DIR> && cd ~/<REPO_DIR> &&
      git remote add origin <https URL> && git remote set-url --push origin PUSH-DISABLED--push-from-the-Mac &&
      printf "CLAUDE.local.md\n" >> .git/info/exclude'
    git -C <REPO> push ssh://<BASE>@orb/home/<VM_USER>/<REPO_DIR> +origin/main:refs/remotes/origin/main
    orb run -m <BASE> git -C ~/<REPO_DIR> reset -q --hard origin/main

## 6. Install the tooling

    ./task install-vm && ./task refresh

`refresh` must end with "Base ready to clone". Then, in the base, start the dev stack once
(`agent-devstack`) and run `agent-ci`; both must pass. Stop the dev stack again (`overmind quit`).

## 7. Claude login **(user)**

On the Mac: `claude setup-token`. Then put the token into the base without passing it through this session:

    orb run -m <BASE> bash -c 'mkdir -p ~/.config/task-agent && cat > ~/.config/task-agent/env && chmod 600 ~/.config/task-agent/env'
    # paste: CLAUDE_CODE_OAUTH_TOKEN=<token>   then Ctrl-D

## 8. Smoke test

Write `tasks/1/prompt.md` ("Add one sentence to the README and commit it.") and run
`./task new 1 test/smoke tasks/1/prompt.md`. Expect `./task ls` to go working → done within minutes, with
`./task diff 1` showing the commit, `./task attach 1` showing the session, and the user confirming
`./task view 1` opens the app. Then `./task rm 1 --force` (the user's call: the branch was never pushed).

## Extensions (later, if the user wants them)

- Supervised loop: a script that feeds the session fixed steps (research by an isolated subagent, plan,
  questions to the user, plan review by a second model, implement, CI, code review, fix) and checks each one.
- Screenshots: headless Chrome + Playwright in the base, an `agent-screenshot` command and before/after
  screenshots in the preamble.
- Rules: a file the Mac copies into every machine as `CLAUDE.local.md`, grown from corrections in merged PRs.
