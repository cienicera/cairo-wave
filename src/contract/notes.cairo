use cairo_wave::note::Note;

#[starknet::interface]
trait INotesContract<TContractState> {
    fn get_note(self: @TContractState, note: Note) -> ByteArray;
}

#[starknet::contract]
mod NotesContract {
    use core::traits::Into;
    use cairo_wave::note::{Note, Music, MusicToWavFile};
    use cairo_wave::wave::WavFile;

    use super::INotesContract;

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl NotesContractImpl of INotesContract<ContractState> {
        fn get_note(self: @ContractState, note: Note) -> ByteArray {
            let music = Music { notes: array![note].span(), sample_rate: 8000 };
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
}
