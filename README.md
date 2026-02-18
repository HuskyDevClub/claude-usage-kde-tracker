# Claude Usage Tracker

A KDE Plasma 6 widget that displays your Claude AI usage limits and quotas directly in your panel.

## Preview

![Preview](screenshots/preview.png)

## Features

- **Panel donut chart** showing current session utilization at a glance
- **Session (5-hour) and weekly (7-day) usage bars** with reset time countdowns
- **Per-model breakdown** for Sonnet and Opus utilization
- **Extra usage tracking** for paid overage credits
- **Daily usage bar chart** for recent usage history
- **Configurable auto-refresh** interval
- **Auto-login** via Claude Code CLI credentials
- **Pin popup** to keep the detail view open

## Requirements

- KDE Plasma 6
- Python 3 with the `requests` module (`pip install requests`)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (run `claude login` to set up credentials)

## Installation

Just copy and paste this single line into your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/HuskyDevClub/claude-usage-kde-tracker/main/install-remote.sh | bash
```

Then right-click your panel, select **Add Widgets**, and search for **Claude**.

To upgrade, run the same command again.

## Uninstallation

```bash
curl -fsSL https://raw.githubusercontent.com/HuskyDevClub/claude-usage-kde-tracker/main/uninstall.sh | bash
```

## Configuration

Right-click the widget and select **Configure** to adjust:

| Setting | Default | Description |
|---|---|---|
| Refresh interval | 1 min | How often to fetch fresh data from the API (1-60 min) |
| Show extra usage | On | Show paid overage section |
| Show recent usage | Off | Show daily usage bar chart |

## How it works

The widget calls the Anthropic OAuth usage API (`/api/oauth/usage`) using credentials from Claude Code CLI. A Python script ([fetch_usage.py](contents/code/fetch_usage.py)) handles authentication and API communication, while the QML frontend renders the data as interactive progress bars and charts.

Usage data is cached locally at `~/.local/share/claude-usage-tracker/usage.json` so the widget can display stale data instantly while a fresh fetch runs in the background.

## Contributing

Contributions are welcome! Whether it's bug reports, feature requests, or pull requests — every bit helps make this the best Claude usage tracker for KDE Plasma.

Here are some ways you can help:

- **Report bugs** — Open an [issue](https://github.com/HuskyDevClub/claude-usage-kde-tracker/issues) if something isn't working right
- **Suggest features** — Have an idea for a useful addition? Let us know
- **Submit pull requests** — Code improvements, UI tweaks, and documentation fixes are all appreciated
- **Share feedback** — Let us know how you use the widget and what could be better

If you'd like to contribute code, fork the repo, create a branch, and open a PR. There are no strict contribution guidelines — just keep changes focused and test before submitting.

## License

GPL-3.0
