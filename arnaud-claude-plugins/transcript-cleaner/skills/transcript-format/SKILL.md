---
name: transcript-format
description: Use when cleaning, polishing, or formatting meeting transcripts, transcriptions, or raw speech-to-text output. Provides rules for transforming raw transcripts into clean, readable markdown.
version: 1.0.0
---

# Transcript Format Skill

This skill provides rules and guidelines for cleaning raw meeting transcripts into polished, readable markdown.

## When This Skill Applies

This skill activates when:
- Cleaning or polishing a transcript
- Formatting raw speech-to-text output
- Processing meeting notes or recordings
- Working with WhisperX or similar transcription output

## Core Principles

### 1. Concise Capture
Preserve speaker intent and meaning, not verbatim content. If someone says the same thing multiple ways, condense to the clearest expression. The goal is a readable record that captures what was communicated.

### 2. Clean and Preserve Intent
Remove filler words, fix grammar, AND condense redundancy while maintaining each speaker's communication style and meaning.

### 3. Add Visual Context
Note when speakers reference screen shares, documents, diagrams, or other visuals using italicized brackets: `*[Screen share - architecture diagram]*`

### 4. Rename Assets
Rename generic image files (img1.png, screenshot.png) to descriptive names that reflect their content (e.g., `spanner-schema-overview.png`).

### 5. NO Timestamps
Do not include timestamps in the output. They are error-prone and not essential for the document's value.

### 6. NO Speaker Renaming
Keep original speaker labels (Speaker 1, Speaker 2, etc.). The user will rename these manually after review.

## Cleaning Rules

### Remove These Filler Words
- uh, um, ah
- like (when used as filler, not comparison)
- you know, I mean
- sort of, kind of
- basically, actually, literally (when used as filler)
- right? (when used as filler/confirmation)

### Condense These Patterns
- Repetitive confirmations ("Right, right, right. Okay. Yeah.") → Single acknowledgment ("Right.")
- Multiple attempts at same thought → Clearest expression of the idea
- Redundant qualifiers and hedging → Remove while keeping meaning
- Wordy questions → Direct, clear questions

### Fix These Issues
- Run-on sentences → Break into shorter sentences
- Subject-verb disagreement → Correct
- Unclear pronoun references → Clarify if meaning is obvious
- Incomplete sentences → Complete if meaning is clear

### Preserve
- Technical terminology exactly as spoken
- Speaker's communication style (formal vs casual)
- Key details and nuances
- Questions and responses in order

## Condensation Examples

| Before | After |
|--------|-------|
| "That makes sense. That makes a lot of sense. Do you have by any chance maybe kind of like a visual of a table that I can just kind of look at to build this?" | "That makes sense. Do you have a sample table I could reference?" |
| "So basically what I'm saying is, kind of like, you know, we need to consider..." | "So we should consider..." |
| "Right, right, right. Okay. Yeah. So..." | "Right. So..." |
| "I guess what I'm wondering is the schema - not the schema, but like some form of schema." | "I'm wondering about the schema structure." |

## Asset Naming

Rename generic filenames to descriptive ones:

| Before | After |
|--------|-------|
| `img1.png` | `architecture-overview-diagram.png` |
| `img2.png` | `spanner-query-results.png` |
| `screenshot.png` | `bigquery-console-schema.png` |

## Output Structure

See `references/format-template.md` for the complete output format.

## Quality Checklist

Before finishing, verify:
- [ ] Speaker intent preserved (meaning, not verbatim words)
- [ ] Redundant phrasing condensed
- [ ] Speaker labels unchanged from original
- [ ] No timestamps added
- [ ] Visual context notes included where appropriate
- [ ] Image assets renamed to descriptive names
- [ ] Key Takeaways section captures decisions and actions
