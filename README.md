# cairo-wave
An implementation of the WAVE file format in Cairo

## Test: 
`scarb test -f get_notes > tmp/test; python scripts/data_to_wave.py tmp/test; mplayer tmp/test.wav`