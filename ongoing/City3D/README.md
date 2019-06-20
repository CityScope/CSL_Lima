# **City3D**
Recognizes the colors of Legos arranged in a NxN grid using a camera, in order to build a 3D model of the grid, which represents a city.

![lego table 1](/images/table1.png) ![lego table 2](/images/table2.png)
![city3d render](/images/city3d.png)

The calibrations for color identification and image region of interest (ROI) can be changed and saved while running.

![configuration](/images/config.png) ![configuration](/images/patterns.png)

## **Contact Info**
**Vanesa Alcántara**: v.alcantarapanta@alum.up.edu.pe | https://github.com/vaap1997 .
**Jesús García**: jesusgarciaruiz1004@gmail.com | https://github.com/JesusGarcia98 .
**Javier Zárate**: javierazd1305@gmail.com | https://github.com/javierazd1305 .

## **Legal Description**
This code uses GNU Affero General Public License v3.0. For more information: https://www.gnu.org/licenses/gpl-3.0.en.html

## **Configuration (Class)**
1. Constructor
```java
new Configuration(String path, PImage whiteBackground, PImage blackBackground, PImage otherBackground)
```
2. Methods
   - *`updateSizeCanvas(int w, int h)`*: Changes the size of the canvas.
   - *`exportGridUDP()`*: Exports color patterns and ids in the mesh.
   - *`exportGrid()`*: Exports a JSON file with color patterns and ids in the mesh.
   - *`saveConfiguration()`*: Saves custom calibration regarding color ranges, saturation, brightness and perspective calibration points in a JSON file.
   - *`load(String path, PImage whiteBackground, PImage blackBackground, PImage otherBackground)`*: Loads calibration parameters regarding color ranges, saturation, brightness and perspective calibration points from a JSON file.
   - *`flip(PGraphics canvas, Capture cam, boolean flip)`*: Mirrors the image shown by the camera.
   - *`runSketches(String[] patterns, String[] colors, String[] block, String[] city)`*: Runs the PApplets.
   - *`drawWarp(PGraphics canvas)`*: Calls the **_drawWarp(PGraphics canvas)_** method of WarpedPerspective.
   - *`applyPerspective(PGraphics canvas)`*: Calls the **_applyPerspective(PGraphics canvas)_** of WarpedPerspective.
   - *`applyFilter(PImage img)`*: Calls the **_applyFilter(PImage img)_** method of Mesh.
   - *`drawGrid(PGraphics canvas)`*: Calls the **_drawGrid(PGraphics canvas)_** method of Mesh.
   - *`increaseSaturation(float inc)`*: Calls the **_increaseSaturation(float inc)_** method of Mesh.
   - *`decreaseSaturation(float dec)`*: Calls the **_decreaseSaturation(float dec)_** method of Mesh.
   - *`increaseBrightness(float inc)`*: Calls the **_increaseBrightness(float inc)_** method of Mesh.
   - *`decreaseBrightness(float dec)`*: Calls the **_decreaseBrightness(float dec)_** method of Mesh.
   - *`getBlocks()`*: Calls the **_getBlocks()_** method of Mesh.
   - *`increaseBlocks()`*: Calls the **_increaseBlocks()_** method of Mesh.
   - *`decreaseBlocks()`*: Calls the **_decreaseBlocks()_** method of Mesh.
   - *`select(int x, int y, int threshold)`*: Calls the **_select(int x, int y, int threshold)_** method of WarpedPerspective.
   - *`move(int x, int y)`*: Calls the **_move(int x, int y)_** method of WarpedPerspective.
   - *`unselect()`*: Calls the **_unselect()_** method of WarpedPerspective.
   - *`update(int w)`*: Calls the **_update(int w)_** method of Mesh.
   - *`showBlockReader()`*: Calls the **_show()_** method of BlockReader.
   - *`showColorRange()`*: Calls the **_show()_** method of ColorRange.
   - *`showPatterns()`*: Calls the **_show()_** method of Patterns.


## **Cells (Class)**
1. Constructor
```java
new Cells(int id, PVector startPoint, int size, ArrayList<Color> colors)
```
2. Methods
   - *`drawCell(PGraphics canvas)`*: Draws the Cell with the standard color.
   - *`setCounter()`*: Sets the counter for every possible color of the object to 0.
   - *`setColor()`*: Instantiates colors from the separately to simplify color manipulation.
   - *`applyFilter(PImage img, float sat, float bright)`*: Asigns a standard color to every group of an image pixels in the same color range.
   - *`getColor()`*: Gets the Color object of this Cell.


