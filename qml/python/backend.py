import subprocess
import os
import shlex
import json
import re

user = os.getenv('USER')

# Fallback cesty k yt-dlp
YTDLP_CANDIDATES = [
    f"/home/{user}/.local/bin/yt-dlp",  # user install
    "/usr/share/harbour-sailtube/bin/yt-dlp"  # bundled in app (optional)
    #"yt-dlp",  # PATH
]

def _find_ytdlp():
    for path in YTDLP_CANDIDATES:
        if path == "yt-dlp":
            return path
        if os.path.exists(path) and os.access(path, os.X_OK):
            return path
    return None


def get_stream_url(url, mode="video"):
    ytdlp = _find_ytdlp()
    if not ytdlp:
        return {
            "ok": False,
            "error": "yt-dlp not found"
        }

    if mode == "audio":
        fmt = "bestaudio/best"
    else:
        fmt = "best"

    NODE = "/home/.nodejs/bin/node"

    def run(cmd):
        proc = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=os.environ
        )
        out, err = proc.communicate()
        return proc.returncode, out.decode("utf-8", errors="ignore"), err.decode("utf-8", errors="ignore")

    try:
        # 1️⃣  normal usage without JS runtime
        code, out, err = run([ytdlp, "-f", fmt, "-g", url])

        if code != 0:
            # 2️⃣ fallback with JS runtime
            code2, out2, err2 = run([
                ytdlp,
                "--js-runtimes", f"node:{NODE}",
                "-f", fmt,
                "-g", url
            ])

            if code2 != 0:
                return {
                    "ok": False,
                    "error": "[no-js] " + err.strip() + "\n[js-fallback] " + err2.strip()
                }

            out = out2

        stream = out.strip().split("\n")[0]

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


def get_channel_latest(channel_id, limit=10):
    ytdlp = _find_ytdlp()
    if not ytdlp:
        return {"ok": False, "error": "yt-dlp not found"}

    # uploads playlist (UC... -> UU...)
    uploads_id = channel_id.replace("UC", "UU", 1)
    url = "https://www.youtube.com/playlist?list=" + uploads_id

    try:
        proc = subprocess.Popen(
            [ytdlp, url, "--dump-json", "--flat-playlist", "--playlist-end", str(limit)],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=os.environ
        )
        out, err = proc.communicate()

        if proc.returncode != 0:
            return {"ok": False, "error": err.decode("utf-8", errors="ignore")}

        videos = []
        for line in out.decode("utf-8", errors="ignore").splitlines():
            info = json.loads(line)

            # filter - zero length
            duration = info.get("duration") or 0
            if duration <= 0:
                continue


            videos.append({
                "videoId": info.get("id"),
                "title": info.get("title"),
                "lengthSeconds": duration
                #"publishedText": info.get("upload_date")  # YYYYMMDD
            })

        return {"ok": True, "videos": videos}

    except Exception as e:
        return {"ok": False, "error": str(e)}


def search_videos(query, limit=6):
    ytdlp = _find_ytdlp()
    if not ytdlp:
        return {"ok": False, "error": "yt-dlp not found"}

    try:
        proc = subprocess.Popen(
            [ytdlp, f"ytsearch{limit}:{query}", "--dump-json", "--flat-playlist", "--no-warnings", "--quiet", "--js-runtimes", "node:/home/.nodejs/bin/node"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=os.environ
        )
        out, err = proc.communicate()

        if proc.returncode != 0:
            return {"ok": False, "error": err.decode("utf-8", errors="ignore")}

        videos = []
        for line in out.decode("utf-8", errors="ignore").splitlines():
            info = json.loads(line)

            # ky →zero duration time video
            duration = info.get("duration") or 0
            if duration <= 0:
                continue

            videos.append({
                "videoId": info.get("id"),
                "title": info.get("title"),
                "author": info.get("uploader"),
                "authorId": info.get("uploader_id"),
                "lengthSeconds": duration
                #"thumbnail": info.get("thumbnail")
            })

        return {"ok": True, "videos": videos}

    except Exception as e:
        return {"ok": False, "error": str(e)}


def get_stream_info(url, mode="video"):
    ytdlp = _find_ytdlp()
    if not ytdlp:
        return {"ok": False, "error": "yt-dlp not found"}

    fmt = "bestaudio/best" if mode == "audio" else "best"

    NODE = "/home/.nodejs/bin/node"

    def run(cmd):
        proc = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=os.environ
        )
        out, err = proc.communicate()
        return proc.returncode, out.decode("utf-8", errors="ignore"), err.decode("utf-8", errors="ignore")

    try:
        # 1️⃣  normal usage without JS runtime
        code, out, err = run([ytdlp, "--dump-json", url])
        if code != 0:
            # 2️⃣ fallback with JS runtime
            code2, out2, err2 = run([
                ytdlp,
                "--js-runtimes", f"node:{NODE}",
                "--dump-json", url
            ])
            if code2 != 0:
                return {"ok": False, "error": "[no-js] " + err.strip() + "\n[js-fallback] " + err2.strip()}
            out = out2

        data = json.loads(out)
        video_id = data.get("id")
        title = data.get("title")

        # Vybere URL streamu podle formátu
        formats = data.get("formats", [])
        best_url = None
        for f in reversed(formats):  # yt-dlp sort from the worse to the best
            if f.get("format_note") == mode or f.get("acodec") != "none" or f.get("vcodec") != "none":
                best_url = f.get("url")
                break
        if not best_url:
            best_url = data.get("url")  # fallback

        return {"ok": True, "video_id": video_id, "title": title, "url": best_url}

    except Exception as e:
        return {"ok": False, "error": str(e)}
