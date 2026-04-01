# Step 6: CSV Export via Share Sheet

**Read first:** [swiftui-advanced.md — UIViewControllerRepresentable](../../../../lessons/swiftui-advanced.md#uiviewcontrollerrepresentable)

**Difficulty:** ★★★ Advanced

---

## Goal

Export all expenses as a CSV file and present it via `UIActivityViewController` wrapped in `UIViewControllerRepresentable`. The user can share, save to Files, or AirDrop the export.

## When you're done

- [ ] A function generates a CSV string from the expenses array (header row + data rows)
- [ ] The CSV includes: date, category, amount, note
- [ ] The CSV is written to a temporary file URL
- [ ] `UIActivityViewController` is wrapped via `UIViewControllerRepresentable`
- [ ] Tapping "Export" presents the share sheet with the CSV file
- [ ] The share sheet shows relevant options (Files, AirDrop, Mail, etc.)

## Files to edit

- **Create** `Services/CSVExporter.swift`
- **Create** `Views/ShareSheet.swift`
- **Edit** `Views/DashboardView.swift` (add export button)

---

## LLM Review

Copy your `CSVExporter.swift`, `ShareSheet.swift`, and the view with the export button plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

CSV GENERATION
- A header row is included (e.g., "Date,Category,Amount,Note")
- Each expense produces one row with properly formatted fields
- Fields containing commas or special characters are quoted or escaped
- The date is formatted consistently (ISO 8601 or locale-appropriate)
- The amount uses a decimal representation (not a formatted currency string)

UIViewControllerRepresentable
- ShareSheet wraps UIActivityViewController
- makeUIViewController creates the controller with activityItems
- The file URL (not raw string) is passed as an activity item
- updateUIViewController is implemented (even if empty)

INTEGRATION
- An export button triggers CSV generation and presents the share sheet
- The temporary file is written to FileManager.default.temporaryDirectory
- The sheet is presented via .sheet modifier bound to a boolean

QUALITY
- The CSV file has a .csv extension
- Empty expense lists produce a valid CSV (header only, no crash)
- No UIKit imports in views other than ShareSheet
- The temporary file is cleaned up or overwritten on next export
```
