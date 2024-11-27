use cubit::f64::types::fixed::{Fixed, FixedTrait, FixedZero};
const PRECISION: u64 = 1_000_000;
const ONE_SEC_IN_MS: u32 = 1_000;

// TODO Bit Depth Enum
pub fn get_max_value(bit_depth: u16) -> Option<u64> {
    let mut res = Option::None;
    if bit_depth == 8 {
        res = Option::Some(0xFF);
    } else if bit_depth == 16 {
        res = Option::Some(0xFFFF);
    } else if bit_depth == 24 {
        res = Option::Some(0xFFFFFF);
    } else {
        res = Option::Some(0xFFFFFFFF);
    }
    res
}
// TODO: Test append to array version for efficiency

pub fn generate_sine_wave(
    frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32, bit_depth: u16
) -> Array<u32> {
    let mut samples: Array<u32> = array![];
    let mut num_samples_left: u64 = ((duration_ms * sample_rate_hz.into()) / ONE_SEC_IN_MS).into();
    let num_samples: u64 = num_samples_left;
    let max_value: u64 = get_max_value(bit_depth).expect('unsupported bit depth');

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

        let mut fp_sample_value: Fixed = fp.sin_fast();

        if bit_depth == 8_u16 {
            fp_sample_value = fp_sample_value + 1_u32.into();
        } else {
            if fp_sample_value < FixedZero::zero() {
                fp_sample_value = fp_sample_value + 2_u32.into();
            }
        };

        fp_sample_value = fp_sample_value * (max_value / 2 + 1).into();
        let sample_value: u32 = fp_sample_value.floor().try_into().expect('sin wave overflow');

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

    let max_value: u64 = get_max_value(bit_depth).expect('unsupported bit depth');
    while num_samples_left > 0 {
        if (num_samples_left * PRECISION) % mega_full < mega_half {
            samples.append(0);
        } else {
            samples.append(max_value.try_into().expect('square wave overflow'));
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

    let max_value: u64 = get_max_value(bit_depth).expect('unsupported bit depth');

    while num_samples_left > 0 {
        let value = ((num_samples_left * PRECISION) % mega_full) * max_value / mega_full;

        samples.append(value.try_into().expect('sawtooth wave overflow'));

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

    let max_value: u64 = get_max_value(bit_depth).expect('unsupported bit depth');
    while num_samples_left > 0 {
        let pos = (num_samples_left * PRECISION) % mega_full;
        let value = if pos < mega_half {
            pos * max_value / mega_half
        } else {
            (mega_full - pos) * max_value / mega_half
        };
        samples.append(value.try_into().expect('triangle wave overflow'));
        num_samples_left -= 1;
    };
    samples
}

