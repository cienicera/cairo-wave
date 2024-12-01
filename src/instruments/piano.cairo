use cubit::f64::types::fixed::{Fixed, FixedTrait, FixedZero};

use cairo_wave::utils;
use cairo_wave::wave::WavFile;

const ONE_SEC_IN_MS: u32 = 1_000;

#[derive(Drop, Copy)]
pub struct PianoMusic {
    pub notes: Span<PianoNote>,
    pub sample_rate: u32,
    pub bit_depth: u16,
}

#[derive(Drop, Copy, Serde)]
pub struct PianoNote {
    pub frequency_hz: u32,
    pub duration_ms: u32,
}


pub trait NoteToSamples<T> {
    fn to_mono(self: T, sample_rate_hz: u32, bit_depth: u16) -> Array<u32>;
    fn append_to_mono(self: T, ref data: Array<u32>, sample_rate_hz: u32, bit_depth: u16);
}

pub impl NoteToSamplesImpl of NoteToSamples<PianoNote> {
    fn to_mono(self: PianoNote, sample_rate_hz: u32, bit_depth: u16) -> Array<u32> {
        generate(self.frequency_hz, self.duration_ms, sample_rate_hz, bit_depth,)
    }

    fn append_to_mono(self: PianoNote, ref data: Array<u32>, sample_rate_hz: u32, bit_depth: u16) {
        let mut new_data = self.to_mono(sample_rate_hz, bit_depth);
        while let Option::Some(value) = new_data.pop_front() {
            data.append(value);
        }
    }
}

// Y = sin(2 * pi * frequency * time) * exp(-0.0004 * 2 * pi * frequency * time)
// Plus overtones
fn generate(
    frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32, bit_depth: u16,
) -> Array<u32> {
    let mut samples: Array<u32> = array![];
    let mut num_samples: u64 = ((duration_ms * sample_rate_hz.into()) / ONE_SEC_IN_MS).into();
    let max_value: u64 = utils::get_max_value(bit_depth).expect('unsupported bit depth');

    let denum: Fixed = FixedTrait::new_unscaled(ONE_SEC_IN_MS.into() * num_samples, false);
    let PI: Fixed = FixedTrait::new(13493037705, false);
    let TWO: Fixed = 2_u32.into();
    for i in 0_u64
        ..num_samples
            .into() {
                let num: Fixed = (i * duration_ms.into()).into();

                let t: Fixed = num / denum;
                let fp: Fixed = frequency_hz.into() * t * TWO * PI;

                let h1: Fixed = fp.sin_fast();
                let h2: Fixed = (TWO * fp).sin_fast();
                let h3: Fixed = (3_u32.into() * fp).sin_fast();
                let h4: Fixed = (4_u32.into() * fp).sin_fast();
                let h5: Fixed = (5_u32.into() * fp).sin_fast();
                let h6: Fixed = (6_u32.into() * fp).sin_fast();
                let tmp_exp: Fixed = (-4_u32.into() * fp / 10000_u32.into()).exp();

                let mut y: Fixed = h1 * tmp_exp
                    + h2 * tmp_exp / 2_u32.into()
                    + h3 * tmp_exp / 4_u32.into()
                    + h4 * tmp_exp / 8_u32.into()
                    + h5 * tmp_exp / 16_u32.into()
                    + h6 * tmp_exp / 32_u32.into();

                y = y / 3_u32.into();
                y = y * y * y;

                if bit_depth == 8_u16 {
                    y = y + 1_u32.into();
                } else {
                    if y < FixedZero::zero() {
                        y = y + 2_u32.into();
                    }
                };

                y = y * (max_value / 2 + 1).into();
                let sample_value: u64 = y.floor().try_into().expect('sin wave overflow');
                let clamp: u32 = core::cmp::min(sample_value, max_value.into()).try_into().unwrap();

                samples.append(clamp);
            };
    samples
}

pub impl MusicToWavFile of Into<PianoMusic, WavFile> {
    fn into(self: PianoMusic) -> WavFile {
        // TODO: loop over notes
        let mut data: Array<u32> = array![];
        let mut notes: Span<PianoNote> = self.notes;
        while let Option::Some(note) = notes.pop_front() {
            let note: PianoNote = *note;
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
