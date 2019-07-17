/**
* Parking - Visualize parkings behavior
* @author        Vanesa Alcantara
* @version       3.0
*/

import org.joda.time.*;
import org.joda.time.Minutes;
import org.joda.time.format.DateTimeFormatter;
import org.joda.time.format.DateTimeFormat;


Roads roads;
POIs pois;
POI poi;
Path path;
TimePark timePark;
WarpSurface surface;
PieChart pieChart;
Agents agents;
DateTimeFormatter fmtPark = DateTimeFormat.forPattern("dd/MM/yy HH:mm");
DateTimeFormatter fmtToShow = DateTimeFormat.forPattern("dd/MM/yy  HH:mm");
DateTime minDate;

boolean showBG = true;
boolean freeze = true;
boolean names = false;
boolean type1 = true;
boolean type2 = true;
boolean type3 = true;
boolean type4 = true;
boolean type5 = true;
boolean type6 = true;
boolean type7 = true;
boolean type8 = true;
boolean type9 = true;
boolean type0 = true;
PGraphics canvas;
PGraphics legend;
PGraphics chart;
PGraphics linearGraphic;
PGraphics individualCanvas;
PImage BG;
PImage speedometer;

PVector[] roi = new PVector[] {
    new PVector(42.505086, 1.509961),
    new PVector(42.517066, 1.544024),
    new PVector(42.508161, 1.549798),
    new PVector(42.496164, 1.515728)
};

final PVector[] orthoBounds = new PVector[] {

    new PVector(42.495, 1.50803),
    new PVector(42.5181, 1.55216)
};


final String roadsPath = "roads.geojson";
final String bgPath = "orto.jpg";
DateTime datesS;
String actualDate;
int indiceLine = 0;
int simWidth = 1000;
int simHeight = 847;
int timer = millis();
int speed = 200;
int indice = 0;
int lastIndice = 0;
int totalAgent = 200;
int numLinks, numPeriods;
int currhour = 1;
int lastNamex = 600 ;
int lastNamey = 600 ;
public int maxHourT = 23;
ArrayList deviceNumPark;
ArrayList<String> maxDay;
ArrayList<PVector> lastCoord = new ArrayList();
ArrayList<ArrayList> dinamicHours;
ArrayList<String> dinamicDay;
PImage coche_rojo;
PImage coche_verde;
PImage coche_blanco;
PImage mapa_dAndorra;
PImage bus;
PImage pesa;
PImage pCompras;
PImage pLaboral;
PImage radar;
//IntList occupancy = new IntList();

/**
* Create a canvas by linking more than one screen
* Create a surface to manipulate the canvas
* Upload roads
* Place pois
* Read timepark
* Fullfit dictionary of occupancy per poi per date
* Create PGraphics and inicialize line graphics
* Inicialize agents
*/
void setup(){
  fullScreen(P2D,SPAN);
  background(0);
  smooth(); 
  
  BG = loadImage(bgPath);
  simWidth = BG.width;
  simHeight = BG.height;
  surface = new WarpSurface(this, 1500, 550, 20, 10);
  surface.loadConfig();
  canvas = new Canvas(this, simWidth, simHeight, orthoBounds ,roi);
  
  roads = new Roads(roadsPath,simWidth,simHeight,orthoBounds);
  
  pois = new POIs();
  pois.loadCSV("Aparcaments.csv",roads);
  pois.loadPrivateCSV("Private_Parkings.csv",roads);

  timePark = new TimePark("Aparcaments_julio.csv", pois); 
  pois.loadED(timePark.chronometer, timePark.parks);
  minDate =  timePark.minDate;
  
  legend = createGraphics(700, 80);
  linearGraphic = createGraphics(860, 520);
  //linearGraphic = createGraphics(1520, 520);
  //individualCanvas = createGraphics(1520,height - linearGraphic.height-100);
  individualCanvas = createGraphics(1460,height - linearGraphic.height);
  chart = createGraphics(580,linearGraphic.height+20);
  pieChart =  new PieChart();

  int j=0;
  for(POI poi : pois.getAll()){
    if(poi.access.equals("publicPark")){
       lastCoord.add(j,new PVector(pieChart.borderX,(int)poi.getCrowd(minDate) / poi.CAPACITY)); 
       j++;
    }
  }
  
 agents = new Agents();
 agents.loadVehicles(totalAgent, "vehicle", roads);
 agents.setSpeed(3, 6);
 
 coche_rojo = loadImage("coche_rojo.png");
 coche_rojo.resize(int(coche_rojo.width * 0.3), int(coche_rojo.height * 0.3));
 coche_verde = loadImage("coche_verde.png");
 coche_verde.resize(int(coche_verde.width * 0.3), int(coche_verde.height * 0.3));
 coche_blanco = loadImage("coche_blanco.png");
 coche_blanco.resize(int(coche_blanco.width * 0.3), int(coche_blanco.height * 0.3));
 mapa_dAndorra = loadImage("Mapa_d'Andorra2.png");
 mapa_dAndorra.resize(int(mapa_dAndorra.width*0.12),int(mapa_dAndorra.height*0.12));
 bus = loadImage("bus.png");
 bus.resize(int(bus.width*0.25),int(bus.height*0.25));
 pesa = loadImage("serra.png");
 pesa.resize(int(pesa.width*0.60),int(pesa.height*0.60));
 pCompras = loadImage("compras.png");
 pCompras.resize(int(pCompras.width*0.45),int(pCompras.height*0.45));
 pLaboral = loadImage("portafolio1.png");
 pLaboral.resize(int(pLaboral.width*0.16),int(pLaboral.height*0.16));
 radar = loadImage("radar.png");
 radar.resize(int(radar.width*0.55),int(radar.height*0.55));
}


