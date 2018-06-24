# **QRreader**
Creates a mesh with nblocks x nblocks (number of blocks), assign a QR value to each block, if it exist, reading what the camera sees.

## **Contact Info**
**Vanesa Alcántara**: v.alcantarapanta@alum.up.edu.pe | https://github.com/vaap1997 .
**Jesús García**: je.garciar@up.edu.pe | https://github.com/JesusGarcia98

## **Legal Description**
This code uses GNU Affero General Public License v3.0. For more information: https://www.gnu.org/licenses/gpl-3.0.en.html

## **QR (Class)**
1. Constructor
```java
new QR(String path)
```
2. Methods
    - *`decode(Mesh mesh, PImage im0)`*: Scans **_im0_** for QR codes and gets the content stored in them.
    - *`loadData()`*: Reads the JSON file stored in **_path_** and loads its content into the **__contour_** points as coordinates.
    - *`saveData()`*: Overwrites the JSON file in **_path_** to store the new coordinates of the **_contour_** points.

## **WarpPerspective (Class)**
1. Constructor
```java
new WarpPerspective(ArrayList<PVector> contour)
```
2. Methods
    - *`selected(int x, int y, int threshold)`*: Checks if a certain point of the **_contour_** is selected.
    - *`unselect()`*: Sets the **_selected_** attribute to false.
    - *`move(int x, int y)`*: Changes the coordinates of the selected point according to the x and y parameters.
    - *`draw(PGraphics canvas)`*: Draws the contour points to the screen.
    - *`changeContours(ArrayList<PVector> calibrationPoints)`*: Updates the points stored in **_contour_** to be equal to those in the calibrationPoints parameter.
    

## **Cells (Class)**
1. Constructor
```java
new Mesh(int id, ArrayList<PVector> coords, PVector canvasCoords)
```
2. Methods
    - *`selected(PVector check)`*: Checks wether the coordinate of a QR, which is the check parameter, is inside a cell or not.
    - *`setPattern(String decoded)`*: Sets the pattern of the cell equal to the decoded value of the QR inside it.
    - *`restartPattern()`*: Sets the pattern back to its default value
## **Mesh (Class)**
1. Constructor
```java
new Mesh(int nblocks, int w)
```
2. Methods
    - *`addBlock()`*: Add a new blow to the mesh.
    - *`deleteBlock()`*: Delete one block from the mesh.
    - *`uploadMesh(int nblocks)`*: Upload configuration related to each cell.
    - *`create()`*: Creates the grid.
    - *`checkPattern(PImage im0)`*: Whenever called, the function resets the values of each cell in the grid. Then, scans the image for QR codes and gets the stored values in them, prints these values enumerated to the console and if the coordinate of the QR is within the boundaries of a cell, sets the pattern of said cell equal to the decoded value.
    - *`exportGrid()`*: Creates a JSON file that will store the coordinates of the QR codes along with their values.
