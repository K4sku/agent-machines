# Project settings for ./task (sourced). See BUILD.md.
REPO=$HOME/work/myapp     # Mac checkout used for all git/GitHub work; origin = where branches are pushed
GH_REPO=me/myapp          # where issues are read and PRs are opened
FORK_OWNER=               # set when origin is your fork of GH_REPO (PRs then come from FORK_OWNER:<branch>)
BASE=myapp                # base machine; task machines are $BASE-<id>
REPO_DIR=myapp            # checkout inside machines: ~/$REPO_DIR
VM_USER=$(whoami)         # OrbStack creates machines with your macOS user name
APP_PORT=3000             # dev server port inside machines (task view)
SOFT_LIMIT=10             # warn when this many task machines already run
