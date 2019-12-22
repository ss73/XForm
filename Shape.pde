import java.util.StringTokenizer;
import java.io.*;

static class Shape {
  Matrix[] clean_vertices;
  Matrix[] morph_vertices;
  Matrix transform;

  int[][] edges;

  static String square = "-10, 10; 10, 10; 10, -10; -10, -10|0,1; 1,2; 2,3; 3,0"; 
  static String cube = "-10, 10, -10; 10, 10, -10; 10, -10, -10; -10, -10, -10;"+
                       "-10, 10,  10; 10, 10,  10; 10, -10,  10; -10, -10,  10|"+
                       "0,1; 1,2; 2,3; 3,0; 4,5; 5,6; 6,7; 7,4; 0,4; 1,5; 2,6; 3,7"; 
  
  public Shape() {
  }
  
  public int size() {
    return clean_vertices.length;
  }
  
  public void addTransform(Matrix transform) {
    if(this.transform == null) {
      this.transform = transform;
    }
    else {
      this.transform = Matrix.multiply(transform, this.transform);
    }
  }
  
  public void addScalarTransform(float scalar) {
    if(transform == null) {
      transform = Matrix.getIdentityMatrix(clean_vertices[0].cols);
    }
    transform = Matrix.scalarMultiply(scalar, transform);
  }
  
  public void clearTransform() {
    transform = null;
  }
  
  public void morphSource() {
    for(int i = 0; i < clean_vertices.length; i++) {
      clean_vertices[i] = Matrix.multiply(transform, clean_vertices[i]);
    }
  }
  
  public void morph() {
    for(int i = 0; i < clean_vertices.length; i++) {
      //System.out.println("i=" + i + "(" + clean_vertices.length + ")");
      morph_vertices[i] = Matrix.multiply(transform, clean_vertices[i]);
    }
  }
  
  public void morph(int index) {
    morph_vertices[index] = Matrix.multiply(transform, clean_vertices[index]);
  }
  
  public float[] point(int index) {
    int size = morph_vertices[index].matrix.length;
    float p[] = new float[size];
    for(int i = 0; i < size; i++) {
      p[i] = morph_vertices[index].matrix[i][0];
    }
    return p;
  }
  
  public float[][] edge(int index) {
    float[][] result = new float[2][];
    int from_index = edges[index][0];
    int to_index = edges[index][1];
    int from_size = morph_vertices[from_index].matrix.length;
    float p1[] = new float[from_size]; 
    for(int i = 0; i < from_size; i++) {
      p1[i] = morph_vertices[from_index].matrix[i][0];
    }
    int to_size = morph_vertices[to_index].matrix.length;
    float p2[] = new float[to_size]; 
    for(int i = 0; i < to_size; i++) {
      p2[i] = morph_vertices[to_index].matrix[i][0];
    }
    result[0] = p1;
    result[1] = p2;
    return result;
  }
  
  public float[] minMaxXYZ() {
    float minX = 9999; float maxX = -9999; float minY = 9999; float maxY = -9999; float minZ = 9999; float maxZ = -9999;
    float[] result = new float[6];
    for(int i = 0; i < clean_vertices.length; i++) {
      //System.out.println(clean_vertices[i]);
      if(clean_vertices[i].matrix[0][0] < minX){
        minX = clean_vertices[i].matrix[0][0];
      }
      if(clean_vertices[i].matrix[0][0] > maxX){
        maxX = clean_vertices[i].matrix[0][0];
      }
      if(clean_vertices[i].matrix[1][0] < minY){
        minY = clean_vertices[i].matrix[1][0];
      }
      if(clean_vertices[i].matrix[1][0] > maxY){
        maxY = clean_vertices[i].matrix[1][0];
      }
      if(clean_vertices[i].matrix[2][0] < minZ){
        minZ = clean_vertices[i].matrix[2][0];
      }
      if(clean_vertices[i].matrix[2][0] > maxZ){
        maxZ = clean_vertices[i].matrix[2][0];
      }
    }
    result[0] = minX; result[1] = maxX;
    result[2] = minY; result[3] = maxY;
    result[4] = minZ; result[5] = maxZ;
    return result;
  }
  
  public float getXSize() {
    float[] minmax = minMaxXYZ();
    return minmax[1] - minmax[0];
  }

  public float getYSize() {
    float[] minmax = minMaxXYZ();
    return minmax[3] - minmax[2];
  }
  
  public float getZSize() {
    float[] minmax = minMaxXYZ();
    return minmax[5] - minmax[4];
  }

