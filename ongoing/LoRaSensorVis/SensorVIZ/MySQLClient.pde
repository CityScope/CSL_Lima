import de.bezier.data.sql.*;
import controlP5.*;


/**
 * MySQLClient - Extends Observable. Establishes a remote connection to a MySQL database to query it
 * @author    Jesús García
 * @version   0.1
 */
public class MySQLClient extends Observable {
  MySQL client;
  boolean connected;
  ControlP5 cp5;
  String from, to;


  /**
   * Creates a MySQLClient object
   * @param parent      Sketch's PApplet
   * @param host        IP where the database is located
   * @param database    Database to connect to
   * @param user        Registered username in the MySQL environment
   * @param pswd        Registered password in the MySQL environment
   */
  public MySQLClient(PApplet parent, String host, String database, String user, String pswd) {
    client = new MySQL(parent, host, database, user, pswd);
    cp5 = new ControlP5(parent);
    connected = client.connect();
  }


  /**
   * Shows the text boxes to customize the queries by timestamp (YYYY-MM-DD HH:MM:ss)
   * @param font  PFont to be used when writing
   */
  public void createTextBoxes(PFont font) {
    cp5.addTextfield("FROM")
      .setPosition(20, 100)
      .setSize(200, 40)
      .setFont(font)
      .setAutoClear(false)
      ;

    cp5.addTextfield("TO")
      .setPosition(20, 170)
      .setSize(200, 40)
      .setFont(font)
      .setAutoClear(false)
      ;
  }


  /**
   * Queries the database using the text written in the boxes. Deletes the written texts
   * Sends the result of the query to its Observers
   */
  public void query() {
    from = cp5.get(Textfield.class, "FROM").getText();
    to = cp5.get(Textfield.class, "TO").getText();
    if (from != null && to != null && connected) {
      client.query("SELECT * FROM clientData WHERE timestamp BETWEEN '" + from + "' AND '" + to + "'");
      setChanged();
      notifyObservers(client);
    }
    cp5.get(Textfield.class, "FROM").clear();
    cp5.get(Textfield.class, "TO").clear();
  }
}
