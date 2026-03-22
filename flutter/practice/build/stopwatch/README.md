# Build: Stopwatch

**Guide:** `README.md` → Module 5 (Async & Streams)

## What to build

A stopwatch screen with Start / Pause / Resume / Reset controls. The elapsed time display updates once per second and is driven by a **reactive data source** — not a `setState` loop.

## Requirements

| Behaviour | Detail |
|-----------|--------|
| Display | `mm:ss`, updates every second while running |
| Start | Begins counting from 0 (or from the paused position after a reset) |
| Pause / Resume | Freezes the count; resuming continues from the last tick |
| Reset | Stops and returns to `00:00` |
| Cleanup | No console errors after navigating away from the screen |

## Constraints

- The display widget must **not** call `setState` to advance the clock — it should rebuild in response to a reactive data source
- All resources (streams, subscriptions, controllers) must be released in `dispose`

## Approach

Pick whatever mechanism you're most comfortable with, then try the others:

| Approach | Key APIs |
|----------|----------|
| Vanilla streams | `Stream.periodic`, `StreamController`, `StreamBuilder`, `StreamSubscription.pause/resume` |
| RxDart | `BehaviorSubject`, `interval`, `scan` |
| Riverpod | `StreamProvider`, `ref.watch` |

## How to run

```bash
cd starter
flutter pub get
flutter run -d chrome   # or any connected device
```
