/*  Most of this code came from http://peregrinusforce.com/2011/08/24/guid-generator-in-salesforce/
*  I've tweaked it slightly to allow for the formatting preference I wanted
*  CM - 2014/1/17
*
*/

global class guidGenerator {

    private static String fillerChars = '0123456789ABCEFGHIJK';
    private static String prefixChars = 'ABCEFGHJKMNPQRSTUWXYZ';
    private static String checkinChars = '0123456789ABCEFGHJKMNPQRSTUWXYZ';

    global static String generate_checkin_code() {
      String return_val = '';
      Integer nextByte = 0;
      Double rand_num = 0;
      for(Integer i = 0; i<6;i++) {
      	rand_num = Math.round((Math.random() * 30));
      	nextByte = rand_num.intValue();
      	return_val += charAt(checkinChars,nextByte);
      }
      return return_val;
    }

    global static String generateCheckCode() {
      Boolean wid_unique = false;
      String wid = '';
      //keep looping through,  until we get a unique WID
      Integer pass = 0;
      while(!wid_unique) {
      	wid = generate_checkin_code();
      	//check to see if the number generated is assigned to a lead already
        Integer cnt = [select count() from Consult_Inventory__c where check_in_code__c = :wid];
        //putting the pass opt out for now to keep this from exhausting the max queries
        //Once I'm comfortable with this working properly,  it needs to be pulled out.
        if(cnt==0 || pass==5)
          wid_unique = true;
        else {
        	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		      mail.setToAddresses(toAddresses);
		      mail.setReplyTo('cmcdowell@clearchoice.com');
		      mail.setSenderDisplayName('Apex error message');
		      mail.setSubject('Check In Code Generation - # not Unique');
		      mail.setPlainTextBody('A number generated by the GUID was not unique.  Check In Code ID : ' + wid);
		      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        pass++;
      }
      return wid;
    }

    WebService static void generateSignInCode(String opp_ID) {
      Boolean wid_unique = false;
      String wid = '';
      //keep looping through,  until we get a unique WID
      Integer pass = 0;
      while(!wid_unique) {
      	wid = generate_checkin_code();
      	//check to see if the number generated is assigned to a lead already
        Integer cnt = [select count() from Opportunity where short_code__c = :wid];
        //putting the pass opt out for now to keep this from exhausting the max queries
        //Once I'm comfortable with this working properly,  it needs to be pulled out.
        if(cnt==0 || pass==10)
          wid_unique = true;
        else {
        	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		      mail.setToAddresses(toAddresses);
		      mail.setReplyTo('cmcdowell@clearchoice.com');
		      mail.setSenderDisplayName('Apex error message');
		      mail.setSubject('Check In Code Generation - # not Unique');
		      mail.setPlainTextBody('A number generated by the GUID was not unique.  Check In Code ID : ' + wid);
		      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        pass++;
      }
      try {
      	Opportunity o = [select short_code__c from Opportunity where id = :opp_id];
      	o.short_code__c = wid;
      	update o;
      }  catch (Exception e) {
      		Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		      mail.setToAddresses(toAddresses);
		      mail.setReplyTo('cmcdowell@clearchoice.com');
		      mail.setSenderDisplayName('Apex error message');
		      mail.setSubject('Check In Code Generation - Opp Update');
		      mail.setPlainTextBody('Unable to assign wid to Opportunity.  Check In Code ID : ' + wid + ' Opportunity Id : ' + opp_id);
		      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
      }
    }
    
    global static String generateGUID(){

        String returnValue = '';
        Integer nextByte = 0;
        Double rand_num = 0;
        for(Integer i = 0; i < 8; i++){
            if(i==4 || i==8){
                returnValue += '-';
            }

            //nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if(i==0 || i==4 || i==8) {
            	rand_num = Math.round((Math.random() * 20));
              nextByte = rand_num.intValue();
              returnValue += charAt(prefixChars,nextByte);
            }
            else {
            	rand_num = Math.round((Math.random() * 19));
              nextByte = rand_num.intValue();
              returnValue += charAt(fillerChars,nextByte);
            }
        }
        return returnValue;
    }

    public static String charAt(String str, Integer index){
        if(str == null) {
            return null;
        }
        if(str.length() <= 0){
            return str;
        }
        if(index == str.length()){
            return null;
        }
        return str.substring(index, index+1);
    }

    global static String generateWID() {
      Boolean wid_unique = false;
      String wid = '';
      //keep looping through,  until we get a unique WID
      Integer pass = 0;
      while(!wid_unique) {
      	wid = generateGuid();
      	//check to see if the number generated is assigned to a lead already
        Integer cnt = [select count() from Lead where warranty_id__c = :wid];
        //putting the pass opt out for now to keep this from exhausting the max queries
        //Once I'm comfortable with this working properly,  it needs to be pulled out.
        if(cnt==0 || pass==5)
          wid_unique = true;
        else {
        	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		      mail.setToAddresses(toAddresses);
		      mail.setReplyTo('cmcdowell@clearchoice.com');
		      mail.setSenderDisplayName('Apex error message');
		      mail.setSubject('WID Generation - # not Unique');
		      mail.setPlainTextBody('A number generated by the GUID was not unique.  Warranty ID : ' + wid);
		      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        pass++;
      }
      return wid;
    }
}