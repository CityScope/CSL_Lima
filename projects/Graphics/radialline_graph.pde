/**
* radialline_graph - create radial graphic to compare diferent indicadors and differents entries     
* @author        Vanesa Alcantara
* @version       1.0
*/

public class RadialLine{
  int title = 40;
  int border = 40;  
  int sizeL = 16;
  int hue = 53;
  public RadialLine(){
   
  }
 
  public void drawRadialGraph(PGraphics canvas, ArrayList<ArrayList> localsParameters, String header){
    canvas.background(0);
    canvas.stroke(200);canvas.fill(200);canvas.textAlign(CENTER);canvas.textSize(16);
    canvas.text(header, canvas.width/2, title/2);
    canvas.fill(255); canvas.stroke(255);
    PVector center = new PVector( (canvas.width + border/2)/ 2 , (canvas.height +  border/2) /2 );
    int r = (canvas.height - border - title )/2 - sizeL;
    //EXTRA LINES
    int r1 = ( (canvas.height - border - title )/2 - sizeL)/ 2;
    float l1 = (2*PI*r1) / localsParameters.get(0).size();
    float arclength1 = 0;
    //
    PVector prevCoords;PVector prevCoords1;
    float l =  (2*PI*r) / localsParameters.get(0).size();
    float arclength = 0; 
    canvas.noFill(); canvas.stroke(255);
    for(int i=0; i<localsParameters.get(0).size(); i++){
      float theta = arclength / r;
      PVector  xy = new PVector(center.x+r*cos(theta),center.y+r*sin(theta));
      float theta1 = arclength1 / r1;
      PVector xy1 = new PVector(center.x+r1*cos(theta1),center.y+r1*sin(theta1));
      prevCoords = xy;
      prevCoords1 = xy1;
      arclength += l;
      arclength1 += l1;
      theta = arclength / r;
      xy = new PVector(center.x+r*cos(theta),center.y+r*sin(theta));
      theta1 = arclength1 / r1;
      xy1 = new PVector(center.x+r1*cos(theta1),center.y+r1*sin(theta1));
      canvas.line(prevCoords.x,prevCoords.y,xy.x,xy.y);
      canvas.line(prevCoords1.x,prevCoords1.y,xy1.x,xy1.y);
      canvas.line(center.x,center.y,prevCoords.x,prevCoords.y);
      //Parameter's title
      canvas.pushMatrix();
      canvas.translate(xy.x, xy.y);
      canvas.rotate(theta+PI/2);
      canvas.text("Parameters "+ str(i),0,0);
      canvas.popMatrix();
      //
    }
    //legend
    canvas.fill(#FFFFFF,90);canvas.stroke(#FFFFFF);
    canvas.rectMode(CORNER);
    canvas.rect(canvas.width * 0.80, canvas.height * 0.05 , canvas.width * 0.18, canvas.height * 0.25);
    int rs = int (( canvas.height * 0.25 - 10 - localsParameters.size() )/ localsParameters.size() ) ;
    //Draw parameters per locals
    for(int i=0; i<localsParameters.size(); i++){
      ArrayList<Float> temp = localsParameters.get(i);
      canvas.colorMode(HSB,360,100,100); canvas.stroke(hue * i,100,100);canvas.fill(hue * i,100,100,70);  
      canvas.beginShape(); 
      ArrayList<PVector> polCoords = new ArrayList();
      for(int j=0; j<temp.size();j++){
        r = int( ((canvas.height - border - title )/2 - sizeL ) * (temp.get(j)) );
        arclength = (2*PI*r*j) / temp.size();        
        float theta = arclength / r;
        PVector  xy = new PVector(center.x+r*cos(theta),center.y+r*sin(theta));
        polCoords.add(xy);
        arclength += l;
        canvas.vertex(xy.x,xy.y);
      }
      canvas.endShape(CLOSE);
      canvas.rect(canvas.width * 0.80 + 5,canvas.height * 0.05 + 5 + (rs+2) *i, rs , rs);
      canvas.fill(#FFFFFF); canvas.stroke(#FFFFFF);canvas.textSize(10);
      canvas.text(str(polygonArea(polCoords)), canvas.width * 0.80 + 5 + rs*3, canvas.height * 0.05 + 5 + (rs+2) *i + rs*0.7);
    }
    

  }
  
  
  private float polygonArea(ArrayList<PVector> xy){ 
    float area = 0;         // Accumulates area in the loop
    int j = xy.size()-1;  // The last vertex is the 'previous' one to the first
  
    for (int i=0; i<xy.size(); i++)
      { area = area +  (xy.get(j).x+xy.get(i).x) * (xy.get(j).y+xy.get(i).y); 
        j = i;  //j is previous vertex to i
      }
    return area/2;
  }

}