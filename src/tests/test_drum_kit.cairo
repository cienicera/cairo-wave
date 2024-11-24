use crate::instruments::drum_kit::{get_drum_sound, DrumSound};
use crate::wave::WavFile;
use crate::tests::utils::to_hex;

#[test]
fn test_get_drum_kit() {
    let sample_rate = 8000;
    let bit_depth = 8;
    // Get individual drum sounds
    let kick = get_drum_sound(DrumSound::Kick, sample_rate, bit_depth).span();
    let snare = get_drum_sound(DrumSound::Snare, sample_rate, bit_depth).span();
    let hi_hat = get_drum_sound(DrumSound::HiHat, sample_rate, bit_depth).span();
    let _bass = get_drum_sound(DrumSound::Bass, sample_rate, bit_depth).span();

    let mut silence: Span<u32> = [0; 2000].span();

    let mut samples: Array<u32> = array![];
    // Demo pop rhythm
    samples.append_span(kick);
    samples.append_span(silence);
    // Hi-hat
    samples.append_span(hi_hat);
    samples.append_span(silence);
    // Snare
    samples.append_span(snare);
    samples.append_span(silence);
    // Hi-hat
    samples.append_span(hi_hat);
    samples.append_span(silence);
    // Kick
    samples.append_span(kick);
    samples.append_span(silence);
    // Hi-hat
    samples.append_span(hi_hat);
    samples.append_span(silence);
    // Snare
    samples.append_span(snare);
    samples.append_span(silence);
    // Hi-hat
    samples.append_span(hi_hat);
    samples.append_span(silence);
    // Kick
    samples.append_span(kick);
    samples.append_span(silence);
    // Hi-hat
    samples.append_span(hi_hat);
    samples.append_span(silence);
    // Snare
    samples.append_span(snare);
    samples.append_span(silence);
    // Hi-hat
    samples.append_span(hi_hat);
    samples.append_span(silence);

    let total_samples = samples.len();

    // Create a WavFile struct
    let wav = WavFile {
        chunk_size: 36 + (total_samples * 8),
        num_channels: 1, // Mono
        sample_rate,
        bits_per_sample: bit_depth,
        subchunk2_size: total_samples * 8,
        data: samples.span(),
    };
    // Convert WavFile to ByteArray
    let res: ByteArray = wav.into();
    assert!(res[0] == 'R', "First byte should be 'R'");
    assert!(res[1] == 'I', "Second byte should be 'I'");
    assert!(res[2] == 'F', "Third byte should be 'F'");
    assert!(res[3] == 'F', "Fourth byte should be 'F'");

    println!("{:}", to_hex(@res));
}
