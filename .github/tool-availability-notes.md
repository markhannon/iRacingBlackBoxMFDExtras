# Tool Availability Notes

Updated: 2026-04-14

## Not Available

- `rg` (ripgrep) is not available in the PowerShell terminal environment on this machine.
  - Symptom: `The term 'rg' is not recognized as the name of a cmdlet...`
  - Fallback used: `Select-String` for line-numbered searches.

## Limited Scope

- VS Code workspace search tools (for example `grep_search`) only search within the active workspace folder.
  - Paths outside the workspace (for example sibling app folders under `apps/lua`) are not searchable with workspace-only search calls.
  - Fallback used: terminal-based `Select-String` from the target folder.
