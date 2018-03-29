public with sharing class ctrl_lab_queue {
  public Integer page = 1;
  public Integer getpage() {return page;}
  public Integer num_pages = 0;
  public Integer getnum_pages() {return num_pages;}
  Integer record_count;
  Double page_holder;
  public Integer records_per_page {get; set;}
  public boolean display_next = true;
  public boolean display_prev = false;
  public boolean getdisplay_next() { return display_next; }
        public boolean getdisplay_prev() { return display_prev; }
  public String selected_center {get; set;}
  public String search_status {get; set;}
  public String search_assigned {get; set;}
  public String search_ctype {get; set;}
  public String search_csubtype {get; set;}
  public String search_ptype {get; set;}
  public String search_ticket {get; set;}
  public boolean display_admin;
  public boolean display_lab_manager;
  public boolean display_lab_user;
  public string sort_filter {get;set;}
  public string result_msg {get;set;}
  public Boolean modal_display {get; set;}
  public String modal_out {get; set;}
  
  public String search_apt_name {get; set;}
  public Lab_Case__c search_date_start {get; set;}
  public Lab_Case__c search_date_end {get; set;}
  public Lab_Case__c search_lab_dates;
  public boolean display_error_msg {get; set;}
  public String error_msgs {get; set;}
  List<Selectoption> assign_to_list;  
  public Lab_Case__c new_lab_case {get; set;}
  
  Lab_Case__c[] lab_queue;
  
  public ctrl_lab_queue() {
        modal_display = false;
        modal_out = '';
        records_per_page = 15;
        search_apt_name = '';
        search_status = 'mine';
        search_ctype = 'all';
        search_csubtype = 'all';
        search_ptype = 'all';
        search_assigned = '';
        search_ticket = '';
        sort_filter = 'apt_date__c';
        search_date_start = new Lab_Case__c(due_date__c = Date.today().addDays(-30));
        search_date_end = new Lab_Case__c(due_date__c = Date.today().addDays(30));
        display_error_msg = false;
        error_msgs = '';
        result_msg = '';
        //set the selected center on page open
        User u = [select lab_center__c from user where id = :userinfo.getUserId()];
        if(u.Lab_Center__c==null) 
          selected_center = 'Unknown';
        else
          selected_center = u.lab_center__c;
        refresh_case_list();
        refresh_assign_options();
        if(Userinfo.getUserName()=='cmcdowell@clearchoice.com') {
         // display_lab_user = true;
          //display_admin = false;
          //display_lab_manager = false;
        }
  }
  
  public List<Selectoption> getassign_list() {
        return assign_to_list;
  }
  
  public void change_queue() {
        reset_errors();         
                if(Apexpages.currentPage().getParameters().get('squeue')==null) {
                        display_error_msg = true;
                        error_msgs = '<span class="warning">Unable to detect queue filter.  Please contact IT</span>';
                }
                else {
                        search_status = Apexpages.currentPage().getParameters().get('squeue');
                  refresh_case_list();
                } 
  }
  
  public void refresh_assign_options() {
        Set<ID> assigned_ids = new Set<ID> ();
        assign_to_list = new List<Selectoption>();
    assign_to_list.add(new SelectOption('','Unassigned'));     
    for(User u : [select id,name from user where lab_center__c = :selected_center order by name]) {
        assign_to_list.add(new SelectOption(u.id,u.name));
        assigned_ids.add(u.id);
    }
    
    //add lab users
    for(User u : [select id,name from user where name like '% lab' order by name]) {
        if(!assigned_ids.contains(u.id)) {
                assign_to_list.add(new SelectOption(u.id,u.name));
                assigned_ids.add(u.id);
        }
    }
    
    //add users not in the existing list but who have a case assigned to them (likely people who transferred or were let go)
    for(Lab_Case__c cm : lab_queue) {
        if(cm.assigned_to__c<>null) {
          if(!assigned_ids.contains(cm.assigned_to__c)) {
            assign_to_list.add(new SelectOption(cm.assigned_to__c,cm.assigned_to__r.name));
            assigned_ids.add(cm.assigned_to__c);
          }
        }
    }        
  }
  
  public void reset_errors() {
        display_error_msg = false;
        error_msgs = '';
        result_msg = '';
  }
  
  public void refresh_case_list() {
        lab_queue = new Lab_Case__c[] {};
        reset_errors();         
        if(selected_center=='Unknown') {
          display_error_msg = true;     
          error_msgs = '<span class="warning">You are currently not mapped to a lab in the system.  Please contact IT if you feel this is in error</span>';           
        }
        else {
                try {
                                String query_filter = ' where due_date__c >= ' + string.valueof(search_date_start.due_date__c).substring(0,10) + ' and due_date__c <= ' + string.valueof(search_date_end.due_date__c).substring(0,10) ;
                                if(selected_center<>'all')
                                  query_filter += ' and (Clinic_Name__c = \'' + selected_center + '\' or assigned_to__r.name = \'' + selected_center + ' lab\')';
                                if(search_apt_name.trim()<>'') 
                                        query_filter += ' and windent_patient__r.name like \'%' + search_apt_name + '%\'';                      
                                if(search_status<>'all')
                                  if(search_status=='all_open')
                                    query_filter += ' and status__c not in (\'Completed\',\'Cancelled\')';                                
                                  else if(search_status=='mine')
                                    query_filter += ' and status__c not in (\'Completed\',\'Cancelled\') and assigned_to__c = \'' + userinfo.getuserid() + '\'';
                else if(search_status=='unassigned')                      
                                    query_filter += ' and status__c = \'' + search_status + '\'';       
                                  else if(Search_status=='Completed')
                                    query_filter += ' and status__c in (\'Completed\',\'Cancelled\')';                                                                  
                        if(search_assigned<>'')
                                query_filter += ' and assigned_to__r.name like \'%' + search_assigned + '%\'';
                        if(search_ctype<>'all')
                          query_filter += ' and case_type__c = \'' + search_ctype + '\'';
                        if(search_csubtype<>'all')
                          query_filter += ' and case_sub_type__c = \'' + search_csubtype + '\'';
                        if(search_ptype<>'all')
                          query_filter += ' and procedure_type__c = \'' + search_ptype + '\'';
                        if(search_ticket.trim()<>'')
                          query_filter += ' and name = \'' + search_ticket + '\'';
                                                
                        //holder to handle sort by clicks
        query_filter += ' order by ' + sort_filter;                   
        System.debug('Testing : ' + 'Select l.Windent_Patient__c, l.Time_To__c, l.Time_From__c, l.SystemModstamp, l.Status__c, l.Procedure_Type__c, l.OwnerId, l.Name, l.LastModifiedDate, l.LastModifiedById, l.IsDeleted, l.Id, l.Due_Date__c, l.CreatedDate, l.CreatedById, l.Clinic_Name__c, l.Case_Type__c, l.case_sub_type__c, l.Case_Type_Map__c, l.Assigned_To__c, l.Assigned_Time__c, l.Assigned_By__c, l.Apt_Type_Id__c, l.Apt_Date__c,l.windent_patient__r.name,l.assigned_to__r.name From Lab_Case__c l ' + query_filter);                   
                        List<Lab_Case__c> results = database.query('Select l.Windent_Patient__c, l.Time_To__c, l.Time_From__c, l.SystemModstamp, l.Status__c, l.Procedure_Type__c, l.OwnerId, l.Name, l.LastModifiedDate, l.LastModifiedById, l.IsDeleted, l.Id, l.Due_Date__c, l.CreatedDate, l.CreatedById, l.Clinic_Name__c, l.Case_Type__c, l.case_sub_type__c, l.Case_Type_Map__c, l.Assigned_To__c, l.Assigned_Time__c, l.Assigned_By__c, l.Apt_Type_Id__c, l.Apt_Date__c,l.windent_patient__r.name,l.assigned_to__r.name From Lab_Case__c l ' + query_filter);
                        record_count = results.size();
                        page_holder = math.ceil((record_count/records_per_page));                               
                                num_pages = page_holder.intvalue();
                        if(math.mod(record_count, records_per_page)>0)
                            num_pages++;
                                Integer low_range = (page - 1) * records_per_page;
                                Integer high_range = page * records_per_page;
                                Integer cnt = 1;
                                if(page > 1)
                                  display_prev = true;
                                else
                                  display_prev = false;
                                if(num_pages > 1 && page < num_pages)
                                  display_next = true;
                                else
                                  display_next = false; 
                          for(Lab_Case__c c : results) {
                                if(cnt > low_range && cnt <= high_range) 
                                        lab_queue.add(c);
                                cnt++;
                          }
                          display_error_msg = true;
                          error_msgs = 'Select l.Windent_Patient__c, l.Time_To__c, l.Time_From__c, l.SystemModstamp, l.Status__c, l.Procedure_Type__c, l.OwnerId, l.Name, l.LastModifiedDate, l.LastModifiedById, l.IsDeleted, l.Id, l.Due_Date__c, l.CreatedDate, l.CreatedById, l.Clinic_Name__c, l.Case_Type__c, l.Case_Type_Map__c, l.Assigned_To__c, l.Assigned_Time__c, l.Assigned_By__c, l.Apt_Type_Id__c, l.Apt_Date__c,l.windent_patient__r.name,l.assigned_to__r.name From Lab_Case__c l ' + query_filter;
                          /*if(Lab_queue.size()==0) {
                                display_error_msg = true;
                                error_msgs = '<span class="warning">There are no lab cases that match your search criteria</span>';
                        }       */      
                }  
                  catch (Exception e) {
                        display_error_msg = true;
                          error_msgs = '<span class="warning">' + e.getMessage() + '</span>';
                  }
        }       
  }
  
  public Lab_Case__c[] getcase_list() {
        return lab_queue;
  }
  
  public Pagereference case_search() { 
        System.debug('Case Search'); 
    page = 1;
                refresh_case_list();
                return null;
        }
  
  public List<SelectOption> getStatusOptions() {
    List<SelectOption> options = new List<SelectOption>(); 
    options.add(new SelectOption('all','Any Status'));
    options.add(new SelectOption('all_open','Any Open Status'));     
    for(Schema.PicklistEntry Value : Lab_Case__c.status__c.getDescribe().getPicklistValues()) {
        options.add(new SelectOption(Value.getValue(),Value.getLabel()));
                }
    return options; 
        }
  
  public List<SelectOption> getCaseTypeOptions() {
    List<SelectOption> options = new List<SelectOption>(); 
    options.add(new SelectOption('all','All Cases'));     
    for(Schema.PicklistEntry Value : Lab_Case__c.Case_Type__c.getDescribe().getPicklistValues()) {
        options.add(new SelectOption(Value.getValue(),Value.getLabel()));
                }
    return options; 
        }
        
        public List<SelectOption> getCaseSubTypeOptions() {
    List<SelectOption> options = new List<SelectOption>(); 
    options.add(new SelectOption('all','All Types'));     
    for(Schema.PicklistEntry Value : Lab_Case__c.Case_Sub_Type__c.getDescribe().getPicklistValues()) {
        options.add(new SelectOption(Value.getValue(),Value.getLabel()));
                }
    return options; 
        }
         
        public List<SelectOption> getProcedureTypeOptions() {
    List<SelectOption> options = new List<SelectOption>(); 
    options.add(new SelectOption('all','Any Procedure'));     
    for(Schema.PicklistEntry Value : Lab_Case__c.Procedure_Type__c.getDescribe().getPicklistValues()) {
        options.add(new SelectOption(Value.getValue(),Value.getLabel()));
                }
    return options; 
        }
        
        public List<SelectOption> getCenterOptions() {
    List<SelectOption> options = new List<SelectOption>(); 
    options.add(new SelectOption('all','All Centers'));     
    for(Schema.PicklistEntry Value : User.Lab_Center__c.getDescribe().getPicklistValues()) {
        options.add(new SelectOption(Value.getValue(),Value.getLabel()));
                }
                options.add(new SelectOption('Unknown','Unknown Center'));
    return options; 
        }
                
  public Boolean getdisplay_admin() {
        if(display_admin==null) {
                Integer admin_count = [select count() from Profile where name in ('System Administrator','RBD','New System Administrator','System Administration - Test') and id = :Userinfo.getProfileId()];
            if(admin_count>0 || Test.isRunningTest()) {
              display_admin = true;
              display_lab_user = false;
              display_lab_manager = false;
            }
            else
              display_admin = false;
        }       
          return display_admin;
  }
  
  public Boolean getdisplay_lab_manager() {
        if(display_lab_manager==null) {
                Integer admin_count = [select count() from Profile where name in ('To Be Determined') and id = :Userinfo.getProfileId()];
            if(admin_count>0 || Test.isRunningTest()) {              
              display_lab_manager = true;
              display_admin = false;
              display_lab_user = false;
            }
            else
              display_lab_manager = false;
        }       
          return display_lab_manager;
  }
  
  public Boolean getdisplay_lab_user() {
        if(display_lab_user==null) {
                Integer admin_count = [select count() from Profile where name in ('To Be Determined') and id = :Userinfo.getProfileId()];
            if(admin_count==0 || Test.isRunningTest()) {
              display_lab_user = true;
              display_lab_manager = false;
              display_admin = false;
            }
            else
              display_lab_user = false;
        }       
          return display_lab_user;
  }
  

    
  public void change_sort_filter() {
        reset_errors();         
                if(Apexpages.currentPage().getParameters().get('sfilter')==null) {
                        display_error_msg = true;
                        error_msgs = '<span class="warning">Unable to detect sort filter.  Please contact IT</span>';
                }
                else {
                        if(sort_filter==Apexpages.currentPage().getParameters().get('sfilter'))
                          sort_filter += ' desc';
                        else
                    sort_filter = Apexpages.currentPage().getParameters().get('sfilter');
                  refresh_case_list();
                } 
  }
  
  public void next() {
                page++;
                refresh_case_list();
        }
        
        public void prev() {
                page = page - 1;
                refresh_case_list();
        }
        
        public void grab_ticket() {
                reset_errors();
                if(Apexpages.currentPage().getParameters().get('tid')==null) {
                        display_error_msg = true;
                        error_msgs = '<span class="warning">Unable to detect ticket. Please contact IT</span>';
                }
                else {
                        try {
                                //make sure the ticket is still unassigned
                                Lab_Case__c target_ticket = [select id,name,status__c,assigned_to__c,assigned_by__c,assigned_time__c from Lab_Case__c where id = :Apexpages.currentPage().getParameters().get('tid')];
                                if(target_ticket.status__c == 'Unassigned' || target_ticket.assigned_to__c==null) {
                                        for(Lab_case__c lc : lab_queue) {
                                                if(lc.id == target_ticket.id) {
                                                        lc.status__c = 'Assigned';
                                                        lc.assigned_to__c = userinfo.getuserid();
                                                  lc.assigned_by__c = userinfo.getUserId();
                                                        lc.assigned_time__c = System.now();                             
                                                        Lab_Case_Note__c ln = new Lab_Case_Note__c(Lab_Case__c = target_ticket.id, Case_Notes__c = 'Ticket has been assigned to ' + userinfo.getfirstname() + ' ' + userinfo.getLastName());
                                                        insert ln;
                                                }
                                                update lab_queue;                                               
                                        }                           
                                        //update target_ticket;           
                                }
                                else {
                                        display_error_msg = true;
                                        error_msgs = '<span class="warning">Claim Ticket Failed - Ticket # ' + target_ticket.name + ' has already been assigned to someone else</span>';
                                }
                        }
                        catch (Exception e) {
                                display_error_msg = true;
                                error_msgs = '<span class="warning">Claim Ticket Failed - Ticket # ' + e.getMessage() + '</span>';
                        }
                }
        }
        
        public String getcurrent_name() {
                return userinfo.getFirstName() + ' ' + userinfo.getLastName();
        }
        
        public void save() {
                reset_errors();
                result_msg = '<span style="font-weight:bold;color:blue;">Success - Save Completed</span><br />';
                try {
                        List<Lab_Case_Note__c> new_notes = new List<Lab_Case_Note__c>();
                        Set<ID> lab_case_id = new Set<ID>();
                        for(Lab_Case__c lc : lab_queue) {
                                lab_case_id.add(lc.id);
                        }
                        Map<Id,Lab_Case__c> old_case_map = new Map<Id,Lab_Case__c>  ();
                        for(Lab_Case__c lc : [select assigned_to__c,apt_date__c,due_date__c,id from Lab_Case__c where id in :lab_case_id]) {
                                old_case_map.put(lc.id,lc);
                        }                                       
                        for(Lab_Case__c lc : lab_queue) {
                                Lab_Case__c old_case = old_case_map.get(lc.id);
                                if(lc.Assigned_To__c<>null) { 
                                        if(lc.status__c=='Unassigned')                                  
                                            lc.status__c = 'Assigned';
                                        if(lc.Assigned_To__c<>old_case.assigned_to__c) {
                                                lc.assigned_by__c = userinfo.getUserId();
                                                lc.assigned_time__c = System.now();
                                                User u = [select name from User where id = :lc.assigned_to__c];
                                                Lab_Case_Note__c ln = new Lab_Case_Note__c(Lab_Case__c = lc.id, Case_Notes__c = 'Ticket has been assigned to ' + u.name);
                                                new_notes.add(ln);                                      
                                        }
                                }
                        }
                        update lab_queue;
                        if(new_notes.size()>0)
                          insert new_notes;
                }
                catch (Exception e) {
                        result_msg = '<span class="warning">Error Encountered - ' + e.getMessage() + '</span>';
                }
        }
        
        public void close_modal() {
    modal_display = false;      
        modal_out = '';
        new_lab_case = null;
  }
  
  public void display_new_ticket_form() {
        modal_out = '';
        modal_display = true;
        new_lab_Case = new Lab_Case__c();
        if(selected_center<>'all')
          new_lab_case.Clinic_Name__c = selected_center;        
  } 
  
  public void add_ticket() {
        try {
                modal_out = '';
                if(new_lab_case.Windent_Patient__c==null) 
                  modal_out += '<span class="warning">Warning - You must select a patient in order to create a new ticket</span><br />';
                if(new_lab_case.Case_Type__c==null)
                  modal_out += '<span class="warning">Warning - You must select a case type in order to create a new ticket</span><br />';
                if(new_lab_case.Due_Date__c==null)
                  modal_out += '<span class="warning">Warning - You must enter a due date in order to create a new ticket</span><br />';  
                if(new_lab_case.Clinic_name__c==null)
                  modal_out += '<span class="warning">Warning - You must select a clinic in order to create a new ticket</span><br />';  
                if(modal_out=='') {             
                        new_lab_case.Apt_Date__c = new_lab_case.Due_Date__c;                      
                  insert new_lab_case;
                  modal_display = false;
                                refresh_case_list();                              
                }       
        }
        catch (Exception e) {
                modal_out = '<span class="warning">Note Insert Failed - </span> ' + e.getmessage();
        }
  }
}