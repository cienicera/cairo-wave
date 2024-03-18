use core::array::SpanTrait;
use cairo_wave::utils;
use cairo_wave::wave::WavFile;

#[derive(Drop, Copy, Serde)]
enum NoteType {
    Sine,
    Square,
    Sawtooth,
    Triangle,
}

#[derive(Drop, Copy, Serde)]
struct Note {
    frequency_hz: u32,
    duration_ms: u32,
    note_type: NoteType,
}

#[derive(Drop, Copy)]
struct Music {
    notes: Span<Note>,
    sample_rate: u32,
}

// TODO generics
trait NoteToSamples {
    fn to_mono(self: Note, sample_rate_hz: u32) -> Array<u8>;
    fn append_to_mono(self: Note, ref data: Array<u8>, sample_rate_hz: u32);
}

impl NoteToSamplesImpl of NoteToSamples {
    fn to_mono(self: Note, sample_rate_hz: u32) -> Array<u8> {
        match self.note_type {
            NoteType::Sine => utils::generate_sine_wave(
                self.frequency_hz, self.duration_ms, sample_rate_hz
            ),
            NoteType::Square => utils::generate_square_wave(
                self.frequency_hz, self.duration_ms, sample_rate_hz
            ),
            NoteType::Sawtooth => utils::generate_sawtooth_wave(
                self.frequency_hz, self.duration_ms, sample_rate_hz
            ),
            NoteType::Triangle => utils::generate_triangle_wave(
                self.frequency_hz, self.duration_ms, sample_rate_hz
            ),
        }
    }

    fn append_to_mono(self: Note, ref data: Array<u8>, sample_rate_hz: u32) {
        let mut new_data = self.to_mono(sample_rate_hz);
        while let Option::Some(value) = new_data.pop_front() {
            data.append(value);
        }
    }
}

use core::debug::PrintTrait;

impl PrintTraitImpl of PrintTrait<Span<u8>> {
    fn print(self: Span<u8>) {
        let mut s = self;
        while let Option::Some(x) = s.pop_back() {
            print!(" {:}", *x);
        }
    }
}

impl MusicToWavFile of Into<Music, WavFile> {
    fn into(self: Music) -> WavFile {
        // TODO: loop over notes
        let mut data: Array<u8> = array![];
        let mut notes = self.notes;
        while let Option::Some(note) = notes
            .pop_front() {
                (*note).append_to_mono(ref data, self.sample_rate);
            };
        WavFile {
            chunk_size: (36 + data.len()),
            num_channels: 1_u16,
            sample_rate: self.sample_rate,
            bits_per_sample: 8_u16,
            subchunk2_size: data.len() * 8,
            data: data.span()
        }
    }
}

