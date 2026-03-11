# Exercise 6: Map Safe Get with Default

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods, Generics

---

## Challenge

Create an extension on `Map<K, V>` that safely gets a value with a default fallback.

## Requirements

1. Create an extension on `Map<K, V>` (generic key and value)
2. Implement a method `getOr(K key, V defaultValue)`
3. Return the value if key exists, otherwise return the default
4. Similar to null-coalescing but for map lookups

## Examples

```dart
{'a': 1}.getOr('a', 0)     // 1
{'a': 1}.getOr('b', 0)     // 0
{}.getOr('x', 'def')       // 'def'
{'name': 'John'}.getOr('name', 'Unknown')  // 'John'
{'name': 'John'}.getOr('age', 0)           // 0
```

## Hints

<details>
<summary>Hint 1: containsKey</summary>
Use `containsKey()` to check if the key exists.
</details>

<details>
<summary>Hint 2: Alternative</summary>
You can also use the `[]` operator and check for null.
</details>

<details>
<summary>Hint 3: One-liner</summary>
This can be solved with a ternary or null-coalescing operator.
</details>

## Starter Code

See `main.dart` - implement the `getOr(K key, V defaultValue)` method.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
