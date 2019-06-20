# **QRreader**
Creates a n x n grid. Reads what the camera sees and, if a QR code is found within a blocks, assigns that value to the corresponding block.

## **Contact Info**
**Vanesa Alcántara**: v.alcantarapanta@alum.up.edu.pe | https://github.com/vaap1997 .
**Jesús García**: je.garciar@alum.up.edu.pe | https://github.com/JesusGarcia98

## **Legal Description**
This code uses GNU Affero General Public License v3.0. For more information: https://www.gnu.org/licenses/gpl-3.0.en.html

## **QR (Class)**
1. Constructor
```java
new QR(Mesh mesh)
```
2. Methods
    - *`decode(PImage img)`*: Calls the **_checkPattern()_** method of Mesh.


## **WarpedPerspective (Class)**
1. Constructor
```java
new WarpedPerspective(JSONObject calibrationParameters)
```
2. Methods
    - *`load(JSONObject calibrationParameters)`*: Loads calibration points.
    - *`applyPerspective(PGraphics img)`*: Places the contour points on an image to create a shape object from a part of it.
    - *`select(int x, int y)`*: Changes the status of a contour point to selected if the mouse clicks within a certain distance from it.
    - *`move(int x, int y)`*: If **_SELECTED_** is true, the contour point will move following the mouse. This will distort the image.
    - *`unselect()`*: Set **_SELECTED_** to false.
    - *`draw(PGraphics canvas)`*: Draw the contour points in a **_canvas_**.
    - *`saveConfiguration()`*: Saves its current contour points.


## **Cells (Class)**
1. Constructor
```java
new Cells(int id, PVector startPoint, PVector canvasCoords, int size)
```
2. Methods
    - *`check(PVector coordinate)`*: Checks wether a coordinate is within the bounds of the object.
    - *`setPattern(String decoded)`*: Sets the value of **_PATTERN_**.
    - *`resetPattern()`*: Sets the pattern back to its default value.
    - *`draw(PGraphics canvas)`*: Draws an square using the stored coordinates and size.


## **Mesh (Class)**
1. Constructor
```java
new Mesh(JSONObject data, int size)
```
2. Methods
    - *`addBlock()`*: Adds one block to the grid.
    - *`deleteBlock()`*: Deletes one block from the grid.
    - *`update()`*: Updates values of the object.
    - *`create()`*: Creates grid and Cells objects.
    - *`checkPattern(PImage img)`*: Scans an image looking for QR codes and gets their stored values. Prints the enumerated values of the QR codes to the console. Resets the patterns of the Cells objects. Sets the pattern of the Cells where the QR code was found equal to its decoded pattern.
    - *`draw(PGraphics canvas)`*: Draws the grid.
    - *`getNBlocks()`*: Gets the value of **_NBLOCKS_**.
    - *`getZoomSize()`*: Gets the value of **_ZOOMSIZE_**.
    - *`getWidth()`*: Gets the value of **_CANVASWIDTH_**.
    - *`exportGrid()`*: Creates a JSON file that will store the coordinates of the Cell objects along with their patterns. Calls the **_saveConfiguration()_** method for each stored Cells object.


## **Configuration (Class)**
1. Constructor
```java
new Configuration(String data, int size)
```
2. Methods
   - *`getWidth()`*: Calls the **_getWidth()_** method of Mesh.
   - *`applyPerspective(PGraphics canvas)`*: Calls the **_applyPerspective(PGraphics canvas)_** method of WarpedPerspective.
   - *`drawWarp(PGraphics canvas)`*: Calls the *+_draw(PGraphics canvas)_** method of WarpedPerspective.
   - *`drawGrid(PGraphics canvas)`*: Calls the *+_draw(PGraphics canvas)_** method of Mesh.
   - *`flip(PGraphics canvas, Capture cam, boolean flip)`*: Mirrors the image shown by the camera.
   - *`select(int mousex, int mousey, int threshold)`*: Calls the **_select(int mousex, int mousey, int threshold)_** method of WarpedPerspective.
   - *`move(int x, int y)`*: Calls the **_move()_** method of WarpedPerspective.
   - *`unselect()`*: Calls the **_unselect()_** method of WarpedPerspective.
   - *`decode()`*: Calls the **_decode()_** method of Qr.
   - *`addBlock()`*: Calls the **_addBlock()_** method of Mesh.
   - *`deleteBlock()`*: Calls the **_deleteBlock()_** method of Mesh.
   - *`saveConfiguration()`*: Saves the current values of the WarpedPerspective and Mesh instances. Calls the **_saveConfiguration()_** method of WarpedPerspective.
   - *`exportGrid()`*: Calls the **_exportGrid()_** method of Mesh.
