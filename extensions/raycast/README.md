# Pomo

Control **Pomo**, a minimal and elegant Pomodoro timer for macOS, directly from Raycast.

![Pomo Screenshot](media/screenshot-main.jpeg)

## Install Pomo (Required)

This extension controls the **Pomo** macOS app. If you don’t have it installed yet:

1. Download the latest DMG: [**Pomo.dmg**](https://github.com/claudfuen/Pomo/releases/latest/download/Pomo.dmg)
2. Open the DMG and **drag Pomo to your Applications folder**
3. Launch Pomo once (it appears in the **menu bar**)
4. Run the Raycast commands again

![Pomo Menu Bar](media/screenshot-menubar.jpeg)

## Commands

- **Start 5/10/15/25/45 Minutes**: Start a timer with a specific duration
- **Toggle Timer**: Start / pause / resume based on current state
- **Pause Timer**: Pause the running timer
- **Reset Timer**: Reset the timer to the idle state

## Troubleshooting

### “Pomo App Not Found”

If Raycast says Pomo isn’t installed:

- Make sure Pomo is in **`/Applications`** (not inside the DMG)
- Launch Pomo at least once so macOS registers it
- Try quitting and reopening Raycast
