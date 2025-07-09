# Graphics
Template to create different kinds of graphics. Include line graphics, bar graphics,
pie ring graphics, speedometers, population graphics and radial line graphics.

## **Contact Info**
**Vanesa Alcántara**: v.alcantarapanta@alum.up.edu.pe | https://github.com/vaap1997 .

## **BarGraph (Class)**
1. Constructor
```java
new Building_Plan()
```
2. Methods
- *`drawBarGraph(PGraphics canvas, ArrayList<String> localsName, ArrayList<Float> localsParameters, String header)`*: Create a bar graphic with localsName in the x axis and the localParameters (percentage) in the y axis.

## **LineGraph (Class)**
1. Constructor
```java
new LineGraph(ArrayList<Local> locals, int w, int h)
```
2. Methods
- *`drawLineGraph(PGraphics canvas, ArrayList<Float> localsParameters, ArrayList<DateTime> chronometer, String header)`*: Create a line graph with chronometer in the x axis, localsParameters in the y axis and header as graph title.

## **Line (Class)**
1. Constructor
```java
new Line(float lastCoordsx, float lastCoordsy, int coordsx, int coordsy, int type, int repeat)
```
2. Description
Create line separate groups in the different items.

## **Piering (Class)**
1. Constructor
```java
new Piering()
```
2. Methods
- *`drawPieRing(PGraphics canvas, ArrayList<String> localsName, ArrayList<ArrayList> localsParameters, String header)`*: Takes size of localsParameters ans create a pie for each of it.

- *`pieChart(PGraphics canvas,float diameter, int i,ArrayList<Float> localsParameters)`*: Create a piechart and fill each part with its parameter where green is 0% and red is 100%.

## **PopulationGraph (Class)**
1. Constructor
```java
new PopulationGraph()
```
2. Methods
- *`drawPopulationGraph(PGraphics canvas, ArrayList<String> localsName, ArrayList<Float> localsParameters, String header)`*: Takes the local parameter and proportionally shows 10 people fill according to the parameter percentage.

## **RadialLine (Class)**
1. Constructor
```java
new RadialLine()
```
2. Methods
- *`drawRadialGraph(PGraphics canvas, ArrayList<ArrayList> localsParameters, String header)`*: Takes size of localsParameters ans create a pie for each of it.

- *`polygonArea(ArrayList<PVector> xy)`*: Calculate polygonArea.
