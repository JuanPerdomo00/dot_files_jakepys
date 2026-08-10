#!/usr/bin/env python3
# change_wallpaper.py - Randomly rotates wallpapers using awww
# Copyright (C) 2026 Jakepys
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# awww img /home/jakepys/Pictures/wallpapers/yuta.jpg --transition-type grow --transition-fps 60

import os
import random
import subprocess
import sys
import time

TRANSITIONS = (
    "fade",
    "left",
    "right",
    "top",
    "bottom",
    "wipe",
    "wave",
    "grow",
    "center",
    "outer",
)

VALID_EXTENSIONS = (".jpg", ".jpeg", ".png", ".gif")


class ChangeWallpaper:
    def __init__(self, init_path: str, interval: int) -> None:
        self.init_path = init_path
        self.interval = interval

    def get_images(self) -> list[str]:
        images = []
        for current_folder, _subfolders, files in os.walk(self.init_path):
            for file in files:
                _, extension = os.path.splitext(file)
                if extension.lower() in VALID_EXTENSIONS:
                    full_path = os.path.join(current_folder, file)
                    images.append(full_path)
        return images

    def set_wallpaper(self, image_path: str) -> None:
        transition = random.choice(TRANSITIONS)
        command = [
            "awww",
            "img",
            image_path,
            "--transition-type",
            transition,
            "--transition-fps",
            "60",
        ]
        subprocess.run(command, check=False)

    def run(self) -> None:
        images = self.get_images()

        if not images:
            print(f"No valid images found in {self.init_path}")
            sys.exit(1)

        while True:
            image = random.choice(images)
            self.set_wallpaper(image)
            time.sleep(self.interval)


if __name__ == "__main__":
    try:
        if len(sys.argv) < 3:
            print("Usage: change_wallpaper.py <folder> <interval_seconds>")
            sys.exit(1)

        path = sys.argv[1]
        interval = int(sys.argv[2])

        cw = ChangeWallpaper(path, interval)
        cw.run()
    except KeyboardInterrupt:
        sys.exit(1)
