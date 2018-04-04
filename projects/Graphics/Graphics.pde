/**
* estadictic_graphics - templates for different kinds of graphics changing with time
* @author        Vanesa Alcantara
* @version       2.0
*/

import org.joda.time.*;
import org.joda.time.format.*;

int max;
int indice = 0;
int lastIndice = 0;
int timer = millis();
ArrayList<Local> locals;
ArrayList<DateTime> chronometer;
Boolean stop = false;
DateTime now;

PGraphics canvasLine;
PGraphics canvasPieRing;
PGraphics canvasBar;
PGraphics canvasPopulation;
PGraphics canvasRadial;
PGraphics canvasSpeedometer2;
PGraphics canvasSpeedometer3;


LineGraph lineGraph;
PieRing   pieRing;
BarGraph barGraph;
PopulationGraph populationGraph;
RadialLine  radialLine;
Speedometer speedometer2;
Speedometer speedometer3;

public void setup(){
  fullScreen(P2D);
  background(0);
  locals = loadJSON();
  now = new DateTime();
  chronometer = new ArrayList();
  for(int i=0; i< locals.get(0).parameters.size(); i++){
     chronometer.add(now.plusDays(i)); 
  } 
  canvasLine = createGraphics(600,420);
  lineGraph = new LineGraph(locals, canvasLine.width,canvasLine.height);
  
  canvasPieRing = createGraphics(450,height - canvasLine.height);
  pieRing = new PieRing();
  
  canvasBar = createGraphics(600,height - canvasLine.height);
  barGraph = new BarGraph();

  canvasPopulation = createGraphics(300 , 370);
  populationGraph = new PopulationGraph();
  
  canvasRadial = createGraphics(width - canvasLine.width - canvasPopulation.width, 420);
  radialLine = new RadialLine(); 
  int hS = (height - canvasRadial.height)/2;

  canvasSpeedometer2 = createGraphics(width - canvasPieRing.width - canvasBar.width, hS);
  canvasSpeedometer3 = createGraphics(width - canvasPieRing.width - canvasBar.width, hS);

  speedometer2 = new Speedometer();
  speedometer3 = new Speedometer();
  
  
  //frameRate(30);
}

public void draw(){
  if(millis() - timer > 2000){
    if(indice < chronometer.size()-1 & !stop){
      indice ++;
    }else if(indice < chronometer.size()-1 & stop){
      
    }else{
     indice = 0;
    }
    timer = millis();
  }
  
    background(0);
    textSize(20);textAlign(CENTER); fill(200); stroke(200);
    text(chronometer.get(indice).toString(),canvasLine.width + canvasRadial.width + canvasPopulation.width/2,25);
    
    canvasBar.beginDraw();
    barGraph.drawBarGraph(canvasBar,getLocalsName(),getLocalsParameters(indice),"EXAMPLE OF BARGRAPHIC" );
    canvasBar.endDraw();
    image(canvasBar, canvasPieRing.width, canvasLine.height);
    
    canvasLine.beginDraw();
    canvasLine.fill(0);
    lineGraph.drawLineGraph(canvasLine,getLocalsParameters(indice), chronometer,"EXAMPLE OF LINEGRAPHIC");
    canvasLine.endDraw();
    image(canvasLine,0,0);
    
    canvasPieRing.beginDraw();
    pieRing.drawPieRing(canvasPieRing, getLocalsName(), getLocaslsAllParameters(),"EXAMPLE OF PIERINGGRAPHIC");
    canvasPieRing.endDraw();
    image(canvasPieRing, 0,canvasLine.height);
    
    canvasPopulation.beginDraw();
    populationGraph.drawPopulationGraph(canvasPopulation,getLocalsName(),getLocalsParameters(indice),"EXAMPLE OF POPULATIONGRAPHIC");
    canvasPopulation.endDraw();
    image(canvasPopulation, canvasLine.width,0);
    
    canvasSpeedometer2.beginDraw();
    speedometer2.drawSpeedometer(canvasSpeedometer2, locals.get(0).name, locals.get(0).parameters2.get(indice),indice,"EXAMPLE 2 OF SPEEDOMETERGRAPHIC");  
    canvasSpeedometer2.endDraw();
    image(canvasSpeedometer2, canvasPieRing.width + canvasBar.width,canvasRadial.height);
    
    canvasSpeedometer3.beginDraw();
    speedometer3.drawSpeedometer(canvasSpeedometer3, locals.get(1).name, locals.get(1).parameters3.get(indice),indice,"EXAMPLE 3 OF SPEEDOMETERGRAPHIC");  
    canvasSpeedometer3.endDraw();
    image(canvasSpeedometer3, canvasPieRing.width + canvasBar.width,canvasRadial.height + canvasSpeedometer2.height );  
    
    canvasRadial.beginDraw();
    radialLine.drawRadialGraph(canvasRadial,getAllParameters(indice), "EXAMPLE2  OF LINEARGRAPHIC");
    canvasRadial.endDraw();
    image(canvasRadial,canvasLine.width +  canvasPopulation.width, 0);  
  
  
}

