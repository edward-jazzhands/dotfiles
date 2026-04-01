# Copy the transcript using the "Show Transcript" button at the bottom
# of the video description.
# Pass in the path to the transcript file as the first argument when you
# run this script (eg. `python3 $pyscripts/yt-formatter.py transcript.md`)

import sys
from pathlib import Path

# cwd = Path.cwd()
file_name = sys.argv[1]

with open(file_name, "r") as f:
    lines = f.readlines()

print("Read successfully")

new_lines = []
combine_amt = 2
for i, line in enumerate(lines):
    if i % combine_amt == 0:
        pass
    else:
        prev_line = lines[i-1].replace("\n", " ")
        new_lines.append(prev_line + line)

with open(file_name, "w") as f:
    f.writelines(new_lines)

print("Done")