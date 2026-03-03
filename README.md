# WSGFlagCaller

A WoW 1.12 / Turtle WoW addon perfectly designed for Warsong Gulch. It tracks flag carriers, features a clean click-to-focus HUD, and calls out Enemy Flag Carrier health milestones in standard Battleground chat. Complete with smart anti-spam healing hysteresis.

## Setup

1. Copy the `WSGFlagCaller` folder exactly as it is into `C:\Games\turtlewow\Interface\AddOns\`
2. When you start the game, make sure to click "AddOns" in the bottom-left corner and ensure WSGFlagCaller is enabled.

## Features

- **Fully Event-Driven:** It only initializes within Warsong Gulch. Once you leave, the addon shuts down all loops and hooks, using zero CPU when not needed.
- **HUD Frame:** A movable transparent box lets you precisely track both friendly and enemy flag carriers. Clicking a row targets and attempts to focus them.
- **Auto-Announcements:** Pickups, drops, captures, and returns are properly alerted in `/bg`.
- **Health Phase Callouts:** When the Enemy Carrier falls to 75%, 50%, or 25% HP, an alert is automatically sent safely to your team.
- **Anti-Spam & Hysteresis:** Callouts lock themselves to prevent spam. If the FC is being repeatedly healed through the 50% border, the callout won't endlessly reactivate unless they are solidly healed back up 10% higher than the threshold.
- **SuperWoW Integration:** If you run the SuperWoW launcher mod, WSGFlagCaller optionally leverages SuperWoW's GUID Unit lookup to read enemy HP even when you don't have them permanently targeted.

## Commands

Type `/wfc info` in the game to pull up the full control list.

- `/wfc flag pickup on|off`
- `/wfc flag drop on|off`
- `/wfc flag capture on|off`
- `/wfc flag return on|off`
- `/wfc hp on|off`
- `/wfc thresholds 75 50 25`
- `/wfc frame on|off`
- `/wfc minimap on|off`
- `/wfc reset` (Resets UI window position)
- `/wfc status`
