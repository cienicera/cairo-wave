use crate::note::{Note, NoteType, Music, MusicToWavFile};
use crate::wave::WavFile;
use crate::tests::utils::to_hex;


#[test]
fn test_get_note() {
    let note = Note { frequency_hz: 440, duration_ms: 1000, note_type: NoteType::Square };
    let music = Music { notes: array![note].span(), sample_rate: 8000, bit_depth: 16 };
    let wav: WavFile = music.into();
    let res: ByteArray = wav.into();
    assert!(res[0] == 'R');
    assert!(res[1] == 'I');
    assert!(res[2] == 'F');
    assert!(res[3] == 'F');
    println!("{:}", to_hex(@res));
}

#[test]
fn test_get_melody() {
    let note_type = NoteType::Square;
    let duration_ms = 500;
    let sol: Note = Note { frequency_hz: 392, duration_ms, note_type };
    let la: Note = Note { frequency_hz: 440, duration_ms, note_type };
    let la2: Note = Note { frequency_hz: 440, duration_ms: 2 * duration_ms, note_type };
    let si: Note = Note { frequency_hz: 494, duration_ms, note_type };
    let do2: Note = Note { frequency_hz: 523, duration_ms: duration_ms * 2, note_type };
    let si2: Note = Note { frequency_hz: 494, duration_ms: duration_ms * 2, note_type };
    let empty: Note = Note { frequency_hz: 16000, duration_ms: 10, note_type };

    let music = Music {
        notes: array![sol, la, si, sol, la2, empty, la, si, do2, empty, do2, si2, empty, si2]
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
