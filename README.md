# cairo-wave
An implementation of the WAVE file format in Cairo

## Local testing: 
```bash
scarb test -f get_notes > tmp/test; 
python scripts/data_to_wave.py tmp/test; 
mplayer tmp/test.wav
```

## Sepolia testing 
_Needs a working starkli configured with a Seppolia RPC_
```bash
python scripts/get_notes.py
mplayer tmp/out.wav
```