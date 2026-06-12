#!/usr/bin/python3
# Copyright (C) 2026 Jakepys
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

import subprocess


def main():
    result_pacman_updates = subprocess.run(
        ["checkupdates"], capture_output=True, text=True
    )
    result_aur_updates = subprocess.run(
        ["paru", "-Qua"], capture_output=True, text=True
    )
    print(
        f"󰮯 -> {len(result_pacman_updates.stdout.splitlines()) if result_pacman_updates.returncode == 0 else 0} "
        f" -> {len(result_aur_updates.stdout.splitlines()) if result_aur_updates.returncode == 0 else 0}"
    )


if __name__ == "__main__":
    main()
