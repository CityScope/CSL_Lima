Calibration calibration;
//PRUEBA

public void settings(){
  size(300,300);
}

public void setup(){
  colorMode(HSB,360,100,100);
  calibration = new Calibration();
  String[] cali = {"Calibration"};
  PApplet.runSketch(cali,calibration);
  

}

public void draw(){
  
}