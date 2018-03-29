public class CECEmailApptReminder {
	private static String org_sender_name = 'Esthetics Sender Test';
	private static String subject = 'ClearChoice Esthetics Appointment Reminder';
	private static String plain_text_body = 'text plain text email';
	private static String html_body = '<h1>test email body text</h1>';

	@InvocableMethod(label='CEC Email Reminder' description='Sends email to patients reminding them of an upcoming appointment.')
    public static void send_email_reminder(Consult_Inventory__c[] appointments) {
		Messaging.SingleEmailMessage[] emails = emails(appointments);
		Messaging.sendEmail(emails);
    }

	public static Messaging.SingleEmailMessage[] emails(Consult_Inventory__c[] appointments) {
		Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[]{};
		ID esthetics_org_ID = [SELECT ID FROM OrgWideEmailAddress WHERE DisplayName = :org_sender_name].id;
		Map<ID, Consult_Inventory__c> appointment_map = appointment_map(appointments);
		for (Consult_Inventory__c appointment : appointments) {
			String recipient_address = recipient_address(appointment_map.get(appointment.id));
			if (!String.isBlank(recipient_address)) {emails.add(email(esthetics_org_ID, recipient_address));}
		}
		return emails;
	}

			private static Map<ID, Consult_Inventory__c> appointment_map(Consult_Inventory__c[] appointments) {
				ID[] appointment_IDs = appointment_IDs(appointments);
				appointments = [SELECT ID, Scheduled_Account__r.PersonEmail, Scheduled_Patient__r.Patient_Email__c FROM Consult_Inventory__c WHERE ID IN :appointment_IDs];
				Map<ID, Consult_Inventory__c> appointment_map = new Map<ID, Consult_Inventory__c>();
				for (Consult_Inventory__c appointment : appointments) {appointment_map.put(appointment.id, appointment);}
				return appointment_map;
			}

			private static ID[] appointment_IDs(Consult_Inventory__c[] appointments) {
				ID[] appointment_IDs = new ID[]{};
				for (Consult_Inventory__c appointment : appointments) {appointment_IDs.add(appointment.id);}
				return appointment_IDs;
			}

			private static String recipient_address(Consult_Inventory__c appointment) {
				return (appointment.Scheduled_Account__c != null) ? appointment.Scheduled_Account__r.PersonEmail : appointment.Scheduled_Patient__r.Patient_Email__c;
			}

			private static Messaging.SingleEmailMessage email(ID org_ID, String email_address) {
				String[] email_addresses = new String[]{email_address};
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email.setOrgWideEmailAddressId(org_ID);
				// email.setReplyTo('awaisman+esthetics_test@clearchoice.com');
				email.setSubject(subject);
				email.setPlainTextBody(plain_text_body);
				email.setHTMLBody(html_body);
				email.setToAddresses(email_addresses); email.setSaveAsActivity(false);
				return email;
			}

}