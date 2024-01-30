use core::debug::PrintTrait;

// TODO
fn generate_sine_wave(frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32) -> Span<u8> {
    let samples = array![];
    samples.span()
}

fn generate_square_wave(frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32) -> Span<u8> {
    let mut samples: Array<u8> = array![];
    let mut num_samples_left = (duration_ms * sample_rate_hz) / 1000;
    loop {
        if num_samples_left == 0 {
            break;
        }
        let half_freq = frequency_hz / 2;
        let pos: u128 = ((sample_rate_hz.into() * duration_ms.into() - num_samples_left.into())
            * sample_rate_hz.into())
            / frequency_hz.into();
        if pos % frequency_hz.into() < half_freq.into() {
            samples.append(0);
        } else {
            samples.append(255);
        }
        num_samples_left -= 1;
    };
    samples.span()
}

// TODO
fn generate_sawtooth_wave(frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32) -> Span<u8> {
    let samples = array![];
    samples.span()
}

fn generate_triangle_wave(frequency_hz: u32, duration_ms: u32, sample_rate_hz: u32) -> Span<u8> {
    let samples = array![];
    samples.span()
}
