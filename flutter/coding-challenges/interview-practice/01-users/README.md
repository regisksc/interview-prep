# Challenge 01: Users List

## Description

A simple app that fetches users from an API and displays them in a list. Each user has: name, email, phone, company name, city.

**API:** `https://jsonplaceholder.typicode.com/users`

### Key Classes

- `main.dart` — a single file with everything crammed in: networking, model, UI, formatting.

## Goal

Refactor the code to make it testable and scalable. Separate concerns into proper layers.

### Tasks

1. **Refactor** — Extract into layers: Model, Repository (with abstract class), ViewModel/Controller, UI Widgets. Add tests for the repository.

2. **Algorithm** — After fetching, group users by company name and sort groups alphabetically. Display as grouped sections. The `groupByCompany()` function currently returns empty.

3. **Feature** — Add a search bar that filters users by name or email in real time.

### Discussion

- Why use an abstract class for the repository?
- How would you handle offline caching?
- What state management would you choose for a larger app and why?
