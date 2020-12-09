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
* population_graph - create percentage population graphic      
*/

public class PopulationGraph{
  ArrayList<Local> locals;
  int w;
  int h;
  int w1;
  int h1;
  int title = 40;
  int border = 40;
  PImage free;
  PImage full;
  public PopulationGraph(){
    free = loadImage("free.png"); free.resize(int(free.width *0.05),int(free.height *0.05));
    full = loadImage("full.png"); full.resize(int(full.width *0.05),int(full.height *0.05));    
  }
  
  public void drawPopulationGraph(PGraphics canvas,ArrayList<String> localsName, ArrayList<Float> localsParameters, String header ){
    canvas.background(0);
    canvas.fill(200);
    h1 = (canvas.height-title) / localsName.size() ; 
    canvas.stroke(200);canvas.fill(200);canvas.textAlign(CENTER);canvas.textSize(16);
    canvas.text(header, canvas.width/2, title/2);
    canvas.textAlign(LEFT); canvas.fill(255); canvas.stroke(255);
    for(int i=0; i<localsName.size();  i++){
      canvas.text(localsName.get(i),border,title+ i * h1);
      int totalFull = int( localsParameters.get(i) * 10);
      for(int j=0; j<totalFull;j++){
        canvas.image(full, border + j*full.width, title+ 5 + i * h1 ); 
      }
      int totalFree = 10 - totalFull;
      for(int j=0; j<totalFree;j++){
        canvas.image(free, border + (j+totalFull)*free.width , title+ 5 + i * h1 ); 
      } 
      
      canvas.text(int(localsParameters.get(i) * 100) + "%", border + 11*full.width , title+ 5 + full.height/1.5 + i * h1);
      
    }
  }
  
  
}