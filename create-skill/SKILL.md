---
name: Skill Creation
description: Framework for creating well-structured, reusable global skills for Claude Code
author: pvalena
version: 1.1.0
tags: [meta, skill-development, documentation, best-practices, templates]
---

# Skill Creation Skill

**Purpose**: Provide a systematic framework for creating high-quality, reusable global skills that follow
best practices and maintain consistency across the skill library.

## When to Use This Skill

Use this skill when:
- Creating a new global skill from scratch
- You've developed a successful workflow that should be reusable
- Need to document a complex process for future use
- Standardizing a repetitive task across multiple projects
- Refactoring existing ad-hoc processes into formal skills

## What Makes a Good Skill

### Do Create Skills For:
- **Repeatable workflows** - Multi-step processes used across projects
- **Complex procedures** - Tasks requiring specific order or careful execution
- **Domain knowledge** - Specialized expertise worth capturing
- **Quality workflows** - Processes with quality gates and verification
- **Error-prone processes** - Where mistakes are costly

### Don't Create Skills For:
- **One-time tasks** - Won't be reused
- **Trivial operations** - Too simple to document
- **Highly variable processes** - No standard workflow
- **Tool-specific** - Better as tool documentation
- **Project-specific** - Use project README instead

## Skill Structure

### Required Components

#### 1. YAML Frontmatter

```yaml
---
name: Skill Name Here
description: Brief one-line description (80-120 chars)
author: your-username
version: 1.0.0
tags: [tag1, tag2, tag3, tag4]
---
```

**Fields:**
- `name`: Human-readable name (Title Case)
- `description`: What the skill does (1 sentence, no period). **Critical for discoverability** -- Claude
  Code uses this field to understand when to offer the skill and to display it in the available skills
  list. Without it, the skill is effectively invisible.
- `author`: Your username or identifier
- `version`: Semantic versioning (MAJOR.MINOR.PATCH)
- `tags`: 3-8 descriptive tags for searchability

**Version guidelines:**
- `1.0.0` - Initial stable version
- `1.x.0` - New features added
- `x.0.0` - Breaking changes or major restructure

**Important**: The frontmatter block must start with `---` on the first line of the file and close with
`---`. If the file starts with anything else (e.g., a markdown heading), Claude Code will not parse the
frontmatter and the skill will not appear in the available skills list.

#### 2. Main Heading & Purpose
```markdown
# Skill Name Skill

**Purpose**: Clear statement of what this skill accomplishes and why it exists.
```

- Heading matches `name` field from frontmatter + " Skill"
- Purpose is 1-3 sentences max
- Focus on WHAT and WHY, not HOW

#### 3. When to Use Section
```markdown
## When to Use This Skill

Use this skill when:
- Specific scenario 1
- Specific scenario 2
```

- List 4-8 concrete use cases
- Be specific, not generic
- Use action-oriented language

### Optional (but Recommended) Components

#### 4. Core Principles

Document philosophical guidelines, quality standards, and important trade-offs. Use when the skill has
non-obvious constraints (e.g., "zero false positives" in code review).

#### 5. Complete Workflow

Break into 3-7 phases. Each phase has a clear goal. Steps are numbered and actionable. Include examples
and expected outputs.

```markdown
### Phase N: Phase Name

**Goal**: What this phase accomplishes

#### 1. Step Name

Instructions here.

**Output**: Expected result
```

#### 6. Templates, Examples, Checklists

Include as applicable. Templates standardize output. Examples use real data from actual usage. Checklists
ensure critical steps aren't missed.

#### 7. Red Flags / Best Practices / Version History / See Also

Document when NOT to use the skill, lessons learned, change history, and related skills.

## Skill Creation Workflow

### Phase 1: Conceptualize

**Goal**: Determine if a skill is needed and define its scope

#### 1. Identify the Need

Ask yourself:
- Have I done this workflow 3+ times?
- Is there a consistent pattern?
- Would others benefit from this?
- Does it take > 15 minutes to complete?

#### 2. Define Scope

Determine:
- **Input**: What does the user start with?
- **Output**: What is produced?
- **Phases**: What are the major steps?
- **Complexity**: How many steps? How long?

#### 3. Choose Skill Name

Guidelines:
- Use 1-3 words, action or domain focused
- Lowercase with hyphens (directory name)
- Title Case in YAML/heading

Examples: `code-review` -> "Code Review", `refresh-docs` -> "Documentation Refresh"

### Phase 2: Structure

**Goal**: Create the skeleton before filling content

#### 1. Create Skill Directory and File

```bash
mkdir -p ~/.claude/skills/SKILL-NAME
```

Create `~/.claude/skills/SKILL-NAME/SKILL.md` with frontmatter, heading, purpose, and "When to Use"
section before filling in the workflow content.

### Phase 3: Document Workflow

**Goal**: Fill in the complete workflow with detailed instructions

#### 1. Break into Phases

- 3-7 phases is ideal
- Each phase should be cohesive and sequential
- Each phase has clear goal

#### 2. Add Examples and Templates

For each phase or step where helpful:
- Show real commands and actual output
- Demonstrate common variations
- Provide copy-pasteable commands
- Include filled-in examples, not just placeholders

### Phase 4: Add Supporting Sections

**Goal**: Enhance skill with supporting content

Add as applicable:
- **Core Principles** - Philosophical guidelines and quality standards
- **Checklist** - Critical steps and verification points
- **Red Flags** - When NOT to use the skill, common misapplications
- **Best Practices** - Lessons learned and optimization tips

