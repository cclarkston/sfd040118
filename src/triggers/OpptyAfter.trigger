/*
modified by cm on 2012-3-2
adding some code in here to keep the cancelled date field current on an opportunity record

modified by cm on 2017-03-28
pulled some code that was updating campaignmemberstatus
*/
trigger OpptyAfter on Opportunity (after insert, after update) {    
  
	Set<ID> opptyIds = new Set<ID>(); 
	Set<ID> contactIds = new Set<ID>();
	Set<ID> accIds = new Set<ID>();
	Map<Id, Opportunity> contactToOppMap = new Map<Id, Opportunity>(); 
	Map<Id, Opportunity> accountToOppMap = new Map<Id, Opportunity>();
	
  if(!Util_TriggerContext.hasalreadyProcessed()) {
	for(Opportunity o: Trigger.new) {
      opptyIds.add(o.id);
      accIds.add(o.AccountId);
      accountToOppMap.put(o.AccountId, o);
	}
	system.debug('accountToOppMap: ' + accountToOppMap);
	
	
	
	/*List<Contact> contactList = new List<Contact>([select id, AccountId FROM Contact WHERE Contact.AccountId in: accIds]);
	
	for(Contact c: contactList) {
	  contactIds.add(c.id);
	  Opportunity o = accountToOppMap.get(c.AccountId);
	  contactToOppMap.put(c.id, o);       
	}
	
	system.debug('contactToOppMap: ' + contactToOppMap);*/
	
	/*List<CampaignMember> campmems = new List<CampaignMember>([select id, Status, CampaignId, Contact.AccountId, ContactId FROM CampaignMember WHERE CampaignMember.ContactId in:contactIds]);
	List<Opportunity> updateOpportunityList = new List<Opportunity>();
	List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>();*/
	    
	if(Trigger.isInsert) {		
    /*for(CampaignMember campmem: campmems) {
      Opportunity o = new Opportunity();
               
      if(contactToOppMap.get(campmem.ContactId) != null) {
        o = contactToOppMap.get(campmem.ContactId);
        System.debug('o:'  + o);          
      }
        
      campmem.Status = 'Started';
      OpportunityContactRole ocr = new OpportunityContactRole();
      ocr.ContactId = campmem.ContactId; 
      ocr.OpportunityId = o.id;
      ocr.Role = 'Economic Buyer';
      system.debug('ocr:' + ocr);
      oppContactRoleList.add(ocr);                     
    }*/
    
    Set<String> call_back_list = new Set<String> {'2nd Consult','30 Day Pipeline','60 Day Pipeline','90 Day Pipeline','Medical Clearance','Doctor Declined Case','Refered Out to Doctor',
      	 'No Longer Interested','Not a Candidate','No Money','Walked Out','Treatment Received Elsewhere'};
    //if the consult record has a result type in the call back list,  we need to update it to Prostho Exam Scheduled Call Back
    List<Account> all_accounts = [select id,consult_result__c,createddate from Account where id in :accIds]; 
    for(Account a : all_accounts) {
      if(call_back_list.contains(a.consult_result__c)) {
      	//check to see if the start is a same day start.
      	Opportunity o = accounttooppmap.get(a.id);
      	if(o.createddate.issameday(a.createddate))
      	  a.consult_result__c = 'Prostho Exam Scheduled';
      	else
          a.consult_result__c = 'Prostho Exam Scheduled Call Back';
      }       
    }
    try {
    	Boolean util_state = Util_TriggerContext.hasalreadyProcessed(); 
      Util_TriggerContext.setalreadyProcessed();
      update all_accounts;
      Util_TriggerContext.alteralreadyprocessed(util_state);
    }
    catch(Exception e) {
			  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
	      mail.setToAddresses(toAddresses);
	      mail.setReplyTo('cmcdowell@acme.com');
	      mail.setSenderDisplayName('Apex error message');
	      mail.setSubject('Opportunity After Trigger - Account Update Issue');
	      mail.setPlainTextBody(e.getMessage() + ' ' + e);
	      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
	}
	
	List<Opportunity> update_list = new List<Opportunity>();
	Opportunity upd_op;
	
	if(Trigger.isUpdate) {
		Set<Id> cancellation_list = new Set<Id> ();
		Set<Id> owner_changed_list = new Set<Id> ();
		map<ID,ID> owner_change_map = new map<ID,ID> ();
	  for (Integer i = 0; i < Trigger.new.size(); i++)    {
	    /*if(Trigger.new[i].StageName == 'Cancelled Not Rescheduled') {
	      for(CampaignMember c: campmems){
	        if(c.Contact.AccountId == Trigger.new[i].AccountId)
	          c.Status = 'Start Lost';
	      }
	    }	    
	    if(Trigger.new[i].StageName != 'Cancelled Not Rescheduled' && Trigger.old[i].StageName == 'Cancelled Not Rescheduled') {
        for(CampaignMember c: campmems) {
          if(c.Contact.AccountId == Trigger.new[i].AccountId)
            c.Status = 'Started';
        }	        
	    }*/
	    
	    //check to see if the current_prosth_exam_owner__c field has been changed
	    if(trigger.new[i].current_prosth_owner__c != trigger.old[i].current_prosth_owner__c && trigger.old[i].current_prosth_owner__c!=null) {
	      owner_changed_list.add(trigger.new[i].id);
	      owner_change_map.put(trigger.new[i].id,trigger.new[i].current_prosth_owner__c);
	    }
	    
	    /*modified by cm on 2016-1-5 
	      rule is being revised to total payments > 1000 and outstanding balance <= 0,  mark this as paid
	      from a data governance decision in the last week of December
	    */
	    //checking to see if we've recieved the $1000 prosth exam fee.	    
	    //if(trigger.new[i].total_net_payments__c>=1000 && trigger.old[i].total_net_payments__c<1000) {
	    //if(trigger.new[i].Total_Payments__c>=1000 && trigger.old[i].Total_Payments__c<1000 && trigger.old[i].prosth_exam_paid__c == false) {
	    if(trigger.new[i].Total_Payments__c>=1000 && trigger.new[i].Outstanding_Balance_incl_anticipated__c<=0 && trigger.new[i].prosth_exam_paid__c == false) {
	      upd_op = new Opportunity(id = trigger.new[i].id, prosth_exam_paid__c = true, prosth_exam_paid_date__c = System.today());
	      update_list.add(upd_op);
	    }
	    
	     //checking to see if we dropped below 1,000 in collected payments - red user error or trying to cheat the system
	     //note - haveing outstanding balance go above 0 is not going to cancel out a start.  That will be managed by the audit team for now.
	    //if(trigger.new[i].total_net_payments__c>=1000 && trigger.old[i].total_net_payments__c<1000) {
	    if(trigger.new[i].Total_Payments__c<1000 && trigger.old[i].Total_Payments__c>=1000 && trigger.old[i].prosth_exam_paid__c == true) {
	      upd_op = new Opportunity(id = trigger.new[i].id, prosth_exam_paid__c = false, prosth_exam_paid_date__c = null);
	      update_list.add(upd_op);
	    }
	    
	    //new code to look for records that need the cancel date updated - CM 
	    if(Trigger.new[i].StageName == 'Cancelled Not Rescheduled' && (Trigger.old[i].StageName != 'Cancelled Not Rescheduled'
	      && Trigger.old[i].Completed_Stage__c <> 'Not Moving Forward' && Trigger.old[i].Completed_Stage__c <> 'Financing Difficulty'
	      && Trigger.old[i].Completed_Stage__c <> 'Patient Non Responsive' && Trigger.old[i].Completed_Stage__c <> 'Non Candidate'
	      && Trigger.old[i].Completed_Stage__c <> 'Doctor Declined Case')) {
        upd_op = new Opportunity(id = trigger.new[i].Id,cancel_date__c = Datetime.now());
        update_list.add(upd_op);    
        cancellation_list.add(trigger.new[i].Id);    
	    }
	    else if((Trigger.new[i].Completed_Stage__c == 'Not Moving Forward' || Trigger.new[i].Completed_Stage__c == 'Financing Difficulty'
	      || Trigger.new[i].Completed_Stage__c == 'Patient Non Responsive' || Trigger.new[i].Completed_Stage__c == 'Non Candidate'
	      || Trigger.new[i].Completed_Stage__c == 'Doctor Declined Case') && (Trigger.old[i].StageName != 'Cancelled Not Rescheduled'
	      && Trigger.old[i].Completed_Stage__c <> 'Not Moving Forward' && Trigger.old[i].Completed_Stage__c <> 'Financing Difficulty'
	      && Trigger.old[i].Completed_Stage__c <> 'Patient Non Responsive' && Trigger.old[i].Completed_Stage__c <> 'Non Candidate'
	      && Trigger.old[i].Completed_Stage__c <> 'Doctor Declined Case')) {
        upd_op = new Opportunity(id = trigger.new[i].Id,cancel_date__c = Datetime.now());
        update_list.add(upd_op);
        cancellation_list.add(trigger.new[i].Id);        
	    }
	    //check to see if any opportunities moved into a cancellation state
	    if(cancellation_list.size()>0) {
	    	//if so pull a list of anticipated payments tied to these records so we can update them.
	    	List<CCPayment__c> payment_updates = new List<CCPayment__c>();
	    	for(CCPayment__c payment : [select id,Payment_Status__c from CCPayment__c where opportunity__c in :cancellation_list and 
	    	  payment_status__c in ('Anticipated','Anticipated Promise Note')]) {
	    	  if(payment.payment_status__c == 'Anticipated')
	    	    payment.payment_status__c = 'Anticipated Payment Cancelled';
	    	  else if(payment.payment_status__c=='Anticipated Promise Note')
	    	    payment.payment_status__c = 'Anticipated Prom Note Payment Cancelled';
	    	  payment_updates.add(payment);
	    	}
	    	if(payment_updates.size()>0)
	    	  update payment_updates;
	    }
	    
	    //check to see if we had an owner change
	    if(owner_changed_list.size()>0) {
	      //pull a list of anticipated payments,  and update the pec__c field
	      List<CCPayment__c> payment_list = [select id,opportunity__c,pec__c from CCPayment__c where opportunity__c in :owner_changed_list and payment_status__c in ('Anticipated','Anticipated Promise Note')];
	      for(CCPayment__c cc : payment_list) {
	      	cc.pec__c = owner_change_map.get(cc.opportunity__c);
	      }
	      if(payment_list.size()>0)
	        update payment_list;
	    }	    
	           
	  }	  	  	    	    
	}
	 
 /* try {
	  update campmems;
  }
  catch (Exception e) {
    Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('Apex error message');
		mail.setSubject('Oppurtunity Trigger After - Campaign Member Update');
		mail.setPlainTextBody(e.getMessage());
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }*/
	//adjusting the order here to try and prevent record locks
	if(update_list.size()>0) {
		try {
	    update update_list;
		}
		catch (Exception e) {
			Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		  String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		  mail.setToAddresses(toAddresses);
		  mail.setSenderDisplayName('Apex error message');
		  mail.setSubject('Oppurtunity Trigger After - Opportunity Cancel Date Update X');
		  mail.setPlainTextBody(e.getMessage());
		  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}     
	//insert oppContactRoleList;
  }
}