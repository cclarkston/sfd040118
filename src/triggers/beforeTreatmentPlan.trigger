trigger beforeTreatmentPlan on Treatment_Plan__c (before insert) {
  /*if(trigger.isInsert) {
  	
  	for(Treatment_Plan__c my_plan : Trigger.new) {
  	  if(my_plan.account__c!=null) {
	    Account a = [select id,name,center__c from Account where id = :my_plan.account__c];
	    my_plan.center_information__c = a.center__c;
  	  }
  	  if(my_plan.opportunity__c!=null) {
  	  	Opportunity o = [select id,name,account.center__c from Opportunity where id = :my_plan.account__c];
  	  	my_plan.center_information__c = o.account.center__c;
  	  }
  	}
  }*/
}