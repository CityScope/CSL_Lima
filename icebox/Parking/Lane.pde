/**
* Roads - Class to manage the roadmap of simulation
* @author        Marc Vilella 
* @modifier      Vanesa Alcantara
* @version       2.0
*/


private class Lane {
    
    private String name;
    private String access;
    public color co;
    private Node initNode;
    private Node finalNode;
    private float distance;
    private ArrayList<PVector> vertices = new ArrayList();
    private ArrayList<Agent> crowd = new ArrayList();
    //private ArrayList<RNC> crowdRNC = new ArrayList();
    private FloatDict occupancyRNC = new FloatDict();
    private float maxCrowd = 10;
    private float occupancy;
    
    
    /**
    * create a lane with caracteristics name, access, initNode, finalNode and the vertices insite it
    * Asign a color depending of the line type
    */
    public Lane(String name, String access, Node initNode, Node finalNode, ArrayList<PVector> vertices) {
        this.name = name;
        this.access = access;
        this.initNode = initNode;
        this.finalNode = finalNode;
        
        if(vertices != null && vertices.size()!= 0) this.vertices = new ArrayList(vertices);
        else {
            this.vertices.add(initNode.getPosition());
            this.vertices.add(finalNode.getPosition());   
        }
        
        distance = calcLength();
        
        if(access.equals("primary")) {
           co = color(#FFF500); //yellow
         }else if((access.equals("pedestrian") )|| (access.equals("living_street")) || (access.equals("footway")) || (access.equals("steps"))){
           co = color(#CC68FF); //purple
         }else if( access.equals("secondary")){
           co = color(#002ADA); //blue
         }else{
          co=color(100); 
         } 
    }
    
   /**
   * return finalNode of the lane
   */
   public Node getEnd() {
        return finalNode;
    }
   
   /**
   * true if the vertex is inside vertices
   */
   public boolean contains(PVector vertex) {
        return vertices.indexOf(vertex) >= 0;
    }
    
   /**
   * return all the vertices in one array
   */
   public ArrayList<PVector> getVertices() {
        return new ArrayList(vertices);
    }
   
    /**
   * Allow just some type of roads
   */
   public boolean allows(Agent agent) {
     if((access.equals("pedestrian") )|| (access.equals("living_street")) || (access.equals("footway")) || (access.equals("steps"))){
        return false;
     } else{
       return true;
     }
   }
   
   /**
   * return an specific vertex
   */
   public PVector getVertex(int i) {
        if(i >= 0  && i < vertices.size()){
          return vertices.get(i).copy();
        }
        return null;
    }
    
    /**
   * return vertex given +1
   */
    public PVector nextVertex(PVector vertex) {
        int i = vertices.indexOf(vertex) + 1;
        if(i > 0 && i < vertices.size()) return vertices.get(i);
        return null;
    }
    
    /**
   * true if the vertex is one of the finalvertex of a lane
   */
    public boolean isLastVertex( PVector vertex ) {
        return vertex.equals( vertices.get( vertices.size() - 1 ) );
    }
    
   /**
   * distance between vertex and the one before
   */
    public float calcLength() {
        float dist = 0;
        for(int i = 1; i < vertices.size(); i++) dist += vertices.get(i-1).dist( vertices.get(i) );
        return dist;
    }
    
   /**
   * return dist that was calculate before
   */
    public float getLength() {
        return distance;
    }
    
   /**
   * If it has two ways
   */
    public Lane findContrariwise() {
        for(Lane otherLane : finalNode.outboundLanes()) {
            if( otherLane.isContrariwise(this) ) return otherLane;
        }
        return null;
    }
    
   /**
   * is content inside reversed vertices array
   */
    public boolean isContrariwise(Lane lane) {
        ArrayList<PVector> reversedVertices = new ArrayList(lane.getVertices());
        Collections.reverse(reversedVertices);
        return vertices.equals(reversedVertices);
    }
    
    /**
   * find distance between the position and all the vertices and select the minimum
   */
    public PVector findClosestPoint(PVector position) {
        Float minDistance = Float.NaN;
        PVector closestPoint = null;
        for(int i = 1; i < vertices.size(); i++) {
            PVector projectedPoint = Geometry.scalarProjection(position, vertices.get(i-1), vertices.get(i));
            float distance = PVector.dist(position, projectedPoint);
            if(minDistance.isNaN() || distance < minDistance) {
                minDistance = distance;
                closestPoint = projectedPoint;
            }
        }
        return closestPoint;
    }
  
   /**
   * divide the list of vertices that contain the node in two different arrays, creating two different lines
   */  
   protected boolean divide(Node node) {
        int i = vertices.indexOf(node.getPosition());
        if(i > 0 && i < vertices.size()-1) {
            ArrayList<PVector> dividedVertices = new ArrayList( vertices.subList(i, vertices.size()) );
            PVector type = vertices.get(2);
            node.connect(finalNode, dividedVertices, name, access);
            vertices = new ArrayList( vertices.subList(0,i+1) );
            finalNode = node;
            distance = calcLength();
            return true;
        }
        return false;
    }
    
    /**
   * Create a new node to connect the POI with the closest point in the closest lane
   */
    protected Node split(Node node) {
        if( node.getPosition().equals(vertices.get(0)) ) return initNode;
        else if( node.getPosition().equals(finalNode.getPosition()) ) return finalNode;
        for(int i = 1; i < vertices.size(); i++) {
            if( Geometry.inLine(node.getPosition(), vertices.get(i-1), vertices.get(i)) ) {
                
                ArrayList<PVector> splittedVertices = new ArrayList();
                splittedVertices.add(node.getPosition());
                splittedVertices.addAll( vertices.subList(i, vertices.size()) );
                node.connect(finalNode, splittedVertices, name, access);
                
                vertices = new ArrayList( vertices.subList(0, i) );
                vertices.add(node.getPosition());
                finalNode = node;
                distance = calcLength();
                return node;
            }
        }
        return null;
    }    
   
   /**
   * draw lanes with color
   */
   public void draw(PGraphics canvas, int stroke, color c) {  
     //public void draw(PGraphics canvas, int stroke, color c, DateTime indiceRnc) { 
     for(int i = 1; i < vertices.size(); i++) { 
            canvas.stroke(co, 127); canvas.strokeWeight(stroke); 
            //canvas.stroke(0, 127); canvas.strokeWeight(stroke);
            PVector prevVertex = vertices.get(i-1);
            PVector vertex = vertices.get(i);
            canvas.line(prevVertex.x, prevVertex.y, vertex.x, vertex.y); 
     }
    
     
   }
   
   /**
    * Add reference to an agent that is crossing in the lane. Recalculate occupancy
    * @param agent  The agent crossing the lane
    */
    public void addAgent(Agent agent) {
        crowd.add(agent);
        occupancy = (float) crowd.size() / maxCrowd;
    }
    
    
    /**
    * Remove reference to agent that was crossing in the lane, but it's not anymore. Recalculate occupancy
    * @param agent  The agent that was crossing the lane
    */
    public void removeAgent(Agent agent) {
        crowd.remove(agent);
        occupancy = (float) crowd.size() / maxCrowd;
    }
    
    /**
    * With every change of rncTime add new values to the dictionary
    */
    public void addRncTime(DateTime rncTime){
      occupancyRNC.set(rncTime.toString(), 1);
    }
 
}