# Step 2: Currency Formatter via Custom EnvironmentKey

**Difficulty:** ★★★ Advanced

---

## Goal

Create a custom `EnvironmentKey` that provides a currency `NumberFormatter` configured for the user's locale. All expense amounts in the app read from this environment value instead of creating formatters inline.

## When you're done

- [ ] A custom `EnvironmentKey` struct defines a default `NumberFormatter` (currency style, current locale)
- [ ] An extension on `EnvironmentValues` exposes a `currencyFormatter` property
- [ ] The formatter is injected at the app root via `.environment(\.currencyFormatter, ...)`
- [ ] All views displaying monetary amounts read `@Environment(\.currencyFormatter)` instead of creating their own
- [ ] Changing the locale at the root updates all displayed amounts

## Files to edit

- **Create** `Environment/CurrencyFormatterKey.swift`
- **Edit** all views that display monetary amounts

## Hints

<details>
<summary>Hint — formatter as environment value</summary>
<code>NumberFormatter</code> is a reference type. Your <code>EnvironmentKey.defaultValue</code> can be a pre-configured instance. Make sure the formatter's <code>numberStyle</code> is <code>.currency</code> and <code>locale</code> matches <code>Locale.current</code>.
</details>

---

## LLM Review

Copy your `CurrencyFormatterKey.swift` and one view that uses it plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

ENVIRONMENT KEY
- A struct conforms to EnvironmentKey with a defaultValue of NumberFormatter
- The default formatter has numberStyle = .currency
- An extension on EnvironmentValues exposes a computed get/set property
- The key name is descriptive (e.g., currencyFormatter)

USAGE
- Views read the formatter via @Environment(\.currencyFormatter)
- No views create their own NumberFormatter inline for currency
- The formatter is used to format Decimal or Double amounts into display strings

INJECTION
- The formatter is injected at a high level (.environment on the root or WindowGroup)
- Changing the injected formatter updates all child views

QUALITY
- NumberFormatter is not recreated on every view render
- The formatter handles edge cases (negative amounts, zero, large numbers)
- No hardcoded currency symbols ($ or €)
```
