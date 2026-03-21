# my-opencode-config

My opinionated configuration for opencode.

## Context-mode

This configuration uses [context-mode](https://github.com/mksglu/context-mode) to protect your context window by sandboxing tool calls and providing session continuity.

### What is Context-mode?

Context-mode is an MCP server that:
- **Reduces context usage by 98%** by sandboxing large outputs (web pages, logs, API responses)
- **Maintains session continuity** across conversation compactions via SQLite tracking
- **Enables FTS5 search** with BM25 ranking for indexed content

### Quick Install (Global Setup)

Copy and paste this into your opencode session to install context-mode globally:

```
Install context-mode globally for opencode: npm install -g context-mode, then add it to ~/.config/opencode/opencode.json as an MCP server with command ["context-mode"] and enabled true, and add "context-mode" to the plugin array. Verify with ctx doctor.
```

### Full Setup (Global + Repository)

For a complete setup that installs context-mode globally AND configures it for the current repository:

```
Install context-mode globally and set it up for this repository. First, run npm install -g context-mode. Then update ~/.config/opencode/opencode.json to add context-mode as an MCP server with enabled true and add "context-mode" to the plugin array. Next, check if AGENTS.md exists in this repo - if not, run /init to create it. Finally, add context-mode routing rules to AGENTS.md instructing agents to use ctx_batch_execute, ctx_fetch_and_index, ctx_execute_file, and ctx_search instead of raw Bash/Read/WebFetch/curl. Include blocked commands and tool hierarchy. Verify the setup works.
```

### Manual Install

1. **Install context-mode globally:**
   ```bash
   npm install -g context-mode
   ```

2. **Edit `~/.config/opencode/opencode.json`:**
   ```json
   {
     "$schema": "https://opencode.ai/config.json",
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

3. **Restart OpenCode** for changes to take effect.

4. **Verify installation:**
   ```bash
   ctx doctor
   ctx stats
   ```

### Available Tools

Once installed, you can use these sandbox tools in any opencode session:

- `ctx_batch_execute` - Run multiple commands + search in one call
- `ctx_execute` - Run code in 11 languages (only stdout enters context)
- `ctx_execute_file` - Process files without loading content into context
- `ctx_index` - Index markdown into FTS5 with BM25 ranking
- `ctx_search` - Query indexed content
- `ctx_fetch_and_index` - Fetch URLs, convert to markdown, and index
- `ctx_stats` - Show context savings and session statistics
- `ctx_doctor` - Diagnose installation and runtimes
- `ctx_upgrade` - Upgrade to latest version

### Current Configuration

Our setup uses:
- **Bun runtime** for 3-5x faster JS/TS execution
- **8/11 language runtimes** available (javascript, shell, typescript, python, ruby, go, rust, perl)
- **SQLite FTS5** for full-text search with BM25 ranking

See the [context-mode documentation](https://github.com/mksglu/context-mode) for advanced usage and platform-specific configurations.

### Setting Up Context-mode for Your Repository

To ensure AI agents working on **your projects** use context-mode effectively, add an `AGENTS.md` file to your repository root. This file instructs agents to route large outputs through context-mode's sandbox tools instead of dumping raw data into the context window.

#### Option 1: Automated Setup (Prompt)

Copy and paste this prompt into your opencode session to automatically set up context-mode for this repository:

```
Set up context-mode for this repository. First, check if AGENTS.md exists. If it doesn't exist, run /init and select AGENTS.md to create it. Then read the AGENTS.md file and add context-mode routing rules to it. The rules should instruct AI agents to use ctx_batch_execute for multiple commands, ctx_fetch_and_index for web requests, ctx_execute_file for file analysis, and ctx_search for indexed content. Include a tool hierarchy section and blocked commands (curl, wget, direct HTTP). Save the updated file and verify the routing rules are present.
```

This prompt will:
- Check for existing AGENTS.md or create one via /init
- Add the complete context-mode routing rules
- Ensure agents use sandbox tools instead of raw Bash/Read/WebFetch

#### Option 2: Manual Creation

**Create `AGENTS.md` in your project root:**

```markdown
# AGENTS.md

## Context-mode Routing Rules

You have context-mode MCP tools available. Follow these rules to protect the context window:

### BLOCKED Commands

- **curl / wget**: Use `ctx_fetch_and_index(url, source)` instead
- **Inline HTTP** (fetch, requests.get, etc.): Use `ctx_execute(language, code)` instead
- **Direct web fetching**: Use `ctx_fetch_and_index` + `ctx_search`

### REDIRECTED Tools

- **Shell (>20 lines)**: Use `ctx_batch_execute` or `ctx_execute`
- **File analysis** (not editing): Use `ctx_execute_file(path, language, code)`
- **grep / search** (large results): Use `ctx_execute` in sandbox

### Tool Selection Hierarchy

1. **GATHER**: `ctx_batch_execute(commands, queries)` — Primary for multiple operations
2. **FOLLOW-UP**: `ctx_search(queries)` — Query already-indexed content
3. **PROCESSING**: `ctx_execute` or `ctx_execute_file` — Sandbox execution
4. **WEB**: `ctx_fetch_and_index` then `ctx_search` — Web content
5. **INDEX**: `ctx_index(content, source)` — Store for later search

### Output Constraints

- Keep responses under 500 words
- Write artifacts to FILES, not inline text
- Use descriptive source labels when indexing
```

**Verify it's working:**

When an agent starts working in your repo, they should automatically:
- Use `ctx_batch_execute` instead of multiple Bash calls
- Fetch web pages via `ctx_fetch_and_index` instead of curl
- Process log files via `ctx_execute_file` instead of Read

**Customize for your project:**

Add project-specific sections to your `AGENTS.md`:
- Build/test commands
- Code style guidelines
- Architecture patterns
- MCP tool preferences

See our [`AGENTS.md`](./AGENTS.md) for a full example with context-mode routing rules.
