
public static class Matrix {
    
    private int rows = 0;
    private int cols = 0;
    private float[][] matrix = null;

    public Matrix(int rows, int cols) {
        this.rows = rows;
        this.cols = cols;
        matrix = new float[rows][cols];        
    }

    public Matrix getRowVector(int index) {
        Matrix result = new Matrix(1, cols);
        for(int i = 0; i < cols; i++) {
            result.matrix[0][i] = matrix[index][i];
        }
        return result;
    }

    public Matrix getColumnVector(int index) {
        Matrix result = new Matrix(rows, 1);
        for(int i = 0; i < rows; i++) {
            result.matrix[i][0] = matrix[i][index];
        }
        return result;
    }

    public float getValueAt(int row, int col) {
      return matrix[row][col];
    }
    
    public float[] getRowValues(int row) {
      float[] result = new float[cols];
      for(int i = 0; i < cols; i++) {
        result[i] = matrix[row][i];
      }
      return result;
    }

  public float[] getColumnValues(int column) {
    float[] result = new float[rows];
    for(int i = 0; i < rows; i++) {
      result[i] = matrix[i][column];
    }
    return result;
  }

    public Matrix clone() {
        Matrix result = new Matrix(rows, cols);
        for(int i = 0; i < rows; i++) {
            for(int j = 0; j < cols; j++) {
                result.matrix[i][j] = matrix[i][j];
            }
        }
        return result;
    }

    public Matrix getTranspose() {
        Matrix result = new Matrix(cols, rows);
        for(int i = 0; i < rows; i++) {
            for(int j = 0; j < cols; j++) {
                result.matrix[j][i] = matrix[i][j];
            }
        }
        return result;
    }

    public void transpose() {
        matrix = getTranspose().matrix;
        int new_rows = cols;
        cols = rows;
        rows = new_rows;
    }

    public static float dotProduct(Matrix v1, Matrix v2) {
        if(v1.cols > 1 && v1.rows > 1 || v2.cols > 1 && v2.rows > 1) {
            throw new IllegalArgumentException("Dot product can only be calculated on vectors");
        } 
        if(v1.cols > 1) {
            v1 = v1.getTranspose();
        }
        if(v2.cols > 1) {
            v2 = v2.getTranspose();
        }
        float result = 0;
        for(int i = 0; i < v1.rows; i++) {
            result += v1.matrix[i][0] * v2.matrix[i][0];
        }
        return result;
    }

    public static Matrix crossProduct(Matrix v1, Matrix v2) {
        if(v1.cols > 1) {
            v1 = v1.getTranspose();
        }
        if(v2.cols > 1) {
            v2 = v2.getTranspose();
        }
        if(v1.rows != 3 || v2.rows != 3 || v1.cols != 1 || v2.cols != 1) {
            throw new IllegalArgumentException("Cross product is only defined in R3");
        }
        Matrix result = new Matrix(3, 1);
        result.matrix[0][0] = v1.matrix[1][0] * v2.matrix[2][0] - v1.matrix[2][0] * v2.matrix[1][0];
        result.matrix[1][0] = -(v1.matrix[0][0] * v2.matrix[2][0] - v1.matrix[2][0] * v2.matrix[0][0]);
        result.matrix[2][0] = v1.matrix[0][0] * v2.matrix[1][0] - v1.matrix[1][0] * v2.matrix[0][0];
        return result;
    }

    public static Matrix createRowVector(float[] values) {
        Matrix result = new Matrix(1, values.length);
        for(int i = 0; i < values.length; i++) {
            result.matrix[0][i] = values[i];
        }
        return result;
    }

    public static Matrix createColumnVector(float[] values) {
        Matrix result = new Matrix(values.length, 1);
        for(int i = 0; i < values.length; i++) {
            result.matrix[i][0] = values[i];
        }
        return result;
    }

    public static Matrix createMatrix(float[][] values) {
        Matrix result = new Matrix(values.length, values[0].length);
        for(int i = 0; i < values.length; i++) {
            for(int j = 0; j < values[0].length; j++) {
                result.matrix[i][j] = values[i][j];
            }
        }
        return result;
    }

