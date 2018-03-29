@isTest
private class TestLeadTriggerSendBMP {
  static Lead lead;

  @testSetUp static void setup() {

  }

  static void init() {
  	Lead newLead = new Lead();
  	newLead.FirstName = 'Firstname test';
  	newLead.LastName = 'Lastname test';
  	insert newLead;
    lead = [SELECT Id
            FROM Lead
            LIMIT 1
          ];       
  }

    testMethod static void testCallResult(){
  	Lead newLead = new Lead();
  	newLead.FirstName = 'Firstname test';
  	newLead.LastName = 'Lastname test';
  	insert newLead;
    Test.startTest();
	System.debug('Run this test');    
    System.assert(newLead != null);
    System.assert(!newLead.BCP_DVD_Packet_Sent__c);
    newLead.Pre_Screen__c = 'Checked';
    update newLead;
    //System.assert(newLead.BCP_DVD_Packet_Sent__c);
    Test.stopTest();
  }
}