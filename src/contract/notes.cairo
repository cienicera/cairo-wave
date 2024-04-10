use cairo_wave::note::Note;

#[starknet::interface]
trait INotesContract<TContractState> {
    fn get_note(self: @TContractState, note: Note) -> ByteArray;
    fn get_notes(self: @TContractState, note_dur_ms: u32) -> ByteArray;
    fn get_notes_stereo(self: @TContractState, note_dur_ms: u32) -> ByteArray;
}

#[starknet::contract]
mod NotesContract {
    use core::traits::Into;
    use cairo_wave::note::{Note, NoteType, Channel, Music, MusicToWavFile};
    use cairo_wave::wave::WavFile;

    use super::INotesContract;

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl NotesContractImpl of INotesContract<ContractState> {
        fn get_note(self: @ContractState, note: Note) -> ByteArray {
            let music = Music {
                channels: array![Channel { notes: array![note].span() }].span(),
                sample_rate: 8000,
                bit_depth: 16
            };
            let wav: WavFile = music.into();
            wav.into()
        }

        fn get_notes(self: @ContractState, note_dur_ms: u32) -> ByteArray {
            let note_type = NoteType::Square;
            let duration_ms = note_dur_ms;
            let sol: Note = Note { frequency_hz: 392, duration_ms, note_type };
            let la: Note = Note { frequency_hz: 440, duration_ms, note_type };
            let la2: Note = Note { frequency_hz: 440, duration_ms: 2 * duration_ms, note_type };
            let si: Note = Note { frequency_hz: 494, duration_ms, note_type };
            let do2: Note = Note { frequency_hz: 523, duration_ms: duration_ms * 2, note_type };
            let si2: Note = Note { frequency_hz: 494, duration_ms: duration_ms * 2, note_type };
            let empty: Note = Note { frequency_hz: 16000, duration_ms: 10, note_type };

            let music = Music {
                channels: array![
                    Channel {
                        notes: array![
                            sol, la, si, sol, la2, empty, la, si, do2, empty, do2, si2, empty, si2,
                        ]
                            .span()
                    },
                ]
                    .span(),
                sample_rate: 8000,
                bit_depth: 16,
            };
            let wav: WavFile = music.into();
            wav.into()
        }

        fn get_notes_stereo(self: @ContractState, note_dur_ms: u32) -> ByteArray {
            let note_type = NoteType::Square;
            let duration_ms = note_dur_ms;
            let sol: Note = Note { frequency_hz: 392, duration_ms, note_type };
            let la: Note = Note { frequency_hz: 440, duration_ms, note_type };
            let la2: Note = Note { frequency_hz: 440, duration_ms: 2 * duration_ms, note_type };
            let si: Note = Note { frequency_hz: 494, duration_ms, note_type };
            let do2: Note = Note { frequency_hz: 523, duration_ms: duration_ms * 2, note_type };
            let si2: Note = Note { frequency_hz: 494, duration_ms: duration_ms * 2, note_type };
            let empty: Note = Note { frequency_hz: 16000, duration_ms: 10, note_type };
            let mute: Note = Note { frequency_hz: 16000, duration_ms, note_type };
            let mute2: Note = Note { frequency_hz: 16000, duration_ms: duration_ms * 2, note_type };

            let music = Music {
                channels: array![
                    Channel {
                        notes: array![
                            sol, la, si, sol, la2, empty, la, si, do2, empty, do2, si2, empty, si2,
                            mute, mute, mute, mute, mute2, empty, mute, mute, mute2, empty, mute2, mute2, empty, mute2,
                        ]
                            .span()
                    },
                    Channel {
                        notes: array![
                            mute, mute, mute, mute, mute2, empty, mute, mute, mute2, empty, mute2, mute2, empty, mute2,
                            sol, la, si, sol, la2, empty, la, si, do2, empty, do2, si2, empty, si2
                        ]
                            .span()
                    },
                ]
                    .span(),
                sample_rate: 8000,
                bit_depth: 16,
            };
            let wav: WavFile = music.into();
            wav.into()
        }
    }
}

#[cfg(test)]
mod tests {
    use core::serde::Serde;
    use super::NotesContract;
    use super::{INotesContractDispatcher, INotesContractDispatcherTrait};
    use cairo_wave::note::{Note, NoteType};

    use starknet::deploy_syscall;

    fn deploy() -> INotesContractDispatcher {
        let (contract_address, _) = deploy_syscall(
            NotesContract::TEST_CLASS_HASH.try_into().unwrap(), 0, array![].span(), false
        )
            .expect('deployment failed');
        INotesContractDispatcher { contract_address }
    }

    #[test]
    fn test_get_note() {
        let contract = deploy();
        let note = Note { frequency_hz: 440, duration_ms: 1500, note_type: NoteType::Square };

        let res: ByteArray = contract.get_note(note);
        assert!(res[0] == 'R');
        assert!(res[1] == 'I');
        assert!(res[2] == 'F');
        assert!(res[3] == 'F');
        println!("{:}", res);
    }

    #[test]
    fn test_get_notes() {
        let contract = deploy();

        let res: ByteArray = contract.get_notes(100_u32);
        assert!(res[0] == 'R');
        assert!(res[1] == 'I');
        assert!(res[2] == 'F');
        assert!(res[3] == 'F');
        println!("{:}", res);
    }

    #[test]
    fn test_get_notes_stereo() {
        let contract = deploy();

        let res: ByteArray = contract.get_notes_stereo(100_u32);
        assert!(res[0] == 'R');
        assert!(res[1] == 'I');
        assert!(res[2] == 'F');
        assert!(res[3] == 'F');
        println!("{:}", res);
    }
}
