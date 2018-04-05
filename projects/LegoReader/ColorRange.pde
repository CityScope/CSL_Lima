/**
** @copyright: Copyright (C) 2018
** @authors:   Javier Zárate & Vanesa Alcántara
** @version:   1.0
** @legal:
This file is part of LegoReader.

    LegoReader is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    LegoReader is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with LegoReader.  If not, see <http://www.gnu.org/licenses/>.
**/

public class ColorRange extends PApplet{
 ArrayList<Color> colorLimits = new ArrayList();
 int w;
 int h;
 Boolean black =  false;
 Boolean white = false;
 Boolean otherColors = true;
 int mx;
 int my;
 int scale = 6;
 int control = 5;

  public ColorRange(ArrayList<Color> colorLimits, int w, int h){
    this.colorLimits = colorLimits;
    this.w = w;
    this.h = h;
  }
  
  
 public void settings(){
    size(this.w,this.h+20);
  }
  
  
  public void setup(){
    lengedColor = createGraphics(this.w,this.h+20);
    colorMode(HSB,360, 100, 100);
  }
  /**
  *Create the manual control to change colors limits while running
  **/  
  public void draw(){
   lengedColor.beginDraw();
   lengedColor.background(255);
   lengedColor.fill(0);
   lengedColor.rect(0,h,w,20);
   lengedColor.fill(255);
   lengedColor.textAlign(CENTER); lengedColor.rectMode(CORNER);
   lengedColor.colorMode(HSB,360,100,100);
      
   if(white){
      controlPanelWhite();   
   }else if(black){
      controlPanelBlack();  
   }else{
      controlPanelOthers(); 
   }
   lengedColor.endDraw();
   image(lengedColor,0,0);   
  }
  
  void controlPanelWhite(){
    for(int x=0;x<w;x++){
       for(int y=0;y<h;y++){
         float max = map(y,0,h,0,100);
         if(x<w/5){ //SatMax
           lengedColor.stroke(0,max,100);
           lengedColor.point(x,y);
         }else if(x<(2*w)/5){ //BriMin
           lengedColor.stroke(0,0,max);
           lengedColor.point(x,y);
         }else if(x<(3*w)/5){ //SatMax
           lengedColor.stroke(0,max,100);
           lengedColor.point(x,y);           
         }else if(x<(4*w)/5){ //HueMax
           lengedColor.stroke(max,50,100);
           lengedColor.point(x,y);           
         }else{//HueMin
           lengedColor.stroke(max,50,100);
           lengedColor.point(x,y);            
         }
       } 
     }
     
     for(Color c:colorLimits){
       if(c.name.equals("white")){
         int satMax = (int) map(c.satMax,0,100,0,h);
         int briMin = (int) map(c.briMin,0,100,0,h);
         int satMax2 = (int) map(c.satMax2,0,100,0,h);
         int maxHue = (int) map(c.maxHue,0,100,0,h);
         int hueMin = (int) map(c.hueMin,0,100,0,h);
         lengedColor.fill(0);lengedColor.stroke(0);
         lengedColor.rect((2*w)/5,0,2,h);
         lengedColor.fill(255);lengedColor.stroke(255);
         lengedColor.rect(0,satMax,w/5,control);
         lengedColor.rect(w/5,briMin,w/5,control);    
         lengedColor.rect((2*w)/5,satMax2,w/5,control);
         lengedColor.rect((3*w)/5,maxHue,w/5,control);
         lengedColor.rect((4*w)/5,hueMin,w/5,control);
         lengedColor.text("Modify white parameters",w/5,h+15);
         lengedColor.text("Modify yellow bias",(7*w)/10,h+15);
       }
     }    
  }
  
  void controlPanelBlack(){
    for(int x=0;x<w/2;x++){
       for(int y=0;y<h;y++){
         float max = map(x,0,w/2,0,100);
         lengedColor.stroke(0,0,max);
         lengedColor.point(x,y);
         if(y<h/2){
           lengedColor.point(x+w/2,y);
         }else{
           lengedColor.stroke(0,max,100);
           lengedColor.point(x+w/2,y);
         }
       }
     }
     for(Color c:colorLimits){
       if(c.name.equals("black")){
         int brimax = (int) map(c.briMax,0,100,0,w/2);
         int brimax2 = (int) map(c.briMax2,0,100,0,w/2);
         int satmax = (int) map(c.satMax,0,100,0,w/2);
         lengedColor.fill(255);lengedColor.stroke(255);
         lengedColor.rect(brimax,0,control,h);
         lengedColor.rect(brimax2 + w/2, 0,control,h/2);
         lengedColor.rect(satmax + w/2, h/2,control,h/2);
         lengedColor.text("Modify black parameters ",w/4,h+15);
         lengedColor.text("Modify red bias",(3*w)/4,h+15);
       }
     }    
  }
  
