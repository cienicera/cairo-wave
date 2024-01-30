import sys

if len(sys.argv) != 2:
    print("Usage: python data_to_wave.py <input_file>")
    sys.exit()

input_file = sys.argv[1]

with open(input_file, 'r') as f:
    data = f.read().splitlines()

data_bytes = data[5].encode().decode('unicode-escape').encode('ISO-8859-1')

with open(input_file + '.wav', 'wb') as f:
    f.write(data_bytes)

print(f"{len(data_bytes)} written to {input_file}.wav")
