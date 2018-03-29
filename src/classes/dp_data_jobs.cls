/*using this class to hold some code for data manipulations used in the new clinical software
*/
public with sharing class dp_data_jobs {
	
  public void block_search() {
  	//temporarily playing with stuff here
  	
  	//need a list of eligible blocks,  doctors,  and rooms we can bounce against search inventory for possibilities
  	Patient_POT_Apt__c sched_apt = [Select p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Lab_Time__c, p.Doctor_Notes__c, p.Days_Out__c, p.Clinical_Appointment__c, p.Appointment_Description__c From Patient_POT_Apt__c p
  	  where clinical_appointment__r.name = 'Prosth Exam' and patient_pot__r.account__r.center__r.name = 'Denver' limit 1];
  	
  	  
  	
  	/*Clinical_Appointment__c sched_apt = [select id from Clinical_Appointment__c where center_information__r.name = 'Denver' and
  	  name = 'Prosth Exam' limit 1];*/ 
  	
  	
  	/*Eligible Blocks - will need 2 queries here - first to identify blocks where apt has been specifically authorized
  	second query is to grab blocks that allow any apt....Queries can not be combined due to sub select combination with an or in the filter*/
  	//query 1 - apt authorized for block
  	Map<ID,CR_Schedule_Block__c> block_map = new Map<ID,CR_Schedule_block__c> ([Select id from CR_Schedule_Block__c where id in 
      (Select c.CR_Schedule_Block__c From CR_Sched_Block_Authorized_Apt__c c where clinical_appointment__c = :sched_apt.clinical_appointment__c)]);
    Set<ID> block_ids = block_map.keySet();
    
    //query 2 - blocks that allow anything
    block_map = new Map<ID,CR_Schedule_Block__c> ([select id from CR_Schedule_Block__c where allow_all__c = true and clinical_room__r.center_information__r.name = 'Denver']);
    block_ids.addAll(block_map.keySet());
    
  	//Eligible Doctors  	
  	Set<ID> doctor_ids = new Set<ID>();
  	//to-do : do I need to worry about the active filter on doctor?
  	for(Clinical_DR_Authorized_Apt__c cd : [select doctor__c from Clinical_DR_Authorized_APT__c where clinical_appointment__c = :sched_apt.clinical_appointment__c]) {
  	  doctor_ids.add(cd.doctor__c);
  	} 
  	
  	//Eligible Rooms
  	Map<ID,Clinical_Room__c> room_map = new Map<ID,Clinical_Room__C> ([select id,name from clinical_room__c where id in 
  	  (select clinical_room__c from Clinical_Room_Authorized_Apt__c where clinical_appointment__c = :sched_apt.clinical_appointment__c)]);
  	Set<ID>room_ids = room_map.keySet();
  	
  	//for the search query,  we need to figure out the metrics for the clinical_appointment,  time before dr,  dr time,  and time after dr,  and days out from last apt in the sequence
  	Date earliest_apt_date;
  	if(sched_apt.sort_order__c==1)
  	  earliest_apt_date = System.today();
  	else {
  	  //we need to look at the apt date for the previous apt in the plan of treatment...then add days out to it to get our filter
  	  Integer prior_sort = sched_apt.sort_order__c.intValue() - 1;
  	  Patient_POT_Apt__c prior_apt = [select id, (Select Apt_Date__c From Clinical_Apt_Calendar__r order by apt_date__c desc limit 1) from Patient_POT_Apt__c where sort_order__c = :prior_sort and patient_pot__c = :sched_apt.patient_pot__c and isactive__c = true];
  	  try {
  	    earliest_apt_date = prior_apt.clinical_apt_calendar__r[0].apt_date__c;
  	  } catch (Exception e) {
  	  	//if this is null,  it means we had no date for the previous apt in the chain....that's an issue - use today.
  	  	earliest_apt_date = System.today();  
  	  }
  	}
  	
  	//figuring out time makeup
  	Integer time_before = 0;
  	Integer time_dr = 0;
  	Integer time_after = 0;
  	String current_stage = 'before';
  	for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
      clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p where patient_pot_apt__r.sort_order__c = 1 and isactive__c = true and patient_pot_apt__c = :sched_apt.id]) {
      	//does the procedure need a doctor
        if(pa.clinical_procedure__r.doctor_required__c) {
          //check our stage       
          if(current_stage=='before') {
            current_stage = 'doctor';
            time_dr += pa.time_required__c.intvalue();            
          }
          else if(current_stage=='doctor')
            time_dr += pa.time_required__c.intValue();
          else if(current_stage=='after') {
          	//this means we had a non-doctor required procedure in between some required ones.  for now we handle this by builinding a continuous block of dr time
          	current_stage = 'doctor';
          	time_dr += pa.time_required__c.intValue() + time_after;
          	time_after = 0;
          }
        } else {
          //no doctor needed...check our stage
          if(current_stage=='before')
            time_before += pa.time_required__c.intvalue();
          else if(current_stage=='doctor') {
          	current_stage = 'after';
          	time_after += pa.time_required__c.intvalue();
          }
          else if(current_stage=='after')
            time_after += pa.time_required__c.intvalue();
        }        
    } 
    System.debug('Time Before : ' + time_before);
    System.debug('Time Dr : ' + time_dr);
    System.debug('Time After : ' + time_after);
    Integer total_time = time_before + time_dr + time_after;
    System.debug('Total Time : ' + total_time);
    Integer total_before_dr =  time_before + time_dr;
    Integer total_after_dr = time_after + time_dr;     
    System.debug('Total Before + dr : ' + total_before_dr);
    System.debug('Total After + dr : ' + total_after_dr);
  	
  	List<Clinical_Search_Inventory__c> possible_apts = [Select 
  	  c.Minutes_before_DR__c, 
  	  c.Minutes_after_DR__c, 
  	  c.Minutes_DR_Avail__c, 
  	  c.Clinical_Doctor_Inventory__c, 
  	  c.Clinical_Apt_Calendar__c,
  	  c.minutes_before_and_dr__c, 
  	  c.minutes_after_and_dr__c, 
  	  c.Total_Minutes__c
  	From 
  	  Clinical_Search_Inventory__c c
  	where 
  	  c.clinical_apt_calendar__r.cr_schedule_block__c in :block_ids
  	  and c.clinical_doctor_inventory__r.user__c in :doctor_ids
  	  and c.clinical_apt_calendar__r.clinical_room__c in :room_ids
  	  and c.clinical_apt_calendar__r.apt_date__c >= :earliest_apt_date
  	  and c.total_minutes__c  >= :total_time
  	  and c.minutes_before_and_dr__c >=  :total_before_dr
  	  and c.minutes_after_and_dr__c >= :total_after_dr
  	  and c.minutes_dr_avail__c >= :time_dr];  	  
  	  
  	System.debug('Possible Options : ' + possible_apts.size());
  	
  	//now I need to build a list of possible times...pass the clinical_apt_calendar_id and clinical_doctor_inventory id also need start time and end time (integer) values?
  	
  	
  } 
  
  public void generate_procedure_form_table_from_load_table() {
  	//map of Office Forms
  	Map<String,Office_Form__c> form_map = new Map<String,Office_Form__c>();
  	for(Office_Form__c ofc : [select id,name from Office_Form__c]) {
  	  form_map.put(ofc.name,ofc);
  	}
  	
  	//Map of Clinical Procedures
  	Map<String,Clinical_Procedure__c> procedure_map = new Map<String,Clinical_Procedure__c>();
  	for(Clinical_Procedure__c cp : [select id,name from Clinical_Procedure__c where center_information__r.name = 'Philadelphia' and isactive__c = true]) {
  	  procedure_map.put(cp.name,cp);
  	}
  	
  	List<Clinical_procedure_Form__c> cpf_list = new List<Clinical_Procedure_Form__c>();
  	for(Clinical_Proc_Form_Loader__c cpfl : [Select c.Procedure_Name__c, c.Form_Name__c From Clinical_Proc_Form_Loader__c c]) {
  	  if(form_map.get(cpfl.form_name__c)==null)
  	    System.debug('Form No Match : ' + cpfl.form_name__c);
  	  if(procedure_map.get(cpfl.procedure_name__c)==null)
  	   System.debug('Procedure No Match : ' + cpfl.procedure_name__c);
  	  Clinical_Procedure_Form__c cpf = new Clinical_procedure_form__c(office_form__c = form_map.get(cpfl.form_name__c).id,
  	    clinical_procedure__c = procedure_map.get(cpfl.procedure_name__c).id);
  	  cpf_list.add(cpf);
  	}
  	
  	//System.debug('Insert size would be : '+ cpf_list.size());
  	insert cpf_list;
  }
  
  public void generate_room_authorization_from_load_table() {
  	//map of clincial rooms - by name
	Map<String,Clinical_Room__c> room_map = new Map<String,Clinical_Room__c>();
	for(Clinical_Room__c cr : [select id,name from Clinical_Room__c where center_information__r.name = 'Denver']) {
	  room_map.put(cr.name,cr);   
	}
	
	//map of clinical apts - by name
	Map<String,Clinical_Appointment__c> apt_map = new Map<String,Clinical_Appointment__c>();
	for(Clinical_Appointment__c ca : [select id,name from Clinical_Appointment__c where center_information__r.name = 'Denver']) {
	   apt_map.put(ca.name,ca);
	}
	
	List<Clinical_Room_Authorized_Apt__c> cra_list = new List<Clinical_Room_Authorized_Apt__c>();
	for(Clinical_Room_Apt_Loader__c cra : [Select c.Room_Name__c, c.Apt_Name__c From Clinical_Room_Apt_Loader__c c]) {
	  Clinical_Room_Authorized_Apt__c c = new Clinical_Room_Authorized_Apt__c(clinical_room__c = room_map.get(cra.room_name__c).id,
	    clinical_appointment__c = apt_map.get(cra.apt_name__c).id);
	  cra_list.add(c);
	}  	    	  
	
	insert cra_list;
  }
  
  public void initial_center_data() {
  	//process to copy initial setup tables from the Unknown (Corporate default setup) to the
  	Center_Information__c new_center = [select id,name from Center_Information__c where name = 'Denver'];  	
  	Center_Information__c initial_center = [select id,name from Center_Information__c where name = 'Unknown'];
  	
  	//copy procedures
  	List<Clinical_Procedure__c> proc_list = [Select c.isactive__c, c.Time_Required__c, c.Procedure_Filter__c, c.Procedure_Description__c, c.Name, c.Markup_Min__c, c.Markup_Max__c, c.Insurance_Fee__c, c.Doctor_Required__c, c.Default_Teeth_Selection__c, c.Cost__c, c.Center_Information__c, c.Assistants_Needed__c, c.Allow_Tooth_Selection__c, c.ADA_Code__c From Clinical_Procedure__c c where center_information__c = :initial_center.id];
  	List<Clinical_Procedure__c> new_proc_list = proc_list.deepClone();
  	for(Clinical_Procedure__c cp : new_proc_list) {
  	  cp.center_information__c = new_center.id;
  	}
  	insert new_proc_list;
  	Map<String,Clinical_Procedure__c> new_proc_map = new Map<String,Clinical_Procedure__c>();
  	for(Clinical_Procedure__c cp : new_proc_list) {
  	  new_proc_map.put(cp.name,cp);
  	}
  	
  	//copy apts
  	List<Clinical_Appointment__c> apt_list = [Select c.isactive__c, c.Padding_Time__c, c.Name, c.Lab_Time__c, c.Id, c.Center_Information__c, c.Appointment_Filter__c, c.Appointment_Description__c From Clinical_Appointment__c c where center_information__c = :initial_center.id];
  	List<Clinical_Appointment__c> new_apt_list = apt_list.deepClone();
  	for(Clinical_Appointment__c ca : new_apt_list) {
  	  ca.center_information__c = new_center.id;
  	}
  	insert new_apt_list;
  	Map<String,Clinical_Appointment__c> new_apt_map = new Map<String,Clinical_Appointment__c>();
  	for(Clinical_Appointment__c ca : new_apt_list) {
  	  new_apt_map.put(ca.name,ca);
  	}
  	
  	//copy apt-procedures
  	List<Clinical_Apt_Procedure__c> apt_proc_list = [Select c.Sort_Order__c, c.Clinical_Procedure__c, c.clinical_procedure__r.name, c.Clinical_Appointment__c, c.clinical_appointment__r.name From Clinical_Apt_Procedure__c c where clinical_appointment__r.center_information__c = :initial_center.id];
  	List<Clinical_Apt_Procedure__c> new_apt_proc_list = apt_proc_list.deepClone();
  	for(Clinical_Apt_Procedure__c cap : new_apt_proc_list) {
      //replace clinical procedure and apt with the matching values in the new center
      cap.clinical_procedure__c = new_proc_map.get(cap.clinical_procedure__r.name).id;
      cap.clinical_appointment__c = new_apt_map.get(cap.clinical_appointment__r.name).id;      
  	}
  	insert new_apt_proc_list;
  	
  	//copy pots
  	/*List<Plan_of_Treatment__c> pot_list = [Select p.isActive__c, p.Upper_Arch__c, p.Treatment_Description__c, p.Name, p.Lower_Arch__c, p.Center_Information__c From Plan_of_Treatment__c p where center_information__c = :initial_center.id];
  	List<Plan_of_treatment__c> new_pot_list = pot_list.deepClone();
  	for(Plan_of_Treatment__c pt : new_pot_list) {
  		pt.center_information__c = new_center.id;
  	}
  	insert new_pot_list;
  	Map<String,Plan_of_Treatment__c> new_pot_map = new Map<String,Plan_of_Treatment__C>();
  	for(Plan_of_Treatment__c pt : new_pot_list) {
  	  new_pot_map.put(pt.name,pt);
  	}
  	   	 
  	//copy pot_apts
  	List<POT_Appointment__c> pa_list = [Select p.Sort_Order__c, p.Plan_of_Treatment__c, p.plan_of_treatment__r.name, p.Days_Out__c, p.Clinical_Appointment__c, p.clinical_appointment__r.name From POT_Appointment__c p where plan_of_treatment__c.center_information__c = :initial_center.id];
  	List<POT_Appointment__c> new_pa_list = pa_list.deepClone();
  	for(POT_Appointment__c pa : new_pa_list) {
  	  //replace plan of treatment and clinical appointment with values for the new center
  	  pa.plan_of_treatment
  	}*/
  	
  }
  
  public void load_pot_apt_data() {
  	//should not be used in production - one off for Philly
  	List<POT_Appointment__c> pdetail_list = new List<POT_Appointment__c>();

    //build a map of philly pot
    Map<String,Plan_of_Treatment__c> philly_pot_map = new Map<String,Plan_of_Treatment__c>();
    for(Plan_of_Treatment__c cp : [select id,name from Plan_of_Treatment__c where center_information__r.name = 'Philadelphia']) {
      philly_pot_map.put(cp.name,cp);
    }

    //build a map of philly apts
    Map<String,Clinical_Appointment__c> philly_apt_map = new Map<String,Clinical_Appointment__c>();
    for(Clinical_Appointment__c ca : [select id,name from Clinical_Appointment__c where center_information__r.name = 'Philadelphia']) {
     philly_apt_map.put(ca.name,ca);
    } 

	//loop through clinic pot apt loader table - switch apt/pot codes with map values
	for(Pot_Apt_Loader__c pal : [Select p.Sort_Order__c, p.POT_name__c, p.Id, p.Days_Out__c, p.Apt_Name__c From POT_Apt_Loader__c p]) {
	  String apt_id = null;
	  String pot_id = null;
	  try {
	    apt_id = philly_apt_map.get(pal.apt_name__c).id;
	  } catch (Exception e) {
	  	System.debug('Map match not found - Apt : ' + pal.apt_name__c);
	    System.debug(e);
	  }
	  try {
	    pot_id = philly_pot_map.get(pal.pot_name__c).id;
	  } catch (Exception e) {
	  	System.debug('Map match not found - POT : ' + pal.pot_name__c);
	    System.debug(e);
	  }
	  try {
	  	POT_Appointment__c pa = new POT_Appointment__c(Clinical_appointment__c = apt_id,
	      Plan_of_Treatment__c = pot_id,
	      Sort_Order__c = pal.sort_order__c,
	      Days_out__c = pal.days_out__c);
	    pdetail_list.add(pa);
	  } catch (Exception e) {
	    System.debug('Other error ' + e);
	  }
	  
	}
	
	//insert new list
	System.debug('Philly List Size : ' + pdetail_list.size());
	insert pdetail_list;			
  }
  
  public void load_apt_proc_data() {
  	//should not be used in production - one off for Philly
  	List<Clinical_Apt_Procedure__c> philly_list = new List<Clinical_Apt_Procedure__c>();

    //build a map of philly procedures
    Map<String,Clinical_Procedure__c> philly_proc_map = new Map<String,Clinical_Procedure__c>();
    for(Clinical_Procedure__c cp : [select id,name from Clinical_Procedure__c where center_information__r.name = 'Philadelphia']) {
      philly_proc_map.put(cp.name,cp);
    }

    //build a map of philly apts
    Map<String,Clinical_Appointment__c> philly_apt_map = new Map<String,Clinical_Appointment__c>();
    for(Clinical_Appointment__c ca : [select id,name from Clinical_Appointment__c where center_information__r.name = 'Philadelphia']) {
     philly_apt_map.put(ca.name,ca);
    } 

	//loop through clinic apt proc loader table - switch apt/proc codes with map values
	for(Clinical_Apt_proc_Loader__c capl : [Select c.Sort_Order__c, c.Proc_Name__c, c.Apt_Name__c From Clinical_Apt_Proc_Loader__c c]) {
	  String apt_id = null;
	  String proc_id = null;
	  Boolean create_step = true;
	  try {
	    apt_id = philly_apt_map.get(capl.apt_name__c).id;
	  } catch (Exception e) {
	  	System.debug('Map match not found - Apt : ' + capl.apt_name__c);
	    System.debug(e);
	    create_step = false;
	  }
	  try {
	    proc_id = philly_proc_map.get(capl.proc_name__c).id;
	  } catch (Exception e) {
	  	System.debug('Map match not found - Procedure : ' + capl.proc_name__c);
	    System.debug(e);
	    create_step = false;
	  }
	  try {
	  	if(create_step) {
	      Clinical_Apt_Procedure__c cap = new Clinical_Apt_procedure__c(Clinical_appointment__c = apt_id,
	        Clinical_Procedure__c = proc_id,
	        Sort_Order__c = capl.sort_order__c);
	      philly_list.add(cap);
	  	}
	  } catch (Exception e) {
	    System.debug('Other error ' + e);
	  }
	  
	}
	
	//insert new list
	System.debug('Philly List Size : ' + philly_list.size());
	insert philly_list;			
  }
  
  public class wu_full_response {
  	public wu_response_detail response;
  	public wu_forecast_full forecast;
  	
  	public wu_full_response() {}
  }
  
  public class wu_forecast_full {
  	public wu_forecast_text txt_forecast;
  	public wu_simple_forecastday simpleforecast;
  	
  	public wu_forecast_full() {}
  }
  
  public class wu_simple_forecastday {
  	public List<wu_simple_forecastday_detail> forecastday;
  	
  	public wu_simple_forecastday() {}
  }
  
  public class wu_simple_forecastday_detail {
  	public Map<String,String> fdate;
  	public Integer period;
  	public Map<String,String> high;
  	public Map<String,String> low;
  	public String conditions;
  	public String icon;
  	public String icon_url;
  	public String skyicon;
  	public Integer pop;
  	public Map<String,String> qpf_allday;
  	public Map<String,String> qpf_day;
  	public Map<String,String> qpf_night;
  	public Map<String,String> snow_allday;
  	public Map<String,String> snow_day;
  	public Map<String,String> snow_night;
  	public Map<String,String> maxwind;
  	public Map<String,String> avewind;
  	public Decimal avehumidity;
  	public Decimal maxhumidity;
  	public Decimal minhumidity;
  	
  	public wu_simple_forecastday_detail() {}
  }
  
  public class wu_forecast_text {
  	public String fdate;
  	public List<wu_forecastday> forecastday;
  	
  	public wu_forecast_text() {}
  }
  
  public class wu_forecastday {
  	public Integer period;
  	public String icon;
  	public String icon_url;
  	public String title;
  	public String fcttext;
  	public String fcttext_metric;
  	public String pop;
  	public wu_forecastday() {}
  }
  
  
  
  public class wu_response_detail {
  	public String version;
  	public String termsofService;
  	public Map<String,String> features;
  	  
  	public wu_response_detail() {} 
  }
  
  public void wu_test() {
  	HttpRequest req = new HttpRequest();
  	HttpResponse res = new HttpResponse();
    Http http = new Http();
    
    Center_Information__c load_center = [select id,name,zip_code__c from Center_Information__c where name = 'Denver'];
    
    //Production
    req.setEndpoint('http://api.wunderground.com/api/56a44de3711b6b71/forecast/q/' + load_center.zip_code__c + '.json');
    req.setTimeout(60000);
    req.setMethod('GET');
    
    try {
      res = http.send(req);
      System.debug('Response Status ' + res.getStatusCode());
      System.debug('Response Body ' + res.getBody());
      System.debug('Response Code : ' + res.getStatusCode());
                
	  String sample_response = res.getBody();
       	
  	/*String sample_response = '{' +
      '"response": {' +
        '"version": "0.1",' +
        '"termsofService": "http://www.wunderground.com/weather/api/d/terms.html",' +
        '"features": {' +
          '"forecast": 1' +
        '}' +
      '},' +
      '"forecast": {' +
        '"txt_forecast": {' +
          '"date": "2:00 PM PDT",' +
          '"forecastday": [{' +
            '"period": 0,' +
            '"icon": "partlycloudy",' +
            '"icon_url": "http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",' +
            '"title": "Tuesday",' +
            '"fcttext": "Partly cloudy in the morning, then clear. High of 68F. Breezy. Winds from the West at 10 to 25 mph.",' +
            '"fcttext_metric": "Partly cloudy in the morning, then clear. High of 20C. Windy. Winds from the West at 20 to 35 km/h.",' +
            '"pop": "0"' +
            '}, {' +
            '"period": 7,' +
            '"icon": "partlycloudy",' +
            '"icon_url": "http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",' +
            '"title": "Friday Night",' +
            '"fcttext": "Mostly cloudy. Fog overnight. Low of 52F. Winds from the West at 5 to 10 mph.",' +
            '"fcttext_metric": "Mostly cloudy. Fog overnight. Low of 11C. Winds from the West at 10 to 15 km/h.",' +
            '"pop": "0"' + 
          '}]' +
        '},' +
        '"simpleforecast": {' +
          '"forecastday": [{' +
            '"date": {' +
              '"epoch": "1340776800",' +
              '"pretty": "11:00 PM PDT on June 26, 2012",' +
              '"day": 26,' +
              '"month": 6,' +
              '"year": 2012,' +
              '"yday": 177,' +
              '"hour": 23,' +
              '"min": "00",' +
              '"sec": 0,' +
              '"isdst": "1",' +
              '"monthname": "June",' +
              '"weekday_short": "Tue",' +
              '"weekday": "Tuesday",' +
              '"ampm": "PM",' +
              '"tz_short": "PDT",' +
              '"tz_long": "America/Los_Angeles"' +
            '},' +
            '"period": 1,' +
            '"high": {' +
              '"fahrenheit": "68",' +
              '"celsius": "20"' +
            '},' +
            '"low": {' +
              '"fahrenheit": "50",' +
              '"celsius": "10"' +
            '},' +
            '"conditions": "Partly Cloudy",' +
            '"icon": "partlycloudy",' +
            '"icon_url": "http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",' +
            '"skyicon": "mostlysunny",' +
            '"pop": 0,' +
            '"qpf_allday": {' +
              '"in": 0.00,' +
              '"mm": 0.0' +
            '},' +
            '"qpf_day": {' +
              '"in": 0.00,' +
              '"mm": 0.0' +
            '},' +
            '"qpf_night": {' +
              '"in": 0.00,' +
              '"mm": 0.0' +
            '},' +
            '"snow_allday": {' +
              '"in": 0,' +
              '"cm": 0' +
            '},' +
            '"snow_day": {' +
              '"in": 0,' +
              '"cm": 0' +
            '},' +
            '"snow_night": {' +
              '"in": 0,' +
              '"cm": 0' +
            '},' +
            '"maxwind": {' +
              '"mph": 21,' +
              '"kph": 34,' +
              '"dir": "West",' +
              '"degrees": 272' +
            '},' +
            '"avewind": {' +
              '"mph": 17,' +
              '"kph": 27,' +
              '"dir": "West",' +
              '"degrees": 272' +
            '},' +
            '"avehumidity": 72,' +
            '"maxhumidity": 94,' +
            '"minhumidity": 58' +
          '}, {' +
            '"date": {' +
              '"epoch": "1340863200",' +
              '"pretty": "11:00 PM PDT on June 27, 2012",' +
              '"day": 27,' +
              '"month": 6,' +
              '"year": 2012,' +
              '"yday": 178,' + 
              '"hour": 23,' +
              '"min": "00",' +
              '"sec": 0,' +
              '"isdst": "1",' +
              '"monthname": "June",' +
              '"weekday_short": "Wed",' +
              '"weekday": "Wednesday",' +
              '"ampm": "PM",' +
              '"tz_short": "PDT",' +
              '"tz_long": "America/Los_Angeles"' +
            '},' +
            '"period": 2,' +
            '"high": {' +
              '"fahrenheit": "72",' +
              '"celsius": "22"' +
            '},' +
            '"low": {' +
              '"fahrenheit": "54",' +
              '"celsius": "12"' +
            '},' +
            '"conditions": "Partly Cloudy",' +
            '"icon": "partlycloudy",' +
            '"icon_url": "http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",' +
            '"skyicon": "mostlysunny",' +
            '"pop": 0,' +
            '"qpf_allday": {' +
              '"in": 0.00,' +
              '"mm": 0.0' +
            '},' +
            '"qpf_day": {' +
              '"in": 0.00,' +
              '"mm": 0.0' +
            '},' +
            '"qpf_night": {' +
              '"in": 0.00,' +
              '"mm": 0.0' +
            '},' +
            '"snow_allday": {' +
              '"in": 0,' +
              '"cm": 0' +
            '},' +
            '"snow_day": {' +
              '"in": 0,' +
              '"cm": 0' +
            '},' +
            '"snow_night": {' +
              '"in": 0,' +
              '"cm": 0' +
            '},' +
            '"maxwind": {' +
              '"mph": 11,' +
              '"kph": 18,' +
              '"dir": "WSW",' +
              '"degrees": 255' +
            '},' +
            '"avewind": {' +
              '"mph": 9,' +
              '"kph": 14,' +
              '"dir": "WSW",' +
              '"degrees": 252' +
            '},' +
            '"avehumidity": 70,' +
            '"maxhumidity": 84,' +
            '"minhumidity": 54' +
          '}]' +
        '}' +
      '}' +
    '}';*/ 
    
    sample_response = sample_response.replace('"date"','"fdate"');
    
    //Type resultType = Type.forName('wu_response');
    wu_full_response deserializeResults = (wu_full_response)JSON.deserialize(sample_response, wu_full_response.class);
    System.debug('==========> deserialize() results = ' + deserializeResults); 
    System.debug('Features test : ' + deserializeResults.response.features.get('forecast'));
    System.debug('Forecast day : ' + deserializeResults.forecast);
    System.debug('S Forecast day : ' + deserializeResults.forecast.simpleforecast);
    System.debug('S Forecast day 0 : ' + deserializeResults.forecast.simpleforecast.forecastday[0]);
    System.debug('S Forecast day 1: ' + deserializeResults.forecast.simpleforecast.forecastday[1]);
    System.debug('JSON forecast day 1 : ' + JSON.serialize(deserializeResults.forecast.simpleforecast.forecastday[1]));
    System.debug('JSON length : ' + JSON.serialize(deserializeResults.forecast.simpleforecast.forecastday[1]).length());
    //test weather record insert
    List<Weather__c> weather_list = new List<Weather__c>();
    //System.debug('Type : ' + deserializeResults.forecast.simpleforecast);
    for(wu_simple_forecastday_detail forecast : deserializeResults.forecast.simpleforecast.forecastday) {
      Date cdate = Date.newinstance(Integer.valueof(forecast.fdate.get('year')),Integer.valueof(forecast.fdate.get('month')),Integer.valueof(forecast.fdate.get('day')));
      String dtype = '';
      if(cdate < System.today())
        dtype = 'Past';
      else if(cdate == System.today())
        dtype = 'Current';
      else 
        dtype = 'Forecast'; 	
      Weather__c wrecord = new Weather__c(center_information__c = load_center.id, calendar_date__c = cdate,
        data_type__c = dtype, json_data__c = JSON.serialize(forecast), temp_high__c = decimal.valueof(forecast.high.get('fahrenheit')),
        temp_low__c= decimal.valueof(forecast.low.get('fahrenheit')), conditions__c = forecast.conditions, icon__c = forecast.icon,
        icon_url__c = forecast.icon_url, pop__c = forecast.pop, qpf_allday__c = decimal.valueof(forecast.qpf_allday.get('in')),
        qpf_night__c = decimal.valueof(forecast.qpf_night.get('in')), qpf_day__c = decimal.valueof(forecast.qpf_day.get('in')), snow_day__c = decimal.valueof(forecast.snow_day.get('in')),
        snow_allday__c = decimal.valueof(forecast.snow_allday.get('in')), snow_night__c = decimal.valueof(forecast.snow_night.get('in')), max_wind__c = decimal.valueof(forecast.maxwind.get('mph')),
        avg_wind__c = decimal.valueof(forecast.avewind.get('mph')), max_humidity__c = forecast.maxhumidity, min_humidity__c = forecast.minhumidity);
      weather_list.add(wrecord);
      System.debug('Weather Record : ' + wrecord);
    }
    insert weather_list;
    } catch (Exception e) {
    	System.debug(e);
    }
  }
  
  public void clear_center_data() {
  	try {
  	  //select the center to clear data and load for
  	  String target_center_name = 'Unknown';  	  
  	  Center_Information__c load_center = [select id,name from Center_Information__c where name = :target_center_name];
  	  //might want to clear existing calendar data for the center if I've played around with it
  	  //clinical search inventory
  	  //clinical doctor inventory
  	  //clinical apt calendar
  	  
  	  //might need to clear patient pot tables as well
  	  List<Patient_POT__c> pot_list = [select id from Patient_POT__c where account__r.center__r.name = :target_center_name];
  	  Map<ID,Patient_POT__c> pmap = new Map<ID,Patient_POT__c>(pot_list);
  	  
  	  List<Patient_POT_Apt__c> ppa_list = [select id from Patient_Pot_Apt__c where patient_pot__c in :pmap.keyset()];
  	  Map<ID,Patient_POT_Apt__c> ppmap = new Map<ID,Patient_POT_Apt__c>(ppa_list);
  	  
  	  List<Patient_POT_Apt_Procedure__c> ppap_list = [select id from Patient_Pot_Apt_Procedure__c where patient_pot_apt__c in :ppmap.keyset()];
  	  delete ppap_list;
  	  delete ppa_list;
  	  delete pot_list;
  	  
  	
  	  //delete pot_apts
  	  List<POT_Appointment__c> pa_list = [Select p.Plan_of_Treatment__c, p.Name, p.Id, p.Clinical_Appointment__c 
  	    From POT_Appointment__c p where plan_of_treatment__r.center_information__c = :load_center.id];
  	  delete pa_list;
  	  	
  	  //delete pots
  	  List<Plan_of_Treatment__c> plist = [Select p.Name, p.id, p.Cloned_Plan_of_Treatment__c, p.Center_Information__c From Plan_of_Treatment__c p
  	    where center_information__c = :load_center.id];
  	  delete plist;
  	
  	  //delete apt_procedure
  	  List<Clinical_Apt_Procedure__c> cap_list = [Select c.id, c.Name, c.Clinical_Procedure__c, c.Clinical_Appointment__c From Clinical_Apt_Procedure__c c
  	    where clinical_appointment__r.center_information__c = :load_center.id and clinical_procedure__r.center_information__c = :load_center.id];
  	  delete cap_list;
  	
  	  //delete room authorized apts
  	  List<Clinical_Room_Authorized_Apt__c> cra_list = [Select c.id, c.Clinical_Room__c, c.Clinical_Appointment__c From Clinical_Room_Authorized_Apt__c c where
  	    clinical_appointment__r.center_information__c = :load_center.id and clinical_room__r.center_information__c = :load_center.id];
  	  delete cra_list;
  	
  	  //delete room schedule block authorized apts
  	  List<CR_Sched_Block_Authorized_Apt__c> csb_list = [Select c.SystemModstamp, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Clinical_Appointment__c, c.CR_Schedule_Block__c From CR_Sched_Block_Authorized_Apt__c c where
        clinical_appointment__r.center_information__c = :load_center.id];
      delete csb_list;
     
  	  //delete apts
  	  List<Clinical_Appointment__c> ca_list = [Select c.Id, c.Center_Information__c From Clinical_Appointment__c c where center_information__c = :load_center.id];
  	  delete ca_list;
  	
  	  //delete procedures
  	  List<Clinical_Procedure__c> cp_list = [Select c.Name,  c.Id,  c.Center_Information__c From Clinical_Procedure__c c where center_information__c = :load_center.id];
  	  delete cp_list;
  	
  	  //delete room blocks
  	  List<CR_Schedule_Block__c> csbc_list = [Select  c.Id,  c.Clinical_Room__c From CR_Schedule_Block__c c where clinical_room__r.center_information__c = :load_center.id];
  	  delete csbc_list;  	  
  	
  	  //delete rooms
  	  List<Clinical_Room__c> cr_list = [select id from Clinical_Room__c where center_information__c = :load_center.id];
  	  delete cr_list;
  	    	 
  	} catch (Exception e) {
  	  
  	}
  	
  }
  
  public void test_maintain_sched_build_out() {
  	//pull a list of centers that need HopeRx inventory maintained
  	List<Center_Information__c> center_list = [Select c.id, c.name, c.Maintain_HopeRX_Inventory__c, c.Days_Out_HopeRX__c, c.Last_HopeRx_Inventory_Check__c 
  	  From Center_Information__c c where maintain_hoperx_inventory__c = true order by c.Last_HopeRx_Inventory_Check__c];
  	
  	//pull a map of current inventory for all centers in HopeRx
  	Map<String,Integer> map_center_inventory_days = new Map<String,Integer> ();
  	for(AggregateResult ar : [select clinical_room__r.center_information__c cid,max(apt_date__c) max_date from clinical_apt_calendar__c group by clinical_room__r.center_information__c]) {
  	  Integer days_built_out = 0;
  	  if((Date)ar.get('max_date')!=null) {
  	    Date max_apt = (Date)ar.get('max_date');
  	    days_built_out = System.today().daysBetween(max_apt); 
  	  } 
  	  map_center_inventory_days.put((String)ar.get('cid'),days_built_out);
  	}
  	
  	Integer num_builds = 1;
  	
  	//test here
  	for(Center_Information__c ci : center_list) {
  	  System.debug('Center : ' + ci.name + ' Desired build out : ' + ci.days_out_hoperx__c);
  	  System.debug('Current build out : ' + map_center_inventory_days.get(ci.id));
  	  if(map_center_inventory_days.get(ci.id) < ci.days_out_hoperx__c) {
  	    System.debug('Run Inventory builder - start date : ' + System.today().adddays(map_center_inventory_days.get(ci.id) + 1) + ' days to build ' + (ci.days_out_hoperx__c - map_center_inventory_days.get(ci.id)));
  	    Clinical_Inventory_Builder nclass = new Clinical_inventory_builder();
        nclass.center_name = ci.name;
        nclass.num_days = 1;
        //nclass.num_days = (ci.days_out_hoperx__c - map_center_inventory_days.get(ci.id) - 1);
        nclass.work_day = System.today().adddays(map_center_inventory_days.get(ci.id) + 1);
        nclass.temp_holder();
        ci.last_hoperx_inventory_check__c = System.now();
        num_builds++;
        //limit the number of build outs in one call to 2
        if(num_builds>2)
          break;
  	  }
  	}
  	
  	update center_list;  	
  }
  
  public class TestDynamicClass {
	public String tvar1;
	public String tvar2;
    
    public TestDynamicClass() {
      tvar1 = 'This is var 1';
      tvar2 = 'This is var 2';
    }    
    
	public Object getAttByName(String attributename) {
	    String s = JSON.serialize(this);
	    Map<String,Object> obj = (Map<String,Object>) JSON.deserializeUntyped(s);
	    return obj.get(attributename);    
	}
	
  }
    
  public void run_test_dynamic() {
	TestDynamicClass tdc = new TestDynamicClass();
	System.debug('Tvar1 ' + String.valueof(tdc.getAttbyName('tvar1')));
	System.debug('Tvar2 ' + String.valueof(tdc.getAttbyName('tvar2')));  	
  }

}