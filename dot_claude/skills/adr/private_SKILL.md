---
name: adr
description: "Architecture Decision Record (user)"
---

# Architecture Decision Record (ADR)

Record architectural decisions following ADR best practices. Use this skill when documenting software design choices, technology selections, or significant technical decisions that affect the system architecture.

## When to Use

- New technology or framework adoption
- Significant design pattern changes
- Infrastructure decisions
- API design choices
- Database schema decisions
- Security architecture choices

## Output Location

Save ADRs in the `docs/adr/` directory with the naming convention:
```
NNNN-title-with-dashes.md
```

Where `NNNN` is a sequential number (e.g., `0001`, `0002`).

## ADR Template

Use the following MADR (Markdown Any Decision Record) template:

```markdown
# [ADR-NNNN] Title

## Status

[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

## Date

YYYY-MM-DD

## Context

Describe the background, requirements, and constraints that led to this decision.
- What is the issue we're facing?
- What are the forces at play (technical, political, social, project)?

## Decision

State the architectural decision that was made.

## Considered Options

### Option 1: [Name]

**Pros:**
- Pro 1
- Pro 2

**Cons:**
- Con 1
- Con 2

### Option 2: [Name]

**Pros:**
- Pro 1
- Pro 2

**Cons:**
- Con 1
- Con 2

## Decision Outcome

Explain why this option was chosen over the alternatives.

### Positive Consequences

- Consequence 1
- Consequence 2

### Negative Consequences

- Risk 1
- Risk 2

## Related Decisions

- [ADR-XXXX](./XXXX-related-decision.md)

## References

- [Link to relevant documentation]
- [External resources]
```

## Best Practices

1. **One decision per ADR**: Keep each ADR focused on a single architectural decision
2. **Immutability**: Once accepted, ADRs should not be modified. Create a new ADR to supersede
3. **Context matters**: Provide enough background for future readers to understand the decision
4. **Record alternatives**: Document rejected options to prevent revisiting them without new information
5. **Link dependencies**: Reference related ADRs and external documentation
6. **Review regularly**: Schedule monthly reviews to validate decisions against actual practice

## Status Lifecycle

```
Proposed -> Accepted -> [Deprecated | Superseded by ADR-XXXX]
         -> Rejected
```

## References

- [ADR GitHub Organization](https://adr.github.io/)
- [MADR Template](https://adr.github.io/madr/)
- [Michael Nygard's Original Article](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [AWS ADR Best Practices](https://aws.amazon.com/blogs/architecture/master-architecture-decision-records-adrs-best-practices-for-effective-decision-making/)