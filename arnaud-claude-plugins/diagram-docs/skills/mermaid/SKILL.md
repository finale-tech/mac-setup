# Mermaid Diagram Validation Skill

## Prerequisites
```bash
npm install -g @mermaid-js/mermaid-cli
```

## Workflow

1. **Generate** the Mermaid code
   - Check `MERMAID_GUIDELINES.md` for common pitfalls
   - Save to `diagram.mmd`

2. **Validate and render**
   ```bash
   mmdc -i diagram.mmd -o diagram.png
   ```
   - If it fails, read the error and fix (max 2 retries)
   - If it succeeds, view the PNG to confirm it looks right

3. **Deliver** the final files

## Key Rules from Guidelines
- Escape quotes in labels: `["text with \"quotes\""]`
- Node IDs must start with letter, be alphanumeric
- Use `-->` not `->` for arrows
- Use `%%` for comments
- Declare sequence diagram participants explicitly
- No `@` symbols in flowchart node text (use `Retryable` not `@Retryable`)

If rendering fails repeatedly, simplify the diagram and add complexity incrementally.
