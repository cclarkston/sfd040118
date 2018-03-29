public class OasisOpenOrgWssSecuritySecext { // SecurityUtil

  // Security Class
  public class Security {
    // Constructor for Security used to pass in username and password parameters and instantiate the UsernameToken object
    public Security(String username, String password) {
        this.UsernameToken = new OasisOpenOrgWssSecuritySecext.UsernameToken(username, password);
    }

    public OasisOpenOrgWssSecuritySecext.UsernameToken UsernameToken;
    public String envNamespace = '1';
    private String[] envNamespace_att_info = new String[]{'env:mustUnderstand'};
    public String wsuNamespace = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd';
    private String[] wsuNamespace_att_info = new String[]{'xmlns:wsu'};
    public String wsseNamespace = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
    private String[] wsseNamespace_att_info = new String[]{'xmlns:wsse'};
    private String[] UsernameToken_type_info = new String[]{'UsernameToken','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','UsernameToken','1','1','false'};
    private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
    private String[] field_order_type_info = new String[]{'UsernameToken'};
 }

  // UserToken Class
  public class UsernameToken {
      // Constructor for UsernameToken used to pass in username and password parameters
      public UsernameToken(String username, String password) {
          this.Username = username;
          this.Password = password;
          this.Nonce = generateNounce();
          this.Created = generateTimestamp();
      }

      public String Username;
      public String Password;
      public String Nonce;
      public String Created;
      private String[] Username_type_info = new String[]{'Username','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','string','0','1','false'};
      private String[] Password_type_info = new String[]{'Password','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText','string','0','1','false'};
      private String[] Nonce_type_info = new String[]{'Nonce','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary','string','0','1','false'};
      private String[] Created_type_info = new String[]{'wsu:Created','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','string','0','1','false'};
      public String IdNamespace = 'UsernameToken-648AC0BF70B2958130149876448244239';
      private String[] IdNamespace_att_info = new String[]{'wsu:Id'};
      private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
      private String[] field_order_type_info = new String[]{'Username','Password','Nonce','Created'};

      // Generate Nounce, random number base64 encoded
      public String generateNounce() {
          Integer length = 24;
          Long randomLong = Crypto.getRandomLong();
          String key = EncodingUtil.base64Encode(Blob.valueOf(String.valueOf(randomLong)));
          return key.substring(0, length);      }

      // Generate timestamp in GMT
      public String generateTimestamp() {
          return Datetime.now().formatGmt('yyyy-MM-dd\'T\'hh:mm:ss:SSS\'Z\'');
      }
  }
}