# **Calibration Mode (Matrix)**

## **Contact Info**
**Vanesa Alcántara**: v.alcantarapanta@alum.up.edu.pe | https://github.com/vaap1997 .
**Jesús García**: jesusgarciaruiz1004@gmail.com | https://github.com/JesusGarcia98 .
**Javier Zárate**: javierazd1305@gmail.com | https://github.com/javierazd1305 .



## **Legal Description**
This code uses GNU Affero General Public License v3.0. For more information: https://www.gnu.org/licenses/gpl-3.0.en.html


## **Configuration (Class)**
1. Constructor
```java
new Configuration(int actualSize, 0String path)
```
2. Methods
- *`updateSizeCanvas(int w, int h)`*: Changes the size of the canvas.
- *`exportGrid(ArrayList<patternBlock> patternBlocks, Patterns patterns)`*: Export a JSONfile with patterns and cells color name.
- *`saveConfiguration(ArrayList<Color> colors)`*: Save color ranges, saturation, brightness and perspective calibration points.
- *`loadConfiguration()`*: Load color ranges, saturation, brightness and perspective calibration points.
- *`restartColors()`*: Restart every pixel counter for each color.
- *`flip(PGraphics canvas, Capture cam, boolean flip)`*: Mirrors the image shown by the camera.
- *`fact(int num)`*: Takes factorial of num.
- *`possiblePatterns()`*: Checks if there is any other possible combination to create a new pattern


## **Mesh (Class)**
1. Constructor
```java
new Mesh(int nblocks, int w)
```
2. Methods
   - *`create()`* : Creates a grid of nxn patternBlocks.
   - *`draw(PGraphics canvas)`*: Iterate inside patternBlocks and call its **_draw(PGraphics canvas)_** method.
   - *`drawGrid(PGraphics canvas)`*: Iterate inside patternBlocks and call its **_drawGrid(PGraphics canvas)_** method.
   - *`update(int nblocks, int w)`*: Updates the original configuration.
   - *`updateString()`*: Changes the pattern color.
   - *`applyFilter(PImage img)`*: Classifies colors.          
   - *`checkPattern()`*: Iterate inside patternBlocks and call its **_checkPattern()_** method.

## **Cell (Class)**
1. Constructor
```java
new Cells(int id,PVector initPoint, int sclCell)
```
2. Methods
   - *`draw(PGraphics canvas)`* : Draw a **_shape_**  in a specific **_canvas_** with the corners filling them with the maximun occurency color.
   - *`settingCounter(ArrayList<Color> colorLimits)`*: Star the color counter,  **_IntList_** on 0.
   - *`checkMovilAverage(int threshold, int inc)`*: Verify if the movil media and got a _n_ equals a _threshold_, in other case, delete the last observation.
   - *`movilAverage()`*: Obtain the movil media and return the color.
   - *`applyFilter(PImage imageWrapped)`*: Apply color filters in *HSB* considering the **_maxHue_** condition in  **_Color_** objects.

## **Color (Class)**
1. Constructor
```java
new Color(int id, float maxHue, color stdColor, String name, String acron)
```
```java
new Color(int id, float maxHue, color stdColor, String name, String acron, float satMax, float briMin, float satMax2, float hueMin)
```
```java
new Color(int id, float maxHue, color stdColor, String name, String acron, float briMax, float briMax2, float satMax)
```

2. Methods
    - *`getColor()`*: Return the standard color, **_stdColor_**, created in the object initialization.
    - *`changeMode()`*: Modify the **_selectionMode_** attribute to change the color selected **_maxHue_**.

## **WrapperPerspective (Class)**
1. Constructor
```java
new Wrapper(ArrayList<PVector> contour)
```
2. Methods
    - *`applyPerspective(PGraphics img)`*: Create vertices on the canvas to select a certain part of it.
    - *`selected(int x, int y)`*: If the selection is near a _threshold_, change the **_pointSelected_** value, the new values will be the new perspective points.
    - *`move(int x, int y)`*: Modify perspective points, if **_pointSelected_** is *True*.
    - *`unSelect()`*: Change **_pointSelected_** value to *False*.
    - *`draw(PGraphics canvas)`*: Draw in an specific **_canvas_** the perspective points.
    - *`draw(PGraphics canvas, PImage img, boolean warp)`*: if warp is true draws the selected area. If warp is false draws the points in the canvas.

## **BlockReader (Class extends PApplet)**
1. Constructor
```java
new BlockReader(int w, int h)
```
2. Description: This **_sketch_** shows the final result of the video.

## **ColorRange (Class extends PApplet)**
1. Constructor
```java
new ColorRange(ArrayList<Color> colorLimits, int w, int h)
```
2. Description: This **_sketch_** shows the control panel color .


## **Patterns (Class extends PApplet)**
1. Constructor
```java
new Patterns(PGraphics canvasPattern, Configuration config)
```

## **Block**
1. Constructor
```java
new Block(int id, ArrayList<PVector> corners, String colorName)
```
2. Methods
    - *`getColorFromName(String colorName)`*: Assign a Color to a block depending of its name.
    - *`draw(PGraphics canvas)`*: Draws one block, part of the pattern.
    - *`selected(int x, int y)`*: Change the color to the follow in the main list.

## **Block**
1. Constructor
```java
new BlockGroup(int id, ArrayList<Block> blocks)
```
2. Methods
    - *`draw(PGraphics canvas)`*: Draws every block of the pattern.
    - *`selected(int x, int y)`*: Change the color of the selected block to the follow in the main list.

## **PatternBlocks**
1. Constructor
```java
new PatternBlocks(PGraphics canvas, int blocks)
```
2. Methods
    - *`getColorString()`*: Upload the patterns array so it can be save on the JSONfile.
    - *`selected(int x, int y)`*: Select a pattern and a block inside it. Change the color of the selected block to the follow in the main list.
    - *`createPallet(PGraphics canvas)`*: Creates a new pattern and assign it an standar W-W-W-W parameter
    - *`deletePallet(PGraphics canvas)`*: Delete the last parameter in the parameters list
    - *`createPallet(PGraphics canvas, int blocks)`*: Reads an ArrayList with the patterns colors's name. Creates blocks and BlockGroups.
