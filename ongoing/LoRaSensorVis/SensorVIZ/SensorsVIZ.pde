// Background image
PImage BG;
boolean showBG = true;

// 3D Model projection
WarpSurface surface;

// Canvas Object
Canvas canvas;

// Roadnetwork
Lanes roadnetwork;

// MQTT client
MQTTClient client;

//SQL client
MySQLClient mysqlClient;

// Sensors facade;
Sensors sensors;

// Canvas and Surface configuration
int simWidth = 1000;
int simHeight = 847;
final String bgPath = "bg/orto.png";
final PVector[] bounds = new PVector[] {
  new PVector(42.482119, 1.489794), 
  new PVector(42.533768, 1.572122)
};
PVector[] roi = new PVector[] {
  new PVector(42.505086, 1.509961), 
  new PVector(42.517066, 1.544024), 
  new PVector(42.508161, 1.549798), 
  new PVector(42.496164, 1.515728)
};

LatLon[] ROI = new LatLon[] {
  new LatLon(42.505086, 1.509961), 
  new LatLon(42.517066, 1.544024), 
  new LatLon(42.508161, 1.549798), 
  new LatLon(42.496164, 1.515728)
};

// Roadnetwork configuration
String roadnetworkPath = "roads/roads.geojson";

// MQTT configuration
String broker = "<>://<yourRegion>.thethings.network:<port>";
String user = "<appID>";
String password = "ttn-account-v2.<lotsOfCharacters>";
String topic = "<appID>/devices/<devID>/up";

// Sensors configuration
String sensorsPath = "sensors/sensors.json";

// MySQL configuration
String host = "<IP>:<port>";
String database = "<yourDB>";
String username = "<user>";
String pswd = "<pswd>";

// Color gradient configuration
WarpSurface gradSurface;
PGraphics gradCanvas;
color mint, maxt;
boolean showGradient = true;

//Dashboard object
WarpSurface dashSurface;
PGraphics dashCanvas;

//Font
PFont myFont;

//Artist object
Artist artist;


void settings() {
  fullScreen(P3D);
}


void setup() {
  smooth();

  myFont = createFont("Muli", 15);

  BG = loadImage(bgPath);
  simWidth = BG.width;
  simHeight = BG.height;

  surface = new WarpSurface(this, 900, 300, 10, 5, ROI);
  //surface.loadMainConfig("warp.xml");

  dashSurface = new WarpSurface(this, 1400, 160, 4, 2, null);
  //dashSurface.loadConfig("dash.xml");
  dashCanvas = createGraphics(1400, 160);

  canvas = new Canvas(this, simWidth, simHeight, bounds, roi);

  roadnetwork = new Lanes(roadnetworkPath, simWidth, simHeight, bounds);

  client = new MQTTClient(broker, user, password);
  client.connect();
  client.setCallback();
  client.subscribe(topic);

  mysqlClient = new MySQLClient(this, host, database, username, pswd);
  mysqlClient.createTextBoxes(myFont);

  sensors = new Sensors(sensorsPath, client, surface, mysqlClient);

  mint = #13BCE9;
  maxt = #F7F71B;

  gradCanvas = createGraphics(200, 30);
  gradSurface = new WarpSurface(this, 200, 30, 2, 2, null);
  //gradSurface.loadConfig("grad.xml");

  artist = new Artist(sensors.getSensors(), mint, maxt, roadnetwork, mysqlClient);
}


void draw() {
  background(0);

  canvas.beginDraw();
  canvas.background(255);
  if (showBG) canvas.image(BG, 0, 0); 
  roadnetwork.draw(canvas, 1, #c0c0c0);
  artist.draw(canvas, 15, -10, 30);
  canvas.endDraw();
  surface.draw(canvas);

  dashCanvas.beginDraw();
  dashCanvas.background(0);
  artist.drawDashboard(dashCanvas, myFont);
  dashCanvas.endDraw();
  dashSurface.draw(dashCanvas);

  gradCanvas.beginDraw();
  gradCanvas.background(255);
  artist.drawGradient(gradCanvas, "Temperature range", "-10", "30", 200, 30);
  gradCanvas.endDraw();
  gradSurface.draw(gradCanvas);
}


void keyPressed() {
  switch(key) {
  case 'b':
    showBG = !showBG;
    break;

  case 'c':
    surface.toggleCalibration();
    break;

  case 'd':
    dashSurface.toggleCalibration();
    break;

    //case 'e':
    //  dashSurface.saveConfig("dash.xml");
    //  println("Dashboard configuration saved");
    //  break;

  case 'f':
    gradSurface.toggleCalibration();
    break;

  case 'm':
    artist.toggleMode();
    break;

    //case 'g':
    //  gradSurface.saveConfig("grad.xml");
    //  println("Gradient configuration saved");
    //  break;

  case '\n':
    mysqlClient.query();
    break;

    //case 's':
    //  surface.saveMainConfig("warp.xml");
    //  break;
  }
}
