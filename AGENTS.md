# AGENTS.md - Agentic Coding Guidelines

This file provides guidelines for AI agents working in this repository.

## Project Overview

This repository uses a four-layer configuration system for OpenCode:
1. **Context-mode** - Context window protection and session continuity
2. **oh-my-openagent / OMO profile** - Opinionated agent/model routing for OpenCode
3. **Superpowers** - Development process discipline and workflows
4. **ECC** - Language-specific patterns and domain knowledge

---

## Section 0: Runtime and Model Policy

**Node LTS first.** This repo's install guidance should prefer Node.js LTS and `npm`/`npx`
for context-mode and MCP tools. On macOS, prefer Homebrew `node@24` pinned as the active
runtime. Bun is optional and should only be required by tools that explicitly need Bun or
by OpenCode's internal plugin cache.

**OpenAI subscriber profile.** The curated OMO config lives at:

```text
opencode/oh-my-openagent.openai-subscriber.jsonc
```

Install it with:

```bash
./scripts/install-openai-subscriber-profile.sh
```

This profile is for OpenCode's OpenAI browser/OAuth subscriber login:

```bash
opencode auth login
opencode models --refresh
```

Do not introduce `OPENAI_API_KEY` guidance unless the user explicitly asks for direct API-key
billing. Keep model routing OpenAI-only by default:

| Work type | Preferred model |
|-----------|-----------------|
| Orchestration / review | `openai/gpt-5.5` |
| Deep coding | `openai/gpt-5.3-codex` |
| Lightweight coding agent | `openai/gpt-5.3-codex-spark` |
| Fast/simple work | `openai/gpt-5.4-mini` / `openai/gpt-5.4-mini-fast` |
| Vision / PDFs | `openai/gpt-5.4`, then `openai/gpt-5.3-codex` |

**Doctor guardrail.** After install, upgrade, or meaningful config edits, run:

```bash
./scripts/doctor.sh
```

The doctor preserves the current boundaries: Node 24 LTS, context-mode plugin-only,
oh-my-openagent plugin/TUI registration, and stable curated ECC skills.

**OpenCode ecosystem boundaries.** Keep these roles distinct when editing guidance:

- **Plugins** load OpenCode-native extensions through the top-level `plugin` array.
  Context-mode and oh-my-openagent remain first-class plugin entries.
- **MCP servers** add external tools through `mcp` entries. OpenCode supports local command
  servers, remote URL servers, OAuth flows, and header-based auth for MCP servers.
- **Skills** are instruction files today, with this repo still installing Superpowers and curated
  ECC skill references. Native OpenCode skills directories are a future consideration, not a
  replacement requirement for the current installer.
- **Auth files** are local state. Do not sync, read into docs, or commit OpenCode, OMO, provider,
  or MCP auth files. Document login commands and hygiene rules instead.
- **Runtime** stays Node LTS first. Bun may appear under OpenCode's internal plugin cache, but repo
  setup, docs, and MCP tooling should not make Bun the primary runtime.

---

## Section 1: Context-Mode Routing Rules

**PRIORITY: CRITICAL** - These rules protect your context window from flooding.

You have context-mode plugin tools available. These rules are NOT optional.

### BLOCKED Commands

**curl / wget** — BLOCKED
- Any shell command containing `curl` or `wget` will be intercepted
- Do NOT retry with shell
- **Instead use:** `ctx_fetch_and_index(url, source)`

**Inline HTTP** — BLOCKED  
- Commands with `fetch('http`, `requests.get(`, `requests.post(`, etc.
- Do NOT retry with shell
- **Instead use:** `ctx_execute(language, code)`

**Direct web fetching** — BLOCKED
- Do NOT use any direct URL fetching tool
- **Instead use:** `ctx_fetch_and_index(url, source)` then `ctx_search(queries)`

### REDIRECTED Tools

**Shell (>20 lines output)**
- Shell is ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, short commands
- **Instead use:**
  - `ctx_batch_execute(commands, queries)` - Run multiple + search
  - `ctx_execute(language: "shell", code: "...")` - Sandbox execution

**File reading (for analysis)**
- If reading to **edit** → `Read` tool is correct
- If reading to **analyze/explore/summarize** → `ctx_execute_file(path, language, code)`

**grep / search (large results)**
- Search results can flood context
- **Instead use:** `ctx_execute(language: "shell", code: "grep ...")`

### Approved Linting and Analysis Tools

These tools should **always** use `ctx_execute`:

