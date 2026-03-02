#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct CurrentFrame {
    maximum: i32,
    current: i32,
}

impl CurrentFrame {
    pub fn new(maximum: i32) -> Self {
        CurrentFrame {
            maximum,
            current: 0,
        }
    }

    pub fn inc(&self) -> Self {
        if self.current + 1 >= self.maximum {
            CurrentFrame {
                maximum: self.maximum,
                current: 0,
            }
        } else {
            CurrentFrame {
                maximum: self.maximum,
                current: self.current + 1,
            }
        }
    }

    pub fn dec(&self) -> Self {
        if self.current - 1 < 0 {
            CurrentFrame {
                maximum: self.maximum,
                current: self.maximum - 1,
            }
        } else {
            CurrentFrame {
                maximum: self.maximum,
                current: self.current - 1,
            }
        }
    }

    pub fn get(&self) -> i32 {
        self.current
    }
}

impl std::fmt::Display for CurrentFrame {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Frame {}, maximum {}", self.current, self.maximum)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_inc_wraps() {
        let frame = CurrentFrame::new(3);
        assert_eq!(frame.get(), 0);
        let frame = frame.inc();
        assert_eq!(frame.get(), 1);
        let frame = frame.inc();
        assert_eq!(frame.get(), 2);
        let frame = frame.inc();
        assert_eq!(frame.get(), 0); // wraps
    }

    #[test]
    fn test_dec_wraps() {
        let frame = CurrentFrame::new(3);
        assert_eq!(frame.get(), 0);
        let frame = frame.dec();
        assert_eq!(frame.get(), 2); // wraps to max-1
        let frame = frame.dec();
        assert_eq!(frame.get(), 1);
    }
}
