import sys
import matplotlib.pyplot as plt

if len(sys.argv) != 2:
    print("Usage: python data_to_wave.py <input_file>")
    sys.exit()

input_file = sys.argv[1]

with open(input_file) as f:
    data = f.read().splitlines()

i = 0
while i < len(data):
    if data[i].startswith('RIFF'): break
    i+=1

data_bytes = "".join(data[i:-3])
data_bytes = data_bytes.encode('utf-8')
data_bytes = data_bytes.decode('unicode-escape')
data_bytes = data_bytes.encode('ISO-8859-1')

with open(input_file + '.wav', 'wb') as f:
    f.write(data_bytes)

print(f"{len(data_bytes)} written to {input_file}.wav")
