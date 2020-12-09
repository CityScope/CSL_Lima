/**
 * @copyright: Copyright (C) 2018
 * @legal:
 * This file is part of QRreader.
 
 * QRreader is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * QRreader is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 
 * You should have received a copy of the GNU Affero General Public License
 * along with QRreader. If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * Configuration - Kind of a facade to simplify the manipulation of the WarpedPerspective, Mesh and Qr classes
 * @see:      WarpedPerspective, Mesh, Qr
 * @author:   Jesús García
 * @version:  1.0
 */
public class Configuration {
  private WarpedPerspective WARP;
  private Mesh MESH;
  private Qr QR;


  /**
   * Creates instances of WarpedPerspective, Mesh and Qr using a JSONObject
   * @param: calibrationParameters  JSONObject with data
   */
  public Configuration(String data, int size) {
    JSONObject calibrationParameters = loadJSONObject(data);
    WARP = new WarpedPerspective(calibrationParameters);
    MESH = new Mesh(calibrationParameters, size);
    QR = new Qr(MESH);
  }


  /**
   * Calls the getWidth method of MESH
   * @returns: int  Value returned by the method of MESH
   */
  public int getWidth() {
    return MESH.getWidth();
  }


  /**
   * Calls the applyPerspective method of WARP
   * @param:   img     PGraphics object to be distorted
   * @returns: PImage  Distorted portion of the PGraphics
   */
  public PImage applyPerspective(PGraphics canvas) {
    return WARP.applyPerspective(canvas);
  }


  /**
   * Calls the draw method of WARP
   * @param: canvas  PGraphics object to draw on
   */
  public void drawWarp(PGraphics canvas) {
    WARP.draw(canvas);
  }


  /**
   * Calls the draw method of MESH
   * @param: canvas  PGraphics object to draw on
   */
  public void drawGrid(PGraphics canvas) {
    MESH.draw(canvas);
  }


  /**
   * Mirrors the image shown by the camera
   * @param: canvas  PGraphics to show the mirrored image on
   * @param: cam     Capture object whose content will be mirrored
   * @param: flip    true - mirrors the image / false - does not mirror the image
   */
  public void flip(PGraphics canvas, Capture cam, boolean flip) {
    if (flip) {
      canvas.pushMatrix();
      canvas.scale(-1, 1);
      canvas.image(cam, -canvas.width, 0);
      canvas.popMatrix();
    } else {
      canvas.image(cam, 0, 0);
    }
  }


  /**
   * Calls the select method of WARP
   * @param: x          X coordinate of the mouse
   * @param: y          Y coordinate of the mouse
   * @param: threshold  Distance from the mouse to the control point to change its status
   */
  public void select(int mousex, int mousey, int threshold) {
    WARP.select(mousex, mousey, threshold);
  }


  /**
   * Calls the move method of WARP
   * @param: x  X coordinate of the mouse
   * @param: y  Y coordinate of the mouse
   */
  public void move(int x, int y) {
    WARP.move(x, y);
  }


  /**
   * Calls the unselect method of WARP
   */
  public void unselect() {
    WARP.unselect();
  }


  /**
   * Calls the decode method of QR
   * @param: img  PImage object to look in
   */
  public void decode(PImage img) {
    QR.decode(img);
  }


  /**
   * Calls the addBlock method of MESH
   */
  public void addBlock() {
    MESH.addBlock();
  }


  /**
   * Calls the deleteBlock method of MESH
   */
  public void deleteBlock() {
    MESH.deleteBlock();
  }


  /**
   * Saves the current values of the WarpedPerspective and Mesh instances. Calls the saveConfiguration method of WARP
   */
  public void saveConfiguration() {
    JSONObject calibrationParameters = new JSONObject();

    JSONObject calibrationPoints = WARP.saveConfiguration();
    int nBlocks = MESH.getNBlocks();
    int w = MESH.getWidth();
    int zoom = MESH.getZoomSize();

    calibrationParameters.setJSONObject("Calibration Points", calibrationPoints);
    calibrationParameters.setInt("nblocks", nBlocks);
    calibrationParameters.setInt("w", w);
    calibrationParameters.setInt("zoom", zoom);

    saveJSONObject(calibrationParameters, "data/calibrationParameters.json", "compact");
  }


  /**
   * Calls the exportGrid method of MESH
   */
  public void exportGrid() {
    MESH.exportGrid();
  }
}
