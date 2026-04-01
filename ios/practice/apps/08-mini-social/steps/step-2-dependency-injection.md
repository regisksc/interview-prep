# Step 2: Protocol-Based Dependency Injection

**Difficulty:** ★★★ Advanced

---

## Goal

Build a DI container that resolves protocol dependencies and supports swapping to mock implementations for previews and tests.

## When you're done

- [ ] A `DependencyContainer` (or similar) holds factory closures for each protocol
- [ ] The container is injected via SwiftUI's environment or passed through the view hierarchy
- [ ] ViewModels receive their dependencies from the container (not created inline)
- [ ] A `.mock` or `.preview` container variant wires all mock implementations
- [ ] SwiftUI previews use the mock container and render without network calls
- [ ] The production container wires real implementations

## Files to create/edit

- **Create** `App/DependencyContainer.swift`
- **Edit** app entry point to inject the container
- **Edit** ViewModels to accept injected dependencies

---

## LLM Review

Copy your `DependencyContainer.swift`, app entry point, and one ViewModel that uses injected dependencies plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

CONTAINER DESIGN
- The container holds references to protocol types (not concrete classes)
- Dependencies are created via factory closures or lazy properties
- A production configuration and a mock/preview configuration exist
- The container does not use Service Locator anti-pattern in ViewModels (no global .shared access inside VMs)

INJECTION MECHANISM
- The container (or individual dependencies) is injected via environment, init parameters, or @Environment
- ViewModels do NOT create their own dependencies internally
- Views can resolve ViewModels from the container

MOCK SUPPORT
- The mock container returns mock implementations for all protocols
- SwiftUI #Preview blocks use the mock container
- Mock data is realistic enough to verify layout

QUALITY
- No force-unwrapping when resolving dependencies
- The container is not a god object (keep it focused)
- Switching between production and mock requires changing one line (the container variant)
```
