#[derive(Copy, Drop)]
struct RiffChunk {
    ckID: felt252,
    ckSize: felt252,
    WAVEID: felt252,
}

#[derive(Copy, Drop)]
struct fmtChunk {
    ckID: felt252,
    ckSize: felt252,
    WAVEID: felt252,
    fmtID: felt252,
    fmtSize: felt252,
    fmtCode: FormatCode,
    channels: felt252,
    sampleRate: felt252,
    byteRate: felt252,
    blockAlign: felt252,
    bitsPerSample: felt252,
}

#[derive(Copy, Drop)]
struct dataChunk {
    ckID: felt252,
    ckSize: felt252,
    WAVEID: felt252,
    data: Span<u8>,
}

#[derive(Copy, Drop)]
enum FormatCode {
    PCM, // 0x0001,
    IEEE_FLOAT, // 0x0003,
    ALAW, // 0x0006,
    MULAW, // 0x0007,
    EXTENSIBLE, // 0xFFFE,
}

const ckID: felt252 = 0x52494646;
const WAVEID: felt252 = 0x57415645;
const fmtID: felt252 = 0x666D7420;
const dataID: felt252 = 0x64617461;

#[derive(Copy, Drop)]
struct WavFile {
    riffChunk: RiffChunk,
    fmtChunk: fmtChunk,
    dataChunk: dataChunk,
}
fn generate_example_wave_file() -> WavFile {
    let riffChunk = RiffChunk { ckID: ckID, ckSize: 0, WAVEID: WAVEID, };
    let fmtChunk = fmtChunk {
        ckID: fmtID,
        ckSize: 0,
        WAVEID: WAVEID,
        fmtID: fmtID,
        fmtSize: 16,
        fmtCode: FormatCode::PCM,
        channels: 1,
        sampleRate: 44100,
        byteRate: 88200,
        blockAlign: 2,
        bitsPerSample: 16,
    };
    let dataChunk = dataChunk { ckID: dataID, ckSize: 0, WAVEID: WAVEID, data: array![].span(), };
    let wavFile = WavFile { riffChunk: riffChunk, fmtChunk: fmtChunk, dataChunk: dataChunk, };
    return wavFile;
}
