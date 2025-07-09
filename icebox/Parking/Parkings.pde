/**
* Roads - Class to manage the roadmap of simulation
* @author        Marc Vilella
* @modifier      Vanesa Alcantara
* @version       2.0
*/
public class POIs extends Facade<POI>{   
  int totalAgentsIn;
  
  public POIs(){
    factory = new POIFactory();
  }
  
 
  /**
   * load POIs, error if there is not file
  */ 
  public void loadCSV(String path, Roads roadmap) {
    File file = new File( dataPath(path) );
    if( !file.exists() ) println("ERROR! CSV file does not exist");
    else {
      items.addAll( ((POIFactory)factory).loadCSV(path, roadmap) );
    }
  } 
  
  /**
   * load Escaldes's public or privates POIs, error if there is not file
  */ 
  public void loadPrivateCSV(String path, Roads roadmap){
    File file = new File( dataPath(path) );
    if( !file.exists() ) println("ERROR! CSV file does not exist");
    else {
      items.addAll( ((POIFactory)factory).loadPrivateCSV(path, roadmap) );
    }
  }

  /**
  * fullFit a dictionary with all the occupancies every date
  */ 
  public void loadED(ArrayList<DateTime> chronometer, ArrayList<TimeP> parks){
   print("\nLoading occupancy per date...");
    //print("\nLoading occPerDate...");
    IntList occPerPoi = new IntList();
    for(int a = 0; a < chronometer.size(); a++){
    occPerPoi.set(a,0);
    }
    for(int i=0; i <chronometer.size(); i++){ 
        for(TimeP park:parks){
          if(park.TIME.equals(chronometer.get(i))){
            int c=0;
             for( POI poi:pois.getAll()){
               if(poi.access.equals("publicPark")){
                    if( poi.PARKNUMBER == park.CARPARKNUMBER){
                        if(park.MOVTYPE == 1){
                          occPerPoi.set(c,occPerPoi.get(c)-park.PASSAGES);
                        }else{
                          occPerPoi.set(c,occPerPoi.get(c)+park.PASSAGES);
                        }
                    }
               c++; 
            }
          }
        }
      }
      
     int k=0;
     for(POI poi:pois.getAll()){
       if(poi.access.equals("publicPark")){
          poi.occupancyPerDate.set( chronometer.get(i).toString(),occPerPoi.get(k));
          k++;
        }
      }   
    }
   print("LOADED");
  }

  /**
   * Create an array with parking names
  */ 
  public ArrayList getPOInames(){
    ArrayList<String> namePark = new ArrayList();
    for (POI poi : pois.getAll()){
      if(poi.access.equals("publicPark")){
        namePark.add(new String(poi.NAME));
      }
    }
    return namePark;
  }
  
  /**
   * Create an array with parking capacity
  */ 
  public ArrayList getCapacity(){
     ArrayList CapacityPark = new ArrayList();
     for(POI poi : pois.getAll()){
       if(poi.access.equals("publicPark")){
         CapacityPark.add(int(poi.CAPACITY));
       }
     }
   return CapacityPark;
  }
  
 /**
 * Count the public Andorran POIs
 */ 
  public int count(){
    int i=0;
    for(POI poi : pois.getAll()){
      if(poi.access.equals("publicPark")){
      i++;
      }
    }
    return i;
  }
  
