---
name: skill-creator
description: "Guide for creating Claude Code skills (user)"
---

# Skill Creator Guide

Guide for creating effective Claude Code skills that extend Claude's capabilities with specialized knowledge, workflows, or tool integrations.

## Skill Structure

Skills are defined as directories containing a `SKILL.md` file:

```
~/.claude/skills/<skill-name>/
├── SKILL.md                  # Required: Main skill definition
├── reference-doc.md          # Optional: Reference materials
├── templates/                # Optional: Template files
│   └── template.md
└── scripts/                  # Optional: Executable scripts
    └── helper.py
```

## Skill Locations

| Location | Path | Scope |
|----------|------|-------|
| Personal | `~/.claude/skills/` | All your projects |
| Project | `.claude/skills/` | Team members who clone the repo |
| Plugin | `skills/` (in plugin) | Plugin users |

## SKILL.md Format

### Frontmatter (Required)

```yaml
---
name: skill-name
description: "What this skill does and when to use it (max 1024 chars)"
allowed-tools: Read, Grep, Glob  # Optional: Restrict tool access
model: claude-opus-4-5-20251101  # Optional: Specify model
---
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Lowercase, alphanumeric, hyphens only (max 64 chars) |
| `description` | Yes | What it does and when to use it (Claude uses this to auto-trigger) |
| `allowed-tools` | No | Tools that can be used without permission |
| `model` | No | Model to use for this skill |

### Body Content

The body should contain:

1. **Purpose**: Clear explanation of what the skill does
2. **When to Use**: Specific scenarios that trigger this skill
3. **Core Knowledge**: Domain expertise, principles, best practices
4. **Workflow**: Step-by-step procedures
5. **Templates**: Reusable formats or patterns
6. **Examples**: Concrete usage examples
7. **References**: Links to external resources

## Best Practices

### 1. Progressive Disclosure

- Keep SKILL.md under 500 lines for core content
- Put detailed reference material in separate files
- Use relative links: `[details](./reference.md)`

### 2. Clear Triggering

Write descriptions that clearly indicate when to use:

```yaml
# Good - Specific triggers
description: "Create Architecture Decision Records (ADRs) when documenting
technology choices, design patterns, or significant architectural decisions"

# Bad - Vague
description: "Helps with documentation"
```

### 3. Actionable Content

- Provide concrete steps, not abstract advice
- Include templates users can directly apply
- Show before/after examples

### 4. Tool Restrictions

Use `allowed-tools` for security:

```yaml
# Read-only skill
allowed-tools: Read, Grep, Glob

# Skill that can execute code
allowed-tools: Read, Bash(python:*), Grep
```

### 5. Script Efficiency

Scripts in `scripts/` only add their output to context (not source code), saving tokens.

## Skill Template

```markdown
---
name: my-skill
description: "Description of what this skill does and when to use it"
---

# Skill Name

Brief overview of the skill's purpose.

## When to Use

- Scenario 1
- Scenario 2
- Scenario 3

## Core Principles

1. **Principle 1**: Explanation
2. **Principle 2**: Explanation

## Workflow

1. **Step 1**: Description
2. **Step 2**: Description
3. **Step 3**: Description

## Templates

\`\`\`markdown
# Template Title

## Section 1
[Content]

## Section 2
[Content]
\`\`\`

## Examples

### Example 1: [Scenario]

[Detailed example]

## References

- [Resource 1](https://example.com)
- [Resource 2](https://example.com)
```

## Creating Skills from Subagents

When converting subagent knowledge to skills:

1. Extract domain expertise to SKILL.md
2. Keep subagent concise with skill reference
3. Add behavioral guidance in subagent

**Subagent referencing skill:**

```markdown
---
name: my-agent
description: |
  Agent description with examples...
---

Your role description.

**First read `~/.claude/skills/my-skill/SKILL.md` for detailed guidance.**

Follow that content and apply these additional guidelines:
- Guideline 1
- Guideline 2
```

## Skill Seekers MCP

Use the Skill Seekers MCP to automatically generate skills from external documentation.

### Available Tools

| Tool | Description |
|------|-------------|
| `generate_config` | Create config file for documentation scraping |
| `estimate_pages` | Preview how many pages will be scraped |
| `scrape_docs` | Scrape documentation and build skill |
| `scrape_pdf` | Extract skill from PDF documents |
| `scrape_github` | Build skill from GitHub repo (README, Issues, Changelog) |
| `package_skill` | Package skill directory into .zip |
| `upload_skill` | Upload skill .zip to Claude |
| `list_configs` | List available preset configurations |
| `validate_config` | Validate config file for errors |
| `split_config` | Split large docs (10K+ pages) into multiple skills |
| `generate_router` | Create router skill for split documentation |

### Workflow: Creating Skill from Documentation

1. **Generate config**:
   ```
   generate_config(
     name="react",
     url="https://react.dev/reference",
     description="React documentation for components and hooks"
   )
   ```

2. **Estimate pages** (optional):
   ```
   estimate_pages(config_path="configs/react.json")
   ```

3. **Scrape and build**:
   ```
   scrape_docs(config_path="configs/react.json")
   ```

4. **Package and upload**:
   ```
   package_skill(skill_dir="output/react/")
   ```

### Workflow: Creating Skill from GitHub

```
scrape_github(
  repo="facebook/react",
  name="react-github",
  description="React GitHub issues and changelog"
)
```

### Workflow: Creating Skill from PDF

```
scrape_pdf(
  pdf_path="/path/to/manual.pdf",
  name="manual",
  description="Product manual reference"
)
```

### Config Options

```json
{
  "name": "skill-name",
  "url": "https://docs.example.com",
  "description": "When to use this skill",
  "max_pages": 100,
  "rate_limit": 0.5
}
```

| Option | Default | Description |
|--------|---------|-------------|
| `max_pages` | 100 | Maximum pages to scrape (-1 for unlimited) |
| `rate_limit` | 0.5 | Delay between requests in seconds |
| `unlimited` | false | Remove all limits |

### Large Documentation (10K+ pages)

For large documentation sites:

1. **Split config**:
   ```
   split_config(
     config_path="configs/godot.json",
     strategy="auto",
     target_pages=5000
   )
   ```

2. **Generate router**:
   ```
   generate_router(config_pattern="configs/godot-*.json")
   ```

### Tips

- Use `llms.txt` if available (10x faster processing)
- Check `list_configs()` for preset configurations
- Use `validate_config()` before scraping
- Set `dry_run=true` to preview without saving

## Validation Checklist

- [ ] `name` is lowercase with hyphens only
- [ ] `description` clearly states when to use (max 1024 chars)
- [ ] SKILL.md is under 500 lines
- [ ] Contains actionable content, not just theory
- [ ] Templates are ready to use
- [ ] Examples are concrete and realistic
- [ ] References are valid links