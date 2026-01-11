---
name: tdd
description: "Kent Beck's Test-Driven Development methodology and Tidy First principles (user)"
---

# Test-Driven Development (TDD)

Kent Beck's Test-Driven Development methodology and Tidy First principles for writing clean, maintainable, well-tested code.

## When to Use

- Implementing new features with test-first approach
- Refactoring existing code while maintaining behavior
- Reviewing code for TDD compliance
- Fixing bugs with regression tests
- Learning TDD best practices

## Core Principles

### 1. TDD Cycle (Red-Green-Refactor)

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│    ┌───────┐      ┌───────┐      ┌──────────┐      │
│    │  RED  │ ──▶  │ GREEN │ ──▶  │ REFACTOR │      │
│    └───────┘      └───────┘      └──────────┘      │
│        ▲                              │            │
│        └──────────────────────────────┘            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

1. **Red**: Write a failing test first
   - Test should fail for the right reason
   - Test defines expected behavior
   - Keep tests small and focused

2. **Green**: Write minimal code to pass
   - Only enough code to make the test pass
   - Don't add extra functionality
   - It's okay if the code is ugly

3. **Refactor**: Improve code quality
   - Clean up while tests are green
   - Remove duplication
   - Improve naming and structure
   - Run tests after each change

### 2. Tidy First Philosophy

Clean code before changing behavior:

```
Tidy (structure) → Change (behavior) → Commit separately
```

**Small, safe refactorings first:**
- Extract variable/method
- Inline variable/method
- Move code closer to where it's used
- Rename for clarity

**Boy Scout Rule:** Leave code cleaner than you found it.

### 3. Test Quality (FIRST)

| Principle | Description |
|-----------|-------------|
| **F**ast | Tests run quickly |
| **I**ndependent | No dependencies between tests |
| **R**epeatable | Same result every time |
| **S**elf-validating | Pass or fail, no manual checking |
| **T**imely | Written before or with production code |

## Workflow

### New Feature Implementation

1. Understand the requirements
2. Write a failing test for smallest increment
3. Write just enough code to pass
4. Refactor to improve design
5. Repeat until feature complete

### Bug Fix (Defect-Driven TDD)

1. Write a failing test that reproduces the bug
2. Optionally write a minimal unit test
3. Fix the bug to make both tests pass
4. Refactor if needed

### Code Review for TDD

- Check test coverage and quality
- Identify missing tests
- Look for tidy opportunities
- Suggest improvements following TDD/Tidy First

## Test Naming

Use descriptive names explaining behavior:

```
Good:
- shouldReturnEmptyListWhenNoItemsExist
- shouldThrowExceptionWhenInputIsNull
- shouldCalculateTotalWithDiscount

Bad:
- test1
- testFunction
- itWorks
```

## Test Structure (Arrange-Act-Assert)

```python
def test_should_add_item_to_cart():
    # Arrange - Set up preconditions
    cart = ShoppingCart()
    item = Item("Book", 29.99)

    # Act - Execute the behavior
    cart.add(item)

    # Assert - Verify the outcome
    assert cart.item_count == 1
    assert cart.total == 29.99
```

## Refactoring Patterns

### When to Refactor

- Duplication exists (DRY violation)
- Names are unclear
- Methods are too long
- Classes have too many responsibilities
- Tests are hard to write

### Safe Refactoring Steps

1. Ensure tests pass (green)
2. Make one small change
3. Run tests
4. Commit if green
5. Repeat

### Common Refactorings

| Refactoring | When to Use |
|-------------|-------------|
| Extract Method | Long method, reusable logic |
| Extract Variable | Complex expression |
| Inline | Unnecessary indirection |
| Rename | Unclear naming |
| Move | Wrong location |
| Extract Class | Too many responsibilities |

## Commit Discipline

**Separate structural and behavioral changes:**

```
# Good - Separate commits
commit: "Refactor: Extract calculateDiscount method"
commit: "Feature: Add bulk discount calculation"

# Bad - Mixed in one commit
commit: "Add discount and refactor"
```

**Commit only when:**
- All tests pass
- No compiler/linter warnings
- Single logical unit of work

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Test After | Missing edge cases | Write test first |
| Big Steps | Hard to debug failures | Smaller increments |
| Testing Implementation | Brittle tests | Test behavior |
| Skipping Refactor | Technical debt | Always refactor |
| God Tests | Slow, fragile | One assertion per test |

## References

- [Test-Driven Development by Example](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530) - Kent Beck
- [Tidy First?](https://www.amazon.com/Tidy-First-Personal-Exercise-Empirical/dp/1098151240) - Kent Beck
- [Refactoring](https://refactoring.com/) - Martin Fowler
