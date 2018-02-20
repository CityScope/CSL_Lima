
public class BloackReader extends PApplet {
  int w;
  int h;
  color actualColor;

  public BloackReader(int w, int h){
    this.w = w;
    this.h = h;
    actualColor = color(0,0,0);
  }
  
  
  public void settings() {
    size(this.w, this.h);
  }
  
  
  public void setup(){
    canvasColor = createGraphics(this.w, this.h);
    colorMode(HSB,360,100,100);
  }
  
  
  public void draw() {
    canvasColor.beginDraw();
    canvasColor.background(255);
    mesh.draw(canvasColor, true);
    canvasColor.endDraw();
    image(canvasColor, 0, 0);
  }
  
  
  void mouseClicked(){
  color selected = canvasColor.get(mouseX,mouseY);
  println(hue(selected), saturation(selected), brightness(selected));
  }
  
}