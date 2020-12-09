# Buildings
Create buildings in real time while interacts with a matrix table. Enable to select and see extra information about the building.

## **Contact Info**
**Vanesa Alcántara**: v.alcantarapanta@alum.up.edu.pe | https://github.com/vaap1997 .

## **Base Script**
This script is based on  [LegoReader Script](https://github.com/vaap1997/CSL_Lima/tree/master/projects/LegoReader).

## **Building_Plan (Class)**
1. Constructor
```java
new Building_Plan(PGraphics canvas, int sizeCanvas, int nblocks, ArrayList<patternBlock> patternBlocks)
```
2. Description
- Create a new window and call the Plan draw function and the drawZoom in case there is a selected building.

## **Plan (Class)**
1. Constructor
```java
new Plan(int sizeCanvas, int nblocks, ArrayList<patternBlock> patternBlocks)
```
2. Methods
- *`draw(PGraphics canvas)`*: Create canvas mesh and add buildings dynamically depending of the table.

- *`drawZoom(PGraphics canvas, int id, float centerX, float centerY)`*: Draw the selected building infrastructure.

- *`drawParameter(PGraphics canvas, int id)`: Draw extra information about the selected building.

- *`assignType()`*: Asign a number of floors depending on its parameters.

- *`create(PGraphics canvas)`*: Calls each patternBlock.

- *`createBuildings(PGraphics canvas)`*: Creates a building as a Building objects.

- *`buildingSize()`*: Return the buildings array size, how many building are in a specific moment on the table.

- *`getBuilding()`*: Return all the buildings object inside the table.

## **Building (Class)**
1. Constructor
```java
new Building(int id, float numFloors, float roomSide, int scl, PVector loc, ArrayList<Cells> cells)
```
2. Methods
- *`setColor()`*: Assign an specific color depending on the block id number. This enable to select an specific building in the general sketch.

- *`draw(PGraphics canvas)`*: Create a building depending on its floor number and room per side number. Assign an specific position depending on its location on the mesh

- *`drawZoom(PGraphics canvas)`*: Create a building depending on its floor number and room per side number. Positionate the building in the center of the sketch


- *`assignColor(int x, int y, int limitX, int limitY)`*: Assign a pattern color to each corner of the top floor of the building.
