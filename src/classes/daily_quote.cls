public with sharing class daily_quote {
  public Daily_Quote__c daily_quote {get; set;}
  
  public daily_quote() {
                    
  }     
        
  public void select_quote() {
    //check to see if a daily quote was assigned today already
        Integer cnt = [select count() from Daily_Quote__c where display_date__c = today];
        if(cnt>0) {
                //we have a quote of the day - grab it
                daily_quote = [select quote_from__c,quote_text__c from daily_quote__c where display_date__c = today];
        }
        else {
          //if not,  see if we have any unassigned quotes
          cnt = [select count() from Daily_Quote__c where display_date__c = null];
          if(cnt==0) {
            //if all quotes have been assigned,  reset the table
            List<Daily_Quote__c> dq_update_list = [select id,display_date__c from Daily_Quote__c where display_date__c != null];
            for(Daily_Quote__c dq : dq_update_list) {
                dq.display_date__c = null;
            }  
            try {
              update dq_update_list;
            }
            catch (Exception e) {
                
            }
          }
          daily_quote = [select id,quote_from__c,quote_text__c,display_date__c from daily_quote__c where display_date__c = null];
          daily_quote.display_date__c = System.today();
          try {
                update daily_quote;
          }
          catch (Exception e) {
                
          }
        }               
  }
        
}