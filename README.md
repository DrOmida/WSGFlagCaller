# WSGFlagCaller v2

A WoW 1.12 / Turtle WoW addon perfectly designed for Warsong Gulch. It tracks flag carriers, features a clean click-to-focus HUD, calculates precise 3D distance to the carriers, and calls out Enemy Flag Carrier health milestones in standard Battleground chat. Complete with smart anti-spam healing hysteresis.

## Requirements

The addon functions completely standalone, however, installing the following two optional mods unlocks the full potential of WSGFlagCaller v2:

| Mod | Why it's amazing in WSGFlagCaller | Where to get it |
|---|---|---|
| **Nampower** | Unlocks GUID-tracking. The addon will instantly know if the flag carrier dies without needing you to have them targeted. Enables reading exact HP from anywhere in the Battleground securely. | [Download Nampower v3+](https://gitea.com/avitasia/nampower/releases) |
| **UnitXP** | Unlocks precise 3D distance rendering. Shows the exact yard distance to the flag carriers dynamically on the HUD. | Turtle WoW Discord / Mods |
| Spy | **Not Required**. WSGFlagCaller has its own lightweight internal GUID engine. | - |

## Features

- **Standalone Tracker Engine:** The addon actively harvests `target`, `mouseover`, and Nampower event GUIDs into a tiny, zero-overhead memory footprint to track exactly who is holding the flag without relying on the clunky vanilla `UnitExists("name")` hack.
- **HUD Frame with Distance:** A movable transparent box lets you precisely track both friendly and enemy flag carriers. If UnitXP is installed, the exact distance in yards to the carrier will continually update in red/yellow/white depending on proximity.
- **Server-Authoritative Death Engine:** If Nampower is installed, the addon listens directly to the server's `UNIT_DIED` packet to instantly override and reset the HUD to "Nobody". It purposefully ignores `UnitIsDead` which is notoriously broken by Feign Death. 
- **Health Phase Callouts:** When the Enemy Carrier falls to 75%, 50%, or 25% HP, an alert is automatically sent safely to your team.
- **Anti-Spam & Hysteresis:** Callouts lock themselves to prevent spam. If the FC is being repeatedly healed through the 50% border, the callout won't endlessly reactivate unless they are solidly healed back up 10% higher than the threshold.

## Commands
Type `/wfc info` in the game to pull up the full control list.

- `/wfc hp on/off`
- `/wfc thresholds 75 50 25`
- `/wfc frame on/off`
- `/wfc reset` (Resets UI window position)
- `/wfc debug on/off`
- `/wfc status` Shows current system status and explicitly verifies if Nampower and UnitXP dependencies are active.
