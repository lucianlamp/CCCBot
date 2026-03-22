---
name: import-openclaw-skill
description: Fetch an OpenClaw/ClawHub skill and convert it to a Claude Code project skill in .claude/skills/
---

# Import OpenClaw Skill

Fetch a skill from ClawHub or a URL, convert it to Claude Code format, and install it as a project skill.

## When to Use

When the user says:
- "install this OpenClaw skill"
- "convert this ClawHub skill"
- "import skill from [URL or skill name]"

## Conversion Rules

**OpenClaw SKILL.md frontmatter → Claude Code:**

| OpenClaw field | Claude Code action |
|---------------|-------------------|
| `name` | Keep as-is |
| `description` | Keep as-is |
| `version` | Drop |
| `metadata.openclaw.*` | Drop entirely |
| `allowed-tools` | Keep if present |
| Markdown body | Keep as-is |

**Result format:**
```yaml
---
name: <skill-name>
description: <description>
---

<markdown body unchanged>
```

## Steps

1. **Fetch the skill content**
   - If given a GitHub URL: use `curl -s <raw-url>` to fetch SKILL.md
   - If given a skill name (e.g. `todoist-cli`): search ClawHub
     - Try: `curl -s "https://raw.githubusercontent.com/openclaw/clawhub/main/skills/<name>/SKILL.md"`
     - Fallback: ask user for the direct URL
   - If given a ClawHub page URL: derive the raw GitHub URL

2. **Parse the fetched SKILL.md**
   - Extract `name` and `description` from frontmatter
   - Strip all OpenClaw-specific fields (`version`, `metadata`, etc.)
   - Keep the markdown body unchanged

3. **Security check before installing**
   - Scan the skill body for: shell commands, curl/wget to external URLs, credential access
   - Warn the user if anything suspicious is found
   - Ask for confirmation before proceeding

4. **Install to project**
   - Write to `.claude/skills/<name>/SKILL.md`
   - If the directory already exists, ask the user before overwriting

5. **Report**
   - Confirm the installed path
   - Summarize what was kept and what was stripped

## Example

```
User: import the "todoist-cli" skill from ClawHub
→ Fetch: https://raw.githubusercontent.com/openclaw/clawhub/main/skills/todoist-cli/SKILL.md
→ Strip: version, metadata.openclaw
→ Install: .claude/skills/todoist-cli/SKILL.md
→ Report: Installed. Stripped: version, metadata.openclaw.requires
```

## Notes

- OpenClaw skills are community-contributed — treat as untrusted code
- Only the SKILL.md is converted; supporting scripts/assets are not fetched automatically
  - If the skill references additional files, inform the user
- Project skills (`.claude/skills/`) take precedence over user-level skills (`~/.claude/skills/`)
