/**********************************************************************************
Name    : Test_SyncCallCtrFields
Usage   : For the Lead object, this Trigger Updates the Call_Center_Agent_Owner__c based on the Call_Center_Agent__r.Name
                                                    and Center_Location__c from Lead.Center__r.Name.

CHANGE HISTORY
===============================================================================
DATE            NAME             		DESC
2011-03-07		Mike Merino        		Initial release
2011-09-09		Seth Davidow			Update to remove Id dependencies
2012-07-16		Chad Serpan				Update to check for duplicate

*************************************************************************************/
@isTest
private class Test_SyncCallCtrFields {
    testMethod static void testIt() {

        Lead l1 = new Lead();
        Lead l2 = new Lead();
        Lead l3 = [Select l.Id, l.External_ID__c, l.FirstName, l.LastName, l.Contact_Agency__c, l.Email, l.Phone, l.Status, l.Center_Location__c From Lead l WHERE l.LastName = 'InfoCision' limit 1];
        id usgId = userinfo.getUserId();
		Center_Information__c center = [select id from Center_Information__c limit 1];

        // user setup due to
        //    lead validation rule: Validate_that_Call_Center_Agent_Current
        //    lead custom field Call Center Agent (Lookup);validation rule: Validate_that_Call_Center_Agent_Current
		for (user u:[select u.firstname, u.lastname, u.Phone, u.id from User u where u.id = :usgId limit 1])
		{
			// Test for Insert
	        String Lname = u.LastName;
	        String Fname = u.firstname;
	        String Phone = u.Phone;
	        String ExternalID = 'CLCH00101654';
	  		// system.debug('### '+usgId+'--'+lname);
	        l1.lastName = Lname;
	        l1.firstName = Fname;
	        l1.Phone = Phone;
	    	// system.debug('### '+l1);
	        l1.company=null;
	        l1.status ='Not Scheduled';
	        l1.Call_Center_Agent__c = u.Id; //call_ctr_agent must = usgId
	        l1.center__c = center.id; //'a0S40000002P7MnEAK'; //  atlanta
	        l1.External_ID__c = ExternalID;
	        insert l1;
	        system.debug('### Test_SyncCallCtrFields '+l1);

	        // Test for Duplicate
	  		// system.debug('### '+usgId+'--'+lname);
	        l2.lastName = 'InfoCision';
	        l2.firstName = 'Test';
	        l2.Phone = '(303) 123-4567';
	    	// system.debug('### '+l1);
	        l2.company=null;
	        l2.status ='Not Scheduled';
	        l2.Call_Center_Agent__c = u.Id; //call_ctr_agent must = usgId
	        l2.center__c = center.id; //'a0S40000002P7MnEAK'; //  atlanta
	        l2.External_ID__c = ExternalID;
	        l2.Contact_Agency__c = 'Infocision';
	        insert l2;
	        system.debug('### Test_SyncCallCtrFields '+l2);

			Center_Information__c A = [SELECT c.Id FROM Center_Information__c c ORDER BY CreatedDate DESC LIMIT 1];
			User B = [SELECT u.Id FROM User u ORDER BY CreatedDate DESC LIMIT 1];
			l3.Center__c = A.Id;
			l3.Call_Center_Agent__c = B.Id;
			l3.status ='Seminar Scheduled';
			update l3;
	        system.debug('### Test_SyncCallCtrFields '+l3);

			// now test WelcomePkgSent trigger, whoId must be Lead.id
			// set email flag in lead
            ID rtype = [Select ID From RecordType Where sObjectType = 'Task' and Name = 'Standard'].id;
			List<task> t = new List<task>{
				new task(
			        WhoId = l1.Id,
			       // WhatID = l1.id,
                    RecordTypeID = rtype,
			        Subject='this is Email: myTest',
			        Status='New',
			        Priority='Normal')};

	        insert t;
	        system.debug('### Test_SyncCallCtrFields Task t='+t);

	        List<task> taskstoupdate = New List<task>{ [select id from task where id in :t]};
            for(task tOK:taskstoupdate){
            	tOK.status = 'Completed';
            	Update taskstoupdate;
            }
			// set welcome flag in lead
	        List<task> t1 = new List<task>{ new task(
	        WhoId = l1.Id,
			// WhatID = l1.id,
            RecordTypeID = rtype,
	        Subject='You are Welcome',
	        Status='New',
	        Priority='Normal')};

	        insert t1;
	        system.debug('### Task Test_SyncCallCtrFields t1='+t1);

	        List<task> taskstoupdate1 = New List<task>{ [select id from task where id in :t1]};
            for(task tOK:taskstoupdate){
                 tOK.status = 'Active';
                 Update taskstoupdate1;
            }
	       //  flags already set in lead
	        List<task> taskstoupdate2 = New List<task>{ [select id from task where id in :t1]};
            for(task tOK:taskstoupdate){
            	tOK.Priority = 'Completed';
                Update taskstoupdate2;
            }
		}
	}
}