public void keyPressed(){
  switch(key){
    case ' ':
      stop = !stop;
      break;
  }
}

//[l1name, l2name, etc]
public ArrayList<String> getLocalsName(){
  ArrayList<String> localsNames = new ArrayList();
  for(Local l:locals){
    localsNames.add(l.name);
  }
  return localsNames;
}

// [ l1par, l2par, l3par, etc ]
public ArrayList<Float> getLocalsParameters(int indice){
  ArrayList<Float> localsParameters = new ArrayList();
  for(Local l:locals){
    localsParameters.add(l.parameters.get(indice));
  }
  return localsParameters;
}

// [ [l1par,l2par,l3par,etc] [l1par2,l2par2,l3par3,etc] ]  
public ArrayList<ArrayList> getLocaslsAllParameters(){
  ArrayList<ArrayList> allLocalsParameters = new ArrayList();
  for(int i=0; i<locals.get(0).parameters.size(); i++){
    ArrayList<Float> localsParameters = new ArrayList();
    for(Local l:locals){
      localsParameters.add(l.parameters.get(i));
    }
    allLocalsParameters.add(localsParameters);
  }
  return allLocalsParameters;
}

public ArrayList<ArrayList> getAllParameters(int indice){
  ArrayList<ArrayList> allParameters = new ArrayList();
  for(Local l:locals){
  ArrayList<Float> parameters = new ArrayList();
    parameters.add(l.parameters.get(indice));
    parameters.add(l.parameters2.get(indice));
    parameters.add(l.parameters3.get(indice));
    parameters.add(l.parameters4.get(indice));
    parameters.add(l.parameters5.get(indice));
    allParameters.add(parameters);
  }
  return allParameters;
}



public ArrayList<Local> loadJSON(){
  ArrayList<Local> locals = new ArrayList();
  JSONObject information = loadJSONObject("data/parameters.json");
  JSONObject input = information.getJSONObject("Input");
  for(int i=0; i<input.size(); i++){
    JSONObject loc = input.getJSONObject(str(i));
    String nameLoc = loc.getString("nameLoc");
    ArrayList<Float> parameters = new ArrayList();
    ArrayList<Float> parameters2 = new ArrayList();
    ArrayList<Float> parameters3 = new ArrayList();
    ArrayList<Float> parameters4 = new ArrayList();
    ArrayList<Float> parameters5 = new ArrayList();
    JSONArray parametersA = loc.getJSONArray("parameters");
    JSONArray parametersA2 = loc.getJSONArray("parameters2");
    JSONArray parametersA3 = loc.getJSONArray("parameters3");
    JSONArray parametersA4 = loc.getJSONArray("parameters4");
    JSONArray parametersA5 = loc.getJSONArray("parameters5");
    for(int j=0; j < parametersA.size();j++){
      parameters.add(parametersA.getFloat(j));
      parameters2.add(parametersA2.getFloat(j));
      parameters3.add(parametersA3.getFloat(j));
      parameters4.add(parametersA4.getFloat(j));
      parameters5.add(parametersA5.getFloat(j));
    }
    locals.add(new Local(i,nameLoc,parameters,parameters2,parameters3,parameters4,parameters5));
  }
  print("\nInformation loaded");
  return locals; 
}

public class Local{
  int id;
  String name;
  ArrayList<Float> parameters = new ArrayList();
  ArrayList<Float> parameters2 = new ArrayList();
  ArrayList<Float> parameters3 = new ArrayList();
  ArrayList<Float> parameters4 = new ArrayList();
  ArrayList<Float> parameters5 = new ArrayList();
  
  Local(int id, String name,ArrayList<Float>  parameters,ArrayList<Float>  parameters2,ArrayList<Float>  parameters3,ArrayList<Float>  parameters4,ArrayList<Float>  parameters5){
    this.id = id;
    this.name = name;
    this.parameters = parameters;
    this.parameters2 = parameters2;
    this.parameters3 = parameters3;
    this.parameters4 = parameters4;
    this.parameters5 = parameters5;
  }
 
}