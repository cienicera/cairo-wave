use core::option::OptionTrait;
use core::traits::TryInto;
const PRECISION: u64 = 1_000_000;


fn get_max_value(bit_depth: u16) -> u64 {
    if bit_depth != 4 && bit_depth != 8 && bit_depth != 16 && bit_depth != 24 && bit_depth != 32 {
    panic!("Unsupported bit depth");
    }
    let mut n = bit_depth;
    let mut result: u64 = 1;
    while n > 0 {
        result *= 2;
        n -= 1;
    };
    result - 1_u64
}
// TODO: Test append to array version for efficiency

// TODO
fn generate_sine_wave(frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32, bit_depth: u16) -> Array<u32> {
    let samples = array![];
    samples
}

fn generate_square_wave(frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32, bit_depth: u16) -> Array<u32> {
    let mut samples: Array<u32> = array![];
    let mut num_samples_left: u64 = ((duration_ms * sample_rate_hz) / 1000).into();

    let mega_full: u64 = (PRECISION * sample_rate_hz.into()) / frequency_hz.into();
    let mega_half: u64 = mega_full / 2;

    let max_value: u64 = get_max_value(bit_depth);

    while num_samples_left > 0 {
        if (num_samples_left * PRECISION) % mega_full < mega_half {
            samples.append(0);
        } else {
            samples.append(max_value.try_into().unwrap());
        }
        num_samples_left -= 1;
    };
    samples
}

// TODO
fn generate_sawtooth_wave(frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32, bit_depth: u16) -> Array<u32> {
    let mut samples: Array<u32> = array![];
    let mut num_samples_left: u64 = ((duration_ms * sample_rate_hz) / 1000).into();

    let mega_full: u64 = (PRECISION * sample_rate_hz.into()) / frequency_hz.into();


    let max_value: u64 = get_max_value(bit_depth);

    while num_samples_left > 0 {
        let value = ((num_samples_left * PRECISION) % mega_full) * max_value / mega_full;

        samples.append(value.try_into().unwrap());

        num_samples_left -= 1;
    };
    samples
}

fn generate_triangle_wave(frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32, bit_depth: u16) -> Array<u32> {
    let mut samples: Array<u32> = array![];
    let mut num_samples_left: u64 = ((duration_ms * sample_rate_hz) / 1000).into();

    let mega_full: u64 = (PRECISION * sample_rate_hz.into()) / frequency_hz.into();
    let mega_half: u64 = mega_full / 2;

    let max_value: u64 = get_max_value(bit_depth);

    while num_samples_left > 0 {
        let pos = (num_samples_left * PRECISION) % mega_full;
        let value = if pos < mega_half {
            pos * max_value / mega_half
        } else {
            (mega_full - pos) * max_value / mega_half
        };
        samples.append(value.try_into().unwrap());
        num_samples_left -= 1;
    };
    samples
}