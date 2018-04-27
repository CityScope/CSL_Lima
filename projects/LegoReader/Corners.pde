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

public class Corners{
  PGraphics grayScale;
  int blocksize = 5;
  int speed = 3;
  float k=0.04;
  ArrayList<PVector> posibles = new ArrayList();
  ArrayList<PVector> calibrationPoints = new ArrayList();
  PVector P1 = new PVector(Integer.MAX_VALUE,-Integer.MAX_VALUE);
  PVector P2 = new PVector(Integer.MAX_VALUE,Integer.MAX_VALUE);
  PVector P3 = new PVector(-Integer.MAX_VALUE,Integer.MAX_VALUE);
  PVector P4 = new PVector(-Integer.MAX_VALUE,-Integer.MAX_VALUE);


  public Corners(PGraphics grayScale){
    this.grayScale = grayScale;
  }
 
 public void updateCorners(Configuration config, Capture cam){
    posibles.clear();
    calibrationPoints.clear();
    grayScale.beginDraw();
    grayScale.background(0);
    config.flip(grayScale,cam,true);
    grayScale.filter(GRAY);
    grayScale.filter(BLUR,3.5);
    grayScale.loadPixels();
    
    for(int i=0; i < grayScale.width-blocksize-speed; i += speed){
     for(int j=0; j<grayScale.height-blocksize-speed; j += speed){
       if(HarrisCorner(grayScale,i,j)){
         posibles.add(new PVector(i+speed,j+speed));
       }
     }
    }
    
    refreshP();
    for(PVector posible: posibles){
      if( posible.y < grayScale.height/2 && posible.x < P2.x) P2.x = posible.x;
      if( posible.x < grayScale.width/2 && posible.y < P2.y) P2.y = posible.y;
      if( posible.y > grayScale.height/2 && posible.x < P1.x) P1.x = posible.x;
      if( posible.x < grayScale.width/2 && posible.y > P1.y) P1.y = posible.y;
      if( posible.y < grayScale.height/2 && posible.x > P3.x) P3.x = posible.x;
      if( posible.x > grayScale.width/2 && posible.y < P3.y) P3.y = posible.y;
      if( posible.y > grayScale.height/2 && posible.x > P4.x) P4.x = posible.x;
      if( posible.x > grayScale.width/2 && posible.y > P4.y) P4.y = posible.y;
    }
    
    calibrationPoints.clear();
    calibrationPoints.add(P3);
    calibrationPoints.add(P2);
    calibrationPoints.add(P1);
    calibrationPoints.add(P4);
    //print("\n",P1,"/",P2,"/",P3,"/",P4);
    grayScale.endDraw();
    //image(grayScale, 0, 0);
    
  }
 
 
 public ArrayList<PVector> getCalibrationPoints(){
   return calibrationPoints;
 }

 public ArrayList<PVector> getPosiblesCorners(){
   return posibles;
 }
 
 public void drawCalibrationPoints(PGraphics canvasOriginal, Boolean refresh){
    canvasOriginal.fill(255,0,0);canvasOriginal.stroke(255,0,0);
    if(refresh){
      for(PVector c:calibrationPoints){
        canvasOriginal.ellipse(c.x,c.y,15,15); 
      }
    }
    
    canvasOriginal.fill(61,100,100);canvasOriginal.stroke(61,100,100);
    if(refresh){
      for(PVector p:posibles){
        canvasOriginal.ellipse(p.x,p.y,3,3);
      }    
    }   
 }

 public void applyHCD(Boolean refresh, WrappedPerspective wrappedPerspective ){
    if(refresh){
      this.updateCorners(config, cam);
      calibrationPoints = this.getCalibrationPoints();   
      posibles = this.getPosiblesCorners();
      wrappedPerspective.changeContours(calibrationPoints);
    }
 }

 
 
  public void refreshP(){
    P1 = new PVector(Integer.MAX_VALUE,-Integer.MAX_VALUE);
    P2 = new PVector(Integer.MAX_VALUE,Integer.MAX_VALUE);
    P3 = new PVector(-Integer.MAX_VALUE,Integer.MAX_VALUE);
    P4 = new PVector(-Integer.MAX_VALUE,-Integer.MAX_VALUE);  
  }
  
  public Boolean HarrisCorner(PGraphics grayScale,int iniX,int iniY){
    int[][] Ix = new int[blocksize][blocksize];
    int[][] Iy = new int[blocksize][blocksize];
    float Ex = 0;
    float Ey = 0;
    float Ex2 = 0;
    float Ey2 = 0;
    float Exy = 0;
    float[][] M = new float[2][2];
    float detM;
    float traceM;
    float R;
     
    //int coord = y*cam.width + x;
      
    for(int i=0; i<blocksize;i++){
      for(int j=0; j<blocksize;j++){
        // x variation squater
        Ix[i][j] = (int) red(grayScale.get(iniX+speed+i, iniY+j));
        Ex = ( red(grayScale.get(iniX+i,iniY+j)) - red(grayScale.get(iniX+speed+i,iniY +j))  );       
        // y variation squater
        Iy[i][j] = (int) red(grayScale.get(iniX+i, iniY+speed+j));
        Ey = (red(grayScale.get(iniX+i,iniY+j)) - red(grayScale.get(iniX+i,iniY+speed+j)) );
        
        Exy += (Ex *Ey);
        Ex2 += pow(Ex,2);
        Ey2 += pow(Ey,2);
      } 
    }
    
    M[0][0] = Ex2;
    M[1][0] = Exy;
    M[0][1] = Exy;
    M[1][1] = Ey2;  
  
    
    detM = (M[0][0] * M[1][1]) - (M[1][0] * M[0][1]);
    traceM = M[0][0] + M[1][1];
    //minLambda = detM/traceM;
    
    R = detM - k* pow(traceM,2);
    
    if(R>9000000){
      return true;
    }else{
      return false;  
    }
  }

}