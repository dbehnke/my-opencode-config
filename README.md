# my-opencode-config

An opinionated, complete configuration for OpenCode combining three powerful systems:

1. **Context-mode** - Context window protection and session continuity
2. **Superpowers** - Development process discipline and workflows
3. **ECC** - Language-specific patterns and domain knowledge

## Quick Start (One-Command Setup)

Copy and paste this into OpenCode to set up everything automatically:

```
Set up the complete OpenCode configuration from https://github.com/dbehnke/my-opencode-config. First, clone the repository to a temporary directory like /tmp/my-opencode-config or any directory of your choice. Then run the install script: cd /tmp/my-opencode-config && ./install-ecc-skills.sh to install ECC skills. The script will automatically configure everything including context-mode verification, superpowers installation, and ECC skill integration. Finally, verify the setup by checking that AGENTS.md exists in the repository with complete routing rules for context-mode and references to all available skills from superpowers and ECC.
```

**Or manually clone first:**
```bash
# Use a temporary directory (recommended)
git clone https://github.com/dbehnke/my-opencode-config.git /tmp/my-opencode-config
cd /tmp/my-opencode-config
./install-ecc-skills.sh

# Or clone to your preferred location
git clone https://github.com/dbehnke/my-opencode-config.git ~/my-opencode-config
cd ~/my-opencode-config
./install-ecc-skills.sh
```

**New to these tools?** Check out [EXAMPLES.md](./EXAMPLES.md) for practical workflows, beginner tips, and troubleshooting guides.

## Prerequisites

Before installing, ensure you have:

- **Node.js LTS** (v24 as of this writing) - Required for context-mode
  - Download: https://nodejs.org/ (LTS version)
  - Verify: `node --version` should show v24.x.x or higher

- **Git** - For cloning repositories
  - Verify: `git --version`

- **OpenCode** - Latest stable release
  - Download: https://opencode.ai
  - Verify: `opencode --version`

- **(Optional) Bun** - For faster context-mode execution
  - Automatically detected if installed
  - Falls back to Node.js if not available

## Installation Order

**Install in this sequence to avoid conflicts:**

1. **Context-mode** (Foundation) - Context protection and session management
2. **Superpowers** (Process) - Development workflows and discipline
3. **ECC** (Domain Knowledge) - Language patterns and specialized skills

---

## 1. Context-mode

Context-mode protects your context window by sandboxing large outputs (logs, API responses, web pages) and maintaining session continuity across conversation compactions.

### What It Does
- **98% context reduction** via sandboxing
- **Session continuity** with SQLite-based tracking
- **FTS5 search** with BM25 ranking
- **MCP protocol layer** - works below the agent level

### Installation

**Option 1: Quick Install (Prompt)**
```
Install context-mode globally for opencode: npm install -g context-mode, then add it to ~/.config/opencode/opencode.json as an MCP server with command ["context-mode"] and enabled true, and add "context-mode" to the plugin array. Verify with ctx doctor.
```

**Option 2: Manual**
```bash
npm install -g context-mode
```

Then add to `~/.config/opencode/opencode.json`:
```json
{
  "mcp": {
    "context-mode": {
      "type": "local",
      "command": ["context-mode"],
      "enabled": true
    }
  },
  "plugin": ["context-mode"]
}
```

**Verify:**
```bash
ctx doctor
ctx stats
```

### Available Tools

- `ctx_batch_execute` - Run multiple commands + search in one call
- `ctx_execute` - Sandbox code execution (11 languages)
- `ctx_fetch_and_index` - Fetch URLs and index for search
- `ctx_search` - Query indexed content

