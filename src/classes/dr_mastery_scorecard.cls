public with sharing class dr_mastery_scorecard {
      
  static User uinfo = [select id,name,profile.name from User where id = :userinfo.getuserid()];
  static Set<String> admin_profiles = new Set<String> {'System Administrator','RBD'};
  static Set<String> doctor_profiles = new Set<String> {'Clinical Doctor','SF - Clinical Doctor'};
  
  Map<String,Doctor_Mastery_Threshold__c> threshold_map;
  
  public Boolean getis_admin() {return admin_profiles.contains(uinfo.profile.name);}
  public Boolean getis_doctor() {return doctor_profiles.contains(uinfo.profile.name);}
  
  public String scorecard_user {get; set;}
  public Integer current_month {get;set;}
  public Integer current_year {get;set;}
  
  public List<scorecard_line> scorecard_data {get; set;}
  public mastery_scorecard scorecard {get;set;}
  
  public dr_mastery_scorecard() {
    //is user a doctor
    if(getis_doctor())
      scorecard_user = uinfo.id;
    else
      scorecard_user = 'NA';
    current_month = System.today().month();
    current_year = System.today().year();
    threshold_map = new Map<String,Doctor_Mastery_Threshold__c>();
    for(Doctor_Mastery_Threshold__c thresh : [select id,name,distance_to_associate__c,distance_to_fellow__c,distance_to_diplomate__c,distance_to_clinical_director__c,threshold_direction__c
      from Doctor_Mastery_Threshold__c]) {
      threshold_map.put(thresh.name,thresh); 
    }
    scorecard_data = new List<scorecard_line>();
  }
  
  public String getscorecard_name() {
  	if(scorecard_user=='NA')
  	  return 'NA';
  	else
  	  return [select name from user where id = :scorecard_user].name;
  }
  
  //method to pull a select list for all doctors with a scorecard during this period of time
  public List<Selectoption> getuser_option_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('NA','Select Doctor'));
  	for(Doctor_Mastery_User_Snapshot__c usnap : [select clearchoice_doctor__c,clearchoice_doctor__r.name from Doctor_Mastery_User_Snapshot__c 
  	  where month__c = :current_month and year__c = :current_year order by clearchoice_doctor__r.name ]) {
  	  clist.add(new Selectoption(usnap.clearchoice_doctor__c,usnap.clearchoice_doctor__r.name)); 
  	}
  	return clist;
  }  
  
  //method to pull a list of months with scorecards
  public List<Selectoption> getmonth_option_list() {
  	List<Selectoption> clist = new List<Selectoption>();
    if(scorecard_user!='NA') {
  	  for(Doctor_Mastery_User_Snapshot__c csnap : [select month__c from Doctor_Mastery_User_Snapshot__c 
  	    where clearchoice_doctor__c = :scorecard_user and year__c = :current_year  order by month__c]) {
  	      Integer ar_month = csnap.month__c.intvalue();	  
  	      clist.add(new SelectOption(String.valueof(ar_month),Datetime.newinstance(current_year,ar_month,1).format('MMMM')));
  	  }
    } else {
      Set<Integer> query_month = new Set<Integer>(); 
  	  for(Doctor_Mastery_User_Snapshot__c csnap : [select month__c from Doctor_Mastery_User_Snapshot__c where year__c = :current_year order by month__c]) {
  	    if(!query_month.contains(csnap.month__c.intvalue())) {
  	      Integer ar_month = csnap.month__c.intvalue();	  
  	      clist.add(new SelectOption(String.valueof(ar_month),Datetime.newinstance(current_year,ar_month,1).format('MMMM')));
  	      query_month.add(csnap.month__c.intvalue());
  	    }
  	  }	
    }
	return clist;
  }  
  
  //method to pull a list of years with scorecards
  public List<SelectOption> getyear_option_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	for(Integer syear=2018;syear<=current_year;syear++) {
  	  clist.add(new SelectOption(String.valueof(syear),String.valueof(syear)));
  	}
	return clist;
  }
    
  //method to refresh scorecard info
  public void refresh_scorecard() {
  	//grab the snapshots for this user and month/year combo
  	Doctor_Mastery_User_Snapshot__c usnap;
  	if(scorecard_user!='NA') {   	
  	  try {
  	    usnap = [select id,Total_Arches_Delivered__c, Tenure_Years__c, Doctor_Mastery_Center_Snapshot__c, CCE_Credits__c, Battlegroup_Stars__c,
  	      Doctor_Mastery_Center_Snapshot__r.Surgical_Backlog_Days__c, Doctor_Mastery_Center_Snapshot__r.NPS_Score__c, Doctor_Mastery_Center_Snapshot__r.Leadership_Impact_Assessment__c, 
  	      Doctor_Mastery_Center_Snapshot__r.Ideal_Week_Certified__c, Doctor_Mastery_Center_Snapshot__r.Gross_Margin__c, Doctor_Mastery_Center_Snapshot__r.center_information__r.name 
  	      from Doctor_Mastery_User_Snapshot__c 
  	      where clearchoice_doctor__c = :scorecard_user and month__c = :current_month and year__c = :current_year];
  	    //Doctor_Mastery_Center_Snapshot__c csnap = [select id from Doctor_Mastery_Center_Snapshot__c where ];
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error retrieving scorecard info for this user'));
	    ApexPages.addMessages(e);  	  	
  	  }
  	  //build the lines for scorecard
  	  scorecard_data = new List<scorecard_line>();
  	  //generate our reporting lines
  	  scorecard_data.add(new scorecard_line('CCEs total hours',usnap.cce_credits__c,threshold_map.get('CCE Hours')));
  	  scorecard_data.add(new scorecard_line('Arches',usnap.total_arches_delivered__c,threshold_map.get('Arches Delivered')));
  	  scorecard_data.add(new scorecard_line('Service Years',usnap.tenure_years__c,threshold_map.get('Service Years')));
  	  scorecard_data.add(new scorecard_line('Gross Margin',usnap.doctor_mastery_center_snapshot__r.gross_margin__c,threshold_map.get('Gross Margin')));
  	  scorecard_data.add(new scorecard_line('Surgical Backlog',usnap.doctor_mastery_center_snapshot__r.surgical_backlog_days__c,threshold_map.get('Surgical Backlog')));
  	  scorecard_data.add(new scorecard_line('Battlegroup',usnap.battlegroup_stars__c,threshold_map.get('Battlegroup Stars')));
  	  scorecard_data.add(new scorecard_line('Net Promoter Score',usnap.battlegroup_stars__c,threshold_map.get('NPS')));  	
  	  scorecard = new mastery_scorecard(scorecard_data,usnap);    	  
  	}
  }
  
  public class mastery_scorecard {  	
  	public List<scorecard_line> scorecard_lines {get;set;}  	
  	//public String cce_mastery_level {get;set;}
  	private Map<Integer,String> mastery_text_map {get;set;}
    private Map<String,scorecard_line> score_map {get;set;}
    public Doctor_Mastery_User_Snapshot__c user_snap {get;set;}
    public Map<Integer,Map<String,List<String>>> next_steps {get;set;}
    public Integer cce_mastery_level;
    public Integer network_mastery_level;
    public Integer coe_mastery_level;
    
  	public mastery_scorecard(List<scorecard_line> slines,Doctor_Mastery_User_Snapshot__c usnap) {
  	  mastery_text_map = new Map<Integer,String>();
  	  mastery_text_map.put(0,'None');
  	  mastery_text_map.put(1,'Associate');
  	  mastery_text_map.put(2,'Fellow');
  	  mastery_text_map.put(3,'Diplomate');
  	  mastery_text_map.put(4,'Clinical Director');
  	  this.scorecard_lines = slines;
  	  score_map = new Map<String,scorecard_line> ();
  	  for(scorecard_line sc : slines) {
  	  	score_map.put(sc.line_name,sc);
  	  }
  	  this.user_snap = usnap;
  	  next_steps = new Map<Integer,Map<String,List<String>>> ();
  	  next_steps.put(1,new Map<String,List<String>>());
  	  next_steps.put(2,new Map<String,List<String>>());
  	  next_steps.put(3,new Map<String,List<String>>());
  	  next_steps.put(4,new Map<String,List<String>>());
  	  calculate_cce_mastery_level();
  	  calculate_in_network_mastery_level();
  	  calculate_coe_mastery_level();
  	}
  	
  	public void calculate_cce_mastery_level() {  	  
  	  cce_mastery_level = 0;
  	  scorecard_line cce_line = score_map.get('CCEs total hours');
  	  if(cce_line.getachieved_associate()) 
  	  	cce_mastery_level = 1;
  	  else {
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('CCE',new List<String> {'Complete ' + cce_line.getassociate_distance() + ' more education credits'});
  	  	next_steps.get(1).putall(nsteps);
  	  }
  	  if(cce_line.getachieved_fellow()) 
  	  	cce_mastery_level = 2;
  	  else {
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('CCE',new List<String> {'Complete ' + cce_line.getfellow_distance() + ' more education credits'});
  	  	next_steps.get(2).putall(nsteps);
  	  }
  	  if(cce_line.getachieved_diplomate()) 
  	  	cce_mastery_level = 3;
  	  else {
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('CCE',new List<String> {'Complete ' + cce_line.getdiplomate_distance() + ' more education credits'});
  	  	next_steps.get(3).putall(nsteps);
  	  }
  	  if(cce_line.getachieved_director()) 
  	  	cce_mastery_level = 4;
  	  else {
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('CCE',new List<String> {'Complete ' + cce_line.getdirector_distance() + ' more education credits'});
  	  	next_steps.get(4).putall(nsteps);
  	  }  	    	     	  
  	}
  	
  	public String getcce_mastery_level_text() {return mastery_text_map.get(cce_mastery_level);}
  	
  	public void calculate_in_network_mastery_level() {  	  
  	  network_mastery_level = 0;
  	  scorecard_line service_line = score_map.get('Service Years');
  	  scorecard_line arches_line = score_map.get('Arches');  	  
  	  if(service_line.getachieved_associate() || arches_line.getachieved_associate())
  	    network_mastery_level = 1;
  	  else {  	  	
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('In Network',New List<String>());
  	  	if(!service_line.getachieved_associate())
  	  	  nsteps.get('In Network').add('Continue to work for Clearchoice for ' + service_line.getassociate_distance() + ' days');
  	  	if(!arches_line.getachieved_associate())
  	  	  nsteps.get('In Network').add('Deliver ' + arches_line.getassociate_distance() + ' more arches');
  	  	next_steps.get(1).putall(nsteps);
  	  }
  	  if(service_line.getachieved_fellow() || arches_line.getachieved_fellow()) 
  	    network_mastery_level = 2;
  	  else {  	  	
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('In Network',New List<String>());
  	  	if(!service_line.getachieved_fellow())
  	  	  nsteps.get('In Network').add('Continue to work for Clearchoice for ' + service_line.getfellow_distance() + ' days');
  	  	if(!arches_line.getachieved_fellow())
  	  	  nsteps.get('In Network').add('Deliver ' + arches_line.getfellow_distance() + ' more arches');
  	  	next_steps.get(2).putall(nsteps);
  	  }
  	  if(service_line.getachieved_diplomate() || arches_line.getachieved_diplomate())
  	    network_mastery_level = 3;
  	  else {  	  	
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('In Network',New List<String>());
  	  	if(!service_line.getachieved_diplomate())
  	  	  nsteps.get('In Network').add('Continue to work for Clearchoice for ' + service_line.getdiplomate_distance() + ' days');
  	  	if(!arches_line.getachieved_diplomate())
  	  	  nsteps.get('In Network').add('Deliver ' + arches_line.getdiplomate_distance() + ' more arches');
  	  	next_steps.get(1).putall(nsteps);
  	  }
  	  if(service_line.getachieved_director() || arches_line.getachieved_director())
  	    network_mastery_level = 4;
  	  else {  	  	
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('In Network',New List<String>());
  	  	if(!service_line.getachieved_director())
  	  	  nsteps.get('In Network').add('Continue to work for Clearchoice for ' + service_line.getdirector_distance() + ' days');
  	  	if(!arches_line.getachieved_director())
  	  	  nsteps.get('In Network').add('Deliver ' + arches_line.getdirector_distance() + ' more arches');
  	  	next_steps.get(1).putall(nsteps);
  	  }
  	}
  	
  	public String getin_network_mastery_text() {return mastery_text_map.get(network_mastery_level);}
  	
  	public void calculate_coe_mastery_level() { 
  	  coe_mastery_level = 0;
  	  scorecard_line nps_line = score_map.get('Net Promoter Score');
  	  scorecard_line backlog_line = score_map.get('Surgical Backlog');
  	  scorecard_line margin_line = score_map.get('Gross Margin');
  	  scorecard_line battle_line = score_map.get('Battlegroup');
  	  if(nps_line.getachieved_associate() && backlog_line.getachieved_associate() && margin_line.getachieved_associate() && battle_line.getachieved_associate())
  	    coe_mastery_level = 1;
  	  if(nps_line.getachieved_fellow() && backlog_line.getachieved_fellow() && margin_line.getachieved_fellow() && battle_line.getachieved_fellow())
  	    coe_mastery_level = 2;
  	  if(nps_line.getachieved_diplomate() && backlog_line.getachieved_diplomate() && margin_line.getachieved_diplomate() && battle_line.getachieved_diplomate() && user_snap.Doctor_Mastery_Center_Snapshot__r.ideal_week_certified__c)
  	    coe_mastery_level = 3;
  	  if(nps_line.getachieved_director() && backlog_line.getachieved_director() && margin_line.getachieved_director() && battle_line.getachieved_director())
  	    coe_mastery_level = 4;
  	}
  	
  	public String getcoe_mastery_text() {return mastery_text_map.get(coe_mastery_level);}
  	
  	public Integer getoverall_mastery_level() {
  	  Integer olevel = 0;
  	  if(cce_mastery_level >= 1 && network_mastery_level >= 1 && coe_mastery_level >= 1)
  	    olevel = 1;
  	  if(cce_mastery_level >= 2 && network_mastery_level >= 2 && coe_mastery_level >= 2)
  	    olevel = 2;
  	  if(cce_mastery_level >= 3 && network_mastery_level >= 3 && coe_mastery_level >= 3)
  	    olevel = 3;
  	  if(cce_mastery_level >= 4 && network_mastery_level >= 4 && coe_mastery_level >= 4)
  	    olevel = 4;
  	  return olevel;
  	}
  	
  	public String getoverall_mastery_text() {return mastery_text_map.get(getoverall_mastery_level());}  	
  }
  
  
  //class with threshold stuff?
  public class scorecard_line {
  	public String line_name {get;set;}
  	public Decimal line_value {get;set;}
  	public Doctor_Mastery_Threshold__c thresholds {get;set;}
  	
  	public scorecard_line(String lname,Decimal val,Doctor_Mastery_Threshold__c goals) {
  	  this.line_name = lname;
  	  this.line_value = val;
  	  this.thresholds = goals;
  	}
  	
  	public Boolean greater_than_check(Decimal threshold_value) {
  	  if(line_value>=threshold_value)
  	    return true;
  	  else 
  	    return false;
  	}
  	
  	public Boolean less_than_check(Decimal threshold_value) {
  	  if(line_value<=threshold_value)
  	    return true;
  	  else 
  	    return false;
  	}
  	
  	public Boolean getachieved_associate() {
  	  if(thresholds.threshold_direction__c=='greater than')
  	    return greater_than_check(thresholds.distance_to_associate__c);
  	  else
  	    return less_than_check(thresholds.distance_to_associate__c);	
  	}  	  	
  	
  	public Boolean getachieved_fellow() {
      if(thresholds.threshold_direction__c=='greater than')
  	    return greater_than_check(thresholds.distance_to_fellow__c);
  	  else
  	    return less_than_check(thresholds.distance_to_fellow__c);
  	}
  	
  	public Boolean getachieved_diplomate() {
  	  if(thresholds.threshold_direction__c=='greater than')
  	    return greater_than_check(thresholds.distance_to_diplomate__c);
  	  else
  	    return less_than_check(thresholds.distance_to_diplomate__c);	
  	}
  	
  	public Boolean getachieved_director() {
  	  if(thresholds.threshold_direction__c=='greater than')
  	    return greater_than_check(thresholds.distance_to_clinical_director__c);
  	  else
  	    return less_than_check(thresholds.distance_to_clinical_director__c);
  	}
  	
  	public Decimal getthreshold_distance(Decimal tvalue) {
  	  if(thresholds.threshold_direction__c=='greater than')
  	    return tvalue - line_value;
  	  else
  	    return line_value - tvalue;
  	}
  	
  	public Decimal getassociate_distance() {
  	  return getthreshold_distance(thresholds.distance_to_associate__c);
  	}
  	
  	public Decimal getfellow_distance() {
  	  return getthreshold_distance(thresholds.distance_to_fellow__c);
  	}
  	
  	public Decimal getdiplomate_distance() {
  	  return getthreshold_distance(thresholds.distance_to_diplomate__c);
  	}
  	
  	public Decimal getdirector_distance() {
  	  return getthreshold_distance(thresholds.distance_to_clinical_director__c);
  	}  	  	
  }
    
}