---
name: Skill Creation
description: Framework for creating well-structured, reusable global skills for Claude Code
author: pvalena
version: 1.0.0
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
✓ **Repeatable workflows** - Multi-step processes used across projects
✓ **Complex procedures** - Tasks requiring specific order or careful execution
✓ **Domain knowledge** - Specialized expertise worth capturing
✓ **Quality workflows** - Processes with quality gates and verification
✓ **Time-consuming tasks** - Operations that benefit from guidance
✓ **Error-prone processes** - Where mistakes are costly

### Don't Create Skills For:
✗ **One-time tasks** - Won't be reused
✗ **Trivial operations** - Too simple to document
✗ **Highly variable processes** - No standard workflow
✗ **Tool-specific** - Better as tool documentation
✗ **Project-specific** - Use project README instead

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
- `description`: What the skill does (1 sentence, no period)
- `author`: Your username or identifier
- `version`: Semantic versioning (MAJOR.MINOR.PATCH)
- `tags`: 3-8 descriptive tags for searchability

**Version guidelines:**
- `1.0.0` - Initial stable version
- `1.x.0` - New features added
- `x.0.0` - Breaking changes or major restructure

#### 2. Main Heading & Purpose
```markdown
# Skill Name Skill

**Purpose**: Clear statement of what this skill accomplishes and why it exists.
```

**Guidelines:**
- Heading matches `name` field from frontmatter + " Skill"
- Purpose is 1-3 sentences max
- Focus on WHAT and WHY, not HOW

#### 3. When to Use Section
```markdown
## When to Use This Skill

Use this skill when:
- Specific scenario 1
- Specific scenario 2
- Specific scenario 3
```

**Guidelines:**
- List 4-8 concrete use cases
- Be specific, not generic
- Use action-oriented language

### Optional (but Recommended) Components

#### 4. Core Principles
```markdown
## Core Principles

**Principle name**: Description and rationale.

**Another principle**: Description and rationale.
```

**Use when:**
- Skill has important philosophical guidelines
- Quality standards that must be maintained
- Trade-offs that need explanation

**Examples:**
- Zero false positives (code review)
- Single source of truth (documentation)
- Composability (incremental improvement)

#### 5. Complete Workflow
```markdown
## Complete Workflow

### Phase 1: Name of Phase

**Goal**: What this phase accomplishes

#### 1. Step Name

Description of what to do.

**Commands/actions:**
```bash
command examples
```

**Output**: What you should see after this step
```

**Guidelines:**
- Break into 3-7 phases
- Each phase has clear goal
- Steps are numbered and actionable
- Include examples and expected outputs
- Use consistent formatting

#### 6. Templates
```markdown
## Templates

### Template Name

```template-format
Template content here
```
```

**Use when:**
- Skill involves creating structured documents
- Standard format required
- Examples aid understanding

#### 7. Examples
```markdown
## Examples

### Example 1: Scenario Name

[Show real usage of the skill with actual commands and outputs]
```

**Use when:**
- Workflow is complex
- Concrete examples clarify abstract instructions
- Common variations need demonstration

#### 8. Checklists
```markdown
## Checklist

Use this checklist when applying the skill:

- [ ] Step 1
- [ ] Step 2
- [ ] Step 3
```

**Use when:**
- Skill has critical steps that shouldn't be missed
- Quality gates that must be verified
- Common mistakes to avoid

#### 9. Red Flags / Warnings
```markdown
## Red Flags

**Avoid when:**
- Warning scenario 1
- Warning scenario 2

**Warning signs:**
- Problem indicator 1
- Problem indicator 2
```

**Use when:**
- Skill can be misapplied
- Common pitfalls exist
- Boundaries need clarification

#### 10. Best Practices
```markdown
## Best Practices

1. **Practice name** - Description
2. **Practice name** - Description
```

**Use when:**
- Experienced users have learned lessons
- Optimization tips exist
- Common patterns emerge

#### 11. Version History
```markdown
## Version History

- **1.0.0** (YYYY-MM-DD): Initial version with core workflow
- **1.1.0** (YYYY-MM-DD): Added garbage collection workflow
```

**Guidelines:**
- Always include for versions > 1.0.0
- Include date and brief change description
- Use semantic versioning

#### 12. See Also
```markdown
## See Also

- **other-skill** - Related skill description
- Documentation links
- External resources
```

