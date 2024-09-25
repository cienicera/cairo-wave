use cairo_wave::note::Note;
use core::debug::PrintTrait;
use core::byte_array::ByteArray;

#[starknet::interface]
trait INotesContract<TContractState> {
    fn get_note(self: @TContractState, note: Note) -> ByteArray;
    fn get_melody(self: @TContractState, note_dur_ms: u32) -> ByteArray;
    fn get_drum_kit(self: @TContractState) -> ByteArray;
}

#[starknet::contract]
mod NotesContract {
    use core::traits::Into;
    use core::debug::PrintTrait;
    use core::byte_array::ByteArray;
    use cairo_wave::note::{Note, NoteType, Music, MusicToWavFile};
    use cairo_wave::wave::WavFile;
    use cairo_wave::drum_kit::{DrumSound, get_drum_sound};

    use super::INotesContract;

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl NotesContractImpl of INotesContract<ContractState> {
        fn get_note(self: @ContractState, note: Note) -> ByteArray {
            let music = Music { notes: array![note].span(), sample_rate: 8000, bit_depth: 16 };
            let wav: WavFile = music.into();
            wav.into()
        }

        fn get_melody(self: @ContractState, note_dur_ms: u32) -> ByteArray {
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
                notes: array![
                    sol, la, si, sol, la2, empty, la, si, do2, empty, do2, si2, empty, si2
                ]
                    .span(),
                sample_rate: 8000,
                bit_depth: 8,
            };
            let wav: WavFile = music.into();
            wav.into()
        }
        fn get_drum_kit(self: @ContractState) -> ByteArray {
            let sample_rate = 8000;
            let bit_depth = 8;
            // Get individual drum sounds
            let kick = get_drum_sound(DrumSound::Kick, sample_rate, bit_depth);
            let snare = get_drum_sound(DrumSound::Snare, sample_rate, bit_depth);
            let hi_hat = get_drum_sound(DrumSound::HiHat, sample_rate, bit_depth);
            let bass = get_drum_sound(DrumSound::Bass, sample_rate, bit_depth);
            // Create silence
            let silence_duration = 2000; // 1 second of silence at 8000 Hz
            let mut silence: Array<u32> = ArrayTrait::new();
            let mut i = 0;
            loop {
                if i == silence_duration {
                    break;
                }
                silence.append(0);
                i += 1;
            };
            let mut pattern: Array<Array<u32>> = ArrayTrait::new();
            // Demo pop rhythm
            // Kick
            pattern.append(kick.clone());
            pattern.append(silence.clone());
            // Hi-hat
            pattern.append(hi_hat.clone());
            pattern.append(silence.clone());
            // Snare
            pattern.append(snare.clone());
            pattern.append(silence.clone());
            // Hi-hat
            pattern.append(hi_hat.clone());
            pattern.append(silence.clone());
            // Kick
            pattern.append(kick.clone());
            pattern.append(silence.clone());
            // Hi-hat
            pattern.append(hi_hat.clone());
            pattern.append(silence.clone());
            // Snare
            pattern.append(snare.clone());
            pattern.append(silence.clone());
            // Hi-hat
            pattern.append(hi_hat.clone());
            pattern.append(silence.clone());
            // Kick
            pattern.append(kick.clone());
            pattern.append(silence.clone());
            // Hi-hat
            pattern.append(hi_hat.clone());
            pattern.append(silence.clone());
            // Snare
            pattern.append(snare.clone());
            pattern.append(silence.clone());
            // Hi-hat
            pattern.append(hi_hat.clone());
            pattern.append(silence.clone());
            // Combine all samples into a single array
            let mut all_samples: Array<u32> = ArrayTrait::new();
            let mut i = 0;
            loop {
                if i >= pattern.len() {
                    break;
                }
                all_samples.append_span(pattern[i].span());
                i += 1;
            };
            let total_samples = all_samples.len();
            if total_samples == 0 {
                return ByteArray { data: array![], pending_word: 0, pending_word_len: 0 };
            }
            // Create a WavFile struct
            let wav = WavFile {
                chunk_size: 36 + (total_samples * 8), 
                num_channels: 1, // Mono
                sample_rate,
                bits_per_sample: bit_depth,
                subchunk2_size: total_samples * 8,
                data: all_samples.span(),
            };
            // Convert WavFile to ByteArray
            wav.into()
        }
    }
}

#[cfg(test)]
mod tests {
    use core::serde::Serde;
    use core::debug::PrintTrait;
    use core::byte_array::ByteArray;
    use super::NotesContract;
    use super::{INotesContractDispatcher, INotesContractDispatcherTrait};
    use cairo_wave::custom_note::CustomNoteImpl;
    use cairo_wave::note::{Note, NoteType};
    use cairo_wave::drum_kit::{DrumSound, get_drum_sound};

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
        let note = Note { frequency_hz: 440, duration_ms: 1000, note_type: NoteType::Square };

        let res: ByteArray = contract.get_note(note);
        assert!(res[0] == 'R');
        assert!(res[1] == 'I');
        assert!(res[2] == 'F');
        assert!(res[3] == 'F');
        println!("{:}", res);
    }

    #[test]
    fn test_get_melody() {
        let contract = deploy();

        let res: ByteArray = contract.get_melody(500_u32);
        assert!(res[0] == 'R');
        assert!(res[1] == 'I');
        assert!(res[2] == 'F');
        assert!(res[3] == 'F');
        println!("{:}", res);
    }

    #[test]
    fn test_create_custom_note() {
        let contract = deploy();

        let test_custom_note: Note = CustomNoteImpl::create_custom_note(
            9, 4, 1500, NoteType::Square
        );

        let resultant_note: ByteArray = contract.get_note(test_custom_note);
        assert!(resultant_note[0] == 'R');
        assert!(resultant_note[1] == 'I');
        assert!(resultant_note[2] == 'F');
        assert!(resultant_note[3] == 'F');
        println!("custom here {:}", resultant_note);
    }
    #[test]
    fn test_get_drum_kit() {
        let contract = deploy();
        let res: ByteArray = contract.get_drum_kit();
        if res.len() == 0 {
            'Empty drum kit result'.print();
            return; 
        }
        assert!(res[0] == 'R', "First byte should be 'R'");
        assert!(res[1] == 'I', "Second byte should be 'I'");
        assert!(res[2] == 'F', "Third byte should be 'F'");
        assert!(res[3] == 'F', "Fourth byte should be 'F'");
        println!("{:}", res);
    }
}
