/**
* Roads - Class to manage the roadmap of simulation
* @author        Vanesa Alcantara
* @version       2.0
*/
public class TimePark{
  ArrayList<TimeP> parks;
  ArrayList<DateTime> chronometer;
  IntDict maxMin = new IntDict();
  int totalTime;
  DateTime minDate = null;
  DateTime maxDate = null;
  Period differenceInTime;
  private POIs pois;
  
  /**
  * Recognize if the file exist
  */
  public TimePark(String path, POIs pois){
    this.pois = pois;
    chronometer = new ArrayList();
    if(path!= null) loadCSV(path);
    else println("There is not file");
    chronometer = Chronometer();
  }

  
  /**
  * Load CSV file
  */
  public void loadCSV(String path){
    DateTime parkingTime;
     print("Loading time...");
     
     parks = new ArrayList();   
     Table table = loadTable(path,"header");
     for(TableRow row:table.rows()){
       int movType = row.getInt("Movement Type");
       int passages = row.getInt("Passages");
       if( passages != 0){
         int carParkNumber = row.getInt("Car Park Number");
         int deviceNum = row.getInt("Device Number");
         for(POI poi:pois.getAll()){
           if(poi.access.equals("publicPark")){
             for(int i=0; i < poi.DEVICENUM.size();i++){
                if( (deviceNum == poi.DEVICENUM.get(i)) && ( poi.PARKNUMBER == carParkNumber) ){
                   String timestamp = row.getString("DateTime");
                   parkingTime = fmtPark.parseDateTime(timestamp);
                   
                    if( parkingTime.isAfter(maxDate) || maxDate == null){
                        maxDate = parkingTime;
                    }
                    
                    if(parkingTime.isBefore(minDate) || minDate == null ){
                        minDate = parkingTime;
                    }

                   parks.add(new TimeP(carParkNumber,deviceNum,movType, parkingTime, passages));         
                 }
             }   
           } 
         }
       }
    }
     print("LOADED");
  }
  
  /**
  * Create an array with all the dates in the range
  */
  public ArrayList<DateTime> Chronometer(){
    ArrayList<DateTime> chronometer = new ArrayList();
    DateTime actualDate = minDate;
    while(actualDate.isBefore(maxDate) || actualDate.isEqual(maxDate)){
       chronometer.add(actualDate);
       actualDate =  actualDate.plusMinutes(15);
    }
     return chronometer;
  }
  
  public DateTime getMinDate(){
   return minDate; 
  }
  
 /**
 * compare hours in a day begining by the date given 
 */
  public ArrayList<ArrayList> dinamicHours(int indexResume, DateTime dateToCompare){
    ArrayList<ArrayList> dinamicHours = new ArrayList();
    ArrayList<PVector> dinamicHoursValue = new ArrayList();
    
    for(int k=0; k<pois.count();k++){
      ArrayList a = new ArrayList();
      a.add(" ");
      a.add(" ");
      dinamicHours.add(a);
      dinamicHoursValue.add(new PVector(-Integer.MAX_VALUE,Integer.MAX_VALUE));
    }
    
    for(int i=indexResume; i<indexResume+96; i++){
        String dayToCompare = dateToCompare.toString("HH:mm");
        int x=0;
         for(POI poi:pois.getAll()){
           if(poi.access.equals("publicPark")){
             float compare1 = float((int) poi.getCrowd(dateToCompare));
             float maximo = max((float) dinamicHoursValue.get(x).x, compare1);
             float minimo = min((float) dinamicHoursValue.get(x).y, compare1);
             dinamicHoursValue.set(x, new PVector(maximo,minimo));
             ArrayList b = (ArrayList) dinamicHours.get(x);
             if(dinamicHoursValue.get(x).x == compare1) b.set(0,dayToCompare);
             if(dinamicHoursValue.get(x).y == compare1) b.set(1,dayToCompare);
             dinamicHours.set(x,b);
             x++;
           }
         }
        dateToCompare = dateToCompare.plusMinutes(15); 
      }

    return dinamicHours;
  }
  
