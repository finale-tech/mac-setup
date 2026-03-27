---
description: Polish a raw transcript into clean, readable markdown
argument-hint: <transcript-path> [output-path]
---

# Clean Transcript

Clean the raw transcript at `$1` into polished, readable markdown.

## Instructions

1. Read the raw transcript file at the provided path
2. Check for images/screenshots in the same folder or assets subfolder
3. Apply the transcript-format skill rules to clean the content
4. Rename any generic image files to descriptive names
5. Write the cleaned transcript to the output path (if provided) or `[original-name]_cleaned.md`

## What to Do

- Remove filler words (uh, um, like, you know)
- Condense redundant phrasing while preserving speaker intent
- Fix grammar while preserving each speaker's communication style
- Add paragraph breaks for readability
- Note visual references with `*[Screen share - topic]*`
- Rename image assets to descriptive names (e.g., `img1.png` → `architecture-diagram.png`)
- Generate Key Takeaways section at the end

## What NOT to Do

- Do NOT add timestamps
- Do NOT rename speakers (keep Speaker 1, Speaker 2, etc.)
- Do NOT over-summarize - keep conversation flow, just express it concisely

## Condensation Examples

| Before | After |
|--------|-------|
| "That makes sense. That makes a lot of sense. Do you have by any chance maybe kind of like a visual..." | "That makes sense. Do you have a sample table I could reference?" |
| "Right, right, right. Okay. Yeah. So..." | "Right. So..." |

## Output

Write the cleaned transcript following this structure:

```markdown
# Meeting Transcript

**Date**: [From context]
**Participants**: Speaker 1, Speaker 2, ...

---

## Transcript

**Speaker 1**: [Cleaned, concise content...]

---

## Key Takeaways

### Decisions Made
- ...

### Agreements
- ...

### Action Items
- [ ] ...
```

Now clean the transcript at: $ARGUMENTS
