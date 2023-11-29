use cairo_wave::wave::generate_example_wave_file;

#[test]
#[available_gas(75_000_000)]
fn test_empty_wave_file() {
    let test = generate_example_wave_file();
    assert(@test.fmtChunk.ckID == @0x666D7420, 'Error');
}
