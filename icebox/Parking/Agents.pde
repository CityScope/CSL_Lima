/**
* Agents - Facade to simplify manipulation of agents in simulation
* @author        Marc Vilella
* @version       1.0
* @see           Facade
*/
public class Agents extends Facade<Agent> {
    
    private float speed;
    private float maxSpeed = 6; 
    
    
    /**
    * Initiate agents facade and agents' Factory
    * @param parent  Sketch applet, just put this when calling constructor
    */
    public Agents() {
        factory = new AgentFactory();
    }
    
    public void loadVehicles(int numberAgents, String typeAgent, Roads roads ){
      if( !typeAgent.equals("vehicle") && !typeAgent.equals("Vehicle") ) println("ERROR! typeAgent different to vehicle");
      else {
      items.addAll( ((AgentFactory)factory).loadAgents(numberAgents, typeAgent, roads) );
      }

    }

    
    /**
    * Set agents movement speed
    * @param speed  Speed of agents in pixels/frame
    * @param maxSpeed  Maximum agents' speed
    */
    public void setSpeed(float speed, float maxSpeed) {
        this.maxSpeed = maxSpeed;
        this.speed = constrain(speed, 0, maxSpeed);
    }
    
    
    /**
    * Increment or decrement agents' speed
    * @param inc  Speed increment (positive) or decrement (negative)
    */
    public void changeSpeed(float inc) {
        speed = constrain(speed + inc, 0, maxSpeed);
    }
    
    
    /**
    * Gets the agents' speed
    * @return speed in pixels/frame
    */
    public float getSpeed() {
        return speed;
    }


    /**
    * Move agents
    * @see Agent
    */
    public void move() {
        for(Agent agent : items) {
            agent.move(speed);
        }
    }

}




/**
* AgentFactory - Factory to generate diferent agents from diferent sources 
* @author        Marc Vilella
* @version       1.0
* @see           Factory
*/
private class AgentFactory extends Factory {
    
    /**
    * Create agents from JSON file
    */
    public ArrayList<Agent> loadJSON(File file, Roads roads) {

        print("Loading agents... ");
        ArrayList<Agent> agents = new ArrayList();
        int count = count();
        
        JSONArray JSONagents = loadJSONObject(file).getJSONArray("agents");
        for(int i = 0; i < JSONagents.size(); i++) {
            JSONObject agentGroup = JSONagents.getJSONObject(i);
            
            int id            = agentGroup.getInt("id");
            String name       = agentGroup.getString("name");
            String type       = agentGroup.getString("type");
            int amount        = agentGroup.getInt("amount");
            
            JSONObject style  = agentGroup.getJSONObject("style");
            String tint       = style.getString("color");
            int size          = style.getInt("size");
            
            for(int j = 0; j < amount; j++) {
                Agent agent = null;
                
                if(type.equals("PERSON")) agent = new Person(count, roads, size, tint);
                if(type.equals("CAR")) agent = new Vehicle(count, roads, size, tint);
                
                if(agent != null) {
                    agents.add(agent);
                    counter.increment(name);
                    count++;
                }
            }
        }
        println("LOADED");
        return agents;
    }
    
    /**
    *Load random agents without JSONfile
    */
    public ArrayList<Agent> loadAgents(int numberAgents, String typeAgent, Roads roads ){
     ArrayList<Agent> agents = new ArrayList();
     int count = count();
     for( int i=0; i < numberAgents; i++){
         agents.add(new Vehicle(i, roads, 6 , "#B0B6B7"));
         counter.increment(typeAgent);
         count++;
     }
     return agents;
    }
    
    
}




/**
* Agent -  Abstract class describing the minimum ABM unit in simulation. Agent can move thorugh lanes and perform some actions
* @author        Marc Vilella
* @version       2.0
*/
public abstract class Agent implements Placeable {

    public final int ID;
    protected final int SIZE;
    protected final color COLOR;
    
    protected int speedFactor = 1;
    protected int explodeSize = 0;
    protected int timer = 0;
    
    protected boolean selected = false;
    protected boolean arrived = false;
    protected boolean panicMode = false;
    
