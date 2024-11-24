use cairo_wave::utils::{
    generate_square_wave, generate_sawtooth_wave, generate_triangle_wave, generate_sine_wave
};

#[derive(Drop, Copy, Serde)]
pub enum DrumSound {
    Kick,
    Snare,
    Bass,
    HiHat,
}

// Get drum sound
pub fn get_drum_sound(sound: DrumSound, sample_rate: u32, bit_depth: u16) -> Array<u32> {
    let result = match sound {
        DrumSound::Kick => generate_kick(sample_rate, bit_depth),
        DrumSound::Snare => generate_snare(sample_rate, bit_depth),
        DrumSound::Bass => generate_bass(sample_rate, bit_depth),
        DrumSound::HiHat => generate_hi_hat(sample_rate, bit_depth),
    };

    result
}
// Kick
fn generate_kick(sample_rate: u32, bit_depth: u16) -> Array<u32> {
    let mut kick = generate_square_wave(55, 130, sample_rate, bit_depth);
    add_noise(ref kick, 30);
    apply_decay(ref kick, 95);
    let shortened_length = kick.len() / 2;
    let mut shortened_kick = array![];
    let mut i: u32 = 0;
    loop {
        if i >= shortened_length {
            break;
        }
        shortened_kick.append(*kick.at(i));
        i += 1;
    };

    shortened_kick
}
// Snare
fn generate_snare(sample_rate: u32, bit_depth: u16) -> Array<u32> {
    let mut snare = generate_sawtooth_wave(220, 80, sample_rate, bit_depth);
    let mut snare_high = generate_square_wave(330, 60, sample_rate, bit_depth);
    // Mix the two waves
    let mut mixed_snare = array![];
    let mut i: u32 = 0;
    let min_len = if snare.len() < snare_high.len() {
        snare.len()
    } else {
        snare_high.len()
    };
    loop {
        if i >= min_len {
            break;
        }
        let sample1 = *snare.at(i);
        let sample2 = *snare_high.at(i);
        let mixed_sample = (sample1 * 2 + sample2) / 3;
        mixed_snare.append(mixed_sample);
        i += 1;
    };
    add_noise(ref mixed_snare, 100);
    apply_decay(ref mixed_snare, 40);

    mixed_snare
}
// Bass
fn generate_bass(sample_rate: u32, bit_depth: u16) -> Array<u32> {
    let mut bass = generate_sine_wave(90, 100, sample_rate, bit_depth);
    apply_decay(ref bass, 40);
    bass
}
// Hi-hat
fn generate_hi_hat(sample_rate: u32, bit_depth: u16) -> Array<u32> {
    let mut hi_hat1 = generate_triangle_wave(200, 16, sample_rate, bit_depth);
    let mut hi_hat2 = generate_square_wave(220, 13, sample_rate, bit_depth);
    let mut hi_hat3 = generate_sawtooth_wave(230, 15, sample_rate, bit_depth);
    add_noise(ref hi_hat1, 80);
    add_noise(ref hi_hat2, 90);
    add_noise(ref hi_hat3, 100);

    // Mix the components
    let mut mixed_hi_hat = array![];
    let mut i: u32 = 0;
    let min_len = min(min(hi_hat1.len(), hi_hat2.len()), hi_hat3.len());
    loop {
        if i >= min_len {
            break;
        }
        let sample1 = *hi_hat1.at(i);
        let sample2 = *hi_hat2.at(i);
        let sample3 = *hi_hat3.at(i);
        let mixed_sample = (sample1 / 5 + sample2 / 3 + sample3 / 2);
        mixed_hi_hat.append(mixed_sample);
        i += 1;
    };
    apply_decay(ref mixed_hi_hat, 99);
    add_noise(ref mixed_hi_hat, 150);

    mixed_hi_hat
}

fn apply_decay(ref samples: Array<u32>, decay_factor: u32) {
    let mut new_samples: Array<u32> = array![];
    let len = samples.len();
    if len == 0 {
        samples.append(1);
        return;
    }
    let mut i: u32 = 0;
    loop {
        if i >= len {
            break;
        }
        let sample = *samples.at(i);
        let decay = if len > 1 {
            (decay_factor * i) / (len - 1)
        } else {
            0
        };

        let decayed_sample = if sample > decay {
            sample - decay
        } else {
            1
        };
        new_samples.append(decayed_sample);
        i += 1;
    };
    samples = new_samples;
}

fn add_noise(ref samples: Array<u32>, noise_factor: u32) {
    let mut new_samples: Array<u32> = array![];
    let len = samples.len();
    if len == 0 {
        return;
    }
    let mut i: u32 = 0;
    loop {
        if i >= len {
            break;
        }
        let sample = *samples.at(i);
        let noise = (random() * noise_factor.into() * sample.into()) / 50;
        let noisy_sample: u32 = (sample.into() + noise).try_into().unwrap();
        new_samples.append(noisy_sample);
        i += 1;
    };
    samples = new_samples;
}

fn random() -> u64 {
    42
}


fn min(a: u32, b: u32) -> u32 {
    if a < b {
        a
    } else {
        b
    }
}
