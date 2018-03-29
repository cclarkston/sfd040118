public with sharing class site_login {
  public String uname {get; set;}
  public String pword {get; set;}
  
  public site_login() {
  	
  }
  
  public PageReference attempt_login() {
  	return Site.login(uname,pword,null);
  }
    
}