    protected ArrayList<Node> points;
    protected POI destination;
    protected PVector pos;
    protected Path path;
    protected Node inNode;
    protected float distTraveled;
    protected final Roads ROADMAP;
    
    
    /**
    * Initiate agent with specific size and color to draw it, and places it in defined roadmap
    * @param id  ID of the agent
    * @param roads  Roadmap to place the agent
    * @param size  Size of the agent
    * @param hexColor  Hexadecimal color of the agent
    */
    public Agent(int id, Roads roads, int size, String hexColor) {
        ID = id;
        SIZE = size;
        COLOR = unhex( "FF" + hexColor.substring(1) );
       
        ROADMAP = roads;
        path = new Path(this, roads);
        inNode = getStart();
        pos = inNode.getPosition();
        place(roads);
        destination = findDestination();
    }

    
    /**
    * Place agent in roadmap. Random node by default
    * @param roads  Roadmap to place the agent
    */
    public void place(Roads roads) {
        inNode = getStart();
        //ArrayList<Node> possible = roads.filter(Filters.isAllowed(this));
        //inNode = possible.get( round(random(0, possible.size()-1)) );
        pos = inNode.getPosition();
    }
    
    /**
    * Asign an inicial destination
    */
    public Node getStart(){
     points = new ArrayList();
       for(Node node:ROADMAP.getAll()){
         if(node.allows(this)){
           points.add(node);
         }
     }
    return  points.get(round(random(0, points.size()-1))); 
    }
    
    
    /**
    * Get agent position in screen
    * @return agent position
    */
    public PVector getPosition() {
        return pos.copy();
    }
    
    
    /** 
    * Check if agent is moving
    * @return true if agent is moving, false if has arrived to destination
    */
    public boolean isMoving() {
        return !arrived;
    }
    
    
    /**
    * Find best POI destination based in agent's preferences
    * @return POI destination
    */
    public POI findDestination() {
        path.reset();
        arrived = false;
        POI newDestination = null;
        ArrayList<POI> possible = pois.getAll();
        while(newDestination == null || inNode.equals(newDestination)) {
            newDestination = possible.get( round(random(0, possible.size()-1)) );    // Random POI for the moment
        }
        return newDestination;
    }
    
    
    /*
    * Move agent across the path at defined speed
    * @param speed  Speed in pixels/frame
    */
    public void move(float speed) {
        if(!arrived) {
            if(!path.available()) path.findPath(inNode, destination);
            else {
                PVector movement = path.move(pos, speed * speedFactor);
                pos.add( movement );
                distTraveled += movement.mag();
                inNode = path.inNode();
                if(path.hasArrived()) {
                    if(destination.host(this)) {
                        arrived = true;
                        //whenArrived();
                    } else whenUnhosted();
                }
            }
        } else whenHosted();
    }
    
    
    /**
    * Move agent in random chaotic movement around its position
    * @param maxR  Maximum radius of movement
    */
    //protected void wander(int maxRadius) {
    //    float radius = arrived ? destination.getSize() / 2 : maxRadius;
    //    pos = inNode.getPosition().add( PVector.random2D().mult( random(0, radius)) );
    //}
    
    
    /**
    * Select agent if mouse is hover
    * @param mouseX  Horizontal mouse position in screen
    * @param mouseY  Vertical mouse position in screen
    * @return true if agent is selected, false otherwise
    */
    public boolean select(int mouseX, int mouseY) {
        selected = dist(mouseX, mouseY, pos.x, pos.y) < SIZE;
        return selected;
    }
    
    
    /**
    * Draw agent in panic mode (exploding effect)
    * @param canvas  Canvas to draw agent
    */
    protected void drawPanic(PGraphics canvas) {
        canvas.fill(#FF0000, 50); canvas.noStroke();
        explodeSize = (explodeSize + 1)  % 30;
        canvas.ellipse(pos.x, pos.y, explodeSize, explodeSize);
    }
    
    
    /**
    * Return agent description (ID, DESTINATION, PATH)
    * @return agent description
    */
    public String toString() {
        String goingTo = destination != null ? "GOING TO " + destination + " THROUGH " + path.toString() : "ARRIVED";
        return "AGENT " + ID + " " + goingTo;
    }
    
    
    /**
    * Actions to perform when agent cannot be hosted by destination.
    * By default, to look for another destination
    */
    protected void whenUnhosted() {
        destination = findDestination();
    }
    
    
    /** Actions to perform WHEN agent arrives to destination */
    protected abstract void whenArrived();
    
    /** Actions to perform WHILE agent is in destination */
    protected abstract void whenHosted();
    
    /** Draw agent in screen */
    public abstract void draw(PGraphics canvas);
    
    
}




/**
* Person -  Person is the main pedestrian agent in ABM, it walks and goes to POIs
* @author        Marc Vilella
* @version       1.0
* @see           Agent
*/
private class Person extends Agent {