| Tool | Purpose |
|------|---------|
| `shellcheck` | Shell script linting |
| `ruff` | Python linting |
| `eslint` / `oxlint` | JavaScript/TypeScript linting |
| `golangci-lint` / `go vet` | Go linting |
| `cargo clippy` | Rust linting |
| `markdownlint-cli2` | Markdown linting |
| `alex` | Checking for insensitive language |
| `gitleaks` | Secrets scanning |
| `semgrep` | Static analysis / security |

**Example:**
```bash
# Use ctx_execute for linting
ctx_execute(language: "shell", code: "shellcheck install-agents.sh")
```

### Tool Selection Hierarchy

1. **GATHER**: `ctx_batch_execute(commands, queries)` — Primary tool
2. **FOLLOW-UP**: `ctx_search(queries: [...])` — Query indexed content
3. **PROCESSING**: `ctx_execute` or `ctx_execute_file` — Sandbox execution
4. **WEB**: `ctx_fetch_and_index` then `ctx_search` — Web content
5. **INDEX**: `ctx_index(content, source)` — Store for later search

### Plugin and MCP Tools

OpenCode plugins and MCP servers serve different roles. Plugins run OpenCode-native extensions from
the `plugin` array. MCP servers expose external tools through `mcp` config and can be local command
servers or remote servers using OAuth or header-based auth.

The following plugin and MCP tools provide additional capabilities:

| Server | Tools | Purpose |
|--------|-------|---------|
| `context-mode` plugin | `ctx_batch_execute`, `ctx_execute`, `ctx_fetch_and_index`, `ctx_search` | Context protection and session continuity |
| `playwright` MCP server | `playwright_navigate`, `playwright_screenshot`, `playwright_click`, `playwright_fill`, `playwright_evaluate` | Browser automation, screenshot capture |

**Note:** Use `ctx_fetch_and_index` for documentation lookup; use Playwright MCP for live page interaction and screenshots.

### Output Constraints

- Keep responses under 500 words
- Write artifacts (code, configs) to FILES — never inline text
- Use descriptive source labels when indexing (e.g., `source: "React docs"`)

### Utility Commands

| Command | Action |
|---------|--------|
| `context-mode stats` | Context savings report |
| `context-mode doctor` | Diagnostics checklist |
| `context-mode upgrade` | Upgrade to latest version |

---

## Section 2: Superpowers Skills

Superpowers provides **process discipline** and **development workflows**. These skills trigger automatically based on context.

### Core Workflow Skills

**brainstorming** — Use before any creative work
- Socratic design refinement through questions
- Explores alternatives and presents design in sections
- Auto-triggers when you start discussing features

**writing-plans** — Use when you have a spec/requirements
- Breaks work into bite-sized tasks (2-5 minutes each)
- Every task has exact file paths, complete code, verification steps
- Auto-triggers after design approval

**executing-plans** — Use when executing written plans
- Batch execution with human checkpoints
- Alternative to subagent-driven-development for current session

**subagent-driven-development** — Use for complex multi-step work
- Dispatches fresh subagent per task
- Two-stage review: spec compliance, then code quality
- Can work autonomously for hours

**using-git-worktrees** — Use when starting feature work
- Creates isolated workspace on new branch
- Runs project setup, verifies clean test baseline
- Auto-triggers after design approval

### Quality Assurance Skills

**test-driven-development** — Use when implementing any feature or bugfix
- Enforces RED-GREEN-REFACTOR: write failing test → watch fail → write minimal code → watch pass → commit
- **Iron Law**: Deletes code written before tests
- Auto-triggers during implementation

**systematic-debugging** — Use when encountering any bug
- 4-phase root cause process
- Includes techniques: root-cause-tracing, defense-in-depth, condition-based-waiting

**verification-before-completion** — Use before claiming work is complete
- Ensure it's actually fixed
- Runs verification before commits/PRs

### Code Review Skills

**requesting-code-review** — Use when completing tasks or implementing major features
- Pre-review quality checks
- Reviews against plan, reports issues by severity
- Critical issues block progress

**receiving-code-review** — Use when receiving code review feedback
- Technical rigor and verification
- Handles unclear or questionable feedback
- Not performative agreement

### Completion Skills

**finishing-a-development-branch** — Use when tasks complete
- Verifies tests
- Presents options: merge/PR/keep/discard
- Cleans up worktree

### Meta Skills

**writing-skills** — Use when creating new skills
- Follows best practices for skill creation
- Includes testing methodology