    public static Matrix multiply(Matrix a, Matrix b) {
        if(a.cols != b.rows) {
            System.out.println("A:\n" + a);
            System.out.println("B:\n" + b);
            throw new IllegalArgumentException("Cols in A differ from rows in B");
        }
        Matrix result = new Matrix(a.rows, b.cols);
        for(int i = 0; i < result.rows; i++) {
            for(int j = 0; j < result.cols; j++) {
                float acc = 0;
                for(int x = 0; x < a.cols; x++) {
                    float aix = a.matrix[i][x];
                    float bxj = b.matrix[x][j];
                    acc = acc + aix * bxj;
                }
                result.matrix[i][j] = acc;
            }
        }
        return result;
    }

    public static Matrix add(Matrix a, Matrix b) {
        if(a.cols != b.cols || a.rows != b.rows) {
            throw new IllegalArgumentException("Addition is only defined for same size matrices");
        }
        Matrix result = new Matrix(a.rows, a.cols);
        for(int i = 0; i < a.rows; i++) {
            for(int j = 0; j < a.cols; j++) {
                result.matrix[i][j] = a.matrix[i][j] + b.matrix[i][j];
            }
        }
        return result;
    }

    public static Matrix subtract(Matrix a, Matrix b) {
        if(a.cols != b.cols || a.rows != b.rows) {
            throw new IllegalArgumentException("Subtraction is only defined for same size matrices");
        }
        Matrix result = new Matrix(a.rows, a.cols);
        for(int i = 0; i < a.rows; i++) {
            for(int j = 0; j < a.cols; j++) {
                result.matrix[i][j] = a.matrix[i][j] - b.matrix[i][j];
            }
        }
        return result;
    }

    public static Matrix scalarMultiply(float scalar, Matrix m) {
        Matrix result = new Matrix(m.rows, m.cols);
        for(int i = 0; i < m.rows; i++) {
            for(int j = 0; j < m.cols; j++) {
                result.matrix[i][j] = scalar * m.matrix[i][j];
            }
        }
        return result;
    }

    public static Matrix getIdentityMatrix(int size) {
        Matrix result = new Matrix(size, size);
        for(int i = 0; i < size; i++) {
            result.matrix[i][i] = 1;
        }
        return result;
    }

