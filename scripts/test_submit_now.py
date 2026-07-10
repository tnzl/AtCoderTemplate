import pathlib
import bs4
import onlinejudge_command.utils as ojutils
from onlinejudge._implementation import utils as u

cookie = pathlib.Path.home() / "AppData/Local/online-judge-tools/online-judge-tools/cookie.jar"
code = open(r"d:\projects\atCoder\main.cpp", "rb").read().decode("utf-8")
contest = "abc461"
task = "abc461_a"

with ojutils.new_session_with_our_user_agent(path=cookie) as sess:
    get_url = f"https://atcoder.jp/contests/{contest}/submit?taskScreenName={task}"
    resp = u.request("GET", get_url, session=sess)
    soup = bs4.BeautifulSoup(resp.content.decode(resp.encoding), u.HTML_PARSER)
    form = soup.find("form", action=f"/contests/{contest}/submit")
    sender = u.FormSender(form, url=resp.url)
    sender.set("data.TaskScreenName", task)
    sender.set("data.LanguageId", "6017")
    sender.set("sourceCode", code)

    print("POST with string sourceCode, referer=", resp.url)
    resp2 = sender.request(session=sess)
    print("result url:", resp2.url)
    if "/submissions/me" in resp2.url:
        print("SUCCESS")
    else:
        soup2 = bs4.BeautifulSoup(resp2.content.decode(resp2.encoding), u.HTML_PARSER)
        for alert in soup2.select(".alert-danger, [role=alert]"):
            print("alert:", alert.get_text(" ", strip=True))

    print("\nPOST with bytes sourceCode (oj behavior)")
    resp = u.request("GET", get_url, session=sess)
    soup = bs4.BeautifulSoup(resp.content.decode(resp.encoding), u.HTML_PARSER)
    form = soup.find("form", action=f"/contests/{contest}/submit")
    sender = u.FormSender(form, url=resp.url)
    sender.set("data.TaskScreenName", task)
    sender.set("data.LanguageId", "6017")
    sender.set("sourceCode", code.encode("utf-8"))
    resp3 = sender.request(session=sess)
    print("result url:", resp3.url)
    if "/submissions/me" not in resp3.url:
        soup3 = bs4.BeautifulSoup(resp3.content.decode(resp3.encoding), u.HTML_PARSER)
        for alert in soup3.select(".alert-danger, [role=alert]"):
            print("alert:", alert.get_text(" ", strip=True))
