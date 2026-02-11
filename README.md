# Claude Usage Tracker

A KDE Plasma 6 widget that displays your Claude AI usage limits and quotas directly in your panel.

## Features

- **Panel donut chart** showing current session utilization at a glance
- **Session (5-hour) and weekly (7-day) usage bars** with reset time countdowns
- **Per-model breakdown** for Sonnet and Opus utilization
- **Extra usage tracking** for paid overage credits
- **Daily usage bar chart** for recent usage history
- **Configurable auto-refresh** and cache duration
- **Credential support** for both Claude Code CLI credentials file and KDE Wallet
- **Pin popup** to keep the detail view open

## Requirements

- KDE Plasma 6
- Python 3 with the `requests` module (`pip install requests`)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (run `claude login` to set up credentials)

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/yudonglin/claude-usage-kde-tracker/main/install-remote.sh | bash
```

Then right-click your panel, select **Add Widgets**, and search for **Claude**.

To upgrade, run the same command again.

## Uninstallation

```bash
./uninstall.sh
```

## Configuration

Right-click the widget and select **Configure** to adjust:

| Setting | Default | Description |
|---|---|---|
| Cache duration | 60s | How long to cache API responses before fetching fresh data (30-600s) |
| Auto-refresh | 10 min | Background refresh interval; set to 0 to disable (0-60 min) |
| Credential source | File | Read tokens from `~/.claude/.credentials.json` or KDE Wallet |

### KDE Wallet setup

To use KDE Wallet instead of the credentials file:

```bash
# Store your OAuth token in KDE Wallet
echo "YOUR_TOKEN" | python3 contents/code/kwallet_helper.py write
```

Then switch the credential source to **KDE Wallet** in the widget settings.

## How it works

The widget calls the Anthropic OAuth usage API (`/api/oauth/usage`) using credentials from Claude Code CLI. A Python script ([fetch_usage.py](contents/code/fetch_usage.py)) handles authentication and API communication, while the QML frontend renders the data as interactive progress bars and charts.

Usage data is cached locally at `~/.local/share/claude-usage-tracker/usage.json` so the widget can display stale data instantly while a fresh fetch runs in the background.

## License

GPL-3.0
