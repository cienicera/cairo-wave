use core::traits::TryInto;
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

#[derive(Drop, Copy, Serde)]
struct Channel {
    notes: Span<Note>,
}

#[derive(Drop, Copy)]
struct Music {
    channels: Span<Channel>,
    sample_rate: u32,
    bit_depth: u16,
}

// TODO generics
trait NoteToSamples {
    fn to_samples(self: Note, sample_rate_hz: u32, bit_depth: u16) -> Array<u32>;
    fn append_to_samples(self: Note, ref data: Array<u32>, sample_rate_hz: u32, bit_depth: u16);
}

impl NoteToSamplesImpl of NoteToSamples {
    fn to_samples(self: Note, sample_rate_hz: u32, bit_depth: u16) -> Array<u32> {
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

    fn append_to_samples(self: Note, ref data: Array<u32>, sample_rate_hz: u32, bit_depth: u16) {
        let mut new_data = self.to_samples(sample_rate_hz, bit_depth);
        while let Option::Some(value) = new_data.pop_front() {
            data.append(value);
        }
    }
}

use core::debug::PrintTrait;

impl PrintTraitImpl of PrintTrait<Span<u32>> {
    fn print(self: Span<u32>) {
        let mut s = self;
        while let Option::Some(x) = s.pop_back() {
            print!(" {:}", *x);
        }
    }
}

impl MusicToWavFile of Into<Music, WavFile> {
    fn into(self: Music) -> WavFile {
        // TODO: loop over notes
        let mut data: Array<u32> = array![];
        let num_channels: u16 = self.channels.len().try_into().unwrap();
        if num_channels == 1 {
            let channel: Channel = *self.channels[0];
            let mut notes = channel.notes;
            while let Option::Some(note) = notes
                .pop_front() {
                    (*note).append_to_samples(ref data, self.sample_rate, self.bit_depth);
                };
        } else if num_channels == 2 {
            let left_channel: Channel = *self.channels[0];
            let right_channel: Channel = *self.channels[1];
            let mut left_notes = left_channel.notes;
            let mut right_notes = right_channel.notes;
            let mut left_samples: Array<u32> = array![];
            while let Option::Some(note) = left_notes
                .pop_front() {
                    (*note).append_to_samples(ref left_samples, self.sample_rate, self.bit_depth);
                };
            let mut right_samples: Array<u32> = array![];
            while let Option::Some(note) = right_notes
                .pop_front() {
                    (*note).append_to_samples(ref right_samples, self.sample_rate, self.bit_depth);
                };
            let mut count = 0;
            while count < left_samples.len() {
                data.append(*left_samples[count]);
                data.append(*right_samples[count]);
                count += 1;
            }
        }
        WavFile {
            chunk_size: (36 + data.len()),
            num_channels,
            sample_rate: self.sample_rate,
            bits_per_sample: self.bit_depth,
            subchunk2_size: data.len() * 8,
            data: data.span(),
        }
    }
}

