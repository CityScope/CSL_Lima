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

public class Color {
  int id;
  float maxHue;
  color stdColor;
  String name;
  String acron;
  Boolean selectionMode;
  int n;
  float satMax;
  float briMin;
  float satMax2;
  float hueMin;
  float briMax;
  float briMax2;

  /**
   *Constructor for colors in hue scale
   **/
  public Color(int id, float maxHue, color stdColor, String name, String acron) {
    this.n = 0;
    this.id = id;
    this.maxHue = maxHue;
    this.stdColor = stdColor;
    this.name = name;
    this.selectionMode = false;
    this.acron = acron;
  }

  /**
   *Constructor for white
   **/
  public Color(int id, float maxHue, color stdColor, String name, String acron, float satMax, float briMin, float satMax2, float hueMin) {
    this.n = 0;
    this.id = id;
    this.maxHue = maxHue;
    this.stdColor = stdColor;
    this.name = name;
    this.selectionMode = false;
    this.satMax = satMax;
    this.briMin = briMin;
    this.satMax2 = satMax2;
    this.hueMin = hueMin;
    this.acron = acron;
  }

  /**
   *Constructor for black
   **/
  public Color(int id, float maxHue, color stdColor, String name, String acron, float briMax, float briMax2, float satMax) {
    this.n = 0;
    this.id = id;
    this.maxHue = maxHue;
    this.stdColor = stdColor;
    this.name = name;
    this.selectionMode = false;
    this.briMax = briMax;
    this.briMax2 = briMax2;
    this.satMax = satMax;
    this.acron = acron;
  }

  /**
   *Return a PVector with hue, saturation and brightness respectively
   **/
  public color getColor() {
    return this.stdColor;
  }

  /**
   *Change selectionMode of the Color to calibration mode
   **/
  public void changeMode() {
    this.selectionMode = !selectionMode;
    print(true);
  }
}