### Phase 5: Review & Refine

**Goal**: Ensure quality and usability

#### 1. Self-Review

- [ ] YAML frontmatter complete and valid (especially `description`)
- [ ] Version is 1.0.0 for new skill
- [ ] Tags are relevant and specific (3-8 tags)
- [ ] Purpose is clear and concise (1-3 sentences)
- [ ] "When to Use" has 4+ specific scenarios
- [ ] Workflow has clear phases and steps
- [ ] Commands/examples are correct and use real data
- [ ] Markdown formatting is correct
- [ ] All sections properly nested (H2 for major, H3 for phases, H4 for steps)
- [ ] Version history included

#### 2. Validate All Skills

Run the validation script from the skills root directory to check all skills against quality
standards (frontmatter, required sections, sizing, line width, cross-references):

```bash
~/.claude/skills/create-skill/validate_skills.sh ~/.claude/skills
```

Fix any errors before deploying. Warnings are advisory.

#### 3. Test the Skill

Actually use it:
- Follow your own instructions
- Find gaps or unclear steps
- Verify commands work
- Check output matches descriptions

### Phase 6: Deploy

**Goal**: Make skill available for use

```bash
# Verify file location
ls -la ~/.claude/skills/SKILL-NAME/SKILL.md

# Add to git
cd ~/.claude/skills
git add SKILL-NAME/SKILL.md

# Commit
git commit -m "Add SKILL-NAME skill v1.0.0"
```

**Post-deploy verification**: Start a new Claude Code session and confirm the skill appears in the
available skills list. If it doesn't, check that the frontmatter `description` field exists and the
`---` delimiters are correct.

## Skill Quality Standards

### Clarity
- Instructions are unambiguous
- Steps are actionable
- Examples illustrate concepts
- Technical terms defined

### Completeness
- All phases documented
- Edge cases considered
- Prerequisites stated
- Expected outputs shown

### Consistency
- Formatting matches other skills
- Terminology consistent throughout
- Structure follows conventions

### Usability
- Can be followed by someone else
- Examples are realistic
- Commands are copy-pasteable
- Checklists aid execution

## Sizing Guidelines

Skills should be sized proportional to their usage frequency and domain-specificity:

- **High-frequency, domain-specific** (e.g., code review): 500-800 lines justified
- **Medium-frequency, workflow-based** (e.g., doc refresh): 500-800 lines justified
- **Low-frequency, meta/generic** (e.g., this skill): Target 400-500 lines
- **Analysis frameworks**: Target 150-400 lines

If a skill exceeds its target range, check for:
- Duplicate templates (keep one)
- Generic advice the model already knows (remove)
- Examples that repeat the workflow phases (inline instead)

## Checklist

Use this checklist when creating a new skill:

### Conceptualize
- [ ] Identified clear need (used 3+ times)
- [ ] Defined scope (input/output/phases)
- [ ] Chosen skill name (1-3 words, action-focused)

### Structure
- [ ] Created skill directory (`~/.claude/skills/SKILL-NAME/`)
- [ ] Created SKILL.md with valid frontmatter (especially `description`)
- [ ] Added basic structure (heading, purpose, when-to-use)

### Document
- [ ] Workflow broken into 3-7 phases
- [ ] Steps are actionable with examples
- [ ] Commands are correct and copy-pasteable

### Enhance
- [ ] Added Core Principles (if applicable)
- [ ] Added Checklist (if applicable)
- [ ] Added Red Flags (if applicable)
- [ ] Added Best Practices (if applicable)

### Review
- [ ] Frontmatter valid with description field
- [ ] Tested by following instructions
- [ ] Version history included
- [ ] Size appropriate for usage frequency

### Deploy
- [ ] File in correct location
- [ ] Committed to git
- [ ] Verified skill appears in available skills list

## Red Flags

**Avoid creating skills for:**
- Tasks done only once or twice
- Processes that change constantly
- Simple operations (< 3 steps)
- Tool usage better documented elsewhere
- Project-specific workflows (use project docs)

**Warning signs:**
- "This might be useful someday" - Not proven useful yet
- "Just in case" - No concrete use case
- Too generic - No specific guidance beyond what the model already knows
- Too specific - Only works in one exact scenario
- Oversized - More template padding than actionable content

## Best Practices

1. **Write from experience** - Create skills after you've done the workflow multiple times
2. **Test before committing** - Follow your own instructions to find gaps
3. **Keep it focused** - One clear purpose, not multiple unrelated workflows
4. **Include examples** - Real examples > abstract instructions
5. **Size appropriately** - Domain knowledge justifies length; generic advice doesn't
6. **Document iteratively** - Update as you learn better approaches
7. **Cross-reference** - Link to related skills in "See Also"

## Version History

- **1.0.0** (2026-04-13): Initial version based on creation of refresh-docs, incremental-improvement
  skills
- **1.1.0** (2026-04-21): Trimmed from 871 to ~500 lines; removed redundant full templates and tags
  reference; added frontmatter discoverability lesson and sizing guidelines

## See Also

- **refresh-docs** - Example of well-structured documentation skill
- **review** - Example of workflow skill with quality standards
- **incremental-improvement** - Example of analysis skill with frameworks

---

**Remember**: The best skill is one you actually use. If you create it but never reference it again, it's
documentation overhead, not a productivity tool.
