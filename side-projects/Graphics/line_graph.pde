/**
** @copyright: Copyright (C) 2018
** @authors:   Vanesa Alcántara
** @version:   1.0
** @legal:
This file is part of Graphics.

    Graphics is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Graphics is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with Graphics.  If not, see <http://www.gnu.org/licenses/>.
**/

/**
* line_graph - create line graphic with multiples entries      
*/
public class LineGraph{
  ArrayList<Local> locals;
  ArrayList<PVector> lastCoord = new ArrayList();
  ArrayList<Line> lines = new ArrayList();
  int repeat = 0;
  int w;
  int h;
  int border = 40;
  int title = 40;
  int X;
  int Y;
  int hue = 53;
  DateTimeFormatter fmtToShow = DateTimeFormat.forPattern("dd/MM");
  
 public LineGraph(ArrayList<Local> locals, int w,int h){
   this.locals = locals;
   this.w = w;
   this.h = h;
   this.X = (w-2*border) / (chronometer.size()-1);
   this.Y = (h-border-title) / (10);
   for(int j = 0; j < locals.size(); j++){
     lastCoord.add(j,new PVector(border,h-border)); 
   }
 }
 
 public void drawLineGraph(PGraphics canvas,ArrayList<Float> localsParameters, ArrayList<DateTime> chronometer, String header){
   canvas.background(0);
   if(indice == 0){
     repeat++;
   }
   canvas.ellipseMode(CENTER); canvas.stroke(200);canvas.fill(200);canvas.textAlign(CENTER);canvas.textSize(16);
   canvas.line(border,h-border,border,title);
   canvas.line(border,h-border,w-border,h-border);
   canvas.text(header, w/2,title/2);canvas.textSize(12);
   for(int i=0; i<=10;i++){
     canvas.text(str(i*10),border- 20, h-border-Y*(i)); 
   }
   canvas.textAlign(RIGHT);
   for(int j=0; j<chronometer.size()-1;j++){
     canvas.text(chronometer.get(j+1).toString(fmtToShow),(((j+1)*(w-2*border))/(chronometer.size() - 1))+ border, h - (border - 20));
   }

  for(int i=0; i<localsParameters.size(); i++){
    int x = (indice) * X + border;
    int y = int( (h-border-title) * (1-localsParameters.get(i)) + border );
    if(indice !=0) lines.add(new Line(lastCoord.get(i).x,lastCoord.get(i).y,x,y,i,repeat));
    lastCoord.set(i,new PVector(x,y));     
  }
  
  for(Line line:lines){
    canvas.colorMode(HSB,360,100,100); canvas.stroke(hue * line.TYPE,100,100);
    if(line.repeat == repeat) canvas.line(line.LASTCOORDSx, line.LASTCOORDSy, line.COORDSx, line.COORDSy);
  }
 }
}

public class Line{
  public int TYPE;
  protected final float LASTCOORDSx;
  protected final float LASTCOORDSy;
  protected final int COORDSx;
  protected final int COORDSy;
  protected final int repeat;
  public Line(float lastCoordsx,float lastCoordsy,int coordsx, int coordsy,int type, int repeat){
    TYPE =  type;
    COORDSx = coordsx;
    COORDSy = coordsy;
    LASTCOORDSy = lastCoordsy;
    LASTCOORDSx = lastCoordsx;
    this.repeat =  repeat;   
  }

 }