# Git Full Setup

This is a simple tool that sets up Git perfectly on your computer in one go.

## What does it do?
- Asks for your name and email
- Sets up SSH key for GitHub (creates new one if you don't have)
- Shows you the public key → tells you exactly where to paste it on GitHub
- Tests the SSH connection
- Sets many useful Git settings (aliases, VS Code editor, safe CRLF, etc.)
- Creates a good global .gitignore file
- Shows you everything it did at the end

## Requirements (install these first)
1. Node.js + npm → download from https://nodejs.org (use LTS version)
2. Git → download from https://git-scm.com/downloads
3. Visual Studio Code (recommended, but not required)
4. A GitHub account

## How to install
Open your terminal / Git Bash and run this one command:

```bash
npm install -g git-full-setup