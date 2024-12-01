use crate::instruments::piano::{PianoNote, PianoMusic, MusicToWavFile};
use crate::wave::WavFile;
use crate::tests::utils::to_hex;

#[test]
fn test_get_piano_melody() {
    let duration_ms = 500;
    let sol: PianoNote = PianoNote { frequency_hz: 392, duration_ms };
    let la: PianoNote = PianoNote { frequency_hz: 440, duration_ms };
    let la2: PianoNote = PianoNote { frequency_hz: 440, duration_ms: 2 * duration_ms };
    let si: PianoNote = PianoNote { frequency_hz: 494, duration_ms };
    let do2: PianoNote = PianoNote { frequency_hz: 523, duration_ms: duration_ms * 2 };
    let si2: PianoNote = PianoNote { frequency_hz: 494, duration_ms: duration_ms * 2 };
    let empty: PianoNote = PianoNote { frequency_hz: 16000, duration_ms: 10 };

    let music = PianoMusic {
        notes: array![sol, la, si, sol, la2]
            .span(),
        sample_rate: 8000,
        bit_depth: 8,
    };
    let wav: WavFile = music.into();
    let res: ByteArray = wav.into();
    assert!(res[0] == 'R');
    assert!(res[1] == 'I');
    assert!(res[2] == 'F');
    assert!(res[3] == 'F');

    println!("{:}", to_hex(@res));
}
