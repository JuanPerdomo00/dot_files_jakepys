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
    vpn = subprocess.run(
        ["nmcli", "connection", "show", "--active"], capture_output=True, text=True
    )

    for line in vpn.stdout.splitlines():
        if "vpn" in line:
            name = line.split()[1]
            print(f"{name}")
            return

    wifi = subprocess.run(
        ["nmcli", "-t", "-f", "active,ssid", "dev", "wifi"],
        capture_output=True,
        text=True,
    )

    for line in wifi.stdout.splitlines():
        if line.startswith("yes:"):
            ssid = line[4:]
            print(f"󰤨 {ssid}")
            return

    print("󰤭 ")


if __name__ == "__main__":
    main()