    public float determinant() {
        if(rows != cols) {
            return Float.NaN;
        }
        if(rows == 2) {
            return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];
        }
        if(rows == 3) {
            return matrix[0][0] * matrix[1][1] * matrix[2][2] +
                   matrix[0][1] * matrix[1][2] * matrix[2][0] +
                   matrix[0][2] * matrix[1][0] * matrix[2][1] -
                   matrix[0][2] * matrix[1][1] * matrix[2][0] -
                   matrix[0][1] * matrix[1][0] * matrix[2][2] -
                   matrix[0][0] * matrix[1][2] * matrix[2][1];
        }
        float det = 0;
        for(int i = 0; i < cols ; i++) {
            int sign = i % 2 == 0 ? 1 : -1;
            float subdet = cofactorZeroMatrix(i).determinant();
            det = det + sign * matrix[0][i] * subdet; 
            //System.out.println("i = " + i + " sign = " + sign + " factor " + matrix[0][i] + " cofactor det = " + subdet);
        }
        return det;
    }

    private Matrix cofactorZeroMatrix(int index) {
        Matrix result = new Matrix(rows - 1, cols - 1);
        for(int j = 0; j < index; j++) {
            for(int i = 1; i < rows; i++) {
                result.matrix[i-1][j] = matrix[i][j];
            }
        }
        for(int j = index + 1; j < rows; j++) {
            for(int i = 1; i < rows; i++) {
                result.matrix[i-1][j-1] = matrix[i][j];
            }
        }
        return result;
    }

    public Matrix getInverse() {
        if(rows != cols) {
            throw new IllegalArgumentException("Only square matrixes are invertible");
        }
        float det = determinant();
        if(det == 0) {
            return null;
        }
        if(rows == 2) {
            Matrix result = new Matrix(rows, cols);
            result.matrix[0][0] = matrix[1][1] / det;
            result.matrix[0][1] = -matrix[0][1] / det;
            result.matrix[1][0] = -matrix[1][0] / det;
            result.matrix[1][1] = matrix[0][0] / det;
            return result;
        }
        if(rows == 3) {
            Matrix result = new Matrix(rows, cols);
            result.matrix[0][0] = (matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]) / det;
            result.matrix[0][1] = -(matrix[0][1] * matrix[2][2] - matrix[0][2] * matrix[2][1]) / det;
            result.matrix[0][2] = (matrix[0][1] * matrix[1][2] - matrix[0][2] * matrix[1][1]) / det;

            result.matrix[1][0] = -(matrix[1][0] * matrix[2][2] - matrix[1][2] * matrix[2][0]) / det;
            result.matrix[1][1] = (matrix[0][0] * matrix[2][2] - matrix[0][2] * matrix[2][0]) / det;
            result.matrix[1][2] = -(matrix[0][0] * matrix[1][2] - matrix[0][2] * matrix[1][0]) / det;

            result.matrix[2][0] = (matrix[1][0] * matrix[2][1] - matrix[1][1] * matrix[2][0]) / det;
            result.matrix[2][1] = -(matrix[0][0] * matrix[2][1] - matrix[0][1] * matrix[2][0]) / det;
            result.matrix[2][2] = (matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]) / det;
            return result;
        }
        return getGaussianEliminationInverse();
    }


    public Matrix getGaussianEliminationInverse() {
        if(rows != cols) {
            throw new IllegalArgumentException("Only square matrixes are invertible");
        }
        Matrix clone = clone();
        Matrix identity = getIdentityMatrix(rows);
        for(int i = 0; i < clone.rows; i++) {
            // If pivot is zero, swap with any of the rows below
            float scalar = clone.matrix[i][i];
            if(scalar == 0) {
                for(int ii = i + 1; ii < clone.rows; ii++) {
                    if(clone.matrix[ii][i] != 0) {
                        // Swap rows
                        for(int j = 0; j < clone.cols; j++) {
                            float tmp = clone.matrix[ii][j];
                            clone.matrix[ii][j] = clone.matrix[i][j];
                            clone.matrix[i][j] = tmp;
                            tmp = identity.matrix[ii][j];
                            identity.matrix[ii][j] = identity.matrix[i][j];
                            identity.matrix[i][j] = tmp;
                        }
                        scalar = clone.matrix[i][i];
                        break;
                    }
                }
            }
            // Normalize pivot to 1
            if(scalar != 1) {
                for(int j = 0; j < clone.cols; j++) {
                    clone.matrix[i][j] = clone.matrix[i][j] / scalar;
                    identity.matrix[i][j] = identity.matrix[i][j] / scalar;
                }
            }
            // Eliminate values below pivot
            for(int ii = i+1; ii < clone.rows; ii++) {
                float factor = clone.matrix[ii][i];
                if(factor != 0) {
                    for(int j = 0; j < clone.cols; j++) {
                        clone.matrix[ii][j] = clone.matrix[ii][j] - factor * clone.matrix[i][j];
                        identity.matrix[ii][j] = identity.matrix[ii][j] - factor * identity.matrix[i][j];
                    }
                }
            }
            // Eliminate values above pivot
            for(int ii = 0; ii < i; ii++) {
                float factor = clone.matrix[ii][i];
                if(factor != 0) {
                    for(int j = 0; j < clone.cols; j++) {
                        clone.matrix[ii][j] = clone.matrix[ii][j] - factor * clone.matrix[i][j];
                        identity.matrix[ii][j] = identity.matrix[ii][j] - factor * identity.matrix[i][j];
                    }
                }
            }
        }
        return identity;
    } 


    public String toString() {
        StringBuffer sb = new StringBuffer(rows*cols*5);
        for(int i = 0; i < rows; i++) {
            for(int j = 0; j < cols; j++) {
                sb.append(String.format("%6.2f",matrix[i][j]));
                if(j < (cols - 1)) {
                    sb.append(", ");
                }
            }
            sb.append("\n");
        }
        return sb.toString();
    }

}