    /**
    * Initiate agent with default parameters
    * @see Agent
    */
    public Person(int id, Roads map, int size, String hexColor) {
        super(id, map, size, hexColor);
    }
    
    
    /**
    * Draw Person in screen, with different effects depending on its status
    * @param canvas  Canvas to draw person
    */
    public void draw(PGraphics canvas) {
        
        // Draw aurea, path and some info if agent is selected
        if(selected) {
            path.draw(canvas, 1, COLOR);
            canvas.fill(COLOR, 130); canvas.noStroke();
            canvas.ellipse(pos.x, pos.y, 4 * SIZE, 4 * SIZE);
            //fill(0);
            //text(round(distTraveled) + "/" + round(path.getLength()), pos.x, pos.y);
        }
        
        // Draw exploding effect and line to destination if in panicMode
        if(panicMode) {
            drawPanic(canvas);
            PVector destPos = destination.getPosition();
            canvas.stroke(#FF0000, 100); canvas.strokeWeight(1);
            canvas.line(pos.x, pos.y, destPos.x, destPos.y);
            canvas.text(destination.NAME, pos.x, pos.y);
        }
        
        canvas.fill(COLOR); canvas.noStroke();
        canvas.ellipse(pos.x, pos.y, SIZE, SIZE);
    }


    /**
    * Init [waiting]timer when agent arrives to destination
    */
    protected void whenArrived() {
        timer = millis();
    }
    

    /**
    * Agent stays wandering in destination for a determined time, and then
    * looks for another destination
    */
    protected void whenHosted() {
        //wander(5);
        //if(millis() - timer > 2000) {
        //    panicMode = false;
            destination.unhost(this);    // IMPORTANT! Unhost agent from destination
            destination = findDestination();
        //}
    }

}



/**
* Vehicle -  Vehicle is the main vehicle agent in ABM, it drives and cannot go to people's POIs, but (p.e) parkings
* @author        Marc Vilella
* @version       1.0
* @see           Agent
*/
private class Vehicle extends Agent {
    float r = 6.0;
    /**
    * Initiate agent with default parameters
    * @see Agent
    */
    public Vehicle(int id, Roads map, int size, String hexColor) {
        super(id, map, size, hexColor);
        speedFactor = 3;
    }
    
    
    /**
    * Draw Vehicle in screen, with different effects depending on its status
    * @param canvas  Canvas to draw agent
    */
    public void draw(PGraphics canvas) {
        
        //// Draw aurea, path and some info if agent is selected
        //if(selected) {
        //    path.draw(canvas, 1, COLOR);
        //    canvas.fill(COLOR, 130); canvas.noStroke();
        //    canvas.ellipse(pos.x, pos.y, 4 * SIZE, 4 * SIZE);
        //    canvas.text(destination.NAME, pos.x, pos.y);
        //}
        
        //canvas.noFill(); canvas.stroke(COLOR); canvas.strokeWeight(1);
        //canvas.ellipse(pos.x, pos.y, SIZE, SIZE);
        display();
        
        
    }
    
    /**
    * draw the vehicle on the canvas
    */
    public void display(){
     canvas.pushMatrix();
     canvas.noFill();
     canvas.stroke(175);
     canvas.translate(pos.x,pos.y);
     canvas.ellipse(0,0,r,r);
     canvas.popMatrix();
    }
    
    
    /** Do nothing */
    protected void whenArrived() {}
    
    
    /** Do nothing */
    protected void whenHosted() {
      destination.unhost(this);    // IMPORTANT! Unhost agent from destination
      destination = findDestination();
    }

}

/**
* Path - Class defining the path an agent must follow to arrive to its destination. It's autocontained, and able to be updated and recalculated 
* @author        Marc Vilella
* @credits       aStar method inspired in Aaron Steed's Pathfinding class http://www.robotacid.com/PBeta/AILibrary/Pathfinder/index.html
* @version       2.0
* @see           Node, Lane
*/
public class Path {

    private final Roads ROADMAP; 
    private final Agent AGENT;
    
    private ArrayList<Lane> lanes = new ArrayList();
    private float distance = 0;
    
    // Path movement variables
    private Node inNode = null;
    private Lane currentLane;
    private PVector toVertex;
    private boolean arrived = false;
    
    
    /**
    * Initiate Path
    * @param agent  Agent using the path
    * @param roads  Roadmap used to find possible paths between its nodes
    */
    public Path(Agent agent, Roads roads) {
        ROADMAP = roads;
        AGENT = agent;
    }
    

    /**
    * Check if path is computed and available
    * @return true if path is computed, false otherwise
    */
    public boolean available() {
        return lanes.size() > 0;
    }    