## **PatternCells (Class)**
1. Constructor
```java
new PatternCells(int id, PVector startPoint, int size, PatternBlocks pBlocks)
```
2. Methods
   - *`create(ArrayList<Color> colors)`* : Creates a group of Cells for the object.
   - *`applyFilter(PImage img, float sat, float bright)`*: Calls the **_applyFilter(PImage img, float sat, float bright)_** for each stored Cell object.
   - *`drawPattern(PGraphics canvas)`*: Calls the **_drawCell(PGraphics canvas)_** method for each stored Cell and shows a rectangle with its ID in the middle of the drawn Cells.
   - *`drawGrid(PGraphics canvas)`*: Draws squares that will form a grid.
   - *`checkPattern()`*: Checks if the color pattern of its cells - or a rotated version of it - can be found in the defined patterns of the Patterns class.
   - *`getIndex()`*: Gets the index pattern.


## **Mesh (Class)**
1. Constructor
```java
new Mesh(JSONObject calibrationParameters, PatternBlocks pBlocks)
```
2. Methods
   - *`load(JSONObject calibrationParameters, PatternBlocks pBlocks)`*: Loads parameters.
   - *`create(PatternBlocks pBlocks)`* : Creates a grid of nxn PatternCells.
   - *`drawPatterns(PGraphics canvas)`*: Iterates inside PatternCells and call its **_drawPattern(PGraphics canvas)_** method.
   - *`drawGrid(PGraphics canvas)`*: Iterates inside PatternCells and call its **_drawGrid(PGraphics canvas)_** method.
   - *`update(int nblocks, int w)`*: Overwrites the original configuration.
   - *`applyFilter(PImage img)`*: Iterates inside PatternCells and calls its **_applyFilter(PImage img)_** method.          
   - *`checkPattern()`*: Iterates inside PatternCells and call its **_checkPattern()_** method.
   - *`getGrid()`*: Gets the whole grid.
   - *`getBlockSize()`*: Gets the size of each block in the grid.
   - *`getBlocks()`*: Gets the number of blocks in the grid.
   - *`increaseBlocks()`*: Increase the number of blocks by 1.
   - *`decreaseBlocks()`*: Decrease the number of blocks by 1.
   - *`getSaturation()`*: Gets the saturation level.
   - *`increaseSaturation(float inc)`*: Increases the saturation level.
   - *`decreaseSaturation(float dec)`*: Decreases the saturation level.
   - *`increaseBrightness(float inc)`*: Increases the brightness level.
   - *`decreaseBrightness(float dec)`*: Decreases the brightness level.
   - *`getPatterns()`*: Gets the stored PatternCells.


## **BlockReader (Class extends PApplet)**
1. Constructor
```java
new BlockReader(JSONObject calibrationParameters, Mesh mesh)
```
2. Methods
   - *`show()`*: Shows the PApplet.
3. Description: This **_sketch_** shows the final result of the video.


## **Color (Class)**
1. Constructor
```java
new Color(JSONObject obj)
```
2. Methods
    - *`getAcronym()`*: Gets the **_ACRONYM_**.
    - *`getSelected()`*: Gets **_SELECTED_**.
    - *`getMaxHue()`*: Gets the **_MAXHUE_**.
    - *`setMaxHue(float maxHue)`*: Sets the **_MAXHUE_**.
    - *`getCounter()`*: Gets the **_COUNTER_**.
    - *`setCounter()`*: Increases the **_COUNTER_** by 1.
    - *`resetCounter()`*: Sets the **_COUNTER_** to 0.
    - *`getID()`*: Gets the **_ID_**.
    - *`getColorName()`*: Gets the **_NAME_**.
    - *`getColor()`*: Return the standard color **_STD_**.
    - *`changeMode()`*: Changes **_selectionMode_** to **_calibrationMode_**.


## **White (Class extends Color)**
1. Constructor
```java
new White(JSONObject obj)
```
2. Methods
   - *`getMinHue()`*: Gets the **_MINHUE_**.
   - *`setMinHue(float minHue)`*: Sets the **_MINHUE_**.
   - *`getMaxSat()`*: Gets the **_MAXSAT_**.
   - *`setMaxSat(float maxSat)`*: Sets the **_MAXSAT_**.
   - *`getMaxSat2()`*: Gets the **_MAXSAT2_**.
   - *`setMaxSat2(float maxSat2)`*: Sets the **_MAXSAT2_**.
   - *`getMinBri()`*: Gets the **_MINBRI_**.
   - *`setMinBri(float minBri)`*: Sets the **_MINBRI_**.
   - *`saveConfiguration()`*: Saves its current values.


## **Black (Class extends Color)**
1. Constructor
```java
new Black(JSONObject obj)
```
2. Methods
   - *`getMaxSat()`*: Gets the **_MAXSAT_**.
   - *`setMaxSat(float maxBri)`*: Sets the **_MAXSAT_**.
   - *`getMaxBri()`*: Gets the **_MAXBRI_**.
   - *`setMaxBri(float maxBri)`*: Sets the **_MAXBRI_**.
   - *`getMaxBri2()`*: Gets the **_MAXBRI2_**.
   - *`setMaxBri2(float maxBri2)`*: Sets the **_MAXBRI2_**.
   - *`saveConfiguration()`*: Saves its current values.


