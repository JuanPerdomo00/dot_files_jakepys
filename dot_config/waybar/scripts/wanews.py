#!/usr/bin/python3
#
# A python script to fetch and display arch linux news for waybar.
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

import argparse
import json
import sys
from datetime import datetime, timedelta
from email.utils import parsedate_to_datetime
from urllib.request import urlopen, Request
from urllib.error import URLError, HTTPError
import xml.etree.ElementTree as ET


class ArchNews:
    def __init__(self):
        self.url = "https://archlinux.org/feeds/news/"

    def fetch_rss_feed(self):
        try:
            req = Request(self.url)
            with urlopen(req) as response:
                feed_data = response.read().decode("utf-8")

            if not feed_data:
                raise ValueError("Empty RSS feed")

            return feed_data
        except (URLError, HTTPError) as e:
            error_output = {
                "text": " ✗",
                "tooltip": f"Error: failed to fetch RSS feed - {str(e)}",
                "class": "arch-news-error",
            }
            print(json.dumps(error_output))
            sys.exit(1)
        except ValueError as e:
            error_output = {
                "text": " ✗",
                "tooltip": f"Error: {str(e)}",
                "class": "arch-news-error",
            }
            print(json.dumps(error_output))
            sys.exit(1)

    def parse_feed(self, feed_xml, cutoff_date):
        try:
            root = ET.fromstring(feed_xml)
            items = []

            for item in root.findall(".//item"):
                title_elem = item.find("title")
                pubdate_elem = item.find("pubDate")

                if title_elem is not None and pubdate_elem is not None:
                    title = title_elem.text
                    pubdate_str = pubdate_elem.text

                    try:
                        pubdate = parsedate_to_datetime(pubdate_str)

                        if pubdate >= cutoff_date:
                            items.append(
                                {
                                    "title": title,
                                    "pubDate": pubdate_str,
                                    "pubDate_parsed": pubdate,
                                }
                            )
                    except (TypeError, ValueError):
                        continue

            return items
        except ET.ParseError as e:
            error_output = {
                "text": " ✗",
                "tooltip": f"Error: failed to parse RSS feed - {str(e)}",
                "class": "arch-news-error",
            }
            print(json.dumps(error_output))
            sys.exit(1)

    def format_output(self, items, days, active_color, inactive_color):
        count = len(items)

        if count > 0:
            tooltip_items = []
            for item in items[:5]:
                formatted_date = item["pubDate_parsed"].strftime("%Y-%m-%d %H:%M")
                tooltip_items.append(
                    f'<span color="{active_color}">{item["title"]} '
                    f"({formatted_date})</span>"
                )
            tooltip = "\n\n".join(tooltip_items)
        else:
            tooltip = f"No arch linux news in the last {days} days"

        css_class = "arch_news_active" if count > 0 else "arch_news_inactive"

        percentage = min(count * 10, 100)

        output = {
            "text": f" {count}",
            "tooltip": tooltip,
            "class": css_class,
            "percentage": percentage,
        }

        if count > 0 and active_color:
            output["color"] = active_color
        elif count == 0 and inactive_color:
            output["color"] = inactive_color

        return output


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Fetch and display arch linux news for Waybar"
    )
    parser.add_argument(
        "days",
        nargs="?",
        type=int,
        default=7,
        help="Number of days to look back for news [default: 7]",
    )
    parser.add_argument(
        "--active-color",
        default="#a6e3a1",
        help="Color for active news [default #a6e3a1]",
    )
    parser.add_argument(
        "--inactive-color",
        default="",
        help="Color for inactive/no news [default: '']",
    )
    parser.add_argument("--version", action="version", version="Arch news waybar")

    args = parser.parse_args()

    if args.days <= 0:
        error_output = {
            "text": " ✗",
            "tooltip": "Error: Days must be a positive number",
            "class": "arch-news-error",
        }
        print(json.dumps(error_output))
        sys.exit(1)

    return args


def main():
    args = parse_arguments()
    arch_news = ArchNews()

    cutoff_date = datetime.now() - timedelta(days=args.days)
    cutoff_date = cutoff_date.replace(tzinfo=datetime.now().astimezone().tzinfo)

    feed_xml = arch_news.fetch_rss_feed()
    items = arch_news.parse_feed(feed_xml, cutoff_date)

    output = arch_news.format_output(
        items, args.days, args.active_color, args.inactive_color
    )
    print(json.dumps(output))


if __name__ == "__main__":
    main()