See [context-mode documentation](https://github.com/mksglu/context-mode) for details.

---

## 2. Superpowers

[Superpowers](https://github.com/obra/superpowers) by Jesse Vincent is a complete software development workflow providing process discipline through 15 composable skills.

### What It Does
- **Automatic skill triggering** - Skills activate based on context
- **Development workflow** - From brainstorming to completion
- **Rigorous discipline** - TDD, verification, code review enforcement
- **Subagent orchestration** - Parallel agent workflows

### Installation

**Option 1: Quick Install (Prompt)**
```
Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
```

**Option 2: Manual**
```bash
git clone https://github.com/obra/superpowers.git ~/.config/opencode/skills/superpowers
```

### Available Skills

**Development Process:**
- `brainstorming` - Socratic design refinement (auto-triggers before coding)
- `writing-plans` - Detailed implementation planning
- `executing-plans` - Batch execution with checkpoints
- `subagent-driven-development` - Parallel agent workflows
- `using-git-worktrees` - Isolated feature branches

**Quality Assurance:**
- `test-driven-development` - RED-GREEN-REFACTOR cycle
- `systematic-debugging` - 4-phase root cause analysis
- `verification-before-completion` - Ensure it's actually fixed

**Code Review:**
- `requesting-code-review` - Pre-review quality checks
- `receiving-code-review` - Process feedback rigorously

**Meta:**
- `writing-skills` - Create custom skills
- `using-superpowers` - Entry point documentation

### Basic Workflow

1. **brainstorming** → Refines rough ideas through questions
2. **using-git-worktrees** → Creates isolated workspace
3. **writing-plans** → Breaks work into 2-5 minute tasks
4. **test-driven-development** → RED-GREEN-REFACTOR cycle
5. **requesting-code-review** → Quality checks between tasks
6. **finishing-a-development-branch** → Merge/PR decision

See [Superpowers repository](https://github.com/obra/superpowers) for full documentation.

---

## 3. ECC Skills

Selected skills from [everything-claude-code](https://github.com/affaan-m/everything-claude-code) providing language-specific patterns and filling gaps in superpowers.

### What It Does
- **Language patterns** - Go, TypeScript, Python, Rust idioms
- **Security auditing** - Comprehensive security review
- **Documentation lookup** - API reference research
- **No memory hooks** - Avoids conflicts with context-mode

### Installation

**Prerequisites:** Context-mode and superpowers must be installed first.

**Quick Install:**
```bash
./install-ecc-skills.sh
```

**With specific version:**
```bash
./install-ecc-skills.sh v1.9.0
```

**Integration (automatic):**
The install script automatically updates:
- `~/.config/opencode/opencode.json` - Adds skill references
- `AGENTS.md` - Adds skill documentation

### Available Skills

**Language Patterns:**

Go:
- `golang-patterns` - Idiomatic Go patterns, concurrency, error handling
- `golang-testing` - Go testing patterns, TDD, benchmarks

TypeScript/JavaScript:
- `frontend-patterns` - React, Next.js patterns
- `backend-patterns` - API, database, caching patterns
- `api-design` - REST API design, pagination, error responses
- `e2e-testing` - Playwright E2E patterns

Python:
- `python-patterns` - Pythonic idioms, PEP 8, type hints
- `python-testing` - Python testing with pytest

Rust:
- `rust-patterns` - Idiomatic Rust patterns, ownership, error handling
- `rust-testing` - Rust testing patterns

**Security & Documentation:**
- `security-review` - Security audit checklist and patterns
- `documentation-lookup` - API reference research
- `search-first` - Research-before-coding methodology

**DevOps & Deployment:**
- `docker-patterns` - Docker and Docker Compose patterns, container security
- `deployment-patterns` - CI/CD workflows, deployment strategies, health checks

### Skill Selection Guide

| Task Type | Use This | Reason |
|-----------|----------|--------|
| TDD workflow | Superpowers `test-driven-development` | More rigorous enforcement |
| Verification | Superpowers `verification-before-completion` | Better checkpoints |
| Code review process | Superpowers `requesting-code-review` | Process-focused |
| Go idioms | ECC `golang-patterns` | Language-specific |
| Security audit | ECC `security-review` | Fills superpowers gap |
| API design | ECC `api-design` | Domain-specific knowledge |
| Docker/Containers | ECC `docker-patterns` | Container best practices |
| CI/CD Deployment | ECC `deployment-patterns` | Deployment strategies |
| Pre-PR code review | `@code-reviewer` + `$pr-gate` | Catches issues locally before Copilot sees them |

### Usage Examples

```
"Use golang-patterns to refactor this handler"
"Apply security-review to the authentication module"
"Use api-design principles for this endpoint"
"Use docker-patterns to containerize this application"
"Apply deployment-patterns for CI/CD setup"
```

### Upgrading

Check for updates:
```bash
./scripts/upgrade-ecc.sh
```

Upgrade automatically:
```bash
./scripts/upgrade-ecc.sh --auto
```

### Finding and Installing Additional ECC Skills

The default installation includes a curated selection of skills. To find and install additional skills from the ECC repository:

**Step 1: Browse Available Skills**
Visit the [ECC skills directory](https://github.com/affaan-m/everything-claude-code/tree/main/skills) to see all available skills.

Popular skills not included by default:
- `docker-patterns` - Docker and Docker Compose patterns
- `deployment-patterns` - CI/CD and deployment workflows
- `continuous-learning` - Pattern extraction from sessions (requires ECC memory system)
- `eval-harness` - Verification loop evaluation
- `autonomous-loops` - Autonomous agent patterns

**Step 2: Edit the Skills List**
Add the skill name to `ecc-config/skills-list.txt`:
```bash
# Open the skills list
nano ecc-config/skills-list.txt

# Add your desired skill(s)
docker-patterns
deployment-patterns
```

**Step 3: Re-run the Installer**
```bash
./install-ecc-skills.sh
```

The installer will:
- Check for new skills in your list
- Copy them to `~/.config/opencode/ecc-skills/`
- Update `opencode.json` automatically
- Create backups of existing files

**Step 4: Verify Installation**
Test the new skill:
```
"Use docker-patterns to containerize this application"
```

**Note:** Skills marked as "requires ECC memory system" (like `continuous-learning`) should NOT be installed if you're using context-mode for session management, as they may conflict.

---

## 4. MCP Servers

MCP (Model Context Protocol) servers extend the AI's capabilities with executable tools. Unlike skills (which provide guidelines), MCP servers provide functional capabilities.

### Playwright

Browser automation for screenshot capture, page crawling, and DOM inspection.

**Installation:**
```bash
npm install -g @modelcontextprotocol/server-playwright
npx playwright install --with-deps
```

**Configuration:**
Add to `~/.config/opencode/opencode.json`:
```json
{
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-playwright"],
      "enabled": true
    }
  }
}
```

**Alternative (faster startup):**
```bash
npm install -g @modelcontextprotocol/server-playwright
```

Then in `opencode.json`:
```json
{
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["mcp-server-playwright"],
      "enabled": true
    }
  }
}
```

**Tools provided:**
- `playwright_navigate` — Navigate to a URL
- `playwright_screenshot` — Capture a screenshot
- `playwright_click` — Click an element
- `playwright_fill` — Fill a form field
- `playwright_evaluate` — Execute JavaScript in browser context

**Usage examples:**
- "Take a screenshot of opencode.ai"
- "Crawl this page and extract all links"
- "Check if this page has a login form"

---

## 5. Code Review Agent

A pre-PR review system that catches issues locally before pushing,
breaking the endless AI review loop.

### What It Does

- **Hygiene check** — catches accidentally committed cache/build artifacts
- **Linting** — via Megalinter (80+ linters) or individual tools
- **Secrets detection** — via Gitleaks
- **Security rules** — via Semgrep (custom injection, XSS, auth patterns)
- **AI diff review** — reviews what linters miss for logic, security, async issues
- Returns structured JSON — only surfaces NEW issues on re-runs
- Supports JavaScript, TypeScript, Go, Python, Rust, and Shell

### Installation

Included automatically when you run `./install-ecc-skills.sh`

Or install standalone:

```bash
./install-agents.sh
```

### Tool Setup (Choose One)

**Option A: Individual Linters (Universal)**

No Docker. Install via your package manager (brew, apt, pacman, etc.)
or use Nix (see Option C).

```bash
npm install -g eslint oxlint
# golangci-lint, ruff, shellcheck, semgrep, gitleaks
# Use brew (macOS), apt (Debian/Ubuntu), pacman (Arch), etc.
```

**Option B: Megalinter (Convenience)**

One tool. Docker required (cross-platform: Linux, macOS, Windows).

```bash
docker pull oxsecurity/megalinter:latest
# gitleaks: use package manager or Nix
```

**Option C: Nix (Reproducible)**

For power users. Reproducible environments without Docker.

```bash
# Install Nix, then add to flake.nix:
# packages = [ eslint oxlint golangci-lint ruff shellcheck semgrep gitleaks ]
```

### Usage

```
run pr-gate
```

```
@code-reviewer review the current diff before I push
```

### How It Breaks the Copilot Loop

Copilot reviews are stateless — every review is a fresh pass that will
always find something new. This agent front-loads analysis locally:

1. Hygiene check catches cache/build artifacts
2. Megalinter + Gitleaks catch style/formatting/secrets/simple bugs
3. Semgrep catches security patterns (injection, XSS, auth bypass)
4. AI reviewer only sees what automated tools missed
5. Results are cached by commit hash — re-runs only show new issues
6. By the time Copilot sees the PR, mechanical issues are already resolved

---

## Complete Setup Guide

### Step 1: Install Context-mode
```bash
npm install -g context-mode
# Configure opencode.json (see above)
ctx doctor  # Verify
```

### Step 2: Install Superpowers
```bash
git clone https://github.com/obra/superpowers.git ~/.config/opencode/skills/superpowers
```

### Step 3: Install ECC Skills
```bash
# Clone to temporary directory (recommended for one-time setup)
git clone https://github.com/dbehnke/my-opencode-config.git /tmp/my-opencode-config
cd /tmp/my-opencode-config
./install-ecc-skills.sh

# Or clone to a location you'll keep for updates
git clone https://github.com/dbehnke/my-opencode-config.git ~/my-opencode-config
cd ~/my-opencode-config
./install-ecc-skills.sh
```

### Step 4: Configure Your Repository

Create or update `AGENTS.md` in your project:
```bash
# If AGENTS.md doesn't exist:
/init
# Select AGENTS.md
```

Add context-mode routing rules (see AGENTS.md in this repo for full example).

### Step 5: Restart OpenCode
```bash
# Exit and restart OpenCode for changes to take effect
```

### Step 6: Verify Installation

Test context-mode:
```
ctx stats
```

Test superpowers:
```
"Help me plan a new feature"  # Should trigger brainstorming
```

Test ECC skills:
```
"Use golang-patterns to review this code"
```

---

## Enhancing an Existing AGENTS.md

Already have an AGENTS.md? Enhance it with context-mode routing rules and skill references.

### Option 1: Automated Enhancement (Prompt)

**Safe to run multiple times** - The prompt will check for existing sections and only add what's missing.

```
Enhance the existing AGENTS.md in this repository with context-mode routing rules and skill references from https://github.com/dbehnke/my-opencode-config. First, read the current AGENTS.md to understand its structure. Then fetch the reference AGENTS.md from https://raw.githubusercontent.com/dbehnke/my-opencode-config/main/AGENTS.md. Add Section 1 (Context-Mode Routing Rules), Section 2 (Superpowers Skills), Section 3 (ECC Skills), and Section 4 (Skill Selection Guide) if they don't already exist. Preserve existing project-specific content. Save the enhanced file and report which sections were added.
```

### Option 2: Manual Enhancement

**Step 1:** Review your current AGENTS.md
```bash
cat AGENTS.md
```

**Step 2:** Copy sections from reference
Visit https://github.com/dbehnke/my-opencode-config/blob/main/AGENTS.md and copy:
- Section 1: Context-Mode Routing Rules
- Section 2: Superpowers Skills
- Section 3: ECC Skills
- Section 4: Skill Selection Guide

**Step 3:** Add to your AGENTS.md
```markdown
# AGENTS.md

[Your existing content...]

## Context-Mode Routing Rules
[Paste Section 1]

## Superpowers Skills
[Paste Section 2]

## ECC Skills
[Paste Section 3]

## Skill Selection Guide
[Paste Section 4]

[Your existing content continues...]
```

**Note:** The integration script skips sections that already exist, so manual merging gives you full control over placement and customization.

---

## Repository Structure

```
my-opencode-config/
├── README.md                    # This file
├── AGENTS.md                    # Agent instructions example
├── install-ecc-skills.sh        # ECC installer
├── ecc-config/
│   └── skills-list.txt         # Skills to install
└── scripts/
    ├── integrate-ecc.sh        # Integration helper
    └── upgrade-ecc.sh          # Version checker
```

---

## Troubleshooting

### Context-mode not working
- Verify: `ctx doctor`
- Check opencode.json has context-mode in mcp and plugin arrays
- Restart OpenCode

### Superpowers not triggering
- Verify: `ls ~/.config/opencode/skills/superpowers/skills/`
- Skills trigger automatically based on context
- Try: "Let's brainstorm this feature"

### ECC skills not available
- Check installation: `ls ~/.config/opencode/ecc-skills/`
- Verify opencode.json has instructions array
- Check AGENTS.md has ECC section

### Conflicts between systems
- Ensure installation order: context-mode → superpowers → ECC
- Don't use ECC memory/hook features (disabled by design)
- Check AGENTS.md routing rules are clear

---

## Contributing

This is a personal configuration repository available at https://github.com/dbehnke/my-opencode-config. Feel free to fork and customize:

1. Fork the repository from https://github.com/dbehnke/my-opencode-config
2. Modify `ecc-config/skills-list.txt` to select different skills
3. Adjust installation scripts for your needs
4. Update documentation to reflect your setup

---

## References

- [Context-mode](https://github.com/mksglu/context-mode) - Context window protection
- [Superpowers](https://github.com/obra/superpowers) - Development workflow
- [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) - ECC repository
- [OpenCode Documentation](https://opencode.ai)

---

## License

MIT - Feel free to use and modify for your own setup.
