
#!/usr/bin/env bash
set -e  # Stop on any error

echo "🚀 Starting Git Full Setup..."

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="mac"
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "win32" ]]; then
  OS="windows"
else
  OS="unknown"
fi
echo "Detected OS: $OS"

# === Prompt for name and email FIRST ===
read -p "Enter your full name for Git commits: " USERNAME
read -p "Enter your email for Git (and SSH key comment): " EMAIL

if [ -z "$USERNAME" ] || [ -z "$EMAIL" ]; then
  echo "❌ Name and email are required. Try again."
  exit 1
fi

git config --global user.name "$USERNAME"
git config --global user.email "$EMAIL"
echo "✅ Git user name & email saved."

# === SSH Key Handling ===
echo ""
echo "=== SSH Key Setup for GitHub ==="
KEY_FILE="$HOME/.ssh/id_ed25519"
PUB_FILE="$KEY_FILE.pub"

if [ -f "$PUB_FILE" ]; then
  echo "✅ Existing ed25519 key found."
elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
  echo "⚠️  RSA key found (ed25519 is better). Using RSA."
  KEY_FILE="$HOME/.ssh/id_rsa"
  PUB_FILE="$KEY_FILE.pub"
else
  echo "🔑 No SSH key found. Generating new ed25519 key..."
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE"
fi

echo ""
echo "📋 Your public key:"
cat "$PUB_FILE"
echo ""
echo "✅ Go to: https://github.com/settings/keys"
echo "   Click 'New SSH key'"
echo "   Title: e.g. My $(hostname) - $(date +%Y)"
echo "   Paste the entire key above (starting with ssh-ed25519 ...)"
echo "   Click Add SSH key"
echo ""
read -p "Press Enter AFTER you added the key to GitHub..."

# Start ssh-agent and add key
echo "🔑 Starting SSH agent..."
eval "$(ssh-agent -s)"
ssh-add "$KEY_FILE"

echo "🧪 Testing GitHub SSH connection..."
ssh -T git@github.com || echo "⚠️  Connection test showed warning (normal if first time). Check output above."

echo ""
read -p "Press Enter to continue with Git configurations..."

# === Apply Git Configurations (all your original + more) ===
echo "⚙️  Applying Git configurations..."

git config --global init.defaultBranch main
git config --global help.autocorrect 1
git config --global color.ui auto
git config --global core.editor "code --wait"
git config --global core.fsmonitor true
git config --global fetch.prune true
git config --global pull.ff only
git config --global gc.auto 256
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global push.default simple
git config --global color.status.untracked red

# OS-specific settings
if [ "$OS" = "windows" ]; then
  git config --global core.autocrlf true
  git config --global core.ignorecase true
  git config --global credential.helper manager-core
elif [ "$OS" = "mac" ]; then
  git config --global core.autocrlf input
  git config --global core.ignorecase true
  git config --global credential.helper osxkeychain
else
  git config --global core.autocrlf input
  git config --global core.ignorecase false
  git config --global credential.helper store
fi

# Aliases
git config --global alias.lg "log --graph --oneline --decorate --all"
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch

# VS Code diff/merge
git config --global diff.tool vscode
git config --global difftool.vscode.cmd "code --wait --diff \$LOCAL \$REMOTE"
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd "code --wait \$MERGED"

# Extra useful settings
git config --global core.quotePath false
git config --global merge.conflictstyle zdiff3
git config --global rerere.enabled true

# Global gitignore
git config --global core.excludesfile ~/.gitignore_global
cat << 'EOF' > ~/.gitignore_global
node_modules/
.DS_Store
.env
.env.local
dist/
build/
venv/
__pycache__/
*.pyc
*.log
npm-debug.log*
yarn-error.log*
.vscode/
.idea/
EOF

echo "✅ Global .gitignore created."

# Show final config
echo ""
echo "📋 Final Global Git Configuration:"
git config --global --list | sort

echo ""
echo "🎉 SUCCESS! Git is fully configured."
echo "✅ You can now use SSH to clone repos (git clone git@github.com:username/repo.git)"
echo "💡 Recommendation: Restart your terminal."
echo "   Or run: source ~/.bashrc   (if using bash)"
echo ""
echo "You can close this terminal now."