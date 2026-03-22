# State Management: Picking the Right Tool

Six options, one codebase, one job to do. This is the map for choosing between them.

---

## The landscape

| | MobX | GetX | Provider + ValueNotifier | Riverpod | Bloc / Cubit | RxDart |
|---|---|---|---|---|---|---|
| **Mental model** | Observable graph | Magic controller | InheritedWidget + listener | Global provider registry | Event → State machine | Reactive stream pipeline |
| **Context required** | No | No | Yes | No | No | No |
| **Async state built-in** | Reactions | No | No | `AsyncValue<T>` | Manual | Operators |
| **DI built-in** | No | Yes (`Get.find`) | Partial | Yes | No | No |
| **Compile safety** | Medium | Low | Low | High | High | Medium |
| **Testability** | Good | Poor | Moderate | Excellent | Excellent | Good |
| **Boilerplate** | Low (codegen) | Very low | Low | Low–Medium | Medium–High | Medium |
| **Learning curve** | Medium | Low | Low | Medium | Medium–High | High |
| **Flutter team endorsed** | No | No | Yes (deprecated) | Yes | Yes | No |

---

## Each tool in depth

### MobX

MobX is an **observable graph**: you annotate fields with `@observable`, actions with `@action`, and computed values with `@computed`. The framework automatically tracks which widgets accessed which observables and surgically re-renders only them.

```dart
import 'package:mobx/mobx.dart';
part 'counter.g.dart';

class Counter = _Counter with _$Counter;

abstract class _Counter with Store {
  @observable
  int value = 0;

  @action
  void increment() => value++;

  @computed
  bool get isEven => value % 2 == 0;
}
```

**Pros**
- Minimal boilerplate once codegen is wired up — just annotate and use
- Fine-grained reactivity: only the exact observables that changed trigger rebuilds
- Computed values (`@computed`) are cached and lazy — no manual selector logic
- Familiar to React MobX developers

**Cons**
- Requires build_runner (`flutter pub run build_runner watch`) — adds toolchain friction
- Generated `.g.dart` files clutter the repo and cause confusing merge conflicts
- `ObservableList`, `ObservableMap` — you must use MobX-specific collection types for reactivity; plain `List` mutations are invisible
- Mutable state shared globally is harder to reason about in large teams
- Sparse Flutter ecosystem; less community activity than Riverpod/Bloc

**Excels at**
- **Data-heavy UIs with many interdependencies** — dashboards, forms with cascading derived values, spreadsheet-like views. MobX's computed graph beats writing manual `select`/`where` chains.
- **React Native → Flutter migrations** — teams already fluent in MobX.js transition with minimal conceptual friction.

---

### GetX

GetX is an **all-in-one** package: state management, routing, DI, localization, and utilities in a single import. State is held in `GetxController`; reactive variables are declared with `.obs`; widgets rebuild via `Obx`.

```dart
class CartController extends GetxController {
  final items = <Item>[].obs;
  final total = 0.0.obs;

  void add(Item item) {
    items.add(item);
    total.value += item.price;
  }
}

// Anywhere in the app:
final cart = Get.find<CartController>();

// In a widget:
Obx(() => Text('${cart.items.length} items — \$${cart.total}'))
```

**Pros**
- Near-zero boilerplate — fastest path from idea to working UI
- All-in-one: swap Provider + Navigator + get_it for one package
- `Get.to()`, `Get.back()`, `Get.snackbar()` — convenient and terse
- Good for rapid prototypes or solo projects

**Cons**
- **No `BuildContext` discipline** trains developers to bypass Flutter's widget tree contract — produces bugs that are hard to diagnose
- `Get.find<T>()` is global mutable state with no compile-time guarantee — crash at runtime if the controller isn't registered yet
- Test isolation is difficult: controllers live in a global registry, not a scoped container
- Poor separation of concerns — routing, state, and DI all tangled in the same call
- Flutter team and community at large discourage it in production codebases; it fights framework conventions rather than working with them
- Maintenance has historically been inconsistent

**Excels at**
- **Hackathons and throwaway prototypes** where speed of initial delivery matters more than maintainability.
- **Solo freelance projects** where one developer owns everything and a lean dependency footprint is enough.

GetX does not have a production use case where Riverpod + go_router would not be a better choice given a week more of setup time.

---

### Provider + ValueNotifier

`Provider` wraps `InheritedWidget` with ergonomics. `ValueNotifier<T>` is Flutter's built-in lightweight observable scalar. Together they cover a wide range of cases with zero extra dependencies.

