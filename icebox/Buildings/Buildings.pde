/**
** @copyright: Copyright (C) 2018
** @authors:   Vanesa Alcántara
** @version:   2.0
** @legal:
This file is part of Building.

    Building is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Building is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with Building.  If not, see <http://www.gnu.org/licenses/>.
**/

Calibration calibration;


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