    /**
    * Calculate path length
    * @return path length in pixels
    */
    private float calcLength() {
        float distance = 0;
        for(Lane lane : lanes) distance += lane.getLength();
        return distance;
    }
    
    
    /**
    * Get path length
    * @return path length
    */
    public float getLength() {
        return distance;
    }
    
    
    /**
    * Check if agent has arrived to the end of the path
    * @return true if agent has arrived, false otherwise
    */
    public boolean hasArrived() {
        return arrived;
    }
    
    
    /**
    * Return the node where the agent is placed
    * @return node where agent is placed
    */
    public Node inNode() {
        return inNode;
    }
    
    
    /**
    * Reset path paramters to initial state
    */
    public void reset() {
        lanes = new ArrayList();
        currentLane = null;
        arrived = false;
        distance = 0;
    }
    
    
    /**
    * Move agent across the path.
    * @param pos  Actual agent position
    * @param speed  Speed of agent
    * @return agent position after movement
    */
    public PVector move(PVector pos, float speed) {
        PVector dir = PVector.sub(toVertex, pos);
        PVector movement = dir.copy().normalize().mult(speed);
        if(movement.mag() < dir.mag()) return movement;
        else {
            if( currentLane.isLastVertex( toVertex ) ) goNextLane();
            else toVertex = currentLane.nextVertex(toVertex);
            return dir;
        }
    }
    
    
    /**
    * Move agent to next lane in path. Update node binding and handles lane hosting of agent. If there isn't next lane, finishes path.
    */
    public void goNextLane() {
        inNode = currentLane.getEnd();
        currentLane.removeAgent(AGENT);
        int i = lanes.indexOf(currentLane) + 1;
        if( i < lanes.size() ) {
            currentLane = lanes.get(i);
            toVertex = currentLane.getVertex(1);
            currentLane.addAgent(AGENT);
        } else arrived = true;
    }
    
    
    /**
    * Draw path
    * @param canvas  Canvas to draw path
    * @param stroke  Path stroke
    * @param c    Path color
    */
    public void draw(PGraphics canvas, int stroke, color c) {
        for(Lane lane : lanes) {
            lane.draw(canvas, stroke, c);
        }
    }
    
    
    /**
    * Find a path between two points
    * @param origin  Origin node of the path
    * @param destination  Destination node of the path
    * @return true if a path has been found, false otherwise   
    */
    public boolean findPath(Node origin, Node destination) {
        if(origin != null && destination != null) {
            lanes = aStar(origin, destination);
            if(lanes.size() > 0) {
                distance = calcLength();
                inNode = origin;
                currentLane = lanes.get(0);
                toVertex = currentLane.getVertex(1);
                arrived = false;
            }else {
             destination = AGENT.findDestination();
            }
        }
        return false;
    }
    
    
    /**
    * Perform a A* pathfinding algorithm
    * @param origin  Origin node
    * @param destination  Destination node
    * @return list of lanes that define the found path from origin to destination
    */
    private ArrayList<Lane> aStar(Node origin, Node destination) {
        ArrayList<Lane> path = new ArrayList();
        if(!origin.equals(destination)) {
            for(Node node : ROADMAP.getAll()) node.reset();
            ArrayList<Node> closed = new ArrayList();
            PriorityQueue<Node> open = new PriorityQueue();
            open.add(origin);
            while(open.size() > 0) {
                Node currNode = open.poll();
                closed.add(currNode);
                if( currNode.equals(destination) ) break;
                for(Lane lane : currNode.outboundLanes()) {
                    Node neighbor = lane.getEnd();
                    if(  closed.contains(neighbor) || !lane.allows(AGENT)) continue;
                    boolean neighborOpen = open.contains(neighbor);
                    float costToNeighbor = currNode.getG() + lane.getLength();
                    if( costToNeighbor < neighbor.getG() || !neighborOpen ) {
                        neighbor.setParent(currNode); 
                        neighbor.setG(costToNeighbor);
                        neighbor.setF(destination);
                        if(!neighborOpen) open.add(neighbor);
                    }
                }
            }
            path = tracePath(destination);
        }
        return path;
    }
    
    
    /**
    * Look back all path to a node
    * @param destination  Destination node
    * @return list of lanes that define a path to destination node
    */
    private ArrayList<Lane> tracePath(Node destination) {
        ArrayList<Lane> path = new ArrayList();
        Node pathNode = destination;
        while(pathNode.getParent() != null) {
            path.add( pathNode.getParent().shortestLaneTo(pathNode) );
            pathNode = pathNode.getParent();
        }
        Collections.reverse(path);
        return path;
    }
    
    
    /**
    * Return the list of lanes that form the path
    * @return path description
    */
    @Override
    public String toString() {
        String str = lanes.size() + " LANES: ";
        for(Lane lane : lanes) {
            str += lane.toString() + ", ";
        }
        return str;
    }
    
}