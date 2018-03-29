public with sharing class ctrl_casetypemap {
  public Integer page = 1;
  public Integer getpage() {return page;}
  public Integer num_pages = 0;
  public Integer getnum_pages() {return num_pages;}
  Integer record_count;
  public String result_msg {get; set;}
  Double page_holder;
  public Integer records_per_page {get; set;}
  public boolean display_next = true;
  public boolean display_prev = false;
  public boolean getdisplay_next() { return display_next; }
	public boolean getdisplay_prev() { return display_prev; }
  public String selected_center {get; set;}
  //public String getselected_center() { return selected_center; }
  public boolean display_admin;
  
  public boolean display_lab_manager;
  public boolean display_lab_user;
  public string search_apt_type {get; set;}
  public String search_apt_name {get; set;}
  public boolean display_error_msg {get; set;}
  public String error_msgs {get; set;}  
  List<Selectoption> assign_to_list;  
  
  public class Lab_Case {
  	public Case_Type_Map__c apt_code {get;set;}
  	Integer next_7 = 0;
  	Integer next_14 = 0;
  	Integer next_30 = 0;
  	
  	public Lab_Case(Case_Type_Map__c cm) {
  		this.apt_code = cm;
  		Date current_date = date.today();
  	  for(Windent_Calendar__c wc : [select id,apt_date__c from Windent_Calendar__c where apt_date__c >= today and case_type_map__c = :apt_code.id and apt_date__c <= next_n_days:30]) {
  	  	Integer daydiff = current_date.daysbetween(wc.apt_date__c);
  	  	if(daydiff <= 7)
  	  	  next_7++;
  	  	if(daydiff <= 14)
  	  	  next_14++;
  	  	if(daydiff <= 30)
  	  	  next_30++;
  	  }	
  	}
  	
  	public Integer getnext_7() {
  	  return next_7;
  	}
  	
  	public Integer getnext_14() {
  	  return next_14;
  	}
  	
  	public Integer getnext_30() {
  	  return next_30;
  	}
  }
  
  Lab_Case[] apt_list;
  
  public ctrl_casetypemap() {
  	records_per_page = 15;
  	search_apt_type = '';
  	search_apt_name = '';
  	result_msg = '';
  	display_error_msg = false;
  	error_msgs = '';
  	//set the selected center on page open
  	User u = [select lab_center__c from user where id = :userinfo.getUserId()];  	
  	if(u.Lab_Center__c==null)  
  	  selected_center = 'Unknown';
  	else
  	  selected_center = u.lab_center__c;
  	refresh_aptlist();
  	refresh_assign_options();
  }
  
  public List<Selectoption> getassign_list() {
  	return assign_to_list;
  }
  
  public void refresh_assign_options() {
  	assign_to_list = new List<Selectoption>();
    assign_to_list.add(new SelectOption('','Unassigned'));     
    for(User u : [select id,name from user where lab_center__c = :selected_center order by name]) {
    	assign_to_list.add(new SelectOption(u.id,u.name));
    }
    //add any entries tied to a mapping that are not currently assigned to the lab
    for(Case_Type_Map__c cm : [select auto_assign_to__c,auto_assign_to__r.name from Case_Type_Map__c where clinic_name__c = :selected_center and auto_assign_to__r.lab_center__c <> :selected_center and auto_assign_to__c <> null order by name]) {
    	assign_to_list.add(new SelectOption(cm.auto_assign_to__c,cm.auto_assign_to__r.name));
    }
  }
  
  public void next() {
		page++;
		refresh_aptlist();
	}
	
	public void prev() {
		page = page - 1;
		refresh_aptlist();
	}
  
  public void reset_errors() {
  	display_error_msg = false;
  	error_msgs = '';
  	result_msg = '';
  }
  
  public Integer getaptlist_size() {
  	return apt_list.size();
  }
  
  public void refresh_aptlist() {
  	apt_list = new Lab_Case[] {};
  	reset_errors();
  	if(selected_center=='Unknown') {
  	  display_error_msg = true;  	
  	  error_msgs = '<span class="warning">You are currently not mapped to a lab in the system.  Please contact IT if you feel this is in error</span>';  	  
  	}
  	else {
  		try {
				String query_filter = ' where isdeleted = false';
				if(selected_center<>'all')
				  query_filter += ' and Clinic_Name__c = \'' + selected_center + '\'';
				if(search_apt_name.trim()<>'') 
					query_filter += ' and name like \'%' + search_apt_name + '%\'';			
				if(search_apt_type.trim()<>'') 
					query_filter += ' and Apt_Type_Id__c like \'%' + search_apt_type + '%\'';														
		  	
		  	List<Case_type_map__c> results = database.query('Select c.case_sub_type__c, c.auto_assign_to__c, c.auto_assign_to__r.name, c.Procedure_Type__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.Id, c.Generate_Case__c, c.CreatedDate, c.CreatedById, c.Case_Type__c, c.Apt_Type_Id__c From Case_Type_Map__c c ' + query_filter);
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
		 	  for(Case_Type_Map__c c : results) {
		 	  	if(cnt > low_range && cnt <= high_range)  {
		 	  		Lab_case apt = new Lab_Case(c);
		 	  		apt_list.add(apt);
		 	  	}
		 	  	cnt++;
		 	  }
		 	  if(apt_list.size()==0) {
		 	  	display_error_msg = true;
		 	  	error_msgs = '<span class="warning">There are no apt codes that match your search criteria</span>';
	 	  	}		
  		}  
	 	  catch (Exception e) {
	 	  	display_error_msg = true;
		 	  error_msgs = '<span class="warning">' + e.getMessage() + '</span>';
	 	  }
  	}	
  }
  
  public void case_search() {  
    page = 1;    
		refresh_aptlist();
	}
	
	public void change_lab() {  
    page = 1;    
    refresh_assign_options();
		refresh_aptlist();
	}
  
  public Lab_Case[] getaptlist() {
  	return apt_list;
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
    
  class casesaveException extends Exception {}
  
  public void save() {
    result_msg = '<span style="font-weight:bold;color:blue;">Success - Save Completed</span><br />';
    List<Lab_Case__c> new_cases = new List<Lab_Case__c>(); 
    try {    
	    Set<ID> old_apt_ids = new set<id> {};
	    for(Lab_Case ct : apt_list) {
	    	old_apt_ids.add(ct.apt_code.id);
	    }
	    map<Id,Case_Type_Map__c> old_apt_map = new map<Id,Case_Type_Map__c> {};
	    for(Case_Type_Map__c ct : [select c.case_sub_type__c, c.auto_assign_to__c, c.auto_assign_to__r.name, c.Procedure_Type__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.Id, c.Generate_Case__c, c.CreatedDate, c.CreatedById, c.Case_Type__c, c.Apt_Type_Id__c From Case_Type_Map__c c where id in :old_apt_ids]) {
	    	old_apt_map.put(ct.id,ct);
	    }
	    //work through the cases in the list and see if any changes were made
	    List<Case_Type_Map__c> update_holder = new List<Case_Type_Map__c>();
	    for(Lab_Case ct : apt_list) {
	    	update_holder.add(ct.apt_code);
	    	Case_Type_Map__c old_apt = old_apt_map.get(ct.apt_code.id);
	    	if(ct.apt_code.Procedure_Type__c <> old_apt.procedure_type__c)
	    	  result_msg += 'Apt Type : ' + ct.apt_code.Apt_Type_Id__c + ' has been switched from procedure type - ' + old_apt.procedure_type__c + ' to ' + ct.apt_code.procedure_type__c + '. This change will affect only new tickets that come in.<br />';
	    	if(ct.apt_code.Case_Type__c <> old_apt.case_type__c)
	    	  result_msg += 'Apt Type : ' + ct.apt_code.Apt_Type_Id__c + ' has been switched from case type - ' + old_apt.case_type__c + ' to ' + ct.apt_code.case_type__c + '. This change will affect only new tickets that come in.<br />';
	    	if(ct.apt_code.Case_Sub_Type__c <> old_apt.case_sub_type__c)
	    	  result_msg += 'Apt Type : ' + ct.apt_code.Apt_Type_Id__c + ' has been switched from sub type - ' + old_apt.case_sub_type__c + ' to ' + ct.apt_code.case_sub_type__c + '. This change will affect only new tickets that come in.<br />';
	    	if(ct.apt_code.auto_assign_to__c <> old_apt.auto_assign_to__c) {
	    		/*String old_name = '';
	    		String new_name = '';
	    		if(ct.apt_code.auto_assign_to__c==null)
	    		  new_name = 'Unassigned';
	    		else {
	    			for(Selectoption so : assign_to_list) {
	    				System.debug('Test : ' + so.getvalue() + ' ' + so.getlabel());
	    				if(so.getlabel()<>'Unassigned')
		    			  if(so.getvalue()==ct.apt_code.auto_assign_to__c)
		    		      new_name = so.getlabel();
	    			}
	    			//new_name = ct.apt_code.auto_assign_to__r.name;
	    		}
	    		if(old_apt.auto_assign_to__c==null)
	    		  old_name = 'Unassigned';
	    		else
	    		  old_name = old_apt.auto_assign_to__r.name;
	    	  result_msg += 'Apt Type : ' + ct.apt_code.Apt_Type_Id__c + ' has switched auto assigning from ' + old_name + ' to ' + new_name + '. This change will affect only new tickets that come in.<br />';*/
	    	  result_msg += 'Apt Type : ' + ct.apt_code.Apt_Type_Id__c + ' has adjusted the auto assignment rule<br />';
	    	}
	    	
	    	if(ct.apt_code.generate_case__c) {
	    		if(ct.apt_code.case_type__c==null)
					  throw new casesaveException('Apt Type ' + ct.apt_code.apt_type_id__c + ' was flagged to generate cases,  but no case type was not specified.<br />Please select a case type and try again<br />');
					if(ct.apt_code.case_type__c=='')  
					  throw new casesaveException('Apt Type ' + ct.apt_code.apt_type_id__c + ' was flagged to generate cases,  but no case type was not specified.<br />Please select a case type and try again<br />');					
	    	  if(!old_apt.generate_case__c) {
	    	    //apt has been changed to generate cases - work through calendar and build necessary cases		    	    
	    	    //build a map of the existing lab cases with the apt_type id in question - map<patient_id, apt_date>
	    	    Integer new_case_cnt = 0; 
	    	    Set<String> patient_list = new Set<String>();
	    	    for(Lab_Case__c lc : [Select l.Windent_Patient__c, l.Apt_Type_Id__c, l.Apt_Date__c From Lab_Case__c l where l.case_type_map__c = :ct.apt_code.id and apt_date__c >= today]) {
	    	    	patient_list.add(lc.windent_patient__c + '_' + lc.apt_date__c);
	    	    	System.Debug('Set : ' + lc.windent_patient__c + '_' + lc.apt_date__c);
	    	    }  	    	    
	    	    //work through calendar for all apts with this type. If the map doesn't have a match,  then
	    	    for(Windent_Calendar__c wc : [Select w.Windent_Patient__c, w.TimeTo__c, w.TimeFrom__c, w.apt_date__c, w.Premed__c, w.PatientId__c, w.Name, w.Clinic_Name__c, w.ChairId__c, w.Case_Type_Map__c, 
	    	      w.CalendarStatus__c, w.Appt_Type_Code__c, w.Alert__c From Windent_Calendar__c w where w.apt_date__c >= today and w.case_type_map__c = :ct.apt_code.id and apt_date__c <= next_n_days:30 ]) {
	    	      System.Debug('Looking for : ' + wc.windent_patient__c + '_' + wc.apt_date__c);
	    	      if(!patient_list.contains(wc.windent_patient__c + '_' + wc.apt_date__c)) {
	    	      	//case isn't already in the system - create it
	    	      	Lab_Case__c new_case = new Lab_Case__c(apt_date__c = wc.apt_date__c, apt_type_id__c = wc.appt_type_code__c, case_type__c = ct.apt_code.Case_Type__c, case_sub_type__c = ct.apt_code.case_sub_type__c, case_type_map__c = ct.apt_code.id, clinic_name__c = wc.clinic_name__c,
	    	      	  due_date__c = wc.apt_date__c, procedure_type__c = ct.apt_code.procedure_type__c, status__c = 'Unassigned', time_from__c = wc.TimeFrom__c, time_to__c = wc.timeto__c, windent_patient__c = wc.Windent_Patient__c);
	    	      	if(ct.apt_code.auto_assign_to__c<>null) {
	    	      		new_case.assigned_to__c = ct.apt_code.auto_assign_to__c;
	    	      		new_case.assigned_by__c = userinfo.getuserid();
	    	      		new_case.assigned_time__c = system.now();
	    	      		new_case.status__c = 'Assigned';
	    	      	}
	    	      	new_case_cnt++;
	    	      	new_cases.add(new_case);
	    	      }	    	        	
	    	    }
	    	    String case_text = ' new cases were ';
	    	    if(new_case_cnt==1)
	    	      case_text = ' new case was ';
	    	    result_msg += 'Apt Type : ' + ct.apt_code.apt_type_id__c + ' will now generate cases going forward. ' + new_case_cnt + case_text + ' added to the queue.<br />';
	    	  }
	    	}	    	
	    	if(!ct.apt_code.generate_case__c && old_apt.Generate_Case__c)
	    	  result_msg += 'Apt Type : ' + ct.apt_code.Apt_Type_Id__c + ' will no longer generate cases.  Existing Cases in the quere will remain and should be cleared out manually if necessary.<br />';	    	
	    }
	    update update_holder;
	    if(new_cases.size()>0)
	      insert new_cases;
    }
	  catch (casesaveException e) {
      result_msg = '<span class="warning">Save Failed</span> ' + e.getMessage() + '</span>';	    	
	  }
	  catch (Exception e) {
	  	result_msg = '<span class="warning">Error Encountered - ' + e.getMessage() + '</span>';
	  }
    
  }
}