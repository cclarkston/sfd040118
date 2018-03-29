public with sharing class dp_drag_test {
  public Clinical_Appointment__c ca {get;set;}
  public Plan_of_Treatment__c pt {get; set;}
  
  
  public dp_drag_test() {
    ca = [Select c.isactive__c, c.SystemModstamp, c.Padding_Time__c, c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Center_Information__c, c.Appointment_Description__c From Clinical_Appointment__c c where name = 'Prosth Exam' limit 1];
    pt = [Select p.isActive__c, p.SystemModstamp, p.OwnerId, p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.Doctor__c, p.CreatedDate, p.CreatedById, 
      p.Center_Information__c,p.doctor__r.name From Plan_of_Treatment__c p where name = 'Dr Jones - Lower AO4'];    
  }
  
  public List<POT_Appointment__c> getapt_list_selected() {
        return [Select p.SystemModstamp, p.Sort_Order__c, p.Plan_of_Treatment__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.Days_Out__c, p.CreatedDate, p.CreatedById, p.Clinical_Appointment__c,
      p.clinical_appointment__r.name From POT_Appointment__c p where plan_of_treatment__c = :pt.id order by createddate];
  }
  
  public List<Clinical_Appointment__c> getapt_list_unselected() {
        Set<ID> block_id = new Set<ID>();
        for(POT_Appointment__c pa : getapt_list_selected()) {
          block_id.add(pa.clinical_appointment__c);
        }
        return [Select c.isactive__c, c.SystemModstamp, c.Padding_Time__c, c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Center_Information__c, c.Appointment_Description__c From Clinical_Appointment__c c
          where id not in :block_id];
  }
  
  public List<Clinical_Apt_Procedure__c> getprocedure_list() {
        return [Select c.SystemModstamp, c.Sort_Order__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Clinical_Procedure__c,
          c.clinical_procedure__r.name, c.Clinical_Appointment__c From Clinical_Apt_Procedure__c c where clinical_appointment__c = :ca.id order by sort_order__c];
  } 
  
  public void remove_appointment() {    
        try {
          String pa_id = apexpages.currentpage().getparameters().get('paid');
          System.debug('PA ID : ' + pa_id);
          POT_Appointment__c pa = [select id from pot_appointment__c where id = :pa_id];
          delete pa;
        } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error inserting the pot appointment. Please contact IT for help'));
      ApexPages.addMessages(e); 
    } 
  }
  
  public void add_appointment() {
        try {
          String ca_id = apexpages.currentpage().getparameters().get('caid');
          System.debug('CA ID : ' + ca_id);
          POT_Appointment__c pa = new POT_Appointment__c(plan_of_treatment__c = pt.id, clinical_appointment__c = ca_id, days_out__c = 0, sort_order__c = 1);
          insert pa;
        } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error inserting the pot appointment. Please contact IT for help'));
      ApexPages.addMessages(e); 
    } 
  }
  
  public void test_function_sort() {
        try {
          String pass_thru = apexpages.currentpage().getparameters().get('pthru');
      pass_thru = pass_thru.replace('list[]=','');
      System.debug('pass thru : ' + pass_thru);
      pass_thru = pass_thru.replace('name','');
      System.debug('pass thru : ' + pass_thru);
      String[] pass_array = pass_thru.split('&');
      System.debug('Pass array : ' + pass_array);
      Integer sort_order = 1;
      List<Clinical_apt_procedure__c> cap_list = new List<Clinical_Apt_Procedure__c>();
      for(String my_id : pass_array) {
        Clinical_Apt_Procedure__c cap = [select id,sort_order__c from Clinical_Apt_Procedure__c where id = :my_id];
        cap.sort_order__c = sort_order;
        cap_list.add(cap);
        sort_order++;
      }
      update cap_list;      
    }  catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error updating sort order. Please contact IT for help'));
      ApexPages.addMessages(e); 
    }  
  }
}