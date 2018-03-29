trigger ClearChoiceDoctor_Update on ClearChoice_Doctor__c (after update) {
  /*  3/8/2018 CM - Adding trigger to keep CCE credit hours in synch with monthly snapshots.  When the cce_credits are updated on the doctor record,  
                 this trigger will make a similar change to the currently monthly snapshot*/
	
	  
  if(trigger.isUpdate) {  	
  	//map to store cce credit change amount by clearchoice doctor id
  	Map<ID,Integer> cce_map = new Map<ID,Integer>();
    for(ClearChoice_Doctor__c doctor : trigger.new) {
      ClearChoice_Doctor__c old_doc = Trigger.oldmap.get(doctor.id);
      if(doctor.CCE_Credits__c!=null) {
      	if(doctor.cce_credits__c!=old_doc.cce_credits__c) {
      	  Integer cce_change = doctor.cce_credits__c.intvalue() - old_doc.cce_credits__c.intvalue();
      	  cce_map.put(doctor.id,cce_change);      	        	 
      	}
      }
    }
        
    List<Doctor_Mastery_User_Snapshot__c> user_changes = new List<Doctor_Mastery_User_Snapshot__c>();     
    //did we have any changes to cce credits
    if(cce_map.size()>0) {
      Integer current_month = System.today().month();
      Integer current_year = System.today().year();
      for(Doctor_Mastery_User_Snapshot__c user_snap  : [Select d.Year__c, d.Month__c, d.ClearChoice_Doctor__c, d.CCE_Credits__c,d.id From Doctor_Mastery_User_Snapshot__c d where clearchoice_doctor__c in :cce_map.keyset() and month__c = :current_month and year__c = :current_year]) {
        user_snap.cce_credits__c += cce_map.get(user_snap.clearchoice_doctor__c);
        user_changes.add(user_snap); 
      }
      update user_changes; 
    }	
  }
       
}