/**
* Inicialize choronometer
* draw roads and vehicles insite the surface
* draw surface
* draw legend
* draw linear graphic
* draw a chart with basic parking's statidistics
* draw summary
*/
void draw(){  
    background(0);
    if(indice > 0) lastIndice = indice-1;
    if( millis() - timer >= speed){
      int maxIndice = timePark.getmax();
      if(indice >= maxIndice){
        indice = 0;
      } 
      if(freeze) {
        datesS = timePark.chronometer.get(indice);
        actualDate = datesS.toString(fmtToShow);
      }
      timer = millis();
    }
    //-------------MAP---------------
    canvas.beginDraw();
    canvas.background(0);
    //canvas.background(100);
    if(showBG){
      canvas.image(BG,0,0); 
    }
    else roads.draw(canvas,3,#cacfd6);  
    pois.draw(datesS);
    agents.move(); 
    agents.draw(canvas);
      
    canvas.endDraw(); 
    surface.draw((Canvas) canvas);
    //-------------- LEGEND ----------------------
    legend.beginDraw();
    pieChart.drawLegend();
    legend.endDraw();
    image(legend,3025,757);
    
    //------------LINEAR GRAPHIC---------------
    linearGraphic.beginDraw();
    if(freeze) pieChart.drawLineGraph(datesS,minDate);
    linearGraphic.endDraw();
    //image(linearGraphic,0,100);
    image(linearGraphic,0,0);
    
    //-------------SPEEDOMETER-----------------
    individualCanvas.beginDraw();
    pieChart.BasicParkingStats(indice, datesS);
    individualCanvas.endDraw();
    //image(individualCanvas,0,linearGraphic.height+100);
    image(individualCanvas,0,linearGraphic.height);

    //----------- SUMMARY ----------------------
    chart.beginDraw();
    chart.background(0);
    pieChart.drawSummary();
    chart.endDraw();
    //image(chart,linearGraphic.width,100);
    image(chart,linearGraphic.width,0);    
    
    if(freeze){
     indice++; 
   }
}

/**
*Upload diffent funtionalities
*/
void keyPressed(KeyEvent e){
  switch(key){
    case ' ':
    showBG = !showBG;
    break;
    
    case 'f':
    freeze = !freeze;
    break;
    
    case 'n':
    names = !names;
    break;
        
    case 'k':
    surface.toggleCalibration();
   // ks.toggleCalibration();
    break;
    
    case 's':
    //ks.save();
    //ks.load();
    break;
    
    case 'g':
    surface.saveConfig();
    break;
    
    case '+':
      speed = speed - 20 ;
        agents.changeSpeed(1);
    break;
   
    case '-':
      speed = speed + 20;
        agents.changeSpeed(-1);
    break;
    
    case '1':
    type1 = !type1;
    break;
    
    case '2':
    type2 = !type2;
    break;
    
    case '3':
    type3 = !type3;
    break;
    
    case '4':
    type4 = !type4;
    break;
    
    case '5':
    type5 = !type5;
    break;
    
    case '6':
    type6 = !type6;
    break;
    
    case '7':
    type7 = !type7;
    break;
    
    case '8':
    type8 = !type8;
    break;
    
    case '9':
    type9 = !type9;
    break;
    
    case '0':
    type0 = !type0;
    break;

  }
  switch(e.getKeyCode()){
    case UP:
    surface.move(0,-5);
    break;
    case DOWN:
    surface.move(0,5);
    break;
    case LEFT:
    surface.move(-5,0);
    break;
    case RIGHT:
    surface.move(5,0);
    break;
  } 

}