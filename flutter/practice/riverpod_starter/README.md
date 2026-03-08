# Riverpod Practice — Notes App

Build a simple Notes app from scratch using **only Riverpod** for state.
No StatefulWidget, no setState, no external state libraries.

Run the app at any point with `flutter run` to see your progress.

---

## Step 1 — Note model

Create `lib/models/note.dart`.

Define an immutable `Note` class with:
- `id` (int)
- `title` (String)
- `body` (String)
- `isPinned` (bool, default false)
- A `copyWith` method
- `==` and `hashCode` overrides

---

## Step 2 — NotesNotifier

Create `lib/providers/notes_provider.dart`.

Implement `NotesNotifier extends Notifier<List<Note>>` with:
- `add(String title, String body)`
- `delete(int id)`
- `togglePin(int id)`

Expose it as `notesProvider = NotifierProvider<NotesNotifier, List<Note>>`.

Sanity check: pre-populate a couple of notes in `build()` and verify they
appear when you `ref.watch(notesProvider)` inside a `ConsumerWidget`.

---

## Step 3 — Notes list screen

Create `lib/screens/notes_screen.dart` as a `ConsumerWidget`.

- Watch `notesProvider` and render a `ListView.builder`
- Each tile shows the title and a pin icon (filled when pinned)
- `FloatingActionButton` opens a dialog or new screen to add a note
- Tapping the pin icon calls `togglePin`
- Long-press (or a delete icon) calls `delete`

---

## Step 4 — Derived provider

Add `filteredNotesProvider = Provider<List<Note>>` that:
- Watches `notesProvider`
- Returns pinned notes first, then the rest sorted alphabetically by title

Replace `notesProvider` with `filteredNotesProvider` in the list screen.
Confirm pinned notes automatically float to the top when you pin one.

---

## Step 5 — Search

Add `searchQueryProvider = StateProvider<String>((ref) => '')`.

Update `filteredNotesProvider` to also watch `searchQueryProvider` and exclude
notes whose title and body both do not contain the query (case-insensitive).

Add a `TextField` in the `AppBar` that writes to `searchQueryProvider` via
`ref.read(searchQueryProvider.notifier).state = value` in `onChanged`.

---

## Step 6 — Async sync

Simulate loading initial notes from a remote source.

Create `syncProvider = FutureProvider<void>((ref) async { ... })` that:
- Waits 1.5 s (simulating a network call)
- Calls `ref.read(notesProvider.notifier).add(...)` with a couple of
  "server notes"

In the UI, `ref.watch(syncProvider)` and show:
- A `CircularProgressIndicator` while loading
- An error banner if it fails
- Nothing extra on success

---

## Bonus — autoDispose + keepAlive

Mark `syncProvider` as `.autoDispose`. Add a "Re-sync" button that calls
`ref.invalidate(syncProvider)`. Watch the provider dispose after it completes
and restart fresh on the next invalidation.

---

## What you should be able to explain after finishing

- Why `ref.watch` belongs in `build()` and `ref.read` in callbacks
- Why emitting `state = [...state, item]` instead of mutating `state.add(item)`
- The difference between `Provider`, `StateProvider`, `NotifierProvider`,
  and `FutureProvider` — when to reach for each one
- What `autoDispose` does and when to pair it with `ref.keepAlive()`
- How derived providers let you compose logic without duplicating it
