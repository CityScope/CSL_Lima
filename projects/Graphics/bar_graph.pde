/**
* bar_graph - create bargraphics condiring percentage      
* @author        Vanesa Alcantara
* @version       1.0
*/

public class BarGraph{
 ArrayList<Local> locals;
 int border = 40;
 int title = 40;
 int hue = 53;
  
 public BarGraph(){
   
  }
  
  public void drawBarGraph(PGraphics canvas, ArrayList<String> localsName, ArrayList<Float> localsParameters, String header){
    int Y = (canvas.height-border-title) / (10);
    int X = int((canvas.width-2*border) / (localsName.size()*1.5 + 0.5));
    int rectX = border;
    canvas.background(0);
    canvas.stroke(200);canvas.fill(200);canvas.textAlign(CENTER);canvas.textSize(16);
    canvas.line(border, canvas.height-border, canvas.width-border, canvas.height-border);
    canvas.line(border, canvas.height-border, border, title);
    canvas.text(header,canvas.width/2,title/2);canvas.textSize(12);
    for(int i=0; i<=10;i++){
      canvas.text(str(i*10),border- 20, canvas.height-border-Y*(i)); 
    }
    
    //int ind = 0;
    for(int i=0; i<localsName.size();i++){
        canvas.colorMode(HSB,360,100,100); canvas.stroke(0);canvas.fill(hue * i,100,100);
        rectX += (0.5*X);
        int begin = int( (canvas.height-border-title)*localsParameters.get(i));
        canvas.rect(rectX,canvas.height-border,X,-begin);
        canvas.fill(0,0,90);
        canvas.text(localsName.get(i),rectX+0.5*X,canvas.height-border*0.5);
        rectX += X;
    }
  }
  
  
  
}