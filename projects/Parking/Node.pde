/**
* Node - Class to manage nodes
* @author        Marc Vilella
* @version       2.0
*/

import java.util.Collections;
import java.util.*;

private class Node implements Placeable, Comparable<Node>{
  public int id;
  public final PVector POSITION;
  protected boolean selected;
  protected ArrayList<Lane> lanes = new ArrayList();
  private String direction = null;
  public String typeRoad;
  public String access;
  private Node parent;
  private float f;
  private float g;
    
   /**
   * Asign a variable position to a node
   */
  public Node(PVector position){
    id = -1;
    this.POSITION = position;
  }
  
   /**
   * set ID
   */
    public void setID(int id) {
        this.id = id;
    }
    
    /**
   * get ID
   */
    public int getID() {
        return id;
    }
    
  /**
   *Add roads to an array in order to draw it later
   */
  public void place(Roads roads) {
        roads.add(this);
  }
  
  /**
  * select node (not use)
  */
  public boolean select(int mouseX, int mouseY) {
     selected = dist(POSITION.x, POSITION.y, mouseX, mouseY) < 2;
     return selected;
  }
  
 /**
 *Return node's position
 */
  public PVector getPosition() {
    return POSITION.copy();
  }
  
  public void draw(PGraphics canvas, int stroke, color c) {
         for(Lane lane : lanes) {
           lane.draw(canvas, stroke, c);
         }
  }
  
   public void draw(PGraphics canvas) {
        canvas.fill(#000000); 
        canvas.ellipse(POSITION.x, POSITION.y, 3, 3);
        draw(canvas, 1, #F0F3F5);
   }
   
   
   public Lane shortestLaneTo(Node node) {
        Float shortestLaneLength = Float.NaN;
        Lane shortestLane = null;
        for(Lane lane : lanes) {
            if(node.equals(lane.getEnd())) {
                if(shortestLaneLength.isNaN() || lane.getLength() < shortestLaneLength) {
                    shortestLaneLength = lane.getLength();
                    shortestLane = lane;
                }
            }
        }
        return shortestLane;
    }
   
   
   /**
   * Create a new lane conecting the actual node, the given and with an arrayList of vertices
   */
   protected void connect(Node node, ArrayList<PVector> vertices, String name, String access) {
     this.access = access;
     lanes.add( new Lane(name, access, this, node, vertices) );
   }
   
   /**
   * Create a new lane conecting the actual node, the given and with an arrayList of vertices
   * Create other lane in case the road has two ways
   */
   protected void connectBoth(Node node, ArrayList<PVector> vertices, String name, String access) {
        this.access = access;
        connect(node, vertices, name, access);
        if(vertices != null) Collections.reverse(vertices); 
        node.connect(this, vertices, name, access);
        
    }
    
    /**
   * Allow just some type of roads
   */
    public boolean allows(Agent agent) {
        for(Lane lane : lanes) {
            if(lane.allows(agent)) return true;
        }
        return false;
    }
    
    /**
   * Create a new lane conecting the actual node, the given and with an arrayList of vertices
   * Create other lane in case the road has two ways
   */
    protected void setDirection(String direction) {
        this.direction = direction;
    }
    
    public ArrayList<Lane> outboundLanes() {
        return lanes;
    }
    
    public void setParent(Node parent) {
        this.parent = parent;
    }
    
    public Node getParent() {
        return parent;
    }
    
    public void setG(float g) {
        this.g = g;
    }
    
    public float getG() {
        return g;
    }
    
    public void setF(Node nextNode) {
        float h =  POSITION.dist(nextNode.getPosition());
        f = g + h;
    }
    
    public float getF() {
        return f;
    }
    
    public void reset() {
        parent = null;
        f = g = 0.0;
    }
    
    
    /**
    * To let the PriorityQueue works to compare differents nodes
    */
    public int compareTo(Node node) {
        return f < node.getF() ? -1 : f == node.getF() ? 0 : 1;
    }

}