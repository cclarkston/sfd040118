public class ParseCurrentPhysicians {

    public String name;
    public String phone;
    public String specialty;


    public static List<ParseCurrentPhysicians> parse(String json) {
      return (List<ParseCurrentPhysicians>) System.JSON.deserialize(json, List<ParseCurrentPhysicians>.class);
    }
}