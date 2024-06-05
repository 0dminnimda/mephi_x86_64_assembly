import re
import math
from dataclasses import dataclass
from collections import defaultdict
from pathlib import Path

import matplotlib.pyplot as plt


burner_pattern = re.compile(r"# burner, to warmed up cache\n\./main\.out .+ > /dev/null")

timing_pattern = re.compile(r"""\
\./main\.out (?P<image>[\w./]+) [\w./]+ [\w./]+ [\w./]+ [\w./]+ \d+ \d+ \d+ \d+ \d+
Image loaded: (?P<old_width>\d+)\*(?P<old_height>\d+) pixels, 4 channels
Cropping from \d+ to \d+\+(?P<new_width>\d+) by x and from \d+ to \d+\+(?P<new_height>\d+) by y 
timing with (?P<iterations>\d+) iterations
(?P<tag_1>.+): (?P<time_1>\d+\.\d+)
(?P<tag_2>.+): (?P<time_2>\d+\.\d+)
(?P<tag_3>.+): (?P<time_3>\d+\.\d+)
(?P<tag_4>.+): (?P<time_4>\d+\.\d+)""")


@dataclass
class Timing:
    old_area: int
    new_area: int
    time: float
    tag: str

S_TO_MS = 1000


def parse(text: str):
    timings = list[Timing]()
    text = burner_pattern.sub("", text)
    for match in timing_pattern.finditer(text):
        captures = match.groupdict()
        # image = captures["image"].partition("/")[2]
        old_area = int(captures["old_width"]) * int(captures["old_height"])
        new_area = int(captures["new_width"]) * int(captures["new_height"])
        iterations = int(captures["iterations"])
        for i in range(1, 5):
            timings.append(
                Timing(
                    old_area=old_area,
                    new_area=new_area,
                    time=float(captures[f"time_{i}"]) / iterations,
                    tag=captures[f"tag_{i}"],
                )
            )

    tag_to_time = defaultdict(lambda: defaultdict(list))
    for timing in timings:
        tag_to_time[timing.tag][timing.new_area].append(timing.time * S_TO_MS)

    result = {}
    for tag, item in tag_to_time.items():
        res = {}
        for area, times in item.items():
            res[area] = sum(times) / len(times)
        result[tag] = list(zip(*sorted(res.items())))

    return result


def exclude_top_slowest(processed, n):
    top_times = {}
    for tag, (areas, times) in processed.items():
        top_times[tag] = sum(times)
    new = sorted(top_times.items(), key=lambda x: x[1])[:-n]
    return {
        tag: processed[tag]
        for tag, _ in new
    }


def visualize_one(ax, tag, areas, times):
    if tag.startswith("c"):
        marker = "o"
    else:
        marker = "+"
    
    if "sse" in tag:
        linestyle = "dashed"
    else:
        linestyle = "-"

    ax.plot(areas, times, marker=marker, linestyle=linestyle, label=tag)


data = Path("timing_raw.txt").read_text()

processed = parse(data)

fig, ax = plt.subplots(1, 2)
fig.suptitle("Time (ms) vs Output Image Area")

ax[0].set_xlabel("Output Image Area (log)")
ax[0].set_ylabel("Time (log)")
ax[0].set_title("all")
ax[0].set_xscale("log")
ax[0].set_yscale("log")
for tag, (areas, times) in processed.items():
    visualize_one(ax[0], tag, areas, times)
ax[0].legend()

ax[1].set_xlabel("Output Image Area")
ax[1].set_ylabel("Time")
ax[1].set_title("all, except top 4 slowest")
ax[1].set_xscale("linear")
ax[1].set_yscale("linear")
for tag, (areas, times) in exclude_top_slowest(processed, 4).items():
    visualize_one(ax[1], tag, areas, times)
ax[1].legend()

plt.show()