**using-superpowers** — Entry point
- Introduction to the skills system
- Triggers automatically at session start

---

## Section 3: Skill Selection Guide

**Critical: Avoid skill conflicts by using the right tool for each task.**

### Overlap Matrix

| Task | Use This | Not That | Reason |
|------|----------|----------|--------|
| TDD workflow | Superpowers `test-driven-development` | ECC `tdd-workflow` | Superpowers has stricter enforcement |
| Verification | Superpowers `verification-before-completion` | ECC `verification-loop` | Better checkpoints |
| Code review process | Superpowers `requesting-code-review` | ECC general `code-review` | Process-focused |
| Go idioms & patterns | ECC `golang-patterns` | — | Language-specific knowledge |
| Security audit | ECC `security-review` | — | Fills superpowers gap |
| API design | ECC `api-design` | — | Domain-specific patterns |
| Debugging | Superpowers `systematic-debugging` | — | Proven methodology |
| Planning | Superpowers `writing-plans` | — | Comprehensive task breakdown |

### Decision Tree

**Starting a new feature?**
1. Superpowers `brainstorming` → Refine requirements
2. Superpowers `writing-plans` → Create implementation plan
3. ECC `search-first` → Research APIs/approaches
4. Superpowers `using-git-worktrees` → Create isolated branch

**Writing code?**
- Superpowers `test-driven-development` → TDD workflow
- ECC `golang-patterns` (or language-specific) → Language idioms
- Superpowers `systematic-debugging` → If bugs arise

**Reviewing code?**
- Superpowers `requesting-code-review` → Process checks
- ECC `go-reviewer` (or language-specific) → Language review
- ECC `security-review` → Security audit

**Finishing up?**
- Superpowers `verification-before-completion` → Final checks
- Superpowers `finishing-a-development-branch` → Merge decision

---

## Section 4: Usage Examples

### Context-Mode Examples

```
"Fetch the React documentation and summarize it"
→ Use ctx_fetch_and_index + ctx_search

"Analyze this 500-line log file"
→ Use ctx_execute_file

"Run these 5 commands and summarize results"
→ Use ctx_batch_execute
```

### Superpowers Examples

```
"Help me plan a user authentication feature"
→ Triggers: brainstorming → writing-plans

"Let's implement the login system"
→ Triggers: test-driven-development

"Debug why this test is failing"
→ Triggers: systematic-debugging

"Review this code before I commit"
→ Triggers: requesting-code-review
```

### ECC Examples

```
"Use golang-patterns to refactor this HTTP handler"
→ Applies Go idioms and patterns

"Apply security-review to the authentication module"
→ Runs security audit checklist

"Use api-design principles for this new endpoint"
→ REST API best practices

"Research the Stripe API documentation"
→ Uses documentation-lookup + search-first
```

---

## Section 5: Build/Test/Lint Commands

This is a documentation repository. No build, test, or lint commands are currently configured.

If adding code in the future:
- Use Node.js LTS and `npm`/`npx` by default
- Use Bun only when the specific tool requires it
- Add appropriate package.json scripts for linting/formatting

---

## Section 6: Code Style Guidelines

### Markdown Documentation
- Use ATX-style headers (`#` not `===` underlines)
- Wrap lines at 100 characters
- Use fenced code blocks with language identifiers
- Use `-` for unordered lists, `1.` for ordered
- Reference file paths in backticks: `path/to/file`

### JSON Configuration
- Use 2-space indentation
- Prefer trailing commas in multi-line arrays/objects
- Sort keys alphabetically where logical
- Use lowercase with hyphens for file names

### File Organization
- Configuration files go in `~/.config/opencode/`
- Custom skills go in `~/.config/opencode/skills/`
- Documentation stays in repository root or `docs/`
- Use descriptive, kebab-case filenames

---

## Section 7: AI Agent Instructions

### When Working in This Repo

1. **Follow context-mode routing rules** — Always use sandbox tools for large outputs
2. **Trust superpowers skills** — They trigger automatically for good reason
3. **Request ECC skills explicitly** — When you need language-specific knowledge
4. **Prefer editing existing files** over creating new ones
5. **Follow existing file naming patterns**
6. **Maintain consistency** with existing documentation style
7. **Ask before making structural changes**
8. **Update README.md** if adding major features

### Before Committing

