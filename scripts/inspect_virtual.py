import pathlib
import bs4
import onlinejudge_command.utils as ojutils
from onlinejudge._implementation import utils as u

cookie = pathlib.Path.home() / "AppData/Local/online-judge-tools/online-judge-tools/cookie.jar"
out = pathlib.Path(r"d:\projects\atCoder\scripts\virtual_page.html")

with ojutils.new_session_with_our_user_agent(path=cookie) as sess:
    resp = u.request("GET", "https://atcoder.jp/contests/abc461/virtual", session=sess)
    out.write_bytes(resp.content)
    soup = bs4.BeautifulSoup(resp.content.decode(resp.encoding), u.HTML_PARSER)
    print("url:", resp.url)
    for form in soup.find_all("form"):
        print("form action:", form.get("action"))
        for inp in form.find_all(["input", "button", "select"]):
            print(" ", inp.name, inp.get("name"), inp.get("type"), inp.get("value", "")[:80])
