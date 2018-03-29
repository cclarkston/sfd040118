/*
modified by cm on 2012-3-2
Updating this to handle some changes to the opptyAfter trigger.  Also added some lines to get the old
code in the trigger to 100% coverage.
*/
@isTest
private class TestOpptyTrigger {
	testmethod static void test() {
		Account account = new Account();
		account = [select id, PersonContactId FROM Account limit 1];
		Campaign camp = new Campaign(); 
		camp.name = 'test'; 
		insert camp; 
		CampaignMember cmb = new CampaignMember(); 
		cmb.CampaignId  = camp.id;
		cmb.ContactId = account.PersonContactId; 
		insert cmb; 
		
		Opportunity oppty = new Opportunity(); 
		oppty.AccountId = account.id; 
		oppty.Name = 'tyest';
		oppty.Preliminary_Treatment_Plan__c = 'AO4 Upper'; 
		oppty.CloseDate = System.today();
		oppty.StageName = 'Scheduled';
		insert oppty;		
		oppty.StageName = 'Cancelled Not Rescheduled';
		update oppty;
		oppty.StageName = 'Scheduled';
		update oppty;
		oppty.Completed_Stage__c = 'Not Moving Forward';
		update oppty;
	}
}