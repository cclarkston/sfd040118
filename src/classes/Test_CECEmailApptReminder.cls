/*
6/1/16
Alon Waisman
Classes:
  CECEmailApptReminder - 92%
*/

@isTest
private class Test_CECEmailApptReminder {
	private static Center_Information__c center = new_center();

	@isTest static void test_it_generates_the_correct_emails_from_a_list_of_Consult_Inventories() {
		Account test_account = new_account('testaccount@domain.com');
		Private_Practice_Patient__c test_patient = new_patient('testpatient@domain.com');
		Consult_Inventory__c[] appointments = new_appointments(test_account, test_patient);
		Test.startTest();
			Messaging.SingleEmailMessage[] emails = CECEmailApptReminder.emails(appointments);
			for (Messaging.SingleEmailMessage email : emails) {
				system.assert(!String.isBlank(email.subject));
				system.assert(!String.isBlank(email.PlainTextBody));
				system.assert(!String.isBlank(email.HTMLBody));
				system.assert('testaccount@domain.com' == email.toAddresses[0] || 'testpatient@domain.com' == email.toAddresses[0]);
			}
		Test.stopTest();
	}

			private static Center_Information__c new_center() {
				insert new Center_Information__c(Name = 'Test Center', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233);
				return [SELECT ID FROM Center_Information__c WHERE Name = 'Test Center'];
			}

			private static Account new_account(String email) {
				RecordType person_account_record_type = [SELECT ID FROM RecordType WHERE Name = 'Prospective Patients' and SObjectType = 'Account'];
				insert new Account(PersonEmail = email, RecordTypeID = person_account_record_type.id, LastName = 'User');
				return [SELECT ID FROM Account WHERE PersonEmail = 'testaccount@domain.com' LIMIT 1];
			}

			private static Private_Practice_Patient__c new_patient(String email) {
				insert new Private_Practice_Patient__c(Patient_Email__c = email, Center__c = center.id);
				return [Select ID FROM Private_Practice_Patient__c WHERE Patient_Email__c = 'testpatient@domain.com'];
			}

			private static Consult_Inventory__c[] new_appointments(Account test_account, Private_Practice_Patient__c test_patient) {
				insert new Consult_Rooms__c(Center_Information__c = center.id);
				Consult_Rooms__c room = [SELECT ID FROM Consult_Rooms__c LIMIT 1];
				insert new Consult_Inventory__c[]{
						new Consult_Inventory__c(Scheduled_Account__c = test_account.id,
							Consult_Room__c = room.id, Apt_Date__c = Date.today(), Start_Hour__c = '12', Start_Minute__c = '0', End_Hour__c = '13', End_Minute__c = '0'),
						new Consult_Inventory__c(Scheduled_Patient__c = test_patient.id,
							Consult_Room__c = room.id, Apt_Date__c = Date.today(), Start_Hour__c = '12', Start_Minute__c = '0', End_Hour__c = '13', End_Minute__c = '0')};
				return [SELECT ID FROM Consult_Inventory__c];
			}
}