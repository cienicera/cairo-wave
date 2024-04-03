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


#[cfg(test)]
mod tests {
    use core::serde::Serde;
    use cairo_wave::contract::notes::{
        NotesContract, INotesContractDispatcher, INotesContractDispatcherTrait, tests::deploy
    };
    use cairo_wave::note::{Note, NoteType};
    use starknet::deploy_syscall;

    #[test]
    fn test_create_custom_note() {
        let contract = deploy();
        let test_custom_note: Note = super::CustomNoteImpl::create_custom_note(
            9, 4, 1500, NoteType::Square
        );

        let resultant_note: ByteArray = contract.get_note(test_custom_note);
        assert!(resultant_note[0] == 'R');
        assert!(resultant_note[1] == 'I');
        assert!(resultant_note[2] == 'F');
        assert!(resultant_note[3] == 'F');
        println!("custom here {:}", resultant_note);
    }
}
