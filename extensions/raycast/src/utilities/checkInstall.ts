import { getApplications, showToast, Toast, open } from "@raycast/api";

const POMO_BUNDLE_ID = "com.pomo.app";
const POMO_DOWNLOAD_URL = "https://github.com/claudfuen/Pomo/releases/latest";

async function isPomoInstalled(): Promise<boolean> {
  const installedApps = await getApplications();
  return installedApps.some((app) => app.bundleId === POMO_BUNDLE_ID);
}

export async function checkPomoInstallation(): Promise<boolean> {
  const isInstalled = await isPomoInstalled();

  if (!isInstalled) {
    const options: Toast.Options = {
      style: Toast.Style.Failure,
      title: "Pomo is not installed",
      message: "Download it from GitHub",
      primaryAction: {
        title: "Download Pomo",
        onAction: (toast) => {
          open(POMO_DOWNLOAD_URL);
          toast.hide();
        },
      },
    };
    await showToast(options);
  }

  return isInstalled;
}

