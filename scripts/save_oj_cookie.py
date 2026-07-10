#!/usr/bin/env python3
"""Save AtCoder REVEL_SESSION into oj cookie.jar (Windows-friendly, no aclogin)."""

from __future__ import annotations

import argparse
import http.cookiejar
import sys
import time
from http.cookiejar import Cookie
from pathlib import Path

try:
    import appdirs
except ImportError:
    appdirs = None


def default_cookie_path() -> Path:
    if appdirs is not None:
        return Path(appdirs.user_data_dir("online-judge-tools")) / "cookie.jar"
    local = Path.home() / "AppData" / "Local" / "online-judge-tools" / "online-judge-tools" / "cookie.jar"
    return local


def save_session(cookie_value: str, cookie_path: Path) -> None:
    cookie_value = cookie_value.strip().strip('"').strip("'")
    if not cookie_value:
        raise ValueError("REVEL_SESSION is empty")

    cookie_path.parent.mkdir(parents=True, exist_ok=True)
    cookie_jar = http.cookiejar.LWPCookieJar(str(cookie_path))

    if cookie_path.exists():
        try:
            cookie_jar.load(ignore_discard=True)
        except Exception:
            pass

    now = int(time.time())
    two_years_later = now + 60 * 60 * 24 * 365 * 2

    cookie = Cookie(
        version=0,
        name="REVEL_SESSION",
        value=cookie_value,
        port=None,
        port_specified=False,
        domain="atcoder.jp",
        domain_specified=True,
        domain_initial_dot=False,
        path="/",
        path_specified=True,
        secure=True,
        expires=two_years_later,
        discard=False,
        comment=None,
        comment_url=None,
        rest={"HttpOnly": None},
        rfc2109=False,
    )
    cookie_jar.set_cookie(cookie)
    cookie_jar.save(ignore_discard=True)


def main() -> int:
    parser = argparse.ArgumentParser(description="Save REVEL_SESSION for oj")
    parser.add_argument("cookie_value", nargs="?", help="REVEL_SESSION value")
    parser.add_argument(
        "--cookie-path",
        type=Path,
        default=None,
        help="Path to oj cookie.jar",
    )
    args = parser.parse_args()

    cookie_path = args.cookie_path or default_cookie_path()
    value = args.cookie_value
    if value is None:
        value = sys.stdin.read()

    save_session(value, cookie_path)
    print(f"Saved REVEL_SESSION to {cookie_path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)
