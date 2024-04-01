use koji::midi::{types::{Modes, PitchClass}, pitch::{PitchClassTrait, PitchClassImpl}};
use cairo_wave::note::{Note, NoteType, Music, MusicToWavFile};


trait CustomNoteTrait {
    fn create_custom_note(note: u8, octave: u8, duration: u32, _note_type: NoteType) -> Note;
}

impl CustomNoteImpl of CustomNoteTrait {
    fn create_custom_note(note: u8, octave: u8, duration: u32, _note_type: NoteType) -> Note {
        let custom_note_instance: PitchClass = PitchClass { note: note, octave: octave };

        let custom_freq: u32 = custom_note_instance.freq();

        let custom_note: Note = Note {
            frequency_hz: custom_freq, duration_ms: duration, note_type: _note_type
        };
        custom_note
    }
}
