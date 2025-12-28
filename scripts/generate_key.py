#!/usr/bin/env python3

# Generate key.bin and key.txt for ynoserver

import os

key = os.urandom(32)

with open("key.bin", "bw") as key_bin:
    key_bin.write(key)

with open("key.txt", "w") as key_txt:
    key_txt.write("0x" + key.hex("!").replace("!", ", 0x"))
