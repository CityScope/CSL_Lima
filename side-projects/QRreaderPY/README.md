# **QRreaderPY**
Its a conversion of the original QRreader to a python script in order to increase its efficiency. Creates a n x n grid. Reads what the camera sees and, if a QR code is found within a blocks, assigns that value to the corresponding block.

## **Contact Info**
**Vanesa Alcántara**: v.alcantarapanta@alum.up.edu.pe | https://github.com/vaap1997 .
**Jesús García**: je.garciar@alum.up.edu.pe | https://github.com/JesusGarcia98

## **Legal Description**
This code uses GNU Affero General Public License v3.0. For more information: https://www.gnu.org/licenses/gpl-3.0.en.html

## **QR (Class)**
1. Methods
    - *`decode(img)`*: Decode all QRs in the image given and return a list of  object decoded.
    - *`draw(img, decodedObjects)`*: Draw a rectangle around QRs decoded.


## **WarpedPerspective (Class)**
1. Methods
    - *`WarpedPerspective(pts1, pts2, img, sideLenght)`*: Modifies image perspective and creates a new image taking input points as corners.
    - *`drawPoints(PGraphics canvas)`*: Draw points in the image.


## **Cells (Class)**
1. Constructor
```python
new __init__(Cellid, start, size)
```
2. Methods
    - *`check(loc)`*: Checks wether a coordinate(loc) is within the bounds of the object.
    - *`setPattern(String decoded)`*: Sets the value of **_PATTERN_**.  
    <!-- - *`draw(PGraphics canvas)`*: Draws an square using the stored coordinates and size. -->


## **Mesh (Class)**
1. Constructor
```python
new __init__(cellid, ncells, size)
```
2. Methods
    - *`addBlock(sideLenght, im)`*: Adds one block to the grid.
    - *`deleteBlock(sideLenght, im)`*: Deletes one block from the grid.
    - *`resetPattern()`*: Sets the pattern back to its default value.
    - *`recognizeQR(img)`*:  Resets the patterns of the Cells objects. Scans an image looking for QR codes and gets their stored values.Sets the pattern of the Cells where the QR code was found equal to its decoded pattern.
    - *`export_Grid_json()`*: Creates a JSON file that will store the coordinates of the Cell objects along with their patterns.
    - *`export_Grid_UDP()`*: Sends an array with cell's patterns.  
    - *`draw(PGraphics canvas)`*: Draws the grid.

## **Principal methods**
   - *`mouse_selecting()`*: Enable to move the calibration points to modify WarpedPerspective configuration.
   - *`read_parameters()`*: reads the calibration parameters json.
   - *`safe_parameters()`*: upload calibration parameters json with configuration changes.
