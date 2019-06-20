# Parking - Andorran Parkings


## **Description**
The main aim of this study is understand parking behavior in a data sample on July 2016 and
built the basses to got real statistics of parking behavior. All this in order to have the real data
needed to take decisions about parking reforms.

## **Authors**
The project was done by Vanesa Alcantara, Universidad del Pacífico
under the supervision and support of the ActuaTech Foundation. It began as a way to
understand the actual CityScope, in consequence, the script has contributions from other
works from Mark Vilella and Guillem Francisco Observatory of Sustainability of Andorra
(OBSA), and Arnaud Grignard and Ronan Doorley, MIT Media Lab. References from Daniel
Shiffman.

## **Inputs**
This research uses three different bases: General public parking data, General private parking
data, Entries and Departures data. Also use JSON with roads data.

## **Libraries needed**
This project import [Joda-Time](http://www.joda.org/joda-time/) library. 

## **Classes**
The main code is divided in 13 slides, 12 of different classes and a principal one to call and
organize every class. Inside the 12 classes you can divided them in two groups: principal classes
and secondary classes. The principal classes: Roads, Parking, Time, Vehicle and Chart. The
secondaries: Lane and Node to support Roads and Vehicles; Design Pattern and Interfaces that
support the infrastructure of Roads, Parking, Node and Lane; Projection to transform every
node and parking from Cartesians coordinates to cartographic coordinates, Utils to confirm if a
point is contain in a line and to find to create perpendicular lanes both to connect parking to
roads; and Warp to adjust the canvas to the 3D model surface where part of the visualization is
show.
### **Roads**
1. Constructor
```java
new Roads(String file, int x, int y, PVector[] bounds)
```
2. Description
Read a JSON file in to get the coordinates associate to every road; first in
create different nodes, cleaning the ones out of the area of study and the repeat ones; second,
creating different lines depending of the relation between the nodes. Every road has lanes
associates and every lane has different characteristics: name, initial node, final node, vertices
inside the final and initial node and access.

### **Parking**
1. Constructors
Pois with multiples entries
```java
POI(Roads roads, int parkNumber, String name, String type, PVector position, int capacity, ArrayList<Integer> deviceNum, String price, PVector[] coords)
```
Pois with just one entry
```java
POI(Roads roads, int id, String type, String name, PVector position, int capacity)
```

2. Description
This class place the different Parking (points of interest – POIs) in the canvas and
connect the parking to the roads. There are two types of parking, the public parking that
correspond to the ones with information; private parking and the ones of Escaldes, the ones
without entries and outs information.

### **Agents**
1. Constructors
```java
Agent(int id, Roads roads, int size, String hexColor)
```
2. Description
Create agents in a random position, every vehicle chooses one destination and find a
path to this destination choosing the roads that have access to vehicles. Once arrive, reset all
the information, select a new destination and a new path. Repeat this process while the
visualization is play.

### **Times**
1. Constructors
```java
TimePark(String path, POIs pois)
```
2. Description
Read all the entries and departures and creates, reads the max and min times in order to
create a chronometer from and to this times. Create an array with the occupancy of all the
parking according to the date. Create an array with basic statistics: average max day every
week, the average max day of the week for all the month, the average max and min hour every
day.

### **Chart**
1. Description
Creates a dynamic table with all the statistics create in Time. Create a linear graphic
while the chronometer is going forward, create a line every hour in the chronometer and
associates every line to a cycle of repetition and to a specific parking. Draw the final results.

## **Fuctionalities**

|      Key      |                      Funcionality                           |
| ------------- | ----------------------------------------------------------- |
|    Space      | Change between Andorra’s image map and Andorra’s roads map  |
|      f        | Stop the chronometer and all the visualization              |
|      n        | Show parking’s names                                        |
|      k        | Calibrate Andorra's surface                                 |
|      g        | Safe new warp calibratiton                                  |
|      UP       | Move Andorra’s surface up once in the surface mode          |
|     DOWN      | Move Andorra’s surface down once in the surface mode        | 
|     RIGHT     | Move Andorra’s surface right once in the surface mode       |
|     LEFT      | Move Andorra’s surface left once in the surface mode        |
|     + / -     | Increase / decrease visualization’s speed                   |
|      1        | Show or hide parking Fener 1’s line                         |
|      2        | Show or hide parking Fener 2’s line                         |
|      3        | Show or hide parking Parc Central’s line                    |
|      4        | Show or hide parking Parc Central’s 2 line                  |
|      5        | Show or hide parking Centre Historic’s line                 |
|      6        | Show or hide parking Prada Casadet’s line                   | 
|      7        | Show or hide parking Prat de la Creu’s line                 |
|      7        | Show or hide parking Trilla’s line                          |
|      9        | Show or hide parking Serradells’s line                      |
|      0        | Show or hide parking Antic Cami Ral’s line                  | 
 
## **Example (preliminary)**
![first screen](https://github.com/vaap1997/Parking/blob/master/data/Result_01.png)
![second screen](https://github.com/vaap1997/Parking/blob/master/data/Resultado_02.png)
![third screen](https://github.com/vaap1997/Parking/blob/master/data/Resultado_03.png)




