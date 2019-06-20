/**
* Geometry - find if point is insite the lane
* @author        Marc Vilella
* @version       2.0
*/


public static class Geometry{

   /**
    * Check if a point is contained in a line
    */
    public static boolean inLine(PVector point, PVector l1, PVector l2) {
        final float EPSILON = 0.001f;
        PVector l1p = PVector.sub(point, l1);
        PVector line = PVector.sub(l2, l1);
        return PVector.angleBetween(l1p, line) <= EPSILON && l1p.mag() < line.mag();
    }
   
   /**
    * find the perpendicular projection of the point over a line (find closest line, connect)
    */
    public static PVector scalarProjection(PVector point, PVector l1, PVector l2) {
        PVector l1p = PVector.sub(point, l1);
        PVector line = PVector.sub(l2, l1);
        float lineLength = line.mag();
        line.normalize();
        float dotProd = l1p.dot(line);
        line.mult( dotProd );
        return line.mag() > lineLength ? l2 : dotProd < 0 ? l1 : PVector.add(l1, line);
    }
   
}