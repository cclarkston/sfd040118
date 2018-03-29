trigger after_Surgical_RX on Surgical_RX__c (after insert, after update) {

  /*not an option - content can not be pulled from a trigger (no surprise)  
  if(Trigger.isAfter) {
  	for(Surgical_Rx__c srx : Trigger.new) {
  	  System.debug('Trigger call out to create attachment');
  	  myWS.record_srx(srx.id,srx.account__c,srx.center_information__c);  	  
  	}
  }*/

}