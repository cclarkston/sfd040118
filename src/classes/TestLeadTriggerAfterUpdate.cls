@isTest
private class TestLeadTriggerAfterUpdate {
	static Lead lead;
	@testSetup static void setup() {
		//Create lead for testing 
		lead = new Lead();
		lead.lastName = 'Smith';
		lead.firstName = 'James';	
		lead.Call_Center_Agent__c = UserInfo.getUserId();	
		insert lead;
	}

  	static void init() {	
  		lead = [SELECT Id, lead.BCP_DVD_Packet_Sent__c
            FROM Lead
            LIMIT 1
          ];
  	}

  	private static Integer ReturnAwaitingBulkPrintCount() {
  		return database.countQuery('select count() from Awaiting_Bulk_Print__c');
  	}

  	testMethod static void TestSendBCPIsSet() {
    	init();
    	lead.Pre_Screen__c = 'Green';
    	update lead;
  		lead = [SELECT Id, BCP_DVD_Packet_Sent__c
            FROM Lead
            LIMIT 1
          ];    	
    	System.Assert(lead.BCP_DVD_Packet_Sent__c == true);    	
    }  	

  	testMethod static void TestAwaitingBulkPrintIsCreated(){
    	init();
    	lead.Pre_Screen__c = 'Green';
    	update lead;
    	System.Assert(ReturnAwaitingBulkPrintCount() == 1);    	
    }  	

   	testMethod static void TestAwaitingBulkPrintHasLeadId(){
    	init();
    	lead.Pre_Screen__c = 'Green';
    	update lead;
  		lead = [SELECT Id
            FROM Lead
            LIMIT 1
          ];   
    	Awaiting_Bulk_Print__c awaitingBulkPrint = [SELECT Lead_Id__c
            FROM Awaiting_Bulk_Print__c
            LIMIT 1
          ];    
    	System.Assert(lead.id == awaitingBulkPrint.Lead_Id__c);    	
    }  	   
}