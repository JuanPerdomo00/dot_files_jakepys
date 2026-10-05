#!/usr/bin/env python3
#    procncpu.py
#    Copyright (C) 2026  Jakepys
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# I borrowed some ideas but didn't copy the code directly;
# I tried to make my Python implementation very different.
# I would like to thank linuxvox.com in advance for such useful and essential tutorials.
# https://linuxvox.com/blog/c-api-for-getting-cpu-load-in-linux/

import re
import time

pattern = r"^cpu[0-9]"


class CpuStats:
    def __init__(self, *stats) -> None:
        (
            self.user,
            self.nice,
            self.system,
            self.idle,
            self.iowait,
            self.irq,
            self.softirq,
            self.steal,
        ) = stats

    def total(self) -> int:
        return (
            self.user
            + self.nice
            + self.system
            + self.idle
            + self.iowait
            + self.irq
            + self.softirq
            + self.steal
        )

    def idle_time(self) -> int:
        return self.idle + self.iowait


def read_cpu_stats() -> list[CpuStats]:
    cpu_stats: list[CpuStats] = []

    with open("/proc/stat", "r") as fp:
        for line in fp:
            if re.match(pattern, line):
                fields = line.split()
                counters = [int(i) for i in fields[1:9]]
                cpu_stats.append(CpuStats(*counters))

    return cpu_stats


def get_cpus_load(interval: float = 1.0) -> list[float]:
    first = read_cpu_stats()
    time.sleep(interval)
    second = read_cpu_stats()

    loads: list[float] = []

    for before, after in zip(first, second):
        delta_total = after.total() - before.total()
        delta_idle = after.idle_time() - before.idle_time()

        if delta_total == 0:
            loads.append(0.0)
            continue

        loads.append((delta_total - delta_idle) / delta_total * 100)

    return loads


def main():
    for n, load in enumerate(get_cpus_load()):
        print(f"cpu{n}: {load:5.1f}%")


if __name__ == "__main__":
    main()
