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

public class BlockReader extends PApplet {
  int w;
  int h;
  color actualColor;

  public BlockReader(int w, int h) {
    this.w = w;
    this.h = h;
    actualColor = color(0, 0, 0);
  }

  public void settings() {
    size(this.w, this.h);
  }

  public void setup() {
    canvasColor = createGraphics(this.w, this.h);
    colorMode(HSB, 360, 100, 100);
  }

  public void draw() {
    canvasColor.beginDraw();
    canvasColor.background(255);
    canvasColor.strokeWeight(1);
    mesh.checkPattern();
    mesh.draw(canvasColor);
    canvasColor.endDraw();
    image(canvasColor, 0, 0);
  }

  void mouseClicked() {
    color selected = canvasColor.get(mouseX, mouseY);
    println(hue(selected), saturation(selected), brightness(selected));
    println(red(selected), green(selected), blue(selected));
  }
}