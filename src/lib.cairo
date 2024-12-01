pub mod wave;
pub mod note;
pub mod utils;

// wait for cairo bump
// mod custom_note;

pub mod instruments {
    pub mod drum_kit;
    pub mod piano;
}

#[cfg(test)]
mod tests {
    mod utils;
    mod test_notes;
    mod test_drum_kit;
    mod test_bit_depth;
    mod test_piano;
}