**Use when:**
- Related skills exist
- External documentation helpful
- Cross-references aid understanding

## Skill Creation Workflow

### Phase 1: Conceptualize

**Goal**: Determine if a skill is needed and define its scope

#### 1. Identify the Need

Ask yourself:
- Have I done this workflow 3+ times?
- Is there a consistent pattern?
- Would others benefit from this?
- Does it take > 15 minutes to complete?

**Output**: Clear yes/no on whether to create the skill

#### 2. Define Scope

Determine:
- **Input**: What does the user start with?
- **Output**: What is produced?
- **Phases**: What are the major steps?
- **Complexity**: How many steps? How long?

**Output**: 1-paragraph scope statement

#### 3. Choose Skill Name

Guidelines:
- Use 1-3 words
- Action or domain focused
- Lowercase with hyphens (directory name)
- Title Case in YAML/heading

**Examples:**
- `code-review` → "Code Review"
- `refresh-docs` → "Documentation Refresh"
- `create-skill` → "Skill Creation"

**Output**: Confirmed skill name

### Phase 2: Structure

**Goal**: Create the skeleton before filling content

#### 1. Create Skill Directory

```bash
mkdir -p ~/.claude/skills/SKILL-NAME
```

#### 2. Create SKILL.md with Frontmatter

```bash
cat > ~/.claude/skills/SKILL-NAME/SKILL.md << 'EOF'
---
name: Skill Display Name
description: Brief description here
author: your-username
version: 1.0.0
tags: [tag1, tag2, tag3]
---

# Skill Display Name Skill

**Purpose**: [One sentence purpose]

## When to Use This Skill

Use this skill when:
- [Scenario 1]
- [Scenario 2]

## Complete Workflow

### Phase 1: [Name]

#### 1. [Step]

[Instructions]

---

## Version History

- **1.0.0** ($(date +%Y-%m-%d)): Initial version
EOF
```

**Output**: Basic skill structure in place

### Phase 3: Document Workflow

**Goal**: Fill in the complete workflow with detailed instructions

#### 1. Break into Phases

Guidelines:
- 3-7 phases is ideal
- Each phase should be cohesive
- Sequential order (Phase 1 → 2 → 3)
- Each phase has clear goal

**Pattern:**
```markdown
### Phase N: Phase Name

**Goal**: What this phase accomplishes

#### 1. Step Name

What to do and how to do it.

**Commands:**
```bash
example command
```

**Output**: What you should see
```

#### 2. Add Examples

For each phase or step where helpful:
- Show real commands
- Include actual output
- Demonstrate common variations
- Show error cases if relevant

#### 3. Include Templates

If the skill involves creating structured content:
- Provide complete template
- Use proper markdown formatting
- Include placeholder explanations
- Show filled example

**Output**: Complete workflow documentation

### Phase 4: Add Supporting Sections

**Goal**: Enhance skill with supporting content

#### 1. Add Core Principles (if applicable)

Document:
- Philosophical guidelines
- Quality standards
- Important trade-offs

#### 2. Add Checklist (if applicable)

Create checkbox list of:
- Critical steps
- Verification points
- Quality gates

#### 3. Add Red Flags (if applicable)

Document:
- When NOT to use skill
- Common misapplications
- Warning signs

#### 4. Add Best Practices (if applicable)

Include:
- Lessons learned
- Optimization tips
- Common patterns

**Output**: Well-rounded skill documentation

### Phase 5: Review & Refine

**Goal**: Ensure quality and usability

#### 1. Self-Review Checklist

- [ ] YAML frontmatter complete and valid
- [ ] Version is 1.0.0 for new skill
- [ ] Tags are relevant and specific (3-8 tags)
- [ ] Purpose is clear and concise (1-3 sentences)
- [ ] "When to Use" has 4+ specific scenarios
- [ ] Workflow has clear phases and steps
- [ ] Commands/examples are correct
- [ ] Markdown formatting is correct
- [ ] No typos or grammatical errors
- [ ] Version history included
- [ ] All sections properly nested (heading levels)

#### 2. Test the Skill

Actually use it:
- Follow your own instructions
- Find gaps or unclear steps
- Verify commands work
- Check output matches descriptions

**Iterate**: Fix any issues found

#### 3. Format Verification

