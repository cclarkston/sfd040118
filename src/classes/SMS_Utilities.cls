public class SMS_Utilities {

  // String[] the_phones = new String[]{'6027033263', '9707298268'};
  // String the_message = 'testing bulk messages. reply \'STOP\' to do absolutely nothing.';
  // String the_sender = 'CCT Management';
  // String response = send_bulk_sms(the_phones, the_message, the_sender);
    public static String send_bulk_sms(Set<String> phone_numbers, String message, String sender) {
        // Simple bulk sms sender. It just takes a list of numbers, the message to send, and a sender name, and sends the texts to the list of numbers provided.
        smagicinteract__smsmagic__c[] smsObjectList = new smagicinteract__smsmagic__c[]{};
        smagicinteract__smsMagic__c smsObject;

        for (String phone_number : phone_numbers) {
            smsObject = new smagicinteract__smsMagic__c();
            smsObject.smagicinteract__PhoneNumber__c = phone_number;
            smsObject.smagicinteract__SenderId__c    = sender;
            smsObject.smagicinteract__SMSText__c     = message;
            smsObject.smagicinteract__disableSMSOnTrigger__c = 1;
            smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
            smsObjectList.add(smsObject);
        }
        return !test.isRunningTest() ? smagicinteract.ApexAPI.pushSMSCallout(smsObjectList) : '<?xml version="1.0"?> <response> <vstatus>success</vstatus> <responseText>All SMSes were queued in single sms standard queue</responseText> </response>';
    }

}