- Run `context-mode stats` to verify context savings
- Run `./scripts/doctor.sh` to verify integration boundaries
- Review changes for accuracy
- Ensure no secrets are exposed
- Verify documentation is clear and complete
- Use superpowers `verification-before-completion`

---

## References

- [Context-mode](https://github.com/mksglu/context-mode) - Context window protection
- [Superpowers](https://github.com/obra/superpowers) - Development workflow
- [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) - ECC repository
- [OpenCode Documentation](https://opencode.ai)

## ECC Skills Reference

The following ECC skills are available for language-specific patterns and domain knowledge.
Use these to complement superpowers' process skills.

### Language-Specific Patterns

**Go**
- **golang-patterns** - Idiomatic Go patterns, concurrency, error handling
- **golang-testing** - Go testing patterns, TDD, benchmarks
- **go-reviewer** agent - Go code review specialist

**TypeScript/JavaScript**
- **frontend-patterns** - React, Next.js patterns
- **backend-patterns** - API, database, caching patterns
- **bun-runtime** - Bun runtime idioms and patterns
- **nextjs-turbopack** - Next.js with Turbopack patterns
- **api-design** - REST API design, pagination, error responses
- **e2e-testing** - Playwright E2E patterns
- **typescript-reviewer** agent - TypeScript code review

**Python**
- **python-patterns** - Pythonic idioms, PEP 8, type hints
- **python-testing** - Python testing with pytest
- **python-reviewer** agent - Python code review

**Rust**
- **rust-patterns** - Idiomatic Rust patterns, ownership, error handling
- **rust-testing** - Rust testing patterns
- **rust-reviewer** agent - Rust code review

### DevOps & Deployment

- **docker-patterns** - Docker and containerization best practices
- **deployment-patterns** - Deployment strategies and infrastructure

### Security & Documentation

- **security-review** - Security audit checklist and patterns
- **security-reviewer** agent - Security-focused code review
- **documentation-lookup** - API reference research
- **docs-lookup** agent - Documentation lookup specialist
- **search-first** - Research-before-coding methodology

### Skill Selection Guide

**When to use Superpowers vs ECC:**

| Task Type | Use This | Not That |
|-----------|----------|----------|
| TDD workflow | Superpowers `test-driven-development` | ECC `tdd-workflow` |
| Verification | Superpowers `verification-before-completion` | ECC `verification-loop` |
| Code review process | Superpowers `requesting-code-review` | ECC general code-review |
| Go idioms & patterns | ECC `golang-patterns` | - |
| Security audit | ECC `security-review` | - |
| API design | ECC `api-design` | - |

**Usage Examples:**
- "Use golang-patterns to refactor this handler"
- "Apply security-review to the authentication module"
- "Use api-design principles for this endpoint"

## Pre-PR Review Discipline

CRITICAL: Before any `git push` or when asked to review code for a PR:

1. Call the `$pr-gate` skill to run the full local review pipeline
2. Use `@code-reviewer` for AI diff analysis — it returns structured JSON only
3. Do NOT push if any `severity: error` issues exist
4. The reviewer caches results by commit hash — only NEW issues surface on re-runs

The `@code-reviewer` subagent detects languages automatically from the diff.
Supported: JavaScript, TypeScript, Go, Python, Rust, Shell — plus cross-file
consistency checks, markdown code block validation, and Semgrep-powered
security and secrets scanning across all file types.

### Linter Prerequisites by Language

**Recommended:** Use [Megalinter](https://oxsecurity.github.io/megalinter/) + [Gitleaks](https://github.com/gitleaks/gitleaks) for maximum coverage with minimal setup.

| Language | Linter(s) | Install |
|---|---|---|
| All | Megalinter (80+ linters) | `docker pull oxsecurity/megalinter` or `npm install -g mega-linter-runner` |
| All | Gitleaks (secrets) | `brew install gitleaks` |
| Security | Semgrep (custom rules) | `brew install semgrep` |
| JS/TS | eslint, oxlint | `npm install -D eslint oxlint` |
| Go | golangci-lint, go vet | `brew install golangci-lint` |
| Python | ruff | `pip install ruff` |
| Rust | cargo clippy | included with rustup |
| Shell | shellcheck | `brew install shellcheck` |
| GitHub Actions | actionlint | `brew install actionlint` |

Missing linters are skipped gracefully — the review still runs.

**Quick start (recommended):**
```bash
# Docker (recommended)
docker pull oxsecurity/megalinter:latest
mega-linter-runner

# Gitleaks (secrets)
gitleaks protect --staged
```
