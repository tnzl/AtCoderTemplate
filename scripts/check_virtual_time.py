import re
from pathlib import Path
import onlinejudge_command.utils as ojutils
from onlinejudge._implementation import utils as u

cookie = Path.home() / "AppData/Local/online-judge-tools/online-judge-tools/cookie.jar"
with ojutils.new_session_with_our_user_agent(path=cookie) as sess:
    r = u.request("GET", "https://atcoder.jp/contests/abc461/virtual", session=sess)
    for name in ["virtualStartTime", "virtualEndTime"]:
        m = re.search(rf'{name} = moment\("([^"]+)"\)', r.text)
        print(name, m.group(1) if m else None)
    print("Date header", r.headers.get("Date"))
