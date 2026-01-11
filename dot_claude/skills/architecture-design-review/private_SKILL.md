---
name: architecture-design-review
description: "Architecture design review guidance (user)"
---

# Architecture Design Review

Guidance for reviewing code architecture and design patterns, ensuring adherence to SOLID principles, layered architecture, and clean architecture patterns.

## Core Responsibilities

### 1. Code Architecture Analysis

Examine the overall structure, module organization, and dependencies of provided code.

### 2. SOLID Compliance Evaluation

Systematically check each principle:

- **Single Responsibility Principle (SRP)**: Each class/module should have only one reason to change
- **Open/Closed Principle (OCP)**: Code should be open for extension but closed for modification
- **Liskov Substitution Principle (LSP)**: Derived classes must be substitutable for their base classes
- **Interface Segregation Principle (ISP)**: Clients should not depend on interfaces they don't use
- **Dependency Inversion Principle (DIP)**: Depend on abstractions, not concretions

### 3. Architecture Pattern Evaluation

Evaluate against:

- **Layered Architecture**: Clear separation of presentation, business logic, and data layers
- **Clean Architecture**: Dependencies point inward, business logic independent of frameworks
- **Hexagonal Architecture**: Core domain logic isolated from external concerns
- **Domain-Driven Design**: Check for proper bounded contexts and aggregates where applicable

### 4. Design Issue Identification

Look for:

- Tight coupling between components
- Missing abstractions or over-engineering
- Violations of separation of concerns
- Improper dependencies between layers
- Code smells indicating architecture problems
- Missing or misplaced business logic

### 5. Providing Specific Improvements

For each identified issue:

- Explain why it's a problem from an architecture perspective
- Provide specific refactoring suggestions with code examples
- Suggest appropriate design patterns (Factory, Repository, Strategy, etc.)
- Show before/after comparisons when helpful
- Prioritize improvements by impact and effort

## Analysis Methodology

1. Start with a high-level structure overview
2. Deep dive into specific architectural concerns
3. Focus on the most impactful issues first
4. Provide practical, implementable solutions
5. Consider existing codebase context and constraints

## Output Format

- Start with a concise architecture assessment summary
- List issues grouped by violated SOLID principle or architecture pattern
- For each issue: Problem → Impact → Solution → Example
- Conclude with a prioritized action plan

## Design Patterns Reference

### Creational Patterns
- **Factory**: Create objects without specifying exact class
- **Builder**: Construct complex objects step by step
- **Singleton**: Ensure single instance (use sparingly)

### Structural Patterns
- **Adapter**: Make incompatible interfaces work together
- **Facade**: Provide simplified interface to complex subsystem
- **Decorator**: Add responsibilities dynamically

### Behavioral Patterns
- **Strategy**: Define family of interchangeable algorithms
- **Observer**: Notify dependents of state changes
- **Command**: Encapsulate requests as objects

## Code Smells to Watch

- God Class / Large Class
- Feature Envy
- Shotgun Surgery
- Divergent Change
- Primitive Obsession
- Long Parameter List
- Data Clumps
- Inappropriate Intimacy

## Guidelines

- Focus on recently changed or added code unless explicitly requested otherwise
- Balance ideal architecture with practical constraints
- Suggest incremental improvements that can be implemented gradually
- Consider testability and maintainability in all recommendations