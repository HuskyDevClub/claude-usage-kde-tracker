#!/usr/bin/env python3
"""
KDE Wallet helper for Claude Usage Tracker.
Reads/writes OAuth tokens from KDE Wallet via kwallet-query.
"""

import json
import subprocess
import sys

WALLET = "kdewallet"
FOLDER = "claude-usage-tracker"
ENTRY = "oauth-token"


def run_kwallet_query(
    args: list[str], stdin_data: str | None = None
) -> tuple[int, str, str]:
    """Run kwallet-query with the given arguments."""
    cmd = ["kwallet-query", *args]
    try:
        result = subprocess.run(
            cmd,
            input=stdin_data,
            capture_output=True,
            text=True,
            timeout=10,
        )
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except FileNotFoundError:
        return 1, "", "kwallet-query not found. Install kwalletmanager."
    except subprocess.TimeoutExpired:
        return 1, "", "kwallet-query timed out"


def read_token() -> None:
    """Read OAuth token from KDE Wallet."""
    returncode, stdout, stderr = run_kwallet_query(["-r", ENTRY, "-f", FOLDER, WALLET])
    if returncode == 0 and stdout:
        print(json.dumps({"status": "ok", "token": stdout}))
    else:
        error = stderr if stderr else "Entry not found in wallet"
        print(json.dumps({"status": "error", "error": error}))
        sys.exit(1)


def write_token() -> None:
    """Write OAuth token to KDE Wallet from stdin."""
    token = sys.stdin.read().strip()
    if not token:
        print(json.dumps({"status": "error", "error": "No token provided on stdin"}))
        sys.exit(1)

    returncode, stdout, stderr = run_kwallet_query(
        ["-w", ENTRY, "-f", FOLDER, WALLET],
        stdin_data=token,
    )
    if returncode == 0:
        print(json.dumps({"status": "ok"}))
    else:
        error = stderr if stderr else "Failed to write to wallet"
        print(json.dumps({"status": "error", "error": error}))
        sys.exit(1)


def check_entry() -> None:
    """Check if OAuth token entry exists in KDE Wallet."""
    returncode, stdout, stderr = run_kwallet_query(["-l", "-f", FOLDER, WALLET])
    if returncode == 0 and ENTRY in stdout.splitlines():
        print(json.dumps({"status": "ok", "exists": True}))
    else:
        print(json.dumps({"status": "ok", "exists": False}))


def main() -> None:
    if len(sys.argv) < 2:
        print(
            json.dumps(
                {
                    "status": "error",
                    "error": "Usage: kwallet_helper.py <read|write|check>",
                }
            )
        )
        sys.exit(1)

    action = sys.argv[1]
    if action == "read":
        read_token()
    elif action == "write":
        write_token()
    elif action == "check":
        check_entry()
    else:
        print(json.dumps({"status": "error", "error": f"Unknown action: {action}"}))
        sys.exit(1)


if __name__ == "__main__":
    main()
