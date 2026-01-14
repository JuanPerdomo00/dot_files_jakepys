#!/usr/bin/python3
#
# A python script to check for and update arch linux.
#
# Copyright (C) 2025  Jakepys
#
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
import subprocess
import json
import sys


def main():
    try:
        checkupdate = subprocess.check_output(
            "checkupdates --nosync --nocolor 2>/dev/null", shell=True, timeout=10
        ).decode("utf-8")
        lines_updates = [line for line in checkupdate.split("\n") if line.strip()]
        num_updates = len(lines_updates)

        if num_updates == 0:
            complete_json = {
                "text": "󰏖 ",
                "tooltip": "System up to date",
                "class": "updated",
            }
        else:
            info_packages = []
            for line in lines_updates:
                parts = line.split()
                if len(parts) >= 4:
                    info_packages.append(
                        {"name": parts[0], "old": parts[1], "new": parts[3]}
                    )

            tooltip = f"<span color='#63a4ff'> 󰏖  {num_updates} update{'s' if num_updates != 1 else ''} available:</span>\n\n"

            for pkg in info_packages:
                tooltip += f"<span color='#FFD700'>[+] {pkg['name']}</span> "
                tooltip += f"<span color='#ff9a9e'>{pkg['old']}</span> → "
                tooltip += f"<span color='#b5e8a9'>{pkg['new']}</span>\n"

            if num_updates > 50:
                css_class = "critical"
            elif num_updates > 20:
                css_class = "warning"
            else:
                css_class = "normal"

            complete_json = {
                "text": f"󰏖 {num_updates}",
                "tooltip": tooltip.strip(),
                "class": css_class,
            }

    except subprocess.CalledProcessError:
        complete_json = {
            "text": "󰏖",
            "tooltip": "No updates available",
            "class": "updated",
        }
    except subprocess.TimeoutExpired:
        complete_json = {
            "text": "󰏖 ?",
            "tooltip": "Error: timeout checking for updates",
            "class": "error",
        }
    except Exception as e:
        complete_json = {"text": "󰏖 !", "tooltip": f"Error: {str(e)}", "class": "error"}

    print(json.dumps(complete_json))
    sys.exit(0)


if __name__ == "__main__":
    main()