  public void translate(float deltaX, float deltaY, float deltaZ) {
      for(int i = 0; i < clean_vertices.length; i++) {
        clean_vertices[i].matrix[0][0] = clean_vertices[i].matrix[0][0] + deltaX;
        clean_vertices[i].matrix[1][0] = clean_vertices[i].matrix[1][0] + deltaY;
        clean_vertices[i].matrix[2][0] = clean_vertices[i].matrix[2][0] + deltaZ;
      }
  }
  
  public void centerOrigin() {
    float[] minmax = minMaxXYZ();
    //System.out.println("x0=" + minmax[0] + ", x1=" + minmax[1] + ", y0=" + minmax[2] + ", y1=" + minmax[3] + ", z0=" + minmax[4] + ", z1=" + minmax[5]);
    float deltaX = -(minmax[0] + (minmax[1] - minmax[0]) / 2);
    float deltaY = -(minmax[2] + (minmax[3] - minmax[2]) / 2);
    float deltaZ = -(minmax[4] + (minmax[5] - minmax[4]) / 2);
    translate(deltaX, deltaY, deltaZ);
  }
  
  void loadObj(InputStream in) throws IOException {
    byte[] b  = new byte[in.available()];
    int len = b.length;
    int total = 0;
    while (total < len) {
      int result = in.read(b, total, len - total);
      if (result == -1) {
        break;
      }
      total += result;
      if(total % 100 == 0) {System.out.print("#");}
    }
    in.close();
    String src = new String(b, "ASCII" );
    loadObj(src);
  }
  
  void loadObj(String obj) {
    StringBuffer sb = new StringBuffer();
    StringTokenizer st = new StringTokenizer(obj.trim(), "\r\n");
    for(;st.hasMoreTokens();) {
      String line = st.nextToken().trim();
      if(line.startsWith("v ")) {
        StringTokenizer lt = new StringTokenizer(line, " ");
        lt.nextToken(); // Consume "v"
        sb.append(lt.nextToken()).append(", ");
        sb.append(lt.nextToken()).append(", ");
        sb.append(lt.nextToken());
        if(st.hasMoreTokens()) {sb.append("; ");}
      }
    }
    sb.append("|");
    st = new StringTokenizer(obj, "\r\n");
    for(;st.hasMoreTokens();) {
      String line = st.nextToken().trim();
      if(line.startsWith("f ")) {
        StringTokenizer lt = new StringTokenizer(line, " ");
        lt.nextToken(); // Consume "f"
        int[] lines = new int[lt.countTokens()];
        for(int i = 0; lt.hasMoreTokens(); i++) {
          String face = lt.nextToken(); 
          face = face.substring(0, face.indexOf('/'));
          lines[i] = Integer.parseInt(face)-1;
        }
        for(int i = 0; i < lines.length - 1; i++) {
          sb.append(lines[i]).append(",");
          sb.append(lines[i+1]).append("; ");
        }
        sb.append(lines[lines.length-1]).append(",");
        sb.append(lines[0]);
        if(st.hasMoreTokens()) {sb.append("; ");}
      }
    }
    loadPoints(sb.toString());
  }
  
  void loadPoints(String points) {
    StringTokenizer st = new StringTokenizer(points, "|");
    String vs = st.nextToken().trim();
    String es = st.nextToken().trim();
    
    st = new StringTokenizer(vs, ";");
    clean_vertices = new Matrix[st.countTokens()];
    morph_vertices = new Matrix[st.countTokens()];
    for(int i = 0; st.hasMoreTokens(); i++) {
      StringTokenizer vt = new StringTokenizer(st.nextToken(), ", ");
      float[] values = new float[vt.countTokens()];
      for(int j=0; vt.hasMoreTokens(); j++) {
        values[j] = Float.parseFloat(vt.nextToken());
      }
      Matrix m = Matrix.createColumnVector(values);
      clean_vertices[i] = m;
      morph_vertices[i] = m;
      //System.out.println(m);
    }
    st = new StringTokenizer(es, ";");
    edges = new int[st.countTokens()][2];
    for(int i = 0; st.hasMoreTokens(); i++) {
      StringTokenizer et = new StringTokenizer(st.nextToken(), ", ");
      int from = Integer.parseInt(et.nextToken());
      int to = Integer.parseInt(et.nextToken());
      edges[i][0] = from;
      edges[i][1] = to;
      //System.out.println("Connect: " + edges[i][0] + " --> " + edges[i][1]);
    }
  }
}