  void controlPanelOthers(){
    for(int x=0; x<w;x++){
        for(int y=0; y<h; y++){
           float i = map(x,0,w,0,360);
           lengedColor.stroke(i,y,100);
           lengedColor.point(x,y);
        }
      }
      
      for(Color c:colorLimits){
        int x = (int) map(c.maxHue,0,360,0,w);
        lengedColor.fill(255);lengedColor.stroke(255);
        lengedColor.rect(x,0,control,h);
        lengedColor.text("x = Modify color limits", w/2,h+15);
      }
  }
  
  

  /**
  *White: Select a color rect to change hue, saturation and brightness
  *Black: Select a color rect to change brigness and saturation or rect for brightness
  *Other colors:Select a color rect if it is near threshold
  **/
  void mousePressed(){
    int mousex = mouseX;
    int mousey = mouseY;
    if(white){
      for(Color c:colorLimits){
        if(c.name.equals("white")){
         int satMax = (int) map(c.satMax,0,100,0,h);
         int briMin = (int) map(c.briMin,0,100,0,h);
         int satMax2 = (int) map(c.satMax2,0,100,0,h);
         int maxHue = (int) map(c.maxHue,0,100,0,h);
         int hueMin = (int) map(c.hueMin,0,100,0,h);
         if((mousex<w/5) && (mousey>satMax) && (mousey<satMax+control)){
           print(true);
           c.changeMode();     
         }else if((mousex<(2*w)/5) && (mousey>briMin) && (mousey<briMin+control)){
           print(true);
           c.changeMode();
         }else if((mousex<(3*w)/5) && (mousey>satMax2) && (mousey<satMax2+control)){
           print(true);
           c.changeMode();
         }else if((mousex<(4*w)/5) && (mousey>maxHue) && (mousey<maxHue+control)){
           print(true);
           c.changeMode();
         }else if((mousex<w) && (mousey>hueMin) && (mousey<hueMin+control)){
           print(true);
           c.changeMode();
         }
        }        
      }
    }else if(black){
      for(Color c:colorLimits){
        if(c.name.equals("black")){
          int brimax = (int) map(c.briMax,0,100,0,w/2);
          int brimax2 = (int) map(c.briMax2,0,100,0,w/2);
          int satmax = (int) map(c.satMax,0,100,0,w/2);
          if((mousex>brimax) && (mousex<brimax+control)){
            c.changeMode();
          }else if((mousex>brimax2 + w/2) && (mousex<brimax2+control+w/2) && (mousey< h/2)){
            c.changeMode();
          }else if( (mousex>satmax + w/2) && (mousex<satmax+control+w/2) && (mousey> h/2) ){
            c.changeMode();
          }
        }
      }      
    }else{
      for(Color c:colorLimits){
        int x = (int) map(c.maxHue,0,360,0,w);
        if((mousex>x) && (mousex<x+control)){
          print(c.name);
          c.changeMode(); 
        }
      }
    }
  }
  /**
  *Set a new color Limit for hue, saturation and brightness
  *Set a new color Limit
  **/  
  void mouseReleased(){
    int mousex = mouseX;
    int mousey = mouseY;
    if(white){
      for(Color c:colorLimits){
        if(c.selectionMode){
         if((mousex<w/5)){
           c.satMax = (int) map(mousey,0,h,0,100);
           c.changeMode();     
         }else if((mousex<(2*w)/5)){
           c.briMin = (int) map(mousey,0,h,0,100);
           c.changeMode();
         }else if((mousex<(3*w)/5)){
           c.satMax2 = (int) map(mousey,0,h,0,100);
           c.changeMode();
         }else if((mousex<(4*w)/5)){
           c.maxHue = (int) map(mousey,0,h,0,100);
           c.changeMode();
         }else if((mousex<w)){
           c.hueMin = (int) map(mousey,0,h,0,100);
           c.changeMode();
         }          
        }
      }
    }else if(black){
      for(Color c:colorLimits){
       if(c.selectionMode){
         if(mousex < w/2){
           c.briMax = (int) map(mousex,0,w/2,0,100);
         }else if(mousey<h/2){
           c.briMax2 = (int) map(mousex-w/2,0,w/2,0,100);
         }else{
           c.satMax = (int) map(mousex-w/2,0,w/2,0,100);            
         }         
         c.changeMode();
       }
      }  
    }else{
      for(Color c:colorLimits){
        if(c.selectionMode){
          c.maxHue = map(mousex,0,w,0,360);
          c.changeMode();
        }
      }      
    }    
  }

  /**
  *Move from configuration for white to black and other colors
  **/
 void keyPressed(){
   switch(key){
     
    case 'b':
    if(white |otherColors){
      white=false;
      otherColors=false;
    }
    black = !black;
    if(black) print("\n Black mode on");
    break;
    
    case 'w':
    if(black | otherColors){
      black=false;
      otherColors=false;
    }
    white = !white;
    if(white) print("\n White mode on");
    break;
    
    case 'o':
    if(black | white){
      black=false;
      white=false;
    }
    otherColors = !otherColors;
    if(otherColors) print("\n Hue mode on");
    break;    
   }  
  }

  /**
  *Get all the colors
  **/
  public ArrayList<Color> selectAll(){
    return colorLimits;
  }  
  
}