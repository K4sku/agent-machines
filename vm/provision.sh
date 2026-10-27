#!/usr/bin/env bash
# Usage: orb run -m <base> bash < vm/provision.sh   (once, on a fresh Ubuntu base; see BUILD.md)
# The project's runtime (Ruby, Node, databases...) differs per project, so BUILD.md adds it separately.
set -euo pipefail

sudo apt-get update -q
sudo apt-get install -yq git jq tmux curl unzip build-essential

arch=$(dpkg --print-architecture)
curl -fsSL "https://github.com/DarthSim/overmind/releases/download/v2.5.1/overmind-v2.5.1-linux-$arch.gz" |
  gunzip | sudo tee /usr/local/bin/overmind >/dev/null
sudo chmod 755 /usr/local/bin/overmind

curl -fsSL https://claude.ai/install.sh | bash

git config --global user.name >/dev/null || git config --global user.name "Task Agent"
git config --global user.email >/dev/null || git config --global user.email "agent@localhost"
echo "provisioned: $(git --version), $(overmind --version), claude $(~/.local/bin/claude --version)"
