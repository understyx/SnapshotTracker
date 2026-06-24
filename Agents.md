# SnapshotTracker – Coding Agent Instructions

SnapshotTracker is a World of Warcraft addon targeting **WotLK 3.3.5** (Interface version 30300). It focuses exclusively on tracking periodic damage snapshot strength.

## Project Overview

```text
SnapshotTracker/
├── SnapshotTracker.toc              # Addon manifest; defines load order
├── SnapshotTracker.lua              # Core controller (lifecycle, events, slash commands)
├── Core/
│   └── UpdateEngine.lua             # 100ms update loop for trackers
├── Display/
│   └── SnapshotFrame.lua            # Tracker display frame implementation
├── Libraries/                       # Vendored dependencies (Ace3, LibSharedMedia-3.0, etc.)
├── Settings/
│   └── Options.lua                  # AceConfig-3.0 options table
└── Tracking/
    ├── SnapshotCalc.lua             # Pure math logic for damage/crit modifiers
    ├── SnapshotData.lua             # Static data tables (set bonuses, talents, etc.)
    └── SnapshotTracker.lua          # State management and CLEU event processing
```

## Module Pattern

All modules follow the `ns.SnapshotTracker.ModuleName` pattern:

```lua
local _, ns = ...
ns.SnapshotTracker = ns.SnapshotTracker or {}
local MyModule = {}
ns.SnapshotTracker.MyModule = MyModule
```

The main controller (`SnapshotTracker.lua`) creates the Ace3 addon object and stores it as `ns.SnapshotTracker.Controller`.

## WotLK 3.3.5 Compatibility

SnapshotTracker MUST remain compatible with the 3.3.5 client.

- Use `SetTexture("Interface\\Buttons\\WHITE8X8")` and `SetVertexColor` for solid colors.
- Use frame pooling for UI elements to avoid leaks.
- Avoid modern APIs (e.g., `C_Timer`, `C_Aura`) without appropriate fallbacks or library support.
