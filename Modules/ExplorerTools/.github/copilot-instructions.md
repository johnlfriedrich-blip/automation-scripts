## Purpose

Short, actionable guidance for AI coding agents working on the ExplorerTools PowerShell module.
Target: make an agent productive quickly by surfacing the module's architecture, important files, conventions, and gotchas.

## Quick facts

- Primary files: `ExplorerTools.psm1` (implementation) and `ExplorerTools.psd1` (module manifest).
- Exports a single public function by design: `Get-ExplorerType` (see `FunctionsToExport` in the .psd1).
- The implementation relies on the Windows Shell COM object (`Shell.Application`) and the folder `GetDetailsOf` column indexes.

## Big picture / architecture

- This is a small PowerShell module that provides Explorer-style file metadata and sorting. There are no separate services or background processes — the module is a single script module loaded by PowerShell.
- Data flow: `Get-ExplorerType` → creates `Shell.Application` COM object → uses `Namespace()` and `GetDetailsOf()` to read Explorer columns → builds PSCustomObjects and returns a sorted collection.
- Why this shape: relying on `Shell.Application` yields Explorer-localized metadata (Type column, DateCreated, etc.) rather than pure filesystem attributes.

## Key files (where to look)

- `ExplorerTools.psm1` — implementation. Look here for parsing heuristics, column indexes (type=2, size=1, date=4), and defensive parsing of strings to numbers/dates.
- `ExplorerTools.psd1` — manifest. Contains RootModule, CompatiblePSEditions, ModuleVersion, and `FunctionsToExport`.

## Project-specific conventions & patterns

- Use explicit `Resolve-Path` for user-supplied paths before passing to the Shell COM object.
- `GetDetailsOf()` is used with numeric column indexes; these indexes are fragile (locale and OS dependent). If you change or add columns, search for numeric indexes in the .psm1.
- Parsing approach: size strings strip non-digits before parsing to Int64; date strings are parsed with `[datetime]::Parse` inside try/catch — follow that defensive style on new parsing code.
- Manifest exports are explicit for functions (`FunctionsToExport = 'Get-ExplorerType'`) but variables/aliases are currently `'*'`. Prefer explicit exports if you add new public items.

## Compatibility & integration notes (important)

- `Shell.Application` is a COM object available only on Windows Desktop PowerShell; while the manifest lists `CompatiblePSEditions = 'Core', 'Desktop'`, `Get-ExplorerType` will fail on non-Windows or PowerShell Core where the COM object is not present. Guard new features accordingly.
- `GetDetailsOf()` column numbers are localized: tests that rely on a specific column must run on representative Windows locales or use a more robust lookup strategy.

## Developer workflows (how to run, test, debug)

- Import module for manual testing:
  - Import-Module -Force <module-folder-path> or dot-source the .psm1 file.
  - Example usage: `Get-ExplorerType -Path 'C:\Scripts' -SortBy Type -Descending` (this is the canonical smoke test).
- Debugging: run in Windows PowerShell (Desktop). Manual checks:
  - `New-Object -ComObject Shell.Application` should succeed.
  - Call `Get-ExplorerType` on a small folder and inspect returned PSCustomObjects.
- Automated tests: there are no tests yet. Add Pester tests under a `Tests/` folder (suggested name: `Tests/ExplorerTools.Tests.ps1`) and run with `Invoke-Pester` in Windows PowerShell.

## Examples & snippets to reference

- Column access (in `ExplorerTools.psm1`):
  - Type: `$folder.GetDetailsOf($_, 2)`
  - DateCreated: `$folder.GetDetailsOf($_, 4)`
  - Size (raw): `$folder.GetDetailsOf($_, 1)`

## Do's and Don'ts (concrete)

- Do: Run parsing code inside try/catch as the module currently does (see size/date parsing). Keep PSCustomObject shape consistent (Name, Extension, Type, DateCreated, Size).
- Do: Keep `FunctionsToExport` explicit. If you add helpers, keep them private (do not add them to `FunctionsToExport`).
- Don't: Change `GetDetailsOf()` numeric indexes without adding a locale-aware test — those numbers vary by Windows language and Explorer configuration.
- Don't: Assume the module will run on Linux or macOS; it's Windows/Explorer-specific.

## Where to add new code / tests

- Implementation files: expand `ExplorerTools.psm1`. Prefer adding small helper functions near the top and keeping public surface to minimal exported functions.
- Tests: add Pester tests in `Tests/` and assert that `Get-ExplorerType` returns expected property names and types for a deterministic test folder.

## If you need more context

- The module author (metadata in `ExplorerTools.psd1`) is `John Friedrich` — ask the author for historical decisions about column indexes or localization testing if available.

---

If anything here is unclear, tell me which area to expand (examples, tests, or adding a Pester skeleton) and I will update the file.