```dart
// ValueNotifier for local reactive state
final _count = ValueNotifier<int>(0);

ValueListenableBuilder<int>(
  valueListenable: _count,
  builder: (_, value, __) => Text('$value'),
);

// Provider for scoped dependency injection
ChangeNotifierProvider(
  create: (_) => CartModel(),
  child: const CartScreen(),
);

// Reading from tree
context.watch<CartModel>().items
context.read<CartModel>().add(item)
```

**Pros**
- Zero extra dependencies for `ValueNotifier` — ships with Flutter
- `Provider` is the gateway drug — once understood, Riverpod is a short step
- `ChangeNotifier` + `Provider` is still the most-referenced pattern in the official Flutter docs and beginner tutorials
- `ValueNotifier` is ideal for truly local state that would be overkill for a full state management package

**Cons**
- Requires `BuildContext` everywhere — can't read providers from repositories or services
- `ProviderNotFoundException` is a runtime error, not a compile error
- No built-in `AsyncValue` — loading/error/data states are manual
- `ChangeNotifier` is mutable shared state; `notifyListeners()` is an implicit broadcast that rebuilds everything watching
- `ProxyProvider` for combining providers is verbose and error-prone
- Riverpod was written specifically to fix these problems — there is no reason to start new projects with `Provider`

**Excels at**
- **`ValueNotifier` for isolated widget-level state**: a password visibility toggle, an expandable card, a local form step counter. No package, no boilerplate, no global footprint.
- **Legacy codebases already on Provider** where a migration to Riverpod is not yet justified.
- **Teaching** — the context-based DI model is the foundation; understanding it makes Riverpod and InheritedWidget obvious.

---

### Riverpod

Riverpod replaces `InheritedWidget` with a global registry of compile-time constants. Providers are declared at the top level; `ref` gives access anywhere without `BuildContext`.

```dart
// Providers are top-level constants — no context needed
final cartProvider = NotifierProvider<CartNotifier, List<Item>>(CartNotifier.new);
final totalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, item) => sum + item.price);
});

class CartNotifier extends Notifier<List<Item>> {
  @override
  List<Item> build() => [];

  void add(Item item) => state = [...state, item];
}

// In a widget, service, or test — same API:
ref.watch(cartProvider);
ref.read(cartProvider.notifier).add(item);

// Testing — no widget tree needed:
final container = ProviderContainer(overrides: [
  apiProvider.overrideWithValue(FakeApi()),
]);
```

**Pros**
- No `BuildContext` needed in business logic
- `AsyncValue<T>` handles loading/error/data without a single `if`
- Compile-time safety: missing providers are caught before runtime
- `autoDispose` and `family` make scoped, parameterised state first-class
- Also acts as a DI container — replaces `get_it` for most apps
- `ProviderContainer` enables pure Dart unit tests without pumping a widget

**Cons**
- Two notifier styles coexist in the ecosystem: old `StateNotifier` and modern `Notifier` — tutorials conflict
- `ref.watch` vs `ref.read` vs `ref.listen` confusion trips up developers until the mental model clicks
- No built-in event log — state transitions are opaque unless you add a custom `ProviderObserver`
- `family` parameters must implement `==` and `hashCode` — easy to miss for custom objects

**Excels at**
- **Standard production Flutter apps** at any team size. The combination of DI + async state + compile safety + testability with no framework fighting is the unbeatable default.
- **Feature state with async loading and mutations**: `AsyncNotifierProvider` makes the loading/error/data lifecycle trivial.
- **Cross-cutting services** (auth, analytics, feature flags) exposed as providers consumed by any layer, tested in isolation.

---

### Bloc / Cubit

Bloc models state as an explicit event-driven machine: events arrive, handlers produce new states, and the UI reacts. Cubit simplifies this by replacing events with method calls; use Cubit by default, escalate to Bloc when you need event transformers or a full audit trail.

```dart
// Cubit — method-based, no events
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      emit(AuthSuccess(await _repo.login(email, password)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}

// Bloc — event-based, event transformers available
on<SearchRequested>(_onSearch, transformer: restartable()); // switchMap semantics
```

**Pros**
- Every state transition is a first-class, named, serialisable object — perfect for logging, analytics, and crash reporting
- `sealed` state classes give exhaustive `switch` — the compiler fails the build if a state is unhandled
- `bloc_test` makes state sequence assertions trivial
- `EventTransformer` (`restartable`, `droppable`, `sequential`) handles debounce/cancel at the Bloc level — UI stays clean
- Enforces strict separation: UI dispatches events and renders states, nothing else

