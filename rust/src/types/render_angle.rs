use std::f64::consts::PI;

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct RenderAngle(pub i32);

impl RenderAngle {
    pub fn to_radians(self) -> f64 {
        (self.0 as f64) * (PI / 180.0)
    }

    pub fn invert(self) -> Self {
        RenderAngle(-self.0)
    }

    pub fn increase(self, other: RenderAngle) -> Self {
        let total = self.0 + other.0;
        if total > 359 {
            RenderAngle(total - 360)
        } else {
            RenderAngle(total)
        }
    }

    pub fn decrease(self, other: RenderAngle) -> Self {
        let total = self.0 - other.0;
        if total < 0 {
            RenderAngle(total + 360)
        } else {
            RenderAngle(total)
        }
    }
}

impl std::ops::Add for RenderAngle {
    type Output = RenderAngle;

    fn add(self, other: RenderAngle) -> RenderAngle {
        self.increase(other)
    }
}

impl std::ops::Sub for RenderAngle {
    type Output = RenderAngle;

    fn sub(self, other: RenderAngle) -> RenderAngle {
        self.decrease(other)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_increase_wraps() {
        let a = RenderAngle(350);
        let b = RenderAngle(20);
        assert_eq!(a.increase(b), RenderAngle(10));
    }

    #[test]
    fn test_decrease_wraps() {
        let a = RenderAngle(10);
        let b = RenderAngle(20);
        assert_eq!(a.decrease(b), RenderAngle(350));
    }

    #[test]
    fn test_invert() {
        assert_eq!(RenderAngle(90).invert(), RenderAngle(-90));
    }

    #[test]
    fn test_add_sub_ops() {
        assert_eq!(RenderAngle(90) + RenderAngle(90), RenderAngle(180));
        assert_eq!(RenderAngle(90) - RenderAngle(90), RenderAngle(0));
    }
}
