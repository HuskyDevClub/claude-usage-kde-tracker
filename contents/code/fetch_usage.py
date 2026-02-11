#!/usr/bin/env python3
"""
Claude Usage Fetcher
Fetches usage data from Claude API using Claude Code CLI OAuth credentials.
Supports reading credentials from a file or KDE Wallet.
"""

import argparse
import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Any

try:
    import requests
except ImportError:
    print(
        json.dumps(
            {
                "error": "Python 'requests' module not installed. Run: pip install requests"
            }
        )
    )
    sys.exit(1)

OAUTH_USAGE_URL = "https://api.anthropic.com/api/oauth/usage"
CREDENTIALS_PATH = Path.home() / ".claude" / ".credentials.json"
CACHE_DIR = Path.home() / ".local" / "share" / "claude-usage-tracker"


def load_credentials_from_file() -> tuple[str | None, str | None]:
    """Load OAuth credentials from the Claude Code CLI credentials file.

    Returns:
        Tuple of (access_token, subscription_type) or (None, None) on failure.
    """
    if not CREDENTIALS_PATH.exists():
        return None, None

    try:
        with open(CREDENTIALS_PATH, "r") as f:
            data = json.load(f)

        oauth_data = data.get("claudeAiOauth", {})
        token = oauth_data.get("accessToken")
        subscription_type = oauth_data.get("subscriptionType", "unknown")

        if not token:
            return None, None

        # Check if the token is expired
        expires_at = oauth_data.get("expiresAt")
        if expires_at:
            # expiresAt is in milliseconds
            if isinstance(expires_at, (int, float)):
                if expires_at > 1e12:  # milliseconds
                    expires_at = expires_at / 1000
                if datetime.fromtimestamp(expires_at) < datetime.now():
                    return None, None

        return token, subscription_type
    except (json.JSONDecodeError, IOError, OSError):
        return None, None


def load_credentials_from_kwallet() -> tuple[str | None, str | None]:
    """Load OAuth token from KDE Wallet via kwallet_helper.py.

    Returns:
        Tuple of (access_token, subscription_type) or (None, None) on failure.
    """
    helper_path = Path(__file__).parent / "kwallet_helper.py"
    try:
        result = subprocess.run(
            [sys.executable, str(helper_path), "read"],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode == 0:
            data = json.loads(result.stdout)
            if data.get("status") == "ok" and data.get("token"):
                return data["token"], "unknown"
    except (
        subprocess.TimeoutExpired,
        json.JSONDecodeError,
        FileNotFoundError,
        OSError,
    ):
        pass
    return None, None


def create_empty_result() -> dict[str, Any]:
    """Create an empty result structure."""
    return {
        "session": {"used": 0, "limit": 100},
        "weekly": {"used": 0, "limit": 100},
        "sonnet": {"used": 0, "limit": 100},
        "opus": {"used": 0, "limit": 100},
        "subscriptionType": "unknown",
        "lastUpdated": datetime.now().strftime("%H:%M:%S"),
        "error": None,
    }


def parse_usage_item(data: dict, api_key: str) -> dict[str, Any]:
    """Parse a single usage item from the API response."""
    item = data.get(api_key)
    if not item or not isinstance(item, dict):
        return {"used": 0, "limit": 100}

    result: dict[str, Any] = {
        "used": item.get("utilization", 0),
        "limit": 100,
    }
    if item.get("resets_at"):
        result["resetsAt"] = item["resets_at"]
    return result


def fetch_usage(credential_source: str = "file") -> dict[str, Any]:
    """Fetch current usage data from Claude OAuth API."""
    result = create_empty_result()

    # Load credentials
    if credential_source == "kwallet":
        token, subscription_type = load_credentials_from_kwallet()
        if not token:
            result["error"] = (
                "No token in KDE Wallet. Store one via kwallet_helper.py write"
            )
            return result
    else:
        token, subscription_type = load_credentials_from_file()
        if not token:
            result["error"] = "No credentials found. Run: claude login"
            return result

    result["subscriptionType"] = subscription_type or "unknown"

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "anthropic-beta": "oauth-2025-04-20",
        "Accept": "application/json",
    }

    try:
        response = requests.get(OAUTH_USAGE_URL, headers=headers, timeout=15)

        if response.status_code == 401:
            result["error"] = "Session expired. Run: claude login"
            return result
        if response.status_code == 403:
            result["error"] = "Access denied. Check your subscription."
            return result
        if response.status_code != 200:
            result["error"] = f"API error: {response.status_code}"
            return result

        data = response.json()

        result["session"] = parse_usage_item(data, "five_hour")
        result["weekly"] = parse_usage_item(data, "seven_day")
        result["sonnet"] = parse_usage_item(data, "seven_day_sonnet")
        result["opus"] = parse_usage_item(data, "seven_day_opus")

        # Extra usage (paid overage)
        extra = data.get("extra_usage")
        if extra and isinstance(extra, dict) and extra.get("is_enabled"):
            result["extra"] = {
                "used": extra.get("used_credits", 0),
                "limit": extra.get("monthly_limit", 0),
                "utilization": extra.get("utilization", 0),
            }

    except requests.exceptions.Timeout:
        result["error"] = "Request timeout"
    except requests.exceptions.ConnectionError:
        result["error"] = "Connection error"
    except requests.exceptions.RequestException as e:
        result["error"] = f"Request failed: {e}"
    except json.JSONDecodeError:
        result["error"] = "Invalid API response"

    return result


def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch Claude API usage data")
    parser.add_argument(
        "--credential-source",
        choices=["file", "kwallet"],
        default="file",
        help="Where to read OAuth credentials from",
    )
    args = parser.parse_args()

    usage = fetch_usage(args.credential_source)

    # Cache result
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    cache_file = CACHE_DIR / "usage.json"
    try:
        with open(cache_file, "w") as f:
            json.dump(usage, f, indent=2)
    except OSError:
        pass  # Caching is best-effort

    # Output to stdout for DataSource
    print(json.dumps(usage))


if __name__ == "__main__":
    main()
