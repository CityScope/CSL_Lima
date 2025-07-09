/**
 * @copyright: Copyright (C) 2018
 * @legal:
 * This file is part of HumanitarianModel.
 
 * HumanitarianModel is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * HumanitarianModel is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 
 * You should have received a copy of the GNU Affero General Public License
 * along with HumanitarianModel.  If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * Configuration - Kind of a facade to simplify the manipulation of Grapho and Zoom classes
 * @see:      Grapho, Zoom
 * @author:   Jesús García
 * @version:  1.0
 */
public class Configuration {
  private Grapho GRAPHO;
  private Zoom ZOOM;


  /**
   * Creates a Configuration object using two geoJSON files
   * @param: roadPath  Path to the geoJSON file with the roads
   * @param: poiPath   Path to the geoJSON file with the schools and hospitals
   * @param: parent  PApplet object
   * @param: width   Width of the PApplet
   * @param: height  Height of the PApplet
   */
  public Configuration(String roadPath, String poiPath, PApplet parent, int w, int h) {
    GRAPHO = new Grapho(roadPath, poiPath);
    ZOOM = new Zoom(parent, GRAPHO, w, h);
  }


//  /**
//   * Runs ZOOM's PApplet
//   * @param: zoomName  Name of the PApplet
//   */
//  public void runSketch(String[] zoomName) {
//    PApplet.runSketch(zoomName, ZOOM);
//  }


  /**
   * Calls the draw method of GRAPHO
   * @param: canvas  PGraphics object to draw on
   * @param: zoom    Wether to draw with zoom or not
   */
  public void drawGrapho(PGraphics canvas, boolean zoom) {
    GRAPHO.draw(canvas, zoom);
  }


  /**
   * Calls the drawVisor method of ZOOM
   * @param: canvas  PGraphics object to draw on
   */
  public void drawVisor(PGraphics canvas) {
    ZOOM.drawVisor(canvas);
  }
  
  public void pressedZoom(){
    ZOOM.pressedZoom();
  }

  public void addNode(){
    ZOOM.addNode();
  }
  
  public void deleteNode(){
    ZOOM.deleteNode();
  }
  
  public void clickZoom(){
    ZOOM.clickZoom();
  }
  
  /**
   * Calls the changeAlgorithm method of GRAPHO
   * @param: algorithm  New value of ALGORITHM
   */
  public void changeAlgorithm(int algorithm) {
    GRAPHO.changeAlgorithm(algorithm);
  }


  /**
   * Calls the getSide1 method of ZOOM
   * @returns: PVector  Value of SIDE1
   */
  public PVector getSide1() {
    return ZOOM.getSide1();
  }


  /**
   * Calls the setSide1 method of ZOOM
   * @param: x  New x value of SIDE1
   * @param: y  New y value of SIDE1
   */
  public void setSide1(int x, int y) {
    ZOOM.setSide1(x, y);
  }


  /**
   * Calls the reduceSide1 method of ZOOM
   */
  public void reduceSide1() {
    ZOOM.reduceSide1();
  }


  /**
   * Calls the increaseSide1 method of ZOOM
   */
  public void increaseSide1() {
    ZOOM.increaseSide1();
  }


  /**
   * Calls the getSide2 method of ZOOM
   * @returns: PVector  Value of SIDE2
   */
  public PVector getSide2() {
    return ZOOM.getSide2();
  }


  /**
   * Calls the setSide2 method of ZOOM
   * @param: x  New x value of SIDE2
   * @param: y  New y value of SIDE2
   */
  public void setSide2(int x, int y) {
    ZOOM.setSide2(x, y);
  }


  /**
   * Calls the reduceSide2 method of ZOOM
   */
  public void reduceSide2() {
    ZOOM.reduceSide2();
  }


  /**
   * Calls the increaseSide2 method of ZOOM
   */
  public void increaseSide2() {
    ZOOM.increaseSide2();
  }
}
