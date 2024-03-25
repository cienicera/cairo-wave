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

    let denum: FP32x32 = FixedTrait::new_unscaled(1000 * num_samples_left.into(), false);
    let PI: FP32x32 = FixedTrait::new(13493037705, false);
    loop {
        if num_samples_left == 0 {
            break;
        }
        let num: FP32x32 = FixedTrait::new_unscaled(
            (num_samples.into() - num_samples_left.into()) * duration_ms.into(), false
        );

        println!("denum is______ {}", denum.mag);
        println!("num is {}", num.mag);
        let t: FP32x32 = num / denum / FixedTrait::new_unscaled(1000 , false);
        println!("t is {}", t.mag);
        let mut fp: FP32x32 = (FixedTrait::new_unscaled((2 * frequency_hz.into()), false) * FixedTrait::new_unscaled(t.mag/1000 , false) * PI) / FixedTrait::new_unscaled(10000 , false);
         println!("fp is_________ {}", fp.mag);
        let mut fp_sample_value: FP32x32 = fp.sin() * FixedTrait::new_unscaled(128, false);

        println!("fp sample value is_________ {}", fp_sample_value.mag);

        fp_sample_value += FixedTrait::new_unscaled(128, false);
        println!("sample is {}", fp_sample_value.mag);
        let sample_value: u8 = (fp_sample_value % FixedTrait::new_unscaled(128, false)).try_into().unwrap();
           println!("sample value is {}", sample_value);
        samples.append(sample_value);
        num_samples_left -= 1;

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
