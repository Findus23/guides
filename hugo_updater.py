import tarfile
from io import BytesIO
from pathlib import Path

import requests

version_file = Path("hugo_version.txt")
hugo_binary = Path("hugo")


def get_latest_version():
    r = requests.get("https://api.github.com/repos/gohugoio/hugo/releases")
    data = r.json()
    data.sort(key=lambda r: r["created_at"], reverse=True)
    stable_releases = [r for r in data if not r["prerelease"]]
    return stable_releases[0]


def main():
    latest_release_data = get_latest_version()
    latest_release_version = latest_release_data["tag_name"].lstrip("v")

    if version_file.exists():
        current_version = version_file.read_text().strip()
    else:
        current_version = None

    if latest_release_version == current_version and hugo_binary.exists():
        print(f"hugo is up to date ({current_version})")
        return

    print(f"latest version is {latest_release_version}, updating from {current_version}")
    for asset in latest_release_data["assets"]:
        name = asset["name"]
        if "linux-amd64.tar.gz" not in name or "extended" not in name:
            continue
        download_url = asset["browser_download_url"]
        print("downloading")
        r = requests.get(download_url)
        print("extracting")
        tar = tarfile.open(fileobj=BytesIO(r.content))
        tar.extract("hugo")
        tar.close()
    version_file.write_text(latest_release_version)


if __name__ == '__main__':
    main()
