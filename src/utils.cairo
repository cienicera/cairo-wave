use cubit::f64::types::fixed::{Fixed, FixedTrait, ONE};
const PRECISION: u64 = 1_000_000;
const ONE_SEC_IN_MS: u32 = 1_000;


fn get_max_value(bit_depth: u16) -> u64 {
    if bit_depth != 4 && bit_depth != 8 && bit_depth != 16 && bit_depth != 24 && bit_depth != 32 {
        panic!("Unsupported bit depth");
    } else if bit_depth == 4 {
        return 15;
    } else if bit_depth == 8 {
        return 255;
    }
    let mut n = bit_depth;
    let mut result: u64 = 1;
    while n > 1 {
        result *= 2;
        n -= 1;
    };
    result - 1_u64
}
// TODO: Test append to array version for efficiency

// TODO
pub fn generate_sine_wave(
    frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32, bit_depth: u16
) -> Array<u32> {
    let mut samples: Array<u32> = array![];
    let mut num_samples_left: u64 = ((duration_ms * sample_rate_hz.into()) / ONE_SEC_IN_MS).into();
    let num_samples: u64 = num_samples_left;
    let max_value: u64 = get_max_value(bit_depth);

    let denum: Fixed = FixedTrait::new_unscaled(ONE_SEC_IN_MS.into() * num_samples_left, false);
    let PI: Fixed = FixedTrait::new(13493037705, false);
    loop {
        if num_samples_left == 0 {
            break;
        }
        let num: Fixed = FixedTrait::new_unscaled(
            (num_samples - num_samples_left) * duration_ms.into(), false
        );

        let t: Fixed = num / denum;
        let mut fp: Fixed = FixedTrait::new_unscaled((2 * frequency_hz.into()), false) * t * PI;
        // TODO use sin_fast whe navailable?
        let mut fp_sample_value: Fixed = fp.sin() + FixedTrait::new(ONE, false);
        fp_sample_value = fp_sample_value.abs()
            * FixedTrait::new_unscaled(max_value, false)
            / FixedTrait::new_unscaled(2, false);
        let sample_value: u32 = fp_sample_value.floor().try_into().unwrap();
        samples.append(sample_value.into());
        num_samples_left = num_samples_left - 1_u64;
    };
    samples
}

pub fn generate_square_wave(
    frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32, bit_depth: u16
) -> Array<u32> {
    let mut samples: Array<u32> = array![];
    let mut num_samples_left: u64 = ((duration_ms * sample_rate_hz) / ONE_SEC_IN_MS).into();

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
pub fn generate_sawtooth_wave(
    frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32, bit_depth: u16
) -> Array<u32> {
    let mut samples: Array<u32> = array![];
    let mut num_samples_left: u64 = ((duration_ms * sample_rate_hz) / ONE_SEC_IN_MS).into();

    let mega_full: u64 = (PRECISION * sample_rate_hz.into()) / frequency_hz.into();

    let max_value: u64 = get_max_value(bit_depth);

    while num_samples_left > 0 {
        let value = ((num_samples_left * PRECISION) % mega_full) * max_value / mega_full;

        samples.append(value.try_into().unwrap());

        num_samples_left -= 1;
    };
    samples
}

pub fn generate_triangle_wave(
    frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32, bit_depth: u16
) -> Array<u32> {
    let mut samples: Array<u32> = array![];
    let mut num_samples_left: u64 = ((duration_ms * sample_rate_hz) / ONE_SEC_IN_MS).into();

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

