import subprocess
import os
import shlex

user = os.getenv('USER')

# Fallback cesty k yt-dlp
YTDLP_CANDIDATES = [
    f"/home/{user}/.local/bin/yt-dlp",  # user install
    "/usr/share/harbour-sailtube/bin/yt-dlp"  # bundled in app
    #"yt-dlp",  # PATH
]

def _find_ytdlp():
    for path in YTDLP_CANDIDATES:
        if path == "yt-dlp":
            return path
        if os.path.exists(path) and os.access(path, os.X_OK):
            return path
    return None

def get_stream_url(url):
    ytdlp = _find_ytdlp()
    if not ytdlp:
        return {
            "ok": False,
            "error": "yt-dlp not found"
        }

    try:
        proc = subprocess.Popen(
            [ytdlp, "-f", "best", "-g", url],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=os.environ
        )
        out, err = proc.communicate()

        if proc.returncode != 0:
            return {
                "ok": False,
                "error": err.decode("utf-8", errors="ignore")
            }

        stream = out.decode("utf-8", errors="ignore").strip().split("\n")[0]

        if not stream:
            return {
                "ok": False,
                "error": "yt-dlp returns empty URL"
            }

        return {
            "ok": True,
            "url": stream
        }

    except Exception as e:
        return {
            "ok": False,
            "error": str(e)
        }

def download_video(url, outpath):
    ytdlp = _find_ytdlp()
    if not ytdlp:
        return {
            "ok": False,
            "error": "yt-dlp not found"
        }

    try:
        os.makedirs(os.path.dirname(outpath), exist_ok=True)

        proc = subprocess.Popen(
            [ytdlp, "-f", "best", "-o", outpath, url],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=os.environ
        )
        out, err = proc.communicate()

        if proc.returncode != 0:
            return {
                "ok": False,
                "error": err.decode("utf-8", errors="ignore")
            }

        return {
            "ok": True,
            "path": outpath
        }

    except Exception as e:
        return {
            "ok": False,
            "error": str(e)
        }

