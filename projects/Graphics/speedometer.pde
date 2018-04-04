/**
* speedometer - create speedometer to show a individual KPI flow 
* @author        Vanesa Alcantara
* @version       1.0
*/

class Speedometer{
  // The radius of a circle
  
  // The width and height of the boxes
  float porcOcc = 0.01;
  int title = 40;
  int border = 40; 
  int textSize = 14;
  int a = 0;
  int b = 0;
  
  public Speedometer(){
    
  }
  
  public void drawSpeedometer(PGraphics canvas, String localsName, float parameters,int indice, String header){
  float r = (canvas.height - 2*title  - 3*textSize);
  canvas.background(0);
  canvas.stroke(200);canvas.fill(200);canvas.textAlign(CENTER);canvas.textSize(16);
  canvas.text(header, canvas.width/2, title/2);
  canvas.text(localsName, canvas.width/2, title);
  canvas.textAlign(LEFT); canvas.fill(255); canvas.stroke(255);
  canvas.noFill(); canvas.stroke(255);
  // We must keep track of our position along the curve (perimeter = 2PIr)
  float arclength ;
  if(indice != a){  
    arclength = (PI*r)+(PI*r*(parameters));
    b=0;
  }else if(b%2 != 0){
    arclength = (PI*r)+(PI*r*(parameters+0.01));  
  }else{
    arclength = (PI*r)+(PI*r*(parameters-0.01));
  }
  a = indice;
  b++;
  // Angle in radians is the arclength divided by the radius
  float theta = arclength / r; 
  float  x1 = (canvas.width + border/2)/ 2;
  float  y1 = (canvas.height -  border);
  float  x2 = x1+r*cos(theta);
  float  y2 = y1+r*sin(theta);
  // Our curve is a circle with radius r in the center of the window.
  canvas.stroke(#0000CD); canvas.strokeWeight(2);
  canvas.arc(x1, y1, r*2,r*2,PI,2*PI,CHORD);  
  canvas.ellipseMode(CENTER);

  canvas.ellipse(x2,y2,4,4);
  
  canvas.textFont(createFont("Wide", textSize)); canvas.textAlign(CENTER);
  canvas.text("0",x1+r*cos( ((PI*r)+(PI*r*(0)))/ r)- 20, y1+r*sin(( (PI*r)+(PI*r*(0))) / r)) ;
  canvas.text("50",x1+r*cos( ((PI*r)+(PI*r*(0.5)))/ r), y1+r*sin(( (PI*r)+(PI*r*(0.50))) / r) - 8) ;
  canvas.text("100",x1+r*cos( ((PI*r)+(PI*r*(1)))/ r)+ 8, y1+r*sin(( (PI*r)+(PI*r*(1))) / r)) ;
  canvas.line(x1,y1,x2,y2);
  }
  
  


}