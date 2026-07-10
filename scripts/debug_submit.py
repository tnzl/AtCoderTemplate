import pathlib
import sys
import bs4
import onlinejudge_command.utils as ojutils
from onlinejudge.service.atcoder import AtCoderProblem, _list_alert
from onlinejudge._implementation import utils as u

url = sys.argv[1] if len(sys.argv) > 1 else "https://atcoder.jp/contests/abc461/tasks/abc461_a"
code = open(r"d:\projects\atCoder\main.cpp", "rb").read()
cookie = pathlib.Path.home() / "AppData/Local/online-judge-tools/online-judge-tools/cookie.jar"

with ojutils.new_session_with_our_user_agent(path=cookie) as sess:
    problem = AtCoderProblem.from_url(url)
    print("problem url:", url)
    print("contest_id:", problem.contest_id)
    print("problem_id:", problem.problem_id)
    print("logged_in:", problem.get_service().is_logged_in(session=sess))

    submit_url = f"https://atcoder.jp/contests/{problem.contest_id}/submit"
    resp = u.request("GET", submit_url, session=sess)
    print("GET submit url:", resp.url)

    soup = bs4.BeautifulSoup(resp.content.decode(resp.encoding), u.HTML_PARSER)
    text = soup.get_text("\n", strip=True)
    for line in text.splitlines():
        if any(k in line.lower() for k in ["virtual", "ended", "error", "参加", "contest"]):
            if len(line) < 120:
                print("page:", line)

    form = soup.find("form", action=f"/contests/{problem.contest_id}/submit")
    print("form found:", form is not None)
    if not form:
        pathlib.Path(r"d:\projects\atCoder\scripts\submit_get.html").write_bytes(resp.content)
        print("saved submit_get.html (no form)")
        raise SystemExit(1)

    sender = u.FormSender(form, url=resp.url)
    sender.set("data.TaskScreenName", problem.problem_id)
    sender.set("data.LanguageId", "6017")
    sender.set("sourceCode", code.decode("utf-8"))

    resp2 = sender.request(session=sess)
    print("POST url:", resp2.url)
    if "/submissions/me" in resp2.url:
        print("SUCCESS")
        raise SystemExit(0)

    soup2 = bs4.BeautifulSoup(resp2.content.decode(resp2.encoding), u.HTML_PARSER)
    for alert in soup2.find_all("div", attrs={"role": "alert"}):
        print("alert:", alert.get_text(" ", strip=True))
    for line in soup2.get_text("\n", strip=True).splitlines():
        if any(k in line.lower() for k in ["error", "ended", "virtual", "cannot", "できません", "参加"]):
            print("hint:", line[:200])
    pathlib.Path(r"d:\projects\atCoder\scripts\submit_response.html").write_bytes(resp2.content)
