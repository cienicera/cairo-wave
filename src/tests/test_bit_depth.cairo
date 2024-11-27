use crate::note::{Note, NoteType, Music, MusicToWavFile};
use crate::wave::WavFile;
use crate::tests::utils::to_hex;

#[test]
fn test_get_note_8bits() {
    let note = Note { frequency_hz: 440, duration_ms: 1000, note_type: NoteType::Sine };
    let music = Music { notes: array![note].span(), sample_rate: 8000, bit_depth: 8 };
    let wav: WavFile = music.into();
    let res: ByteArray = wav.into();
    assert!(res[0] == 'R');
    assert!(res[1] == 'I');
    assert!(res[2] == 'F');
    assert!(res[3] == 'F');
    println!("{:}", to_hex(@res));
}

#[test]
fn test_get_note_16bits() {
    let note = Note { frequency_hz: 440, duration_ms: 1000, note_type: NoteType::Sine };
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
fn test_get_note_24bits() {
    let note = Note { frequency_hz: 440, duration_ms: 1000, note_type: NoteType::Sine };
    let music = Music { notes: array![note].span(), sample_rate: 8000, bit_depth: 24 };
    let wav: WavFile = music.into();
    let res: ByteArray = wav.into();
    assert!(res[0] == 'R');
    assert!(res[1] == 'I');
    assert!(res[2] == 'F');
    assert!(res[3] == 'F');
    println!("{:}", to_hex(@res));
}

#[test]
fn test_get_note_32bits() {
    let note = Note { frequency_hz: 440, duration_ms: 1000, note_type: NoteType::Sine };
    let music = Music { notes: array![note].span(), sample_rate: 8000, bit_depth: 32 };
    let wav: WavFile = music.into();
    let res: ByteArray = wav.into();
    assert!(res[0] == 'R');
    assert!(res[1] == 'I');
    assert!(res[2] == 'F');
    assert!(res[3] == 'F');
    println!("{:}", to_hex(@res));
}

