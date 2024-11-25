use cairo_wave::utils;
use cairo_wave::wave::WavFile;

#[derive(Drop, Copy, Serde)]
pub enum NoteType {
    Sine,
    Square,
    Sawtooth,
    Triangle,
}

#[derive(Drop, Copy, Serde)]
pub struct Note {
    pub frequency_hz: u32,
    pub duration_ms: u32,
    pub note_type: NoteType,
}

#[derive(Drop, Copy)]
pub struct Music {
    pub notes: Span<Note>,
    pub sample_rate: u32,
    pub bit_depth: u16,
}

pub trait NoteToSamples<T> {
    fn to_mono(self: T, sample_rate_hz: u32, bit_depth: u16) -> Array<u32>;
    fn append_to_mono(self: T, ref data: Array<u32>, sample_rate_hz: u32, bit_depth: u16);
}

pub impl NoteToSamplesImpl of NoteToSamples<Note> {
    fn to_mono(self: Note, sample_rate_hz: u32, bit_depth: u16) -> Array<u32> {
        match self.note_type {
            NoteType::Sine => utils::generate_sine_wave(
                self.frequency_hz, self.duration_ms, sample_rate_hz, bit_depth
            ),
            NoteType::Square => utils::generate_square_wave(
                self.frequency_hz, self.duration_ms, sample_rate_hz, bit_depth
            ),
            NoteType::Sawtooth => utils::generate_sawtooth_wave(
                self.frequency_hz, self.duration_ms, sample_rate_hz, bit_depth
            ),
            NoteType::Triangle => utils::generate_triangle_wave(
                self.frequency_hz, self.duration_ms, sample_rate_hz, bit_depth
            ),
        }
    }

    fn append_to_mono(self: Note, ref data: Array<u32>, sample_rate_hz: u32, bit_depth: u16) {
        let mut new_data = self.to_mono(sample_rate_hz, bit_depth);
        while let Option::Some(value) = new_data.pop_front() {
            data.append(value);
        }
    }
}

pub impl MusicToWavFile of Into<Music, WavFile> {
    fn into(self: Music) -> WavFile {
        // TODO: loop over notes
        let mut data: Array<u32> = array![];
        let mut notes: Span<Note> = self.notes;
        while let Option::Some(note) = notes.pop_front() {
            let note: Note = *note;
            note.append_to_mono(ref data, self.sample_rate, self.bit_depth);
        };
        WavFile {
            chunk_size: (36 + data.len()),
            num_channels: 1_u16,
            sample_rate: self.sample_rate,
            bits_per_sample: self.bit_depth,
            subchunk2_size: data.len() * 8,
            data: data.span(),
        }
    }
}

