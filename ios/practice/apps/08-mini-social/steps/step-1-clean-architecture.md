# Step 1: Clean Architecture Layers

**Read first:** [README — Module 4 (Architecture & Project Structure)](../../../../README.md#module-4-architecture--project-structure)

**Difficulty:** ★★★ Advanced

---

## Goal

Structure the app into three layers — Presentation, Domain, and Data — with protocols defining boundaries between them. No layer may import a layer above it.

## When you're done

- [ ] Three folder groups exist: `Presentation/`, `Domain/`, `Data/`
- [ ] Domain defines protocols (e.g., `PostRepository`, `UserRepository`) with no UIKit/SwiftUI imports
- [ ] Data contains concrete implementations of those protocols (mock API clients, JSON stubs)
- [ ] Presentation contains Views and ViewModels that depend only on Domain protocols
- [ ] ViewModels reference repository protocols, never concrete data classes
- [ ] The project compiles with mock implementations wired through

## Files to create

- `Domain/Models/Post.swift`, `Domain/Models/User.swift`
- `Domain/Repositories/PostRepository.swift` (protocol)
- `Data/Repositories/RemotePostRepository.swift` (concrete)
- `Data/Repositories/MockPostRepository.swift` (mock)
- `Presentation/ViewModels/FeedViewModel.swift`
- `Presentation/Views/FeedView.swift`

---

## LLM Review

Copy your folder structure listing, one Domain protocol, one Data implementation, and one ViewModel plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

LAYER SEPARATION
- Domain/ contains only models and protocols — no SwiftUI or UIKit imports
- Data/ implements Domain protocols — may import Foundation/networking but not SwiftUI
- Presentation/ contains Views and ViewModels — imports SwiftUI and Domain (not Data directly)
- No circular dependencies between layers

PROTOCOL BOUNDARIES
- Repository protocols are defined in Domain/
- Concrete implementations in Data/ conform to those protocols
- ViewModels accept protocols via init, not concrete types
- Mock implementations exist for testing/preview

DEPENDENCY DIRECTION
- Presentation depends on Domain (protocols)
- Data depends on Domain (protocols to conform to)
- Domain depends on nothing (pure Swift)

QUALITY
- Models are value types (structs) conforming to Identifiable and Codable
- No singleton access to repositories in ViewModels (injection instead)
- The project compiles and a preview works with mock data
```
