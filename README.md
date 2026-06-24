# SnapshotTracker

A World of Warcraft addon for **WotLK 3.3.5** (Interface 30300) that tracks snapshot strength for various spells.

---

## Features

- **Snapshot tracking** – tracks spec-specific damage-window buffs via the combat log for advanced display
- **Minimal GUI** - create and configure snapshot trackers for specific spells.
- **Custom Anchoring** - attach snapshot frames to any other frame in the UI (WeakAuras style).
- **Custom Frame Names** - define global names for frames to allow dynamic interaction or complex anchoring.

---

## Installation

1. Download or clone this repository.
2. Place the `SnapshotTracker` folder inside your WoW `Interface/AddOns/` directory.
3. Restart WoW or reload your UI (`/reload`).

The folder must be named exactly `SnapshotTracker`.

---

## Slash Commands

| Command | Effect |
|---|---|
| `/sst` | Open the settings panel |

---

## Usage

### Opening Settings

Type `/sst` in chat to open the settings panel. From here you can:

- Create and delete snapshot trackers.
- Configure tracked spells.
- Set background color, frame size, and font size.
- Anchor frames to other UI elements.
- Give frames a global name.

---

## Saved Variables

Settings are stored in `SnapshotTrackerDB` (WTF folder).
