/**
 ** @copyright: Copyright (C) 2018
 ** @authors:   Vanesa Alcántara & Jesús García
 ** @version:   1.0 
 ** @legal :
 This file is part of QRreader.
 
 QRreader is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 QRreader is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License
 along with QReader.  If not, see <http://www.gnu.org/licenses/>.
 **/

/*
* Import ZXING library created by  Rolf van Gelder 
* Available for processing:(http://cagewebdev.com/zxing4processing-processing-library/)
*/
 
public class QR {
  ArrayList<PVector> contour = new ArrayList();
  ArrayList<PVector[]> alMarkers = new ArrayList<PVector[]>();
  HashMap<Integer, String> qrs = new HashMap<Integer, String>();
  String path;
  
  public QR(String path) {
    this.path = path;
    loadData();
  }

  /*
  * Adapted from a Zxing example, it scans the video for QR codes and decodes them
  */
  public void decode(Mesh mesh, PImage im0) {
    if (!decodedText.equals("")) {
      decodedText = "";
    } else {
      try {  
        mesh.checkPattern(im0);
        println("");
        decoded = true;
      } 
      catch (Exception e) {  
        println("Zxing4processing exception: "+e);
        decodedText = "";
      }
    }
  }

  public void loadData() {
    //Reads the JSON file and loads its values into the contour points coordinates
    JSONObject json = loadJSONObject(this.path);
    ArrayList<PVector> calibrationPoints = new ArrayList();
    JSONObject points = json.getJSONObject("Calibration Points");
    for (int i = 0; i < points.size(); i++) {
      JSONArray point = points.getJSONArray(str(i));
      calibrationPoints.add(new PVector(point.getFloat(0), point.getFloat(1)));
    }
    this.contour = calibrationPoints;
  }

  /*
  *Creates a new JSON file to store the new coordinates of the contour points
  */
  public void saveData() {
    JSONObject data = new JSONObject();  
    JSONObject points = new JSONObject();
    int i=0;
    for (PVector coord : warpPerspective.contour ) {
      JSONArray point = new JSONArray();
      point.setFloat(0, coord.x);
      point.setFloat(1, coord.y);
      points.setJSONArray(str(i), point);
      i++;
    }
    data.setJSONObject("Calibration Points", points);
    println("Parameters saved.");
    saveJSONObject(data, this.path, "compact");
  }
}