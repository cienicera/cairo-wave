const CHUNK_ID: felt252 = 'RIFF';
const WAVE_ID: felt252 = 'WAVE';
const FMT_ID: felt252 = 'fmt ';
const DATA_ID: felt252 = 'data';
const PCM_SUBCHUNK1_SIZE: u32 = 16;
const PCM_FORMAT: u16 = 1;

#[derive(Copy, Drop)]
pub struct WavFile {
    pub chunk_size: u32,
    pub num_channels: u16,
    pub sample_rate: u32,
    pub bits_per_sample: u16,
    pub subchunk2_size: u32,
    pub data: Span<u32>,
}


impl WavToBytes of Into<WavFile, ByteArray> {
    fn into(self: WavFile) -> ByteArray {
        let mut bytes: ByteArray = "";
        // TODO: Assert correct data size?

        bytes.append_word(CHUNK_ID, 4);
        bytes.append_word_rev(self.chunk_size.into(), 4);
        bytes.append_word(WAVE_ID, 4);
        bytes.append_word(FMT_ID, 4);
        bytes.append_word_rev(PCM_SUBCHUNK1_SIZE.into(), 4);
        bytes.append_word_rev(PCM_FORMAT.into(), 2);
        bytes.append_word_rev(self.num_channels.into(), 2);
        bytes.append_word_rev(self.sample_rate.into(), 4);
        let byte_rate = self.sample_rate
            * self.num_channels.into()
            * self.bits_per_sample.into()
            / 8_u32;
        bytes.append_word_rev(byte_rate.into(), 4);
        let block_align = self.num_channels.into() * self.bits_per_sample.into() / 8_u16;
        bytes.append_word_rev(block_align.into(), 2);
        bytes.append_word_rev(self.bits_per_sample.into(), 2);
        bytes.append_word(DATA_ID, 4);
        bytes.append_word_rev(self.subchunk2_size.into(), 4);

        // Append data
        let mut count = 0;
        if self.bits_per_sample == 4_u16 {
            while self.data.len() - count > 1 {
                let byte: u32 = *self.data[count] * 0x10 + *self.data[count + 1];
                bytes.append_byte((byte).try_into().unwrap());
                count += 2;
            };
        } else {
            while self.data.len() - count > 0 {
                bytes
                    .append_word_rev(
                        (*self.data[count]).into(), self.bits_per_sample.into() / 8_u32
                    );
                count += 1;
            };
        }

        bytes
    }
}

