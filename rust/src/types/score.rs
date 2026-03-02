use std::ops::Add;

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct Score(pub i32);

impl Add for Score {
    type Output = Score;

    fn add(self, other: Score) -> Score {
        Score(self.0 + other.0)
    }
}
