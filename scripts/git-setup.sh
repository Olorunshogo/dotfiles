###############################################
# GIT FULL SETUP SCRIPT
###############################################

# --- Identity ---
git config --global user.name "BAMTEFA Olorunshogo Moses"
git config --global user.email "shownzy001@gmail.com"

# --- Default settings ---
git config --global init.defaultBranch main
git config --global help.autocorrect 1
git config --global color.ui auto
git config --global core.editor "code --wait"

# --- CRLF handling ---
# For Linux/Mac:
git config --global core.autocrlf input
# For Windows (uncomment instead):
# git config --global core.autocrlf true

# --- Performance tweaks ---
git config --global core.fsmonitor true
git config --global fetch.prune true
git config --global pull.ff only
git config --global gc.auto 256

# --- Aliases ---
git config --global alias.lg "log --graph --oneline --decorate --all"
git config --global alias.st "status"
git config --global alias.co "checkout"
git config --global alias.br "branch"

# --- Rebase instead of merge ---
git config --global pull.rebase true
git config --global rebase.autoStash true

# --- Ignore case (Windows/Mac recommended) ---
git config --global core.ignorecase true

# --- Credentials management ---
# Windows
# git config --global credential.helper manager-core
# macOS
# git config --global credential.helper osxkeychain
# Linux
git config --global credential.helper store

# --- Global gitignore ---
git config --global core.excludesfile ~/.gitignore_global

# Create a recommended ignore file
cat << 'EOF' > ~/.gitignore_global
node_modules/
*.log
.DS_Store
.env
dist/
build/
venv/
__pycache__/
*.pyc
EOF

# --- Diff & merge tools (VS Code) ---
git config --global diff.tool vscode
git config --global difftool.vscode.cmd "code --wait --diff \$LOCAL \$REMOTE"

git config --global merge.tool vscode
git config --global mergetool.vscode.cmd "code --wait \$MERGED"

echo "Git configuration completed successfully!"
###############################################
