# Mermaid Common Pitfalls

## The Big 5 (Most Common Errors)

### 1. Quotes in Labels
**Wrong:** `A["Text with "quotes""]`  
**Right:** `A["Text with \"quotes\""]`

### 2. Node IDs
**Wrong:** `1Start` or `my-node` or `node.id`  
**Right:** `Start` or `MyNode` or `node_id`  
Rule: Start with letter, alphanumeric only

### 3. Arrow Syntax
**Wrong:** `A -> B`  
**Right:** `A --> B`  
Options: `-->` `==>` `-.->` for solid/thick/dotted

### 4. Sequence Diagrams
**Wrong:**
```
sequenceDiagram
    User -> System: Request
```

**Right:**
```
sequenceDiagram
    participant User
    participant System
    User->>System: Request
```
Rule: Declare participants, use `->>` not `->`

### 5. Subgraph Names
**Wrong:** `subgraph My Subgraph`  
**Right:** `subgraph MySubgraph["My Subgraph"]`  
Rule: Subgraph ID must be one word

## Quick Reference

**Comments:** Use `%%` not `//` or `#`

**Diagram types:** `flowchart`, `sequenceDiagram`, `classDiagram`, `erDiagram`, `stateDiagram-v2`

**Special chars in flowcharts:** No `@` symbols in node text - use `Retryable` not `@Retryable`

**Class relationships:**
- `<|--` inheritance
- `*--` composition  
- `o--` aggregation
- `-->` association

**ER cardinality:** `||--o{` (one to many), `}o--o{` (many to many)

## When Stuck

1. Remove all styling, test basic structure
2. Check error message for line number
3. Verify node IDs are valid
4. Check quotes are escaped
5. Simplify and add back incrementally
