import interfascia.*;

GUIController c;
IFCheckBox cbx, cby, cbz, cbdots, cblines;

Shape s = new Shape();
Matrix rot3DZ = null;
Matrix projIso = null;
float scale = 10.0;
float theta = 1;
float alpha = PI/180*35.264;
float beta = PI/180*45;
float[][] iso_alpha = {
  {1,           0,          0},
  {0,  cos(alpha), sin(alpha)},
  {0, -sin(alpha), cos(alpha)}
};
float[][] iso_beta = {
  { cos(beta), 0, -sin(beta) },
  {         0, 1,          0 },
  { sin(beta), 0,  cos(beta) }
};
boolean drawPoints = false;
boolean drawEdges = true;

void setup() {
  size(700, 700);  

  c = new GUIController(this);
  cbx = new IFCheckBox("Rotate X", 20, 20);
  cby = new IFCheckBox("Rotate Y", 20, 40);
  cby.keyEvent(new KeyEvent(null, 0, KeyEvent.TYPE, 0, ' ', 0));
  cbz = new IFCheckBox("Rotate Z", 20, 60);
  cbdots = new IFCheckBox("Draw points", 20, 80);
  cblines = new IFCheckBox("Draw lines", 20, 100);
  cblines.keyEvent(new KeyEvent(null, 0, KeyEvent.TYPE, 0, ' ', 0));
  
  c.add(cbx); c.add(cby); c.add(cbz); c.add(cbdots); c.add(cblines);  
  
  try {
    //s.loadObj(createInput("ogreRelief.obj"));
    s.loadObj(createInput("MaleLow.obj"));
    //s.loadObj(createInput("spoon.obj"));
    //s.loadObj(createInput("teacup.obj"));
    //s.loadObj(createInput("teapot.obj"));
    //s.loadPoints(Shape.cube);
  }
  catch(IOException ioe) {
    ioe.printStackTrace();
    s.loadPoints(Shape.cube);
  }
  scale = 0.9 * height/Math.max(s.getXSize(), Math.max(s.getYSize(), s.getZSize()));
  s.centerOrigin();
  s.addTransform(getZrotation(180.0));
  s.morphSource();
  projIso = Matrix.multiply(Matrix.createMatrix(iso_alpha), Matrix.createMatrix(iso_beta));
}

Matrix getZrotation(float theta) {
  float[][] rot3D_raw = {{ cos(PI/180*theta), -sin(PI/180*theta), 0 }, 
                         { sin(PI/180*theta),  cos(PI/180*theta), 0 },
                         {                 0,                  0, 1 }};
  return Matrix.createMatrix(rot3D_raw);
}

Matrix getYrotation(float theta) {
  float[][] rot3D_raw = {{  cos(PI/180*theta), 0, sin(PI/180*theta) }, 
                         {                  0, 1,                 0 },
                         { -sin(PI/180*theta), 0, cos(PI/180*theta) }
  };
  return Matrix.createMatrix(rot3D_raw);
}

Matrix getXrotation(float theta) {
  float[][] rot3D_raw = {{ 1,                 0,                  0 }, 
                         { 0, cos(PI/180*theta), -sin(PI/180*theta) },
                         { 0, sin(PI/180*theta),  cos(PI/180*theta) }};
  return Matrix.createMatrix(rot3D_raw);
}


void draw() {
  background(200);
  stroke(0);
  theta = theta + 1;
  if(theta >= 360) {
    theta = 0;
  }
  s.clearTransform();
  if(cby.isSelected()) {
    s.addTransform(getYrotation(theta));
  }
  if(cbz.isSelected()) {
    s.addTransform(getZrotation(theta));
  }
  if(cbx.isSelected()) {
    s.addTransform(getXrotation(theta));
  }
  s.addTransform(projIso);
  s.addScalarTransform(scale);
  s.morph();
  pushMatrix();
  translate(width/2, height/2);
  if(cbdots.isSelected()) {
    for(int i = 0; i < s.size(); i++) {
      circle(s.point(i)[0], s.point(i)[1], 2);
    }
  }
  if(cblines.isSelected()) {
    for(int i = 0; i < s.edges.length; i++) {
      float[][] edge = s.edge(i);
      line(edge[0][0], edge[0][1], edge[1][0], edge[1][1]);
    }
  }
  popMatrix();
}
