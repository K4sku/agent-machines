# Sourced by ~/.bashrc and by the agent-* scripts: `orb run` from the Mac starts
# non-interactive shells, which skip ~/.bashrc.
. /opt/task-agent/project.env
export PATH="$HOME/.local/bin:$PATH"
# The dev stack's Procfile lives here, not in the repo; the socket outside it keeps `git status` clean.
export OVERMIND_PROCFILE=/opt/task-agent/Procfile
export OVERMIND_SOCKET=$HOME/.overmind.sock

# PROJECT: language runtime and dev-server settings, e.g. for Rails:
# export GEM_HOME="$HOME/.gem/ruby/3.4.0"; export PATH="$GEM_HOME/bin:$PATH"
# export RAILS_DEVELOPMENT_HOSTS=.orb.local   # the Mac opens http://<machine>.orb.local:$APP_PORT