  /**
 * find the max and min hour in promedio in the month
 */
  public ArrayList<PVector> maxMinHour(){
   print("\nLoading max and min per hour...");
   ArrayList<PVector> MaxMin = new ArrayList(pois.count());
   ArrayList<PVector> MaxMinValor = new ArrayList(pois.count());
   for(int k=0; k<pois.count();k++){
      MaxMin.add(k,new PVector(1,-1));
      MaxMinValor.add(k,new PVector(-Integer.MAX_VALUE,Integer.MAX_VALUE)); 
   }
   for( int i = 0; i <24; i++){
         FloatList parkingPerHour = new FloatList(); 
         int x=0;
         for( POI poi:pois.getAll()){
           if(poi.access.equals("publicPark")){
              parkingPerHour.set(x,0);
              x++;
           }
         } 
         for(int c=0; c <chronometer.size(); c++){
           int dayToCompare = minDate.dayOfMonth().get();
           if( dayToCompare == i){
             int j=0;
             for(POI poi:pois.getAll()){ 
               if(poi.access.equals("publicPark")){
                 parkingPerHour.set(j,parkingPerHour.get(j)+(int)poi.getCrowd(minDate));                                 
                  j++;               
               }
             }
           } 
         } 
         for(int k = 0; k < pois.count();k++){
           float maximo = max(MaxMinValor.get(k).x,parkingPerHour.get(k));
           float minimo = min(MaxMinValor.get(k).y,parkingPerHour.get(k));
           MaxMinValor.set(k,new PVector( maximo, minimo));
           if(MaxMinValor.get(k).x == parkingPerHour.get(k)) MaxMin.get(k).x = i;
           if(MaxMinValor.get(k).y == parkingPerHour.get(k)) MaxMin.get(k).y = i;
         }         
   }
   return MaxMin;
 }
 
  /**
 * make arrays statistics of day media occupancy every days for 7 days and compare everyday statistics to find the max day
 */
 public ArrayList<String> dinamicDay(int indexResume, DateTime dateToCompare){
   ArrayList<Float> total = new ArrayList();
   ArrayList<String> maxDay = new ArrayList();
   String[] nameDay = {"SAT", "SUN", "MON", "TUE", "WED", "THR", "FRI"};
   for(int k=0; k<pois.count();k++){
     total.add(k,-Float.MAX_VALUE);
     maxDay.add(k,null);
   }
   int x=0;
   for(int i = indexResume; i<indexResume+672; i=i+96){
     FloatList parkingPerDay = new FloatList();
     for(int c=0; c<pois.count();c++){
       parkingPerDay.set(c,0);
     }
     print("\n",i);
     for(int j=i; j<i+96;j++){
      if(j<totalTime){
        int k=0;
          for(POI poi:pois.getAll()){
            if(poi.access.equals("publicPark")){
              parkingPerDay.set(k,parkingPerDay.get(k)+(int)poi.getCrowd(dateToCompare));
              k++;
            }
          } 
       }
       dateToCompare = dateToCompare.plusMinutes(15); 
     }

     int c=0;
     for(POI poi:pois.getAll()){
       if(poi.access.equals("publicPark")){
         float maximo = max(total.get(c),parkingPerDay.get(c));
         total.set(c,maximo);
         if(total.get(c) == parkingPerDay.get(c)) maxDay.set(c, nameDay[x]);         
         c++;
       }
     }
     x++;
   }
   return maxDay;  
 } 
 

  /**
  * total time in seconds that contain the file
  */
  public int getmax(){
    Minutes minBetween = Minutes.minutesBetween(minDate, maxDate);
    totalTime = minBetween.getMinutes() / 15;
    return totalTime;
  }

}

public class TimeP{
  protected final int DEVICENUM;
  protected final int MOVTYPE;
  protected final DateTime TIME;
  protected final int PASSAGES;
  protected final int CARPARKNUMBER;


  public TimeP(int carParkNumber,int deviceNum,int movType,DateTime time, int passages){
    DEVICENUM = deviceNum;
    MOVTYPE = movType;
    TIME = time;
    PASSAGES = passages;
    CARPARKNUMBER = carParkNumber;
  } 
}