Check:
- Consistent heading levels (H2 for major, H3 for phases, H4 for steps)
- Code blocks properly fenced
- Lists formatted consistently
- Line length reasonable (< 120 chars preferred)

**Output**: Polished, tested skill

### Phase 6: Deploy

**Goal**: Make skill available for use

#### 1. Verify File Location

```bash
ls -la ~/.claude/skills/SKILL-NAME/SKILL.md
```

Should show the file exists with correct name.

#### 2. Add to Git

```bash
cd ~/.claude/skills
git add SKILL-NAME/SKILL.md
git status  # Verify staged correctly
```

#### 3. Commit with Descriptive Message

```bash
git commit -m "$(cat <<'EOF'
Add SKILL-NAME skill v1.0.0

[Brief description of what the skill does]

Features:
- Feature 1
- Feature 2
- Feature 3

[Any additional context]

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Output**: Skill committed to version control

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
- Style guide adhered to

### Usability
- Can be followed by someone else
- Examples are realistic
- Commands are copy-pasteable
- Checklists aid execution

## Common Skill Patterns

### Workflow Skills
Focus on multi-phase processes with clear inputs/outputs.

**Examples:** code-review, refresh-docs, incremental-improvement

**Structure:**
- Clear phases (typically 3-7)
- Step-by-step instructions
- Commands and examples
- Quality checklists

### Reference Skills
Focus on providing templates and examples for specific formats.

**Structure:**
- Multiple templates
- Format specifications
- Real examples
- Usage guidelines

### Analysis Skills
Focus on evaluating and assessing states or conditions.

**Examples:** incremental-improvement

**Structure:**
- Assessment framework
- Evaluation criteria
- Scoring/ranking methods
- Decision guidelines

### Automation Skills
Focus on scripting and tool usage.

**Structure:**
- Tool setup
- Command patterns
- Configuration examples
- Troubleshooting guide

## Tags Reference

Choose from these common categories (mix 3-8):

**Process tags:**
- workflow
- automation
- analysis
- documentation
- maintenance
- verification

**Domain tags:**
- code-review
- security
- quality
- testing
- git
- repository-state

**Quality tags:**
- best-practices
- standards
- formatting
- consistency
- false-positives

**Meta tags:**
- meta
- skill-development
- templates
- framework

**Specific tags:**
- garbage-collection
- incremental-improvement
- [domain-specific terms]

## Templates

### Minimal Skill Template

```markdown
---
name: Skill Name
description: What this skill does in one sentence
author: username
version: 1.0.0
tags: [tag1, tag2, tag3]
---

# Skill Name Skill

**Purpose**: Clear purpose statement.

## When to Use This Skill

Use this skill when:
- Scenario 1
- Scenario 2
- Scenario 3

## Complete Workflow

### Phase 1: Phase Name

**Goal**: What this accomplishes

#### 1. Step Name

Instructions here.

```bash
command example
```

**Output**: Expected result

### Phase 2: Next Phase

[Continue pattern...]

## Version History

- **1.0.0** (YYYY-MM-DD): Initial version
```

### Full-Featured Skill Template

```markdown
---
name: Skill Name
description: What this skill does in one sentence
author: username
version: 1.0.0
tags: [tag1, tag2, tag3, tag4, tag5]
---

# Skill Name Skill

**Purpose**: Detailed purpose statement explaining what and why.

## When to Use This Skill

Use this skill when:
- Specific scenario 1
- Specific scenario 2
- Specific scenario 3
- Specific scenario 4

## Core Principles

**Principle name**: Description and rationale.

**Another principle**: Description and rationale.

## Complete Workflow

### Phase 1: Phase Name

**Goal**: What this phase accomplishes

#### 1. Step Name

Detailed instructions.

**Commands:**
```bash
command example
```

**Output**: What you should see

#### 2. Next Step

[Continue...]

### Phase 2: Next Phase

[Continue pattern...]

## Templates

### Template Name

```
Template content here
```

## Examples

### Example 1: Scenario Name

Concrete example showing real usage.

## Checklist

Use this checklist when applying the skill:

- [ ] Critical step 1
- [ ] Critical step 2
- [ ] Verification point

## Red Flags

**Avoid when:**
- Warning scenario 1
- Warning scenario 2

## Best Practices

1. **Practice name** - Description
2. **Another practice** - Description

## Version History

- **1.0.0** (YYYY-MM-DD): Initial version with core workflow

## See Also

