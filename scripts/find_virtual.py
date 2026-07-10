import pathlib
import sys
import bs4
import onlinejudge_command.utils as ojutils
from onlinejudge._implementation import utils as u

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

cookie = pathlib.Path.home() / "AppData/Local/online-judge-tools/online-judge-tools/cookie.jar"
out = pathlib.Path(r"d:\projects\atCoder\scripts\virtual_links.txt")

urls = [
    "https://atcoder.jp/contests/abc461/tasks/abc461_a",
    "https://atcoder.jp/home",
    "https://atcoder.jp/contests/abc461",
]

lines = []
with ojutils.new_session_with_our_user_agent(path=cookie) as sess:
    for url in urls:
        lines.append(f"\n=== {url} ===")
        resp = u.request("GET", url, session=sess)
        soup = bs4.BeautifulSoup(resp.content.decode(resp.encoding), u.HTML_PARSER)
        for a in soup.find_all("a", href=True):
            href = a["href"]
            text = a.get_text(" ", strip=True)
            if "/submit" in href or "virtual" in href.lower() or "Virtual" in text:
                lines.append(f"  {text[:60]} -> {href}")
        for form in soup.find_all("form"):
            action = form.get("action", "")
            if "virtual" in action.lower() or "submit" in action.lower():
                lines.append(f"  form -> {action}")

out.write_text("\n".join(lines), encoding="utf-8")
print(out.read_text(encoding="utf-8"))
