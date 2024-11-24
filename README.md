# cairo-wave

## About
Generate valid WAV files in Cairo

## Features
 - [x] Output WAV file
 - [x] Handle bit-depths (4, 8, 16, 24, 32)
 - [ ] Handle multiple/stereo channels
 - [x] Generate square wave form
 - [x] Generate sawtooth wave forms
 - [x] Generate triangle wave forms
 - [x] Generate sine wave forms
 - [ ] Generate an instrument (see [Koji](https://github.com/cienicera/Koji))
 - [x] Play [Koji](https://github.com/cienicera/Koji) notes
 - [ ] Play [Koji midi tracks](https://github.com/cienicera/Koji)
 - [x] Generate an 4/8-bit low sample rate sound pack (kick, bass, snare, hi-hat)
 - [X] Play short melodies


## Local testing: 
You need `mplayer` installed and a test that returns the hex of the WAVE file, see [tests](./src/tests)
```bash
./scripts/play.py _8bits
./scripts/play.py test_name
```

## Sepolia testing 
_Needs a working starkli configured with a Sepolia RPC_
```bash
python scripts/get_notes.py
mplayer tmp/out.wav
```

## Resources
- [WAVE PCM File format](http://soundfile.sapp.org/doc/WaveFormat/)
- Unix: `man sox`, `ffprobe file.wave`
- [WAV Header](https://onestepcode.com/read-wav-header/)
- [decode header](https://code.whatever.social/questions/29992898/decoding-a-wav-file-header)
- [generate 8-bit pytho gist](https://gist.github.com/jweinst1/1cd52d7f037197e7efb146d2eb42cae5)
- https://aminet.net/
- [sound pack + player](https://op1.fun/users/beatboyninja/packs/arcade-sounds-pack-41028)
- [gameboy 4-bit depth](https://gbdev.gg8.se/forums/viewtopic.php?id=941)
- http://www.hydrogen18.com/blog/joys-of-writing-a-wav-file.html
