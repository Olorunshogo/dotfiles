## Future Project: Full Machine Setup

🚀 **Planned Project:** A complete development environment setup for a brand-new machine.

This tool is intended for users who:
- Just installed Ubuntu (or macOS)
- Have nothing installed yet
- Want a fully working dev environment in one command

### What it will do

- Update system packages
- Install essential tools:
  - `curl`
  - `wget`
  - `git`
  - `build-essential`
- Install Node.js using **nvm**
- Install multiple package managers:
  - npm (via Node)
  - yarn
  - pnpm
- Install and configure Git
- Set up SSH for GitHub (reuse `git-full-setup`)
- Install VS Code and common extensions
- Apply sensible defaults and aliases
- Verify everything works at the end

### Example Usage (Planned)

```bash
curl -fsSL https://example.com/dev-setup.sh | bash
