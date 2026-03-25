# Examples, Tips & Tricks

A practical guide for getting started with your OpenCode configuration.

---

## Table of Contents

1. [Before You Start](#before-you-start-dev-environment-setup)
2. [Common Beginner Mistakes](#common-beginner-mistakes)
3. [Example Workflows](#example-workflows)
4. [Daily Usage Tips](#daily-usage-tips)
5. [Troubleshooting Common Issues](#troubleshooting-common-issues)
6. [Best Practices](#best-practices)

---

## Before You Start: Dev Environment Setup

pr-gate runs linters before every push. Choose the setup that fits your workflow:

---

### Option A: Individual Linters (Universal)

No Docker. Install via your package manager.

```bash
# JavaScript / TypeScript
npm install -g eslint oxlint

# Go (use your package manager)
# brew install golangci-lint    # macOS
# apt install golangci-lint   # Debian/Ubuntu
# pacman -S golangci-lint     # Arch

# Python
# brew install ruff            # macOS
# apt install ruff             # Debian/Ubuntu

# Rust (included with rustup)

# Shell
# brew install shellcheck     # macOS
# apt install shellcheck      # Debian/Ubuntu

# Security
# brew install semgrep        # macOS
# or use Nix (see Option C)

# Secrets
# brew install gitleaks        # macOS
# apt install gitleaks         # Debian/Ubuntu
# or use Nix (see Option C)
```

**Note:** ESLint v9+ uses flat config (`eslint.config.js`) instead of `.eslintrc`.

---

### Option B: Megalinter (Convenience)

One tool, Docker required (works on Linux, macOS, Windows).

```bash
# Docker (recommended)
docker pull oxsecurity/megalinter:latest

# Secrets (use package manager or Nix)
# brew install gitleaks       # macOS
# apt install gitleaks         # Debian/Ubuntu
# or use Nix (see Option C)
```

**First-time:** Pull image before first run to avoid timeout.

---

### Option C: Nix (Reproducible)

For power users. Reproducible environments without Docker.

```bash
# Install Nix
curl -fsSL https://nixos.org/nix/install -o /tmp/nix-install && bash /tmp/nix-install && rm /tmp/nix-install

# Add to your project's flake.nix:
# packages = [ eslint oxlint golangci-lint ruff shellcheck semgrep gitleaks ]
```

---

### Verification

Test linters before your first push:

```bash
# Check each tool is reachable
npx oxlint --version
golangci-lint version
ruff --version
shellcheck --version
semgrep --version
gitleaks --version
```

### Troubleshooting

| Problem | Solution |
|---------|----------|
| ESLint "config not found" | Use flat config or run `npx eslint` in project dir |
| golangci-lint not found | `brew install golangci-lint` |
| ruff not found | `brew install ruff` |
| gitleaks not found | `brew install gitleaks` |
| semgrep not found | `brew install semgrep` |
| Megalinter slow first time | Pre-pull: `docker pull oxsecurity/megalinter:latest` |

---

## Common Beginner Mistakes

### ❌ Mistake 1: Not Letting Skills Trigger Automatically

**Wrong:**
```
"Brainstorm this feature for me using the brainstorming skill"
```

**Right:**
```
"I need to add user authentication to my app"
```

**Why:** Superpowers skills like `brainstorming` trigger automatically when you describe what you're building. Just start describing your goal - the skill will activate.

---

### ❌ Mistake 2: Using Raw Commands Instead of Context-Mode

**Wrong:**
```
"Run: curl https://api.example.com/data"
```

**Right:**
```
"Fetch data from https://api.example.com/data and summarize it"
```

**Why:** Context-mode will automatically use `ctx_fetch_and_index` to sandbox the response. Never use curl/wget directly.

---

### ❌ Mistake 3: Conflicting Skill Requests

**Wrong:**
```
"Use tdd-workflow and test-driven-development to implement this"
```

**Right:**
```
"Let's implement this feature with tests"
```

**Why:** `tdd-workflow` (ECC) and `test-driven-development` (Superpowers) overlap. The superpowers version is more rigorous, so just describe your goal and let the right skill activate.

---

### ❌ Mistake 4: Not Reading AGENTS.md First

**Wrong:**
Starting a new session without checking what skills are available.

**Right:**
```
"Show me what skills are available for this project"
```

**Why:** AGENTS.md contains the skill reference guide. Check it when starting work on a new repository.

---

### ❌ Mistake 5: Installing Everything at Once

**Wrong:**
Installing context-mode, superpowers, and ECC simultaneously without verifying each step.

**Right:**
Follow the installation order and verify each component:
1. Install context-mode → Run `ctx doctor`
2. Install superpowers → Test with "Help me plan..."
3. Install ECC → Test with "Use golang-patterns..."

**Why:** Each component builds on the previous one. Verify as you go to catch issues early.

---

## Example Workflows

### Workflow 1: Starting a New Feature (Full Stack)

**Scenario:** Adding user authentication to a Go web app

```
You: "I need to add user authentication to my Go web application"

[Superpowers brainstorming activates]
AI: "Let me understand what you're building..."
[Asks questions about JWT vs sessions, password requirements, etc.]

You: [Answer questions]

[Superpowers writing-plans activates]
AI: "Here's the implementation plan:"
[Shows 8-10 specific tasks with file paths]

You: "Looks good, let's implement it"

[Superpowers using-git-worktrees activates]
AI: "Creating isolated workspace on feature/auth branch..."

[Superpowers subagent-driven-development activates]
AI: "Starting implementation with TDD..."
[Writes failing tests, implements auth handlers, etc.]

You: "Review the authentication code"

[Superpowers requesting-code-review activates]
[ECC go-reviewer activates]
AI: "Code review findings:"
[Shows security issues, Go idioms, etc.]
```

**Key Points:**
- Skills chain together automatically
- ECC `go-reviewer` complements superpowers review
- Context-mode handles all file reads/searches behind the scenes

---

### Workflow 2: Debugging a Production Issue

**Scenario:** Application is slow, need to investigate

```
You: "My app is slow, help me debug it"

[Superpowers systematic-debugging activates]
AI: "Let's approach this systematically..."

You: "Here are the logs: [paste or point to log file]"

AI: "I'll analyze these logs in the sandbox..."
[Uses ctx_execute_file to process logs]

[Finds pattern: database connection pool exhausted]

You: "How do I fix the connection pool?"

[ECC golang-patterns activates - if Go app]
AI: "Here are connection pool best practices for Go..."

[Implements fix with connection pool limits]

[Superpowers verification-before-completion activates]
AI: "Before marking complete, let me verify..."
[Runs tests, checks performance]
```

**Key Points:**
- `systematic-debugging` provides structured approach
- Context-mode processes logs without flooding context
- Language-specific patterns guide the fix
- Verification ensures it actually works

---

### Workflow 3: Learning a New API

**Scenario:** Need to integrate Stripe API

```
You: "I need to integrate Stripe for payments"

[ECC search-first activates]
AI: "Let me research the Stripe API first..."
[Uses ctx_fetch_and_index to get Stripe docs]

You: "What are the key endpoints I need?"

[ctx_search queries the indexed Stripe docs]
AI: "For your use case, you need:"
- PaymentIntent API for charges
- Customer API for saving cards
- Webhook handling for events

[ECC api-design activates]
AI: "Here's how to structure your payment endpoints..."

[Superpowers writing-plans activates]
AI: "Implementation plan:"
[Shows specific tasks with Stripe integration steps]
```

**Key Points:**
- `search-first` prevents coding before understanding
- `ctx_fetch_and_index` + `ctx_search` for documentation
- `api-design` for REST endpoint structure
- Context-mode keeps API docs out of your context window

---

### Workflow 4: Containerizing an Application

**Scenario:** Dockerize existing Python Flask app

```
You: "Containerize my Flask app with Docker"

[ECC docker-patterns activates]
AI: "Here's a multi-stage Dockerfile for Flask..."
[Shows optimized Dockerfile with non-root user]

You: "How do I handle environment variables?"

AI: "Use this pattern with docker-compose..."
[Shows compose file with env file support]

[ECC security-review activates]
AI: "Security considerations for your container:"
- Don't hardcode secrets
- Use read-only filesystems where possible
- Scan images for vulnerabilities

[ECC deployment-patterns activates]
AI: "For deployment, consider:"
[Shows health checks, rolling updates]
```

**Key Points:**
- `docker-patterns` for best practices
- `security-review` catches container security issues
- `deployment-patterns` for production readiness

---

### Workflow 5: Pre-PR Code Review

**Scenario:** Feature is complete, about to push to remote

```
You: "run pr-gate"

[pr-gate skill activates]
AI: "Running pre-PR review pipeline..."
[Runs Megalinter on changed files]
[Runs Gitleaks on staged changes]
[Invokes @code-reviewer for AI diff analysis]
AI: "AI Review complete. No issues found."

---
PR Gate Results

LINTER RESULTS
| Tool       | Result                  |
|------------|-------------------------|
| Megalinter | ✅ 0 errors, 0 warnings |
| Gitleaks   | ✅ No secrets detected  |

AI DIFF REVIEW
| Severity | Count |
|----------|-------|
| Errors   | 0     |
| Warnings | 0     |

Gate Decision: ✅ Clean. No issues found. Clear to push.
```

**Key Points:**
- `pr-gate` runs Megalinter (80+ linters) + Gitleaks first (deterministic, fast)
- `@code-reviewer` only reviews what linters miss
- Results cached by commit hash — re-runs show only NEW issues
- Catches mechanical issues, secrets, and security vulnerabilities before Copilot sees them

**Usage:**
```
Before pushing:  "run pr-gate"
Manual review:   "@code-reviewer review the current diff"
```

---

## Daily Usage Tips

### Tip 1: Start Sessions with Context

**Good:**
```
"Continue working on the authentication feature we started yesterday"
```

**Better:**
```
"Continue the auth feature. Context: We're implementing JWT authentication 
for the Go API. Yesterday we completed the login endpoint. Today I need 
to add password reset."
```

**Why:** Context-mode maintains session continuity, but explicit context helps the AI pick up where you left off.

---

### Tip 2: Use Specific Language Requests

**General:**
```
"Review this code"
```

**Specific:**
```
"Use golang-patterns to review this handler for idiomatic Go"
```

**Why:** Specific requests activate the right ECC skill immediately rather than waiting for the AI to figure it out.

---

### Tip 3: Batch Related Tasks

**Inefficient:**
```
"Run tests"
[wait]
"Check test coverage"
[wait]
"Run linter"
```

**Efficient:**
```
"Run tests, check coverage, and run the linter"
```

**Why:** Context-mode's `ctx_batch_execute` handles multiple commands efficiently. The AI can batch these automatically.

---

### Tip 4: Reference AGENTS.md Skills by Name

**Vague:**
```
"Help me think through this design"
```

**Explicit:**
```
"Use brainstorming to explore this design: I'm building a real-time chat feature"
```

**Why:** Explicit skill names ensure the right skill activates, especially when multiple could apply.

---

### Tip 5: Let Verification Happen

**Impatient:**
```
"Skip the tests, just ship it"
```

**Patient:**
```
"Run the full verification suite before completing"
```

**Why:** `verification-before-completion` catches bugs early. It's 5 minutes now vs 5 hours debugging in production later.

---

### Tip 6: Use Worktrees for Parallel Work

**Without worktrees:**
```
"I need to switch to the bugfix branch but I have uncommitted changes"
```

**With worktrees:**
```
"Create a new worktree for the hotfix so I can keep working on the feature"
```

**Why:** `using-git-worktrees` keeps your feature work intact while you handle urgent fixes.

---

## Troubleshooting Common Issues

### Issue 1: Skills Not Triggering

**Symptoms:**
- You say "Help me plan" but no brainstorming happens
- Agent jumps straight to coding

**Solutions:**
1. Check AGENTS.md exists in your repo root
2. Verify superpowers is installed:
   ```bash
   ls ~/.config/opencode/skills/superpowers/skills/
   ```
3. Restart OpenCode
4. Try explicit skill name: "Use brainstorming to explore..."

---

### Issue 2: Context-Mode Tools Not Available

**Symptoms:**
- `ctx doctor` not recognized
- Agent uses raw curl commands

**Solutions:**
1. Verify context-mode is installed:
   ```bash
   npm list -g context-mode
   ```
2. Check opencode.json:
   ```bash
   cat ~/.config/opencode/opencode.json | grep -A5 context-mode
   ```
3. Ensure "enabled": true in the MCP config
4. Restart OpenCode

---

### Issue 3: Large Output Flooding Context

**Symptoms:**
- Conversation becomes slow
- Agent forgets earlier context
- "Context window full" messages

**Solutions:**
1. Check context-mode is actually being used:
   - Look for `ctx_` tool calls in the conversation
2. Verify AGENTS.md has routing rules
3. Don't use raw bash for large outputs
4. Use `ctx stats` to see savings

---

### Issue 4: ECC Skills Not Found

**Symptoms:**
- "Use golang-patterns" returns "I don't have that skill"
- Skills don't activate

**Solutions:**
1. Check ECC installation:
   ```bash
   ls ~/.config/opencode/ecc-skills/
   ```
2. Verify opencode.json has instructions array pointing to ECC skills
3. Re-run installer:
   ```bash
   ./install-ecc-skills.sh
   ```

---

### Issue 5: Conflicting Instructions

**Symptoms:**
- Agent seems confused
- Multiple skills trying to activate
- Contradictory guidance

**Solutions:**
1. Check AGENTS.md for duplicate sections
2. Ensure you're not explicitly requesting overlapping skills
3. Use the Skill Selection Guide in AGENTS.md
4. When in doubt, be specific about which skill to use

---

## Best Practices

### 1. Trust the Process

Superpowers skills are designed with rigor. When `test-driven-development` says "write the test first," do it. The "Iron Law" exists because it works.

### 2. Context-Mode First

Before asking for large file reads, API calls, or log analysis, context-mode will handle it better. Let it work.

### 3. Skills Are Complementary

Don't think "Should I use superpowers or ECC?" Think "Superpowers for process, ECC for domain knowledge." They work together.

### 4. Keep AGENTS.md Updated

As your project evolves:
- Add project-specific build commands
- Document your architecture decisions
- Update skill preferences based on your stack

### 5. Verify Before Committing

Always let `verification-before-completion` run. It's your safety net.

### 6. Use Worktrees for Isolation

One feature per worktree. No more "stash my changes, switch branches, fix bug, switch back, pop stash, resolve conflicts."

### 7. Index Documentation

When working with external APIs:
```
"Fetch and index the Stripe API docs, then search for webhook handling"
```

This keeps the docs searchable without flooding context.

### 8. Batch Small Tasks

Instead of 10 separate requests, batch them:
```
"Do these 5 small refactors: [list them]"
```

`subagent-driven-development` handles this efficiently.

### 9. Be Explicit About Review

When code is ready:
```
"Request code review for this implementation"
```

Don't wait for the AI to suggest it.

### 10. Learn from Debugging

When `systematic-debugging` finds an issue, ask:
```
"What pattern can we extract to prevent this in the future?"
```

Build organizational knowledge.

---

## Quick Reference Card

**When to use what:**

| Situation | System | Example |
|-----------|--------|---------|
| Starting new work | Superpowers | "I need to build..." |
| Debugging | Superpowers | "Help me debug..." |
| Go code | ECC | "Use golang-patterns..." |
| Security review | ECC | "Apply security-review..." |
| Large file analysis | Context-mode | Let it handle automatically |
| API research | Context-mode + ECC | "Fetch and index..." |
| Before commit | Superpowers | "Verify this is complete" |
| Before push | pr-gate | "run pr-gate" |

**Emergency Commands:**

```bash
# Check everything is working
ctx doctor

# See context savings
ctx stats

# Check installed skills
ls ~/.config/opencode/skills/superpowers/skills/
ls ~/.config/opencode/ecc-skills/

# Upgrade ECC
./scripts/upgrade-ecc.sh
```

---

## Getting Help

If you're stuck:

1. **Check this guide** - Most issues are covered above
2. **Review AGENTS.md** - Skill reference is there
3. **Run diagnostics:**
   ```bash
   ctx doctor  # Context-mode
   ls ~/.config/opencode/skills/superpowers/  # Superpowers
   ls ~/.config/opencode/ecc-skills/  # ECC
   ```
4. **Ask in the OpenCode session:**
   ```
   "Show me what skills are available and their status"
   ```

---

Remember: These systems are designed to work together. Context-mode protects your context, superpowers provide process discipline, and ECC fills in domain knowledge. Trust them to do their jobs!