## **Other (Class extends Color)**
1. Constructor
```java
new Other(JSONObject obj)
```
2. Methods
   - *`saveConfiguration()`*: Saves its current values.


## **ColorRange (Class extends PApplet)**
1. Constructor
```java
new ColorRange(PImage whiteBackground, PImage blackBackground, PImage otherBackground, JSONObject calibrationParameters)
```
2. Methods
   - *`load(JSONObject calibrationParameters)`*: Loads color calibrations.
   - *`controlPanelWhite()`*: Enables the option to modify hue, saturation and brightness for color white using control bars.
   - *`controlPanelBlack()`*: Enables the option to modify saturation and brightness for color black using control bars.
   - *`controlPanelOthers()`*: Enables the option to modify ranges for the rest of the colors using control bars.
   - *`getWhite()`*: Gets the **_W_** attribute.
   - *`selectAll()`*: Gets all the stored Color objects.
   - *`getSize()`*: Gets the size of the PApplet.
   - *`show()`*: Shows the PApplet.
   - *`saveConfiguration()`*: Calls the **_saveConfiguration()_** of each Color object.
3. Description: This **_sketch_** shows the color control panels.


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


## **Block (Class)**
1. Constructor
```java
new Block(int size, PVector coordinates, ArrayList<Color> colors, String colorName)
```
2. Methods
    - *`getColorFromName(String colorName)`*: Gets a Color instance from a color name.
    - *`drawBlock(PGraphics canvas)`*: Draws an square using the stored coordinates and fills it using the Color object.
    - *`select(int x, int y)`*: Changes the fill color of the square to the next one in the array of colors.
    - *`getCoords()`*: Gets the **_COORDS_**..
    - *`getColor()`*: Gets the Color instance.
    - *`getSize()`*: Gets the **_SIZE_**.


## **BlockGroup (Class)**
1. Constructor
```java
new BlockGroup(int id, ArrayList<Block> blocks)
```
2. Methods
    - *`findCorners()`*: Sets the upper-right and bottom-left corners of the object.
    - *`drawGroup(PGraphics canvas)`*: Calls the **_drawBlock(PGraphics canvas)_** method for every Block object.
    - *`select(int x, int y)`*: Calls the select method for every Block in the group.
    - *`getBlocks()`*: Gets the value of **_BLOCKS_**.


## **PatternBlocks (Class)**
1. Constructor
```java
new PatternBlocks(ArrayList<JSONArray> options, ColorRange colors, int canvasSize, int blockSize)
```
2. Methods
    - *`getColors()`*: Gets the **_COLORS_** ColorRange instance.
    - *`getGroups()`*: Gets the array of BlockGroup objects **_GROUPS_**.
    - *`select(int x, int y)`*: Calls the select method for every stored BlockGroup object and updates the pattern array.
    - *`createPallet(PGraphics canvas)`*: Creates Block and BlockGroups objects.
    - *`updatePatternOptions()`*: Updates the array of color names so it can be saved on a JSON file.
    - *`createPattern(PGraphics canvas)`*: Creates a new pattern and assigns it a default W-W-W-W parameter.
    - *`deletePattern(PGraphics canvas)`*: Deletes the last pattern of the pattern array.
    - *`drawGroups(PGraphics canvas)`*: Calls the **_drawGroup(PGraphics canvas)_** method for every BlockGroup object.
    - *`saveConfiguration()`*: Saves the current pattern options.


## **Patterns (Class extends PApplet)**
1. Constructor
```java
new Patterns(JSONObject calibrationParameters, ColorRange colors)
```
2. Methods
   - *`load(JSONObject calibrationParameters, ColorRange colors)`*: Loads predefined patterns.
   - *`fact(int num)`*: Gets the factorial of a number.
   - *`getPossiblePatterns()`*: Checks if there is any other possible combination to create a new pattern.
   - *`getBlockSize()`*: Gets the value of the BLOCKSIZE attribute.
   - *`getSize()`*: Gets the width of the PApplet.
   - *`getOptions()`*: Gets the value of the OPTIONS attribute.
   - *`show()`*: Shows the PApplet.
   - *`saveConfiguration()`*: Calls the **_saveConfiguration()_** method of PatternBlocks.


## **Building3D (Class)**
1. Constructor
```java
new Building3D(PVector pos, int w)
 ```
 2. Methods
    - *`setHeight(int h)`*: Sets the height of the building.
    - *`drawBuilding(PGraphics canvas)`*: Draws a building using the stored coordinates and dimensions.


## **City3D (Class extends PApplet)**
1. Constructor
```java
new City3D(Mesh mesh)
```
2. Methods
   - *`design()`*: Updates the number of buildings in the city and their dimensions.
   - *`modelBuildings()`*: Creates and stores Building3D objects for the city.
   - *`raise(ArrayList<Building3D> tempBuildings, ArrayList<PatternCells> heights)`*: Sets the height of the buildings.
   - *`build()`*: Calls the **_drawBuilding()_** method for each stored Building3D.