- **related-skill** - Description
- External documentation links
```

## Checklist

Use this checklist when creating a new skill:

### Phase 1: Conceptualize
- [ ] Identified clear need (used 3+ times)
- [ ] Defined scope (input/output/phases)
- [ ] Chosen skill name (1-3 words, action-focused)

### Phase 2: Structure
- [ ] Created skill directory (`~/.claude/skills/SKILL-NAME/`)
- [ ] Created SKILL.md with frontmatter
- [ ] Added basic structure (heading, purpose, when-to-use)

### Phase 3: Document
- [ ] Workflow broken into 3-7 phases
- [ ] Each phase has clear goal
- [ ] Steps are actionable with examples
- [ ] Commands are correct and copy-pasteable
- [ ] Expected outputs documented

### Phase 4: Enhance
- [ ] Added Core Principles (if applicable)
- [ ] Added Checklist (if applicable)
- [ ] Added Examples (if helpful)
- [ ] Added Templates (if needed)
- [ ] Added Red Flags (if applicable)
- [ ] Added Best Practices (if applicable)

### Phase 5: Review
- [ ] YAML frontmatter valid
- [ ] 3-8 relevant tags chosen
- [ ] Version is 1.0.0
- [ ] No typos or errors
- [ ] Markdown formatting correct
- [ ] Tested by following instructions
- [ ] Version history included

### Phase 6: Deploy
- [ ] File in correct location
- [ ] Added to git
- [ ] Committed with descriptive message
- [ ] Verified skill is accessible

## Red Flags

**Avoid creating skills for:**
- ✗ Tasks done only once or twice
- ✗ Processes that change constantly
- ✗ Simple operations (< 3 steps)
- ✗ Tool usage better documented elsewhere
- ✗ Project-specific workflows (use project docs)

**Warning signs:**
- "This might be useful someday" - Not proven useful yet
- "Just in case" - No concrete use case
- "I'll use this for..." - Haven't actually used it
- Too generic - No specific guidance
- Too specific - Only works in one exact scenario

## Best Practices

1. **Write from experience** - Create skills after you've done the workflow multiple times
2. **Test before committing** - Follow your own instructions to find gaps
3. **Keep it focused** - One clear purpose, not multiple unrelated workflows
4. **Include examples** - Real examples > abstract instructions
5. **Version appropriately** - Start at 1.0.0, increment based on changes
6. **Tag thoughtfully** - Tags make skills discoverable
7. **Document iteratively** - Update as you learn better approaches
8. **Cross-reference** - Link to related skills in "See Also"

## Examples

### Example 1: Creating a Simple Skill

**Scenario**: You've formatted 5 code reviews and want to standardize the process.

**Process:**
1. **Conceptualize**: Identify the workflow (review → format → verify → commit)
2. **Name**: "code-review" skill
3. **Structure**: Create directory and basic SKILL.md
4. **Document**: Write 4 phases (Review, Format, Verify, Commit)
5. **Enhance**: Add checklist of quality standards, examples of good/bad reviews
6. **Review**: Follow the skill yourself on a new review
7. **Deploy**: Commit with descriptive message

**Result**: Reusable skill that ensures consistent quality

### Example 2: Creating a Complex Skill

**Scenario**: Documentation is often out of sync and needs systematic updating.

**Process:**
1. **Conceptualize**: Multi-phase workflow (Identify Changes → Update → Verify → Garbage Collect)
2. **Name**: "refresh-docs" skill
3. **Structure**: Create with frontmatter, purpose, phases
4. **Document**: 5 detailed phases with specific commands for each doc type
5. **Enhance**: Add Core Principles (single source of truth), templates, garbage collection guidelines
6. **Review**: Test on actual documentation update
7. **Deploy**: Commit as v1.0.0, later updated to v1.1.0 when garbage collection added

**Result**: Comprehensive skill preventing documentation drift

## Version History

- **1.0.0** (2026-04-13): Initial version based on creation of refresh-docs, incremental-improvement skills

## See Also

- **refresh-docs** - Example of well-structured documentation skill
- **incremental-improvement** - Example of analysis skill with frameworks
- **code-review** - Example of workflow skill with quality standards
- [Claude Code Skills Documentation](https://docs.claude.com/claude-code)

---

**Remember**: The best skill is one you actually use. If you create it but never reference it again, it's
documentation overhead, not a productivity tool.
