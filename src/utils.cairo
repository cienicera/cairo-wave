use core::option::OptionTrait;
use core::traits::TryInto;
use orion::numbers::{FP16x16, FP16x16Impl, FixedTrait};
const PRECISION: u64 = 1_000_000;

// TODO: Test append to array version for efficiency

// TODO
fn generate_sine_wave(frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32) -> Array<u8> {
    let mut samples: Array<u8> = array![];
    let num_samples: u32 = ((duration_ms * sample_rate_hz).into() / 1000);
    let mut num_samples_left: u32 = ((duration_ms * sample_rate_hz).into() / 1000); //12,000

    let mut i: u32 = 1;
    let mut t: u32 = 1;

    loop {
        if i == num_samples + 1 {
            break;
        }
        let sample_value: FP16x16 = FixedTrait::new_unscaled((2 * 3 * frequency_hz * t), false);
        let test: FP16x16 = sample_value.sin();
        let accurate: u8 = (test.mag % 128).try_into().unwrap(); 
        println!("sampleeeeee {}", accurate);
        samples.append(accurate);
        num_samples_left -= 1;
        if num_samples - num_samples_left == sample_rate_hz * t {
            // println!("change in value at {}", i);
            t += 1;
        }
        i += 1;
    };
    samples
}

fn generate_square_wave(frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32) -> Array<u8> {
    let mut samples: Array<u8> = array![];
    let mut num_samples_left: u64 = ((duration_ms * sample_rate_hz) / 1000).into();

    let mega_full: u64 = (PRECISION * sample_rate_hz.into()) / frequency_hz.into();
    let mega_half: u64 = mega_full / 2;

    while num_samples_left > 0 {
        if (num_samples_left * PRECISION) % mega_full < mega_half {
            samples.append(0);
        } else {
            samples.append(255);
        }
        num_samples_left -= 1;
    };
    samples
}

// TODO
fn generate_sawtooth_wave(frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32) -> Array<u8> {
    let mut samples: Array<u8> = array![];
    let mut num_samples_left: u64 = ((duration_ms * sample_rate_hz) / 1000).into();

    let mega_full: u64 = (PRECISION * sample_rate_hz.into()) / frequency_hz.into();

    while num_samples_left > 0 {
        let value = ((num_samples_left * PRECISION) % mega_full) * 255 / mega_full;

        samples.append(value.try_into().unwrap());

        num_samples_left -= 1;
    };
    samples
}

fn generate_triangle_wave(frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32) -> Array<u8> {
    let mut samples: Array<u8> = array![];
    let mut num_samples_left: u64 = ((duration_ms * sample_rate_hz) / 1000).into();

    let mega_full: u64 = (PRECISION * sample_rate_hz.into()) / frequency_hz.into();
    let mega_half: u64 = mega_full / 2;

    while num_samples_left > 0 {
        let pos = (num_samples_left * PRECISION) % mega_full;
        let value = if pos < mega_half {
            pos * 255 / mega_half
        } else {
            (mega_full - pos) * 255 / mega_half
        };
        samples.append(value.try_into().unwrap());
        num_samples_left -= 1;
    };
    samples
}