**Cons**
- More boilerplate than Riverpod for equivalent functionality — each feature needs an event file, a state file, and a bloc file
- No built-in DI — still needs `get_it` or `Riverpod` to inject repositories
- `emit` after `await` when a Bloc is closed crashes unless you guard with `!isClosed` or use `Emitter.forEach`
- Overkill for simple state that Cubit or Riverpod would handle in five lines

**Excels at**
- **Auditable, regulated flows** — payments, authentication, medical records, financial transactions. Being able to replay every event that led to a state is not optional in these contexts.
- **Large teams with clear UI/logic boundaries** — the event/state contract makes code review and ownership clear; a UI developer cannot accidentally put business logic in a widget.
- **Complex async orchestration** — `restartable()` is the cleanest way to implement search-as-you-type cancellation without leaking futures.

---

### RxDart

RxDart extends Dart's native `Stream` with ReactiveX operators and Subject types. It is not a state management solution — it is a **stream composition toolkit** that feeds into state management layers.

```dart
// The canonical search pipeline
final _query = BehaviorSubject<String>.seeded('');

late final Stream<List<Result>?> _results = _query.stream
    .distinct()
    .debounceTime(const Duration(milliseconds: 300))
    .switchMap((q) => q.isEmpty
        ? Stream.value(null)
        : Stream.fromFuture(api.search(q)));

// Feed into Riverpod:
final searchResultsProvider = StreamProvider.autoDispose<List<Result>?>((ref) {
  return _querySubject.stream.distinct().debounceTime(...).switchMap(...);
});

// Or into Bloc as an event transformer:
on<SearchRequested>(_onSearch, transformer: restartable());
```

**Pros**
- `switchMap` eliminates stale-result races that `Future`-based code gets wrong by default
- `debounceTime` + `distinct` as pure stream operators keep UI code clean
- `BehaviorSubject` exposes the current value synchronously — no `AsyncValue` dance for simple cases
- `combineLatest`, `zip`, `scan` compose multi-source async logic elegantly
- Works with any state layer — Riverpod `StreamProvider`, Bloc event streams, raw `StreamBuilder`

**Cons**
- Not standalone state management — requires pairing with something else
- Streams must be closed in `dispose`; subjects left open cause `setState after dispose` errors
- Pipeline order matters (`distinct` before `debounceTime`, not after) — silent bugs if misplaced
- `flatMap` vs `switchMap` confusion is a common, hard-to-diagnose production bug
- Higher learning curve than any of the above — requires understanding Rx semantics before it pays off

**Excels at**
- **Search-as-you-type** with debounce, deduplication, and stale-result cancellation — the canonical use case.
- **Multi-source derived streams** — combining auth state + feature flags + user preferences into one computed stream with `combineLatest`.
- **Event pipelines inside Bloc** — `restartable()` in `bloc_concurrency` is essentially `switchMap` applied to the event stream; understanding one helps with the other.
- **Real-time data** — WebSocket messages, sensor streams, live collaborative editing — where you need operator-level control over what reaches the UI.

---

## How to pick

```
Is this purely local widget state (toggle, animation trigger, focus)?
  → setState or ValueNotifier. No package needed.

Is this a throwaway prototype or hackathon?
  → GetX if speed is all that matters. Expect to rewrite.

Are you starting a greenfield app?
  → Riverpod. Always.

Is your team already on Provider?
  → Migrate to Riverpod incrementally. The API is intentionally similar.

Do you need a full audit trail of every state transition (payments, auth, compliance)?
  → Bloc on top of Riverpod (Riverpod for DI, Bloc for the auditable features).

Do you have complex UI with many derived, interdependent values?
  → Consider MobX. The computed graph beats manual selector chains.

Do you have real-time streams, search-as-you-type, or multi-source composition?
  → Add RxDart on top of your state layer. It is a complement, not a replacement.
```

---

## The honest summary

**Riverpod is the default.** It solves compile safety, async state, DI, and testability in one coherent system. Every other tool has either a narrower use case or a worse trade-off profile for general production use.

**Bloc is additive, not competing.** Use it when Cubit's method-call simplicity is insufficient — specifically when you need event transformers or a serialisable event log. Pair it with Riverpod for DI.

**RxDart fills a gap neither covers.** Stream composition operators are not the job of a state manager. RxDart belongs in the pipeline, feeding into Riverpod or Bloc.

**MobX is a valid alternative**, not a mistake — but the code-generation dependency and mutable graph model make it a harder sell in team settings where Riverpod exists.

**Provider is legacy.** There is no new project justification. It is the ancestor, not the peer.

**GetX is a liability.** The ergonomics are real. The maintenance, testability, and architectural debt are also real.
