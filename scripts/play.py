#!/usr/bin/env python3

import sys
import subprocess
import re

def main():
    if len(sys.argv) != 2:
        print("Usage: ./play <test_name>")
        sys.exit(1)

    test_filter = sys.argv[1]

    try:
        output = subprocess.check_output(f"scarb test -q {test_filter}", shell=True)
    except subprocess.CalledProcessError as e:
        print("scarb test failed")
        exit(1)

    if len(output) == 0:
        print("No output from scarb test")
        exit(0)
    
    # Find file data
    i = 0
    output  = output.decode('utf-8').splitlines()
    while i < len(output):
        if output[i].startswith(b'RIFF'.hex()): break
        i+=1

    # assumes data is in one line and in hex
    data_bytes = "".join(output[i])

    data_bytes = bytes.fromhex(data_bytes)

    out_file = f"tmp/{test_filter}.wav"

    with open(out_file, 'wb') as f:
        f.write(data_bytes)

    print(f"{len(data_bytes)} written to {out_file}")

    subprocess.call(['mplayer', '-vo', 'null', '-ao', 'alsa', out_file])




if __name__ == "__main__":
    main()
