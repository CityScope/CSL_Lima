/**
* Roads - Class to manage the roadmap of simulation
* @author        Marc Vilella
* @modifier      Vanesa Alcantara
* @version       2.0
*/

public class Roads extends Facade<Node>{
      private PVector window;
      private PVector[] bounds;

      public Roads(String file, int x, int y, PVector[] bounds){
        window = new PVector(x,y);
        this.bounds = scaleBounds(bounds);
        factory = new RoadFactory();
        this.loadJSON(file,this);
        
      }
      
      /**
      * Scale bound in a WGS84 scale
      */
      public PVector[] scaleBounds(PVector[] bounds){
        return new PVector[]{
           Projection.toUTM(bounds[0].x, bounds[0].y, Projection.Datum.WGS84),
           Projection.toUTM(bounds[1].x, bounds[1].y, Projection.Datum.WGS84) 
          };
      }
    
      /**
      * connect a simple poi to the roads
      */
      private void connect(POI poi) {
            
            Lane closestLane = findClosestLane(poi.getPosition());
            Lane closestLaneBack = closestLane.findContrariwise();
            PVector closestPoint = closestLane.findClosestPoint(poi.getPosition());
            
            Node connectionNode = new Node(closestPoint);
            connectionNode = closestLane.split(connectionNode);
            if(closestLaneBack != null) connectionNode = closestLaneBack.split(connectionNode);
            this.add(connectionNode);
            
            poi.connectBoth(connectionNode, null, "footway", poi.access);
            add(poi);
           
      } 
       
     /**
      * connect poi with differect entries to the roads
      */
      private void connectP(POI poi, PVector[] coords){
        for(PVector coord:coords){
              Lane closestLane = findClosestLane(coord);
              Lane closestLaneBack = closestLane.findContrariwise();
              PVector closestPoint = closestLane.findClosestPoint(coord);
              
              Node connectionNode = new Node(closestPoint);
              connectionNode = closestLane.split(connectionNode);
              if(closestLaneBack != null) connectionNode = closestLaneBack.split(connectionNode);
              this.add(connectionNode);
              
              poi.connectBoth(connectionNode, null, "Parking", poi.access);
        }
        add(poi);
     }
     
     

    /**
    * find the closest lane to the point
    * find the closest point insite that lane
    */
     public PVector findClosestPoint(PVector position) {
        Lane closestLane = findClosestLane(position);
        return closestLane.findClosestPoint(position);
     } 

    /**
    * find the closest point in the closest lane
    * find the closest lane if you create a new one
    */
    public Lane findClosestLane(PVector position) {
        Float minDistance = Float.NaN;
        Lane closestLane = null;
        for(Node node : items) {
            for(Lane lane : node.outboundLanes()) {
                PVector linePoint = lane.findClosestPoint(position);
                float distance = position.dist(linePoint);
                if(minDistance.isNaN() || distance < minDistance) {
                    minDistance = distance;
                    closestLane = lane;
                }
            }
        }
        return closestLane;
    }
    

   
    /**
      * scale coordinate into the canvas (surface)
    */
    public PVector toXY(float lat, float lon){
      PVector projPoint = Projection.toUTM(lat, lon,Projection.Datum.WGS84);
      return new PVector(
      map(projPoint.x, bounds[0].x,bounds[1].x,0,window.x),
      map(projPoint.y, bounds[0].y,bounds[1].y,window.y,0)
      );
    }
  
    /**
    * add new node to the array
    */
    public void add(Node node) {
      if(node.getID() == -1) {
        node.setID(items.size());
        items.add(node);
       }
    }
  
    
    /**
      * call the draw of node that calls draw of lane and draw all the roads
    */
    public void draw(PGraphics canvas, int stroke, color c) {
        for(Node node : items){
          node.draw(canvas, stroke, c);
        } 
    }

  /**
  * point of the roads is insite the canvas(surface) 
 */
  public boolean contains(PVector point) {
        return point.x > 0 && point.x < window.x && point.y > 0 && point.y < window.y;
    }

}

public class RoadFactory extends Factory<Node>{
  
  public ArrayList<Node>  loadJSON(File file, Roads roads){
    JSONObject roadNetwork = loadJSONObject(file);
    JSONArray lanes = roadNetwork.getJSONArray("features");

    for(int i = 0; i < lanes.size(); i++){
        JSONObject lane =lanes.getJSONObject(i);
        //JALAR PROPERTIES
        JSONObject props = lane.getJSONObject("properties");
        String access = props.isNull("type")? "service" :  props.getString("type") ;
        String name = props.isNull("name")? "null" : props.getString("name");
        boolean oneWay = props.isNull("oneway")? false : props.getInt("oneway") == 1? true : false;
        String direction = props.isNull("direction")? null : props.getString("direction");
        JSONArray points = lane.getJSONObject("geometry").getJSONArray("coordinates");
        
        Node prevNode = null;
        ArrayList vertices = new ArrayList();
        
         for(int j = 0; j < points.size(); j++){
            PVector point = roads.toXY(points.getJSONArray(j).getFloat(1),points.getJSONArray(j).getFloat(0));
                if( roads.contains(point) ) {      
                 vertices.add(point);
                 Node currNode = getNodeIfVertex(roads,point);
                 if(currNode != null) {
                       if(prevNode != null && j < points.size()-1) {
                           if(oneWay) prevNode.connect(currNode, vertices, name, access);
                           else prevNode.connectBoth(currNode, vertices, name, access);
                           vertices = new ArrayList();
                           vertices.add(point);
                           prevNode = currNode;
                        }
                } else currNode = new Node(point);
                        
                if(prevNode == null) {
                       prevNode = currNode;
                       currNode.place(roads);
                } else if(j == points.size()-1) {
                       if(oneWay) prevNode.connect(currNode, vertices, name, access);
                       else prevNode.connectBoth(currNode, vertices, name, access);
                       currNode.place(roads);
                       if(direction != null) currNode.setDirection(direction);
                }
             }  
         }
    }   
    println("LOADED");
    return new ArrayList();
  }
  
  private Node getNodeIfVertex(Roads roads, PVector position) {
        for(Node node : roads.getAll()) {
            if( position.equals(node.getPosition()) ) return node;
            for(Lane lane : node.outboundLanes()) {
                if( position.equals(lane.getEnd().getPosition()) ) return lane.getEnd();
                else if( lane.contains(position) ) {
                    Lane laneBack = lane.findContrariwise();
                    Node newNode = new Node(position);
                    if(lane.divide(newNode)) {
                        if(laneBack != null) laneBack.divide(newNode);
                        newNode.place(roads);
                        return newNode;
                    }
                }
            }
        }
        return null;
    }
 
    

  
}  