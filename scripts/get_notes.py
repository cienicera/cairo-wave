import subprocess
import ast

CONTRACT_ADDRESS = "0x01ede845ba73f89a810b153fbd6231c1ef79c371d16577e97af80419b47ee6d8"

res = subprocess.run(['starkli', 'call', CONTRACT_ADDRESS, 'get_notes', '90'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
res = res.stdout.decode('utf-8')

res = ast.literal_eval(res)

res = bytes.fromhex("".join(map(lambda x: x[4:], res[1:-1])))

with open("./tmp/out.wav", "wb") as f:
    f.write(res)
