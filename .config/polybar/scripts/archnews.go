// Copyright (C) 2026 Jakepys
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

package main

import (
	"fmt"
	"time"

	"github.com/mmcdole/gofeed"
)

func main() {
	feed, err := gofeed.NewParser().ParseURL(
		"https://archlinux.org/feeds/news/",
	)
	if err != nil || len(feed.Items) == 0 {
		fmt.Print(" ->?")
		return
	}

	item := feed.Items[0]

	if item.PublishedParsed == nil {
		fmt.Print("  -> 0")
		return
	}

	day := 7

	if time.Since(*item.PublishedParsed) <= time.Duration(day)*24*time.Hour {
		fmt.Print("  -> 1")
	} else {
		fmt.Print("  -> 0")
	}
}
