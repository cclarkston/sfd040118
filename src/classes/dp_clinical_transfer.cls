public without sharing class dp_clinical_transfer {
  public Center_Information__c current_center {get; set;}
  public Boolean display_corp_admin {get; set;}
  
  public String transfer_stage {get; set;}
  
  public String search_name {get;set;}
  public String search_first {get;set;}
  public String search_phone {get;set;}
  public String search_email {get; set;}
  public String search_unique {get; set;}
  public List<Account> consult_search_results {get; set;}
  
  Set<ID> market_centers;
  
  public Boolean allow_quick_search;
  public Boolean getallow_quick_search() {
  	if(allow_quick_search==null)
  	  allow_quick_search = [select id,Enable_Patient_Quick_Search__c from user where id = :userinfo.getuserid()].enable_patient_quick_search__c; 
  	return allow_quick_search;
  }
  
  public Integer num_patient_records {get; set;}
  public Boolean display_more_search_records {get; set;}
    
  public dp_clinical_transfer() {  	
  	User u = [select clinic_calendar__c,default_calendar_room__c,default_calendar_view__c from user where id =:userinfo.getUserId()];     
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {
            
        if(u.clinic_calendar__c==null) 
          current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c from Center_Information__c where name = :u.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up your center.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}   
  	  	  	
  	//see if it's a corporate admin
  	Integer admin_count = [select count() from Profile where name in ('System Administrator','New System Administrator','Data Audit Team','CC Schedule Admin','Finance','RBD') and id = :Userinfo.getProfileId()];
  	if(admin_count>0)
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;
  	transfer_stage = 'patient_search';
  	search_name = '';
  	search_first = '';
  	search_unique = '';
  	search_phone = '';
  	search_email = '';   
  	num_patient_records = 20;
  	display_more_search_records = false;
  	consult_search_results = new List<Account>();	
  	market_centers = getcenters_in_market(); 
  }
  
  public class menu_item {
  	public String menu_name {get;set;}
  	public String menu_type {get; set;}
  	public String menu_nav_color {get;set;}
  	public String menu_id {get;set;}
  	public String menu_css {get;set;}
  	
  	public menu_item(String mname, String mtype, String mcolor, String mid, String mcss) {
  	  this.menu_name = mname;
  	  this.menu_type = mtype;
  	  this.menu_nav_color = mcolor;
  	  this.menu_id = mid;
  	  this.menu_css = mcss;
  	} 
  }
  
  public List<Center_Information__c> getcenter_list() {
  	List<Center_Information__c> ci_list;
  	//to-do: need to modify this so it display all centers relevant to the user
  	if(display_corp_admin)
  	  ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id order by name];
  	else
  	  ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id and market__c = :current_center.market__c order by name];
  	return ci_list;
  }
  
  public List<Navigation_Page__c> getgear_menu() {
  	return [Select n.Sort_Order__c, n.Page_URL__c, n.Name, n.Image_Name__c, n.Id , n.image_name_hover__c,n.hyperlink_target__c From Navigation_Page__c n where navigation_header__r.name = 'Gear' order by sort_order__c];
  }
  
  public List<menu_item> getnavigation_menu() {
  	List<menu_item> nav_menu = new List<menu_item>();
  	for(Navigation_Header__c head : [Select n.Sub_System__c, n.Sort_Order__c, n.Name,  n.Id, (Select Id,  Name, Nav_Color__c, Page_URL__c,css_class__c From Navigation_Pages__r order by sort_order__c) From Navigation_Header__c n where sub_system__c = 'Setup' order by sort_order__c]) {
  	  nav_menu.add(new menu_item(head.name,'Header',null,head.id,null));
  	  for(Navigation_Page__c page : head.navigation_pages__r) {
  	  	nav_menu.add(new menu_item(page.name,'Page',page.nav_color__c,page.id,page.css_class__c));
  	  }
  	  nav_menu.add(new menu_item(null,'Spacer',null,null,null));
  	}
  	//remove the last spacer line from the menu - it's not needed
  	nav_menu.remove(nav_menu.size()-1);
  	return nav_menu;
  }
  
  public List<Navigation_Header__c> getmain_menu() {
    return [Select n.Sub_System__c, n.Sort_Order__c, n.Name,  n.Id, (Select Id,  Name, Nav_Color__c, Page_URL__c,css_class__c From Navigation_Pages__r order by sort_order__c) From Navigation_Header__c n where sub_system__c = 'Setup' order by sort_order__c];  	
  }
  
  public void change_center() {
  	try {
  	  System.debug('Changing Center : ' + apexpages.currentpage().getparameters().get('cid'));
  	  current_center = [select id,name,market__c,number_of_lab_techs__c from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
  }
  
  public List<Navigation_Page__c> getclinical_header_items() {
  	return [Select n.Sort_Order__c, n.Page_URL__c, n.Name, n.Image_Name__c, n.Id , n.image_name_hover__c,n.css_class__c From Navigation_Page__c n where navigation_header__r.name = 'Clinical Header' order by sort_order__c];
  }
  
  public PageReference navigate_to() {
  	PageReference pr;
  	if(apexpages.currentpage().getparameters().get('navid')!=null) {
  	  try {
  	  	Navigation_Page__c np = [select page_url__c from Navigation_Page__c where id = :apexpages.currentpage().getparameters().get('navid')];
  	  	System.debug('URL : ' + np.page_url__c);
  	  	if(np.page_url__c!=null) {
  	      pr = new PageReference(np.page_url__c);
  	      pr.getParameters().put('ctrid',current_center.id);
  	      pr.setredirect(true);  	      
  	      return pr;
  	  	}
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change pages.  Please contact IT for help'));
        ApexPages.addMessages(e);
  	  	return null;
  	  }
  	}
  	return pr;
  }
  
  public PageReference navigate_to_recent_patient() {
  	Navigation_Page__c np = [select page_url__c from Navigation_Page__c where name = 'Patient'];
  	Pagereference pr = new PageReference(np.page_url__c);
  	pr.getParameters().put('ctrid',current_center.id);
  	pr.getParameters().put('ptid',apexpages.currentpage().getparameters().get('recentid'));
  	pr.setredirect(true);  	      
  	return pr;  	
  }

  public List<RecentlyViewed> getrecent_records() {
    return [select Id, Name from RecentlyViewed where type = 'Account' order by LastViewedDate desc limit 10];
  }   
  
  public Integer getdosespot_notification_count() {
  	Integer error_count = 0;  	
  	try {  	
  	  /*DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors(current_center);
      Map<String,Object> amap = (Map<String,object>)dres.data;
      error_count += Integer.valueof(amap.get('refillRequestCount'));
      error_count += Integer.valueof(amap.get('transmissionErrorCount'));*/
      //build a list of the clinician ids we need to check
  	  Set<Integer> all_clinician_ids = new Set<Integer>();
  	  for(User u : [select u.id,u.DoseSpot_User_ID__c from User u 
  	    where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name
  	    and u.dosespot_user_id__c != null ]) {  		
  	    all_clinician_ids.add(Integer.valueof(u.dosespot_user_id__c));
  	  } 
  	  //shouldn't happen in production,  but I'm leaving this in place here for the test environment and initial setup circumstances
  	  if(all_clinician_ids.size()==0) {
  	    DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors(current_center);
        Map<String,Object> amap = (Map<String,object>)dres.data;
        error_count += Integer.valueof(amap.get('refillRequestCount'));
        error_count += Integer.valueof(amap.get('transmissionErrorCount'));
  	  } else {
  	  	for(Integer clinician_id : all_clinician_ids) {
  	  	  DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors_by_clinician(current_center,clinician_id);
          Map<String,Object> amap = (Map<String,object>)dres.data;
          error_count += Integer.valueof(amap.get('refillRequestCount'));
          error_count += Integer.valueof(amap.get('transmissionErrorCount'));
  	  	}
  	  }  	  
      return error_count;    
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to connect with Dosespot.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  	return error_count;
  }
  
  public Set<ID> getcenters_in_market() {
  	Set<ID> all_centers = new Set<ID> {current_center.id};
  	try {
  	  for(Center_Information__c ci : [select id from Center_Information__c where market__c = : current_center.market__c and id != :current_center.id]) {
  	    all_centers.add(ci.id);
  	  }
  	} catch (Exception e) {
  	  //bad or missng market__c value?
  	}
  	return all_centers;
  }

  public void more_patient_records() {
  	num_patient_records += 20;
  	search_consult_records();
  }
    
  public void search_consult_records() {
  	Set<ID> opp_matches = new Set<ID>();
  	String query_filter = ' where center__c in :market_centers';
  	if((search_name==null?'':search_name)!='')
  	  query_filter += ' and lastname like \'%' + search_name.trim() + '%\' ';
  	if((search_first==null?'':search_first)!='')
  	  query_filter += ' and firstname like \'%' + search_first.trim() + '%\' ';
  	if((search_unique==null?'':search_unique)!='') {  	  
  	  for(Opportunity o : database.query('select id,accountid from opportunity where windent_patient_id__c like \'%' + search_unique  +'%\'')) {
  	  	opp_matches.add(o.accountid);
  	  }
  	  query_filter += ' and (warranty_id__c like \'%' + search_unique.trim() + '%\' or id in :opp_matches) ';
  	}  	    	  
  	if((search_phone==null?'':search_phone)!='') {
  	  //clean up the phone number so we can search with it
  	  query_filter += ' and (phone like \'%' + search_phone.trim() + '%\' or personmobilephone like \'%' + search_phone.trim() + '%\') ';
  	}
  	if((search_email==null?'':search_email)!='') 
  	  query_filter += ' and (email__c like \'%' + search_email.trim() + '%\' or personemail like \'%' + search_email.trim() + '%\') ';
  	//to-do search for consult matches
  	try {
  	 // System.debug('Consult Search Query : ' + 'select id,name,phone,email__c,billingStreet,billingcity,billingstate,billingpostalcode from Account ' + query_filter + ' limit 20');
  	  consult_search_results = database.query('select id,name,phone,email__c,personemail,billingStreet,billingcity,billingstate,billingpostalcode,personmobilephone,warranty_id__c from Account ' 
  	    + query_filter + ' order by name limit ' + num_patient_records);	
  	  if(consult_search_results.size()==num_patient_records)
  	    display_more_search_records = true;
  	  else
  	    display_more_search_records = false;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error searching for patients.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }     
  
  public Integer getsearch_result_size() {
  	return consult_search_results.size();
  }
  
}