 /**
 * Draw parking occupancy for the chronometer time
 */ 
 public void draw(DateTime date){
    
    int c = 0;
    for(POI poi:pois.getAll()){ 
      if(poi.access.equals("publicPark")){
        //int Occupancy = (int) map(occupancy.get(c),0,800,0,100); 
        int Occupancy = (int) log(poi.getCrowd(date))*12; 
        float use = ((float)poi.getCrowd(date) / (float)poi.CAPACITY);
        color occColor = lerpColor(#4DFF00, #E60000,use);

            canvas.ellipseMode(CENTER); canvas.fill(occColor); canvas.stroke(occColor,127); canvas.strokeWeight(2);
            canvas.ellipse(poi.POSITION.x,poi.POSITION.y,2+Occupancy,2+ Occupancy);
            canvas.stroke(occColor);
            canvas.fill(occColor,100);
            int cap = (int) log(poi.CAPACITY)*12;
            canvas.ellipse(poi.POSITION.x,poi.POSITION.y,cap,cap);    
            canvas.fill(255);
            
            if(names) {   
              canvas.pushMatrix();
              canvas.translate(poi.POSITION.x, poi.POSITION.y);
              canvas.strokeWeight(6);
              canvas.rotate(3.5*PI/4);
              canvas.textSize(40);
              canvas.textAlign(CENTER);
              canvas.fill(#ff9f10);
              canvas.text(poi.NAME,0,0);
              canvas.popMatrix();
              
          }    
        c++;
      }else{
       canvas.fill(100,160);canvas.stroke(100);
       canvas.ellipse(poi.POSITION.x , poi.POSITION.y ,log(poi.CAPACITY)*12,log(poi.CAPACITY)*12);
      }
    }
  }
  


}

  /**
 * Load public parking (the study ones) 
 * Load in case of a JSON
 * Load in case of CSV
 */
public class POIFactory extends Factory {
  
    public ArrayList<POI> loadJSON(File JSONFile, Roads roads) {
        
        print("Loading POIs... ");
        ArrayList<POI> pois = new ArrayList();
        int count = count();
        JSONArray JSONPois = loadJSONObject(JSONFile).getJSONArray("features");
        for(int i = 0; i < JSONPois.size(); i++) {
            JSONObject poi = JSONPois.getJSONObject(i); 
            JSONObject props = poi.getJSONObject("properties");
            int parkNumber = props.getInt("Park number");
            String name = props.isNull("NAME") ? "null" : props.getString("NAME");
            String type = props.isNull("TYPE") ? "null" : props.getString("TYPE");
            int capacity = props.isNull("CAPACITY") ? 0 : props.getInt("CAPACITY");
            float price = props.isNull("Price")? 0 : props.getFloat("Price");
            price = ((int)( price * 100))/100.00;
            JSONArray coord = poi.getJSONObject("geometry").getJSONArray("coordinates");
            PVector location = roads.toXY( coord.getFloat(1), coord.getFloat(0) );
            
            String coords2 = poi.getJSONObject("geometry").getString("coordinates").replace("["," ");
            String coords3 = trim(coords2.replace("]"," "));
            float[] io_coords = float(split(coords3," "));
            PVector[] coords = new PVector[io_coords.length];
            //ArrayList[] DeviceNum = new ArrayList[io_coords.length];
            ArrayList<Integer> deviceNum = new ArrayList();
            
            for(int j = 0 ; j <= io_coords.length; i++){
              coords[j] = roads.toXY(io_coords[0],io_coords[1]);
              deviceNum.add((int)io_coords[2]);
              
            }
            if( roads.contains(location) ) {
                pois.add( new POI(roads, parkNumber, name, type, location, capacity, deviceNum, str(price),coords));
                counter.increment(type);
                count++;
            }
             
        }
        println("LOADED");
        return pois;  
    }  
    
    public ArrayList<POI> loadCSV(String path, Roads roads) {
        
        print("Loading POIs... ");
        ArrayList<POI> pois = new ArrayList();
        int count = count();
        
        Table table = loadTable(path, "header");
        
        for(TableRow row : table.rows()) {
            int parkNumber = row.getInt("Park number");
            String name = row.getString("Name");
            String type = row.getString("Type");
            int capacity = row.getInt("Capacity");
            float price =  row.getFloat("Price");
            price = ((int)( price * 100))/100.00;
            PVector location = roads.toXY(row.getFloat("Latitude"),row.getFloat("Longitude"));
            String entries = row.getString("Entries");
            String[] entries_coords = split(entries,"|");
            PVector[] coords = new PVector[entries_coords.length];
            String io = row.getString("IO");
            String[] io_coords = split(io,"|");
            ArrayList deviceNum = new ArrayList();
            
            for(int i=0; i< entries_coords.length; i++){
              float[] latlonIO = float(split(entries_coords[i]," "));
              coords[i] = roads.toXY(latlonIO[0],latlonIO[1]); 
            }

            for(int i = 0; i < io_coords.length; i++){
              deviceNum.add(int(io_coords[i]));
            }
            if( roads.contains(location) ) {
                pois.add( new POI(roads, parkNumber, name, type, location, capacity, deviceNum, str(price), coords) );
                counter.increment(path); 
                count++;
            }           
        }
        println("LOADED");
        return pois;     
    }
    
     /**
   * Load private parking
   */ 
   public ArrayList<POI> loadPrivateCSV(String path, Roads roads){
     ArrayList<POI> pois = new ArrayList();
     Table table =  loadTable(path, "header");
     int id=0;
      for(TableRow row: table.rows()){
        String name = row.getString("Name");
        String type = row.getString("Type");
        int capacity = row.getInt("Capacity");
        String coord0 = row.getString("Coords");
        String[] coord1 =  split(coord0,",");
        PVector coords =  roads.toXY(float(coord1[0]),float(coord1[1]));
        pois.add(new POI(roads, id, type, name, coords, capacity));
        id ++;
      }
      return pois;
    }
    
}

 /**
 * create class POI with caracteristic
 */
public class POI extends Node{
 protected final int PARKNUMBER;
 protected final String NAME;
 protected final int CAPACITY;
 protected final String access;
 protected final PVector[] COORDS;
 protected final ArrayList<Integer> DEVICENUM;
 protected final String PRICE;
 public int line;
 protected ArrayList<Agent> crowd = new ArrayList();
 private IntDict occupancyPerDate = new IntDict();
 
 
     public POI(Roads roads, int parkNumber, String name, String type, PVector position, int capacity, ArrayList<Integer> deviceNum, String price, PVector[] coords){
            super(position);
            PARKNUMBER = parkNumber ;
            NAME = name;
            CAPACITY = capacity;
            access = type;
            DEVICENUM = deviceNum;
            COORDS = coords;
            PRICE = price;
            place(roads);           
     }
     
     public POI(Roads roads, int id, String type, String name, PVector position, int capacity){
       super(position);
       PARKNUMBER = id ;
       NAME = name;
       CAPACITY = capacity;
       access = type;
       DEVICENUM = null;
       COORDS = null;
       PRICE = null;
       place(roads);
     }
     
    
    /**
    * conect different entries of the poi with the road
    */
    public void place(Roads roads){
      if(access.equals("publicPark")){
        roads.connectP(this, COORDS); 
      }else{
        roads.connect(this); 
      }
    }
    
    /**
    * Upload how many agents are insite the POI
    */
    public boolean host(Agent agent) {
      //int occIn = timePark.getIn(indice,this);
        //if(crowd.size() < occIn) {
            crowd.add(agent);
            return true;
        //}
        //return false;
    }
   
    /**
    * Upload how many agents are insite the POI
    */
    public void unhost(Agent agent) {
        crowd.remove(agent);
    } 
    
    /**
    * get how crowded is in a moment
    */
    public int getCrowd(DateTime date){
      int crowd;
      if(occupancyPerDate.hasKey(date.toString())){
        crowd = occupancyPerDate.get(date.toString());
      }else{
        crowd = 0;
      }
      return crowd;
    } 
    
}