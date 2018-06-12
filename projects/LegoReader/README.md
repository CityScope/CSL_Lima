# **Calibration Mode (Matrix)**

## **Contact Info**
**Vanesa Alcántara**: v.alcantarapanta@alum.up.edu.pe | https://github.com/vaap1997 .
**Javier Zárate**: javierazd1305@gmail.com | https://github.com/javierazd1305 .



## **Legal Description**
This code uses GNU Affero General Public License v3.0. For more information: https://www.gnu.org/licenses/gpl-3.0.en.html


## **Configuration (Class)**
1. Constructor
```java
new Configuration(String path)
```
2. Methods
- *`exportGrid(ArrayList<patternBlock> patternBlocks)`*: Export a JSONfile with patterns and cells color name
- *`safeConfiguration()`*: Safe perspective points changes in **_WrappedPerspective_**, **_brightness_** y **_saturation_**.
- *`loadConfiguration()`*: Charge configuration.
- *`applyFilter(PGraphics canvas, PImage imageWrapped)`*: Apply color filters in *HSB* considering the **_maxHue_** condition in  **_Color_** objects.
- *`SBCorrection(PGraphics canvas, float s, float b)`*: Modify **_saturation_** and **_brightness_** values on a specific **_canvas_**.

## **Mesh (Class)**
1. Constructor
```java
new Mesh(int nblocks, int width)
```
2. Methods
   - *`create()`* : Obtain each **_Cell_** coordinates and safe them on an **_ArrayList_**.
   - *`draw(PGraphics canvas)`* : Iterate inside **_Cells_** list and call its **_draw(PGraphics canvas)_** method.
   - *`getColors(PGraphics canvas, ArrayList<Color> colorLimits)`*:  Iterate inside a **_Cells_** list and call its **_getColors(PGraphics canvas, ArrayList<Color> colorLimits)_** method.

## **Cell (Class)**
1. Constructor
```java
new Cell(ArrayList<PVector> corners)
```
2. Methods
   - *`draw(PGraphics canvas)`* : Draw a **_shape_**  in a specific **_canvas_** with the corners filling them with the maximun occurency color.
   - *`getColor(PGraphics canvas, ArrayList<Color> colorLimits)`*: Read the pixels insite a **_Cell_** classifying it on the standar color range in **_HSB_**.
   - *`settingCounter(ArrayList<Color> colorLimits)`*: Star the color counter,  **_IntList_** on 0.
   - *`addCounter(int index, int amount)`*: Increase the **_count[index]** value in a determinate **_amount_**.
   - *`checkMovilAverage(int threshold, int inc)`*: Verify if the movil media and got a _n_ equals a _threshold_, in other case, delete the last observation.
   - *`movilAverage()`*: Obtain the movil media and return the color.
   - *`gettingColor(int index, ArrayList<Color> colorLimits)`*:  Obtain the **_Color_** on an specific _index_ in the **_ArrayList<Color>_**.

## **Color (Class)**
1. Constructor
```java
new Color(int id, float maxHue, JSONArray stdColor, String name)
```
2. Methods
    - *`getColor()`*: Return the standar color, **_stdColor_**, created in the object initialization.
    - *`changeMode()`*: Modify the **_selectionMode_** atribute to change the color selected **_maxHue_**.
    - *`refreshCordX()`*: Modify the **_cordX_** mapping the **_maxHue_** value with the control width.

## **WrapperPerspective (Class)**
1. Constructor
```java
new Wrapper(ArrayList<PVector> contour)
```
2. Methods
    - *`selected(int x, int y)`*: If the selection is near a _threshold_, change the **_pointSelected_** value, the new values will be the new perspective points.
    - *`move(int x, int y)`*: Modify perspective points, if **_pointSelected_** is *True*.
    - *`unSelect()`*: Change **_pointSelected_** value to *False*.
    - *`draw(PGraphics canvas)`*: Draw in an specific **_canvas_** the perspective points.

## **BlockReader (Class extends PApplet)**
1. Constructor
```java
new BlockReader(int w, int h)
```
2. Description: This **_sketch_** shows the final result of the video.

## **ColorRange (Class extends PApplet)**
1. Constructor
```java
new ColorRange(int w, int h)
```

###########################################################################################################################################################

/*
* Creates a pattern with 4 blocks. Safe its position in order *
*  0 -- 1
*  |    |
*  3 -- 2
*/

## **Patterns (Class extends PApplet)**
1. Constructor
```java
new Patterns(PGraphics canvasPattern, int w, int h)
```
2. Methods
    - *`selected(int x, int y)`*: Change pattern block color.

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
    - *`getColorString()`*: Upload the patterns array so it can be safe on the JSONfile.
    - *`selected(int x, int y)`*: Select a pattern and a block inside it. Change the color of the selected block to the follow in the main list.
    - *`createPallet(PGraphics canvas, int blocks)`*: Reads an ArrayList with the patterns colors's name. Creates blocks and BlockGroups.
