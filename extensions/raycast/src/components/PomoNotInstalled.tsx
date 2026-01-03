import { Detail, ActionPanel, Action } from "@raycast/api";

export default function PomoNotInstalled() {
  const markdown = `
# Pomo is not installed

Pomo is a simple, beautiful Pomodoro timer for macOS. To use this extension, you need to have the Pomo app installed.

![Pomo Icon](../assets/extension-icon.png)

[Download Pomo from GitHub](https://github.com/claudfuen/Pomo/releases)
  `;

  return (
    <Detail
      markdown={markdown}
      actions={
        <ActionPanel>
          <Action.OpenInBrowser
            title="Download Pomo"
            url="https://github.com/claudfuen/Pomo/releases/latest"
          />
        </ActionPanel>
      }
    />
  );
}

