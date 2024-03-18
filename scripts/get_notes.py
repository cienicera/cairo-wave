import subprocess
import ast

CONTRACT_ADDRESS = "0x04753e321e41c407187dc0a444a291957aff9740b526c97fbb8d14d073eee32a"

res = subprocess.run(['starkli', 'call', CONTRACT_ADDRESS, 'get_notes', '90'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
res = res.stdout.decode('utf-8')

res = ast.literal_eval(res)

res = bytes.fromhex("".join(map(lambda x: x[4:], res[1:-1])))

with open("./tmp/out.wav", "wb") as f:
    f.write(res)
