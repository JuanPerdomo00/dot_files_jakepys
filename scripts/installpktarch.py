#!/usr/bin/env python3
# Copyright (C) 2026  Juan Perdomo (Jakepys)
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

import io
import os
import shutil
import stat
import subprocess
import sys
import tarfile
from pathlib import Path


class Logs:
    RESET = "\033[0m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    RED = "\033[91m"
    BLUE = "\033[94m"
    BOLD = "\033[1m"

    @staticmethod
    def success(msg: str) -> str:
        return f"[+] {Logs.GREEN}{msg}{Logs.RESET}"

    @staticmethod
    def warning(msg: str) -> str:
        return f"[!] {Logs.YELLOW}{msg}{Logs.RESET}"

    @staticmethod
    def error(msg: str) -> str:
        return f"[X] {Logs.RED}{msg}{Logs.RESET}"

    @staticmethod
    def info(msg: str) -> str:
        return f"[i] {Logs.BLUE}{msg}{Logs.RESET}"


# Read byte to file .deb
def parse_deb(file: Path) -> bytes:
    with file.open("rb") as deb:
        data = deb.read()
        if data[:8] != b"!<arch>\n":
            print(Logs.error("Error to format .deb"))
            sys.exit(1)

    return data


# read bytes deb and positon magic number 8
def read_entry_deb(bytes_deb: bytes, offset: int) -> tuple[str, bytes, int]:
    header = bytes_deb[offset : offset + 60]
    size = int(header[48:58].decode("ascii").strip())
    name = header[0:16].decode("ascii").strip()
    content = bytes_deb[offset + 60 : offset + 60 + size]
    next_offset = (
        (offset + 60 + (size + 1)) if (size % 2 != 0) else (offset + 60 + size)
    )

    return name, content, next_offset


def list_entries(bytes_deb: bytes) -> list[tuple[str, bytes]]:
    offset = 8
    entries = []

    while offset < len(bytes_deb):
        name, content, next_offset = read_entry_deb(bytes_deb, offset)
        entries.append((name, content))
        offset = next_offset

    return entries


def extract_data_deb(entries: list[tuple[str, bytes]], dest: Path):
    for name, content in entries:
        if name.startswith("data.tar"):
            buffer_deb = io.BytesIO(content)
            with tarfile.open(fileobj=buffer_deb, mode="r:xz") as data:
                data.extractall(path=dest)

            file_count = sum(1 for f in dest.rglob("*") if f.is_file())
            print(Logs.info(f"{file_count} files extracted to {dest}"))
            print(Logs.success("complete extraction..."))
            break
    else:
        print(Logs.error("Error in .deb, not found"))
        sys.exit(1)


def install_files(extracted_dir: Path, install_dir: Path):
    shutil.copytree(
        src=extracted_dir / "opt" / "pt", dirs_exist_ok=True, dst=install_dir
    )
    total_size = sum(f.stat().st_size for f in install_dir.rglob("*") if f.is_file())
    size_mb = total_size / (1024 * 1024)
    print(Logs.info(f"Installed in {install_dir} ({size_mb:.1f} MB)"))


def setup_binary(appimage_path: Path, bin_dir: Path):
    os.chmod(
        appimage_path,
        stat.S_IRWXU | stat.S_IRGRP | stat.S_IXGRP | stat.S_IROTH | stat.S_IXOTH,
    )
    bin_dir.mkdir(parents=True, exist_ok=True)
    link_path = bin_dir / "packettracer"
    if link_path.exists():
        link_path.unlink()
    link_path.symlink_to(appimage_path)


def first_run(appimage_path: Path):
    print(Logs.info("Executing for the first time to accept EULA..."))
    subprocess.run([str(appimage_path)], check=False)


def main():
    if len(sys.argv) < 2 or len(sys.argv) >= 3:
        print(Logs.warning(f"Use: {sys.argv[0]} [.deb Path]"))
        sys.exit(1)

    deb_path = Path(sys.argv[1])

    if not deb_path.exists():
        print(Logs.error(f"The file does not exist: {sys.argv[1]}"))
        sys.exit(1)

    size_mb = deb_path.stat().st_size / (1024 * 1024)
    print(Logs.info(f".deb size {deb_path.name} ({size_mb:.1f} MB)"))

    bytes_deb = parse_deb(deb_path)
    entrys = list_entries(bytes_deb)
    print(Logs.info(f"Found {len(entrys)} entries in the deb file (ar)"))
    dest = Path("/tmp/packettracer")
    extract_data_deb(entrys, dest)

    install_dir = Path.home() / ".local" / "share" / "packettracer"

    install_files(dest, install_dir)

    setup_binary(install_dir / "packettracer.AppImage", Path.home() / ".local" / "bin")

    first_run(install_dir / "packettracer.AppImage")


if __name__ == "__main__":
    main()
