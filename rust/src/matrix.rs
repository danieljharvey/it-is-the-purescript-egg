/// Generic Matrix<T> - column-major flat Vec<T> to match PureScript `matrices` library.
/// Access: data[x * height + y]

#[derive(Clone, Debug)]
pub struct Matrix<T> {
    data: Vec<T>,
    width: usize,
    height: usize,
}

pub struct IndexedItem<T> {
    pub x: usize,
    pub y: usize,
    pub value: T,
}

impl<T: Clone> Matrix<T> {
    pub fn repeat(width: usize, height: usize, value: T) -> Self {
        Matrix {
            data: vec![value; width * height],
            width,
            height,
        }
    }

    pub fn from_2d(cols: &[Vec<T>]) -> Option<Self> {
        if cols.is_empty() {
            return None;
        }
        let width = cols.len();
        let height = cols[0].len();
        if height == 0 {
            return None;
        }
        for col in cols {
            if col.len() != height {
                return None;
            }
        }
        let mut data = Vec::with_capacity(width * height);
        for col in cols {
            data.extend_from_slice(col);
        }
        Some(Matrix {
            data,
            width,
            height,
        })
    }

    pub fn width(&self) -> usize {
        self.width
    }

    pub fn height(&self) -> usize {
        self.height
    }

    pub fn get(&self, x: usize, y: usize) -> Option<&T> {
        if x < self.width && y < self.height {
            Some(&self.data[x * self.height + y])
        } else {
            None
        }
    }

    pub fn set(&self, x: usize, y: usize, value: T) -> Option<Self> {
        if x < self.width && y < self.height {
            let mut new_data = self.data.clone();
            new_data[x * self.height + y] = value;
            Some(Matrix {
                data: new_data,
                width: self.width,
                height: self.height,
            })
        } else {
            None
        }
    }

    pub fn to_indexed_array(&self) -> Vec<IndexedItem<&T>> {
        let mut result = Vec::with_capacity(self.width * self.height);
        for x in 0..self.width {
            for y in 0..self.height {
                result.push(IndexedItem {
                    x,
                    y,
                    value: &self.data[x * self.height + y],
                });
            }
        }
        result
    }

    pub fn map<U: Clone, F: Fn(&T) -> U>(&self, f: F) -> Matrix<U> {
        Matrix {
            data: self.data.iter().map(f).collect(),
            width: self.width,
            height: self.height,
        }
    }

    pub fn indexed_map<U: Clone, F: Fn(usize, usize, &T) -> U>(&self, f: F) -> Matrix<U> {
        let mut data = Vec::with_capacity(self.width * self.height);
        for x in 0..self.width {
            for y in 0..self.height {
                data.push(f(x, y, &self.data[x * self.height + y]));
            }
        }
        Matrix {
            data,
            width: self.width,
            height: self.height,
        }
    }

    pub fn zip_with<U: Clone, V: Clone, F: Fn(&T, &U) -> V>(
        &self,
        other: &Matrix<U>,
        f: F,
    ) -> Option<Matrix<V>> {
        if self.width != other.width || self.height != other.height {
            return None;
        }
        let data: Vec<V> = self
            .data
            .iter()
            .zip(other.data.iter())
            .map(|(a, b)| f(a, b))
            .collect();
        Some(Matrix {
            data,
            width: self.width,
            height: self.height,
        })
    }

    pub fn empty() -> Self {
        Matrix {
            data: Vec::new(),
            width: 0,
            height: 0,
        }
    }
}

impl<T: PartialEq> PartialEq for Matrix<T> {
    fn eq(&self, other: &Self) -> bool {
        self.width == other.width && self.height == other.height && self.data == other.data
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_repeat() {
        let m = Matrix::repeat(3, 2, 0);
        assert_eq!(m.width(), 3);
        assert_eq!(m.height(), 2);
        assert_eq!(m.get(0, 0), Some(&0));
        assert_eq!(m.get(2, 1), Some(&0));
        assert_eq!(m.get(3, 0), None);
    }

    #[test]
    fn test_from_2d() {
        let cols = vec![vec![1, 2, 3], vec![4, 5, 6]];
        let m = Matrix::from_2d(&cols).unwrap();
        assert_eq!(m.width(), 2);
        assert_eq!(m.height(), 3);
        assert_eq!(m.get(0, 0), Some(&1));
        assert_eq!(m.get(0, 2), Some(&3));
        assert_eq!(m.get(1, 0), Some(&4));
        assert_eq!(m.get(1, 2), Some(&6));
    }

    #[test]
    fn test_set() {
        let m = Matrix::repeat(2, 2, 0);
        let m2 = m.set(1, 0, 42).unwrap();
        assert_eq!(m2.get(1, 0), Some(&42));
        assert_eq!(m.get(1, 0), Some(&0)); // original unchanged
    }

    #[test]
    fn test_indexed_map() {
        let m = Matrix::repeat(2, 2, 0);
        let m2 = m.indexed_map(|x, y, _| x * 10 + y);
        assert_eq!(m2.get(0, 0), Some(&0));
        assert_eq!(m2.get(1, 0), Some(&10));
        assert_eq!(m2.get(0, 1), Some(&1));
        assert_eq!(m2.get(1, 1), Some(&11));
    }

    #[test]
    fn test_to_indexed_array() {
        let cols = vec![vec![10, 20], vec![30, 40]];
        let m = Matrix::from_2d(&cols).unwrap();
        let arr = m.to_indexed_array();
        assert_eq!(arr.len(), 4);
        assert_eq!(arr[0].x, 0);
        assert_eq!(arr[0].y, 0);
        assert_eq!(*arr[0].value, 10);
        assert_eq!(arr[2].x, 1);
        assert_eq!(arr[2].y, 0);
        assert_eq!(*arr[2].value, 30);
    }

    #[test]
    fn test_zip_with() {
        let a = Matrix::repeat(2, 2, 1);
        let b = Matrix::repeat(2, 2, 2);
        let c = a.zip_with(&b, |x, y| x + y).unwrap();
        assert_eq!(c.get(0, 0), Some(&3));
    }
}
