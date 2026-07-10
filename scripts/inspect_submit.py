import pathlib
import bs4
import onlinejudge_command.utils as ojutils
from onlinejudge._implementation import utils as u

cookie = pathlib.Path.home() / "AppData/Local/online-judge-tools/online-judge-tools/cookie.jar"
out = pathlib.Path(r"d:\projects\atCoder\scripts\submit_get.html")

with ojutils.new_session_with_our_user_agent(path=cookie) as sess:
    resp = u.request("GET", "https://atcoder.jp/contests/abc461/submit?taskScreenName=abc461_a", session=sess)
    out.write_bytes(resp.content)
    soup = bs4.BeautifulSoup(resp.content.decode(resp.encoding), u.HTML_PARSER)
    print("url:", resp.url)
    for alert in soup.select(".alert, [role=alert], .panel-warning, .panel-danger"):
        t = alert.get_text(" ", strip=True)
        if t:
            print("alert:", t[:200])
    form = soup.find("form", action="/contests/abc461/submit")
    if form:
        print("form fields:")
        for el in form.find_all(["input", "select", "textarea", "button"]):
            print(" ", el.name, el.get("name"), el.get("type"), (el.get("value") or el.get_text())[:100])
    else:
        print("NO SUBMIT FORM")
