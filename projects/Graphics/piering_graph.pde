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
* piering_graph - create piering graphic to easily compare by filter two aspects(around the circle and across the circle)      
*/

public class PieRing{
  ArrayList<Integer> angles = new ArrayList();
  int r;
  String message;
  String header;
  ArrayList promParkHour = new ArrayList();
  int title = 40;

  
  public PieRing(){

  }
  
  public void drawPieRing(PGraphics canvas, ArrayList<String> localsName, ArrayList<ArrayList> allLocalParameters, String header){
    canvas.background(0);
    this.r = int((canvas.height*0.75)/2);
    for(int i=0;i<localsName.size();i++){
      angles.add(360/locals.size());     
    }
    canvas.stroke(200);canvas.fill(200);canvas.textAlign(CENTER);canvas.textSize(16);
    canvas.text(header, canvas.width/2, title/2);
    canvas.textAlign(LEFT); canvas.fill(255); canvas.stroke(255);
    canvas.smooth();
    canvas.translate(canvas.width / 2, canvas.height / 2 );
    canvas.noFill();
    canvas.stroke(0);
    for(int i=0; i< allLocalParameters.size();i++){
      pieChart(canvas,r*2 - (r*2/allLocalParameters.size())*i, i,allLocalParameters.get(i));     
    }
    
    for(int j=0; j<localsName.size(); j++){
      float arclength = 0;
      message = localsName.get(j);
      for(int i=0; i<message.length();i++){
        char currentChar = message.charAt(i);
        float w = textWidth(currentChar);
        arclength += w/2;
        float theta;
        if(j ==0){
         theta = 0 +arclength/r; 
        }else{
         int angle = 0;
         for(int c=0;c<j;c++){
           angle += angles.get(c);
         }
         theta = radians(angle) + arclength / r;
        }
        canvas.pushMatrix();
        // Polar to cartesian coordinate conversion
        canvas.translate(r*cos(theta), r*sin(theta));
        // Rotate the box
        canvas.rotate(theta+PI/2); // rotation is offset by 90 degrees
        // Display the character
        canvas.fill(200);
        canvas.textAlign(CENTER);
        canvas.textSize(13);
        canvas.text(currentChar,0,0);
        canvas.popMatrix();
        // Move halfway again
        arclength += w/2;
      }
      
    }
    
    
  }

  public void pieChart(PGraphics canvas,float diameter, int i,ArrayList<Float> localsParameters) {
      float lastAngle = 0;
      for (int x = 0; x < localsParameters.size(); x++) {  
        color colorR= lerpColor(#21AB34, #CF3434, localsParameters.get(x));
        canvas.fill(colorR);
        canvas.stroke(1);
        canvas.arc(0,0, diameter, diameter, lastAngle, lastAngle+radians(angles.get(x)),PIE);
        lastAngle += radians(angles.get(x));
    }
  }
  
}