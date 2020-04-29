#!/usr/bin/env python3

import subprocess
import re

DYNAMIC_MODULE = re.compile(" --add-dynamic-module=[^ ]+")


def args():
    for line in subprocess.run(["nginx", "-V"],
                               stderr=subprocess.PIPE,
                               text=True).stderr.split("\n"):
        if line.startswith("configure arguments"):
            return line[21:]

#.replace("'", '"')
print(DYNAMIC_MODULE.sub("", args()), end='')
