# Playwright MCP Server Integration Design

## Context

The `my-opencode-config` repository provides a three-layer configuration for OpenCode:
1. **Context-mode** — Context window protection
2. **Superpowers** — Development workflows
3. **ECC** — Language-specific patterns

Currently, the config includes an `e2e-testing` skill that teaches the AI how to *write* Playwright tests. However, there is no MCP server configured to give the AI *browser automation capabilities* (screenshot capture, page crawling, DOM inspection).

## What We're Adding

A **Playwright MCP server** entry that enables the AI to control a real browser. This is separate from the `e2e-testing` skill:

| | Purpose | Goes in |
|---|---|---|
| `e2e-testing` skill | Writing Playwright test code | Skills |
| Playwright MCP server | AI controls browser for automation | `opencode.json` `mcp` section |

## Files to Modify

| File | Change |
|------|--------|
| `README.md` | New "MCP Servers" section with Playwright setup |
| `AGENTS.md` | New MCP tools reference in context-mode section |

### No changes to:
- `ecc-config/skills-list.txt` (MCP server, not a skill)
- `install-ecc-skills.sh` or `install-agents.sh`
- `scripts/integrate-ecc.sh`

## Implementation

### Prerequisites

Users must install:
```bash
npm install -g @modelcontextprotocol/server-playwright
npx playwright install --with-deps
```

### Configuration

Add to user's `~/.config/opencode/opencode.json`:

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

### Alternative: Global Install

For faster startup (avoids `npx` fetch each time):
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

## Documentation

### README.md — New MCP Servers Section

Add after the "## 3. ECC Skills" section:

```markdown
## 4. MCP Servers

MCP (Model Context Protocol) servers extend the AI's capabilities with external tools.
Unlike skills (which provide guidelines), MCP servers provide executable tools.

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

**Usage:**
- "Take a screenshot of opencode.ai"
- "Crawl this page and extract all links"
- "Check if this page has a login form"

**Tools provided:**
- `playwright_navigate` — Navigate to a URL
- `playwright_screenshot` — Capture a screenshot
- `playwright_click` — Click an element
- `playwright_fill` — Fill a form field
- `playwright_evaluate` — Execute JavaScript in browser context
```

### AGENTS.md — Context-Mode Section Update

Add to the context-mode tools reference:

```markdown
### MCP Tools

The following MCP servers provide additional capabilities:

| Server | Tools | Purpose |
|--------|-------|---------|
| `context-mode` | `ctx_batch_execute`, `ctx_execute`, `ctx_fetch_and_index`, `ctx_search` | Context protection and session continuity |
| `playwright` | `playwright_navigate`, `playwright_screenshot`, `playwright_click`, `playwright_fill`, `playwright_evaluate` | Browser automation, screenshot capture |

**Note:** Use `ctx_fetch_and_index` for documentation lookup; use Playwright MCP for live page interaction and screenshots.
```

## Risks & Mitigations

1. **Heavy browser binaries (~100MB+)**
   - **Mitigation**: Document clearly as optional; users who don't need browser automation can skip

2. **`npx -y` fetch on every startup**
   - **Mitigation**: Offer global install as alternative in documentation

3. **Security: AI controlling a browser**
   - **Mitigation**: Document that the AI only uses tools when explicitly requested by user

## Out of Scope

- Creating a new `playwright-patterns` skill (e2e-testing already covers this)
- Modifying install scripts (manual setup as requested)
- CI/CD configuration for Playwright

## Success Criteria

1. Users can add Playwright MCP server by following README.md
2. AI can use Playwright tools when server is configured
3. Documentation clearly distinguishes between MCP server (automation) and skill (patterns)
4. No conflicts with existing e2e-testing skill or context-mode tools
