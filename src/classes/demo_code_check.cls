/* DoctorMasterySnapshot.cls */

/**
*	@author  MArmani
*	@date    Mar 7, 2018
*	@company ClearChoice Management Services, LLC
*	@purpose Insert records into the Doctor_Mastery_Center_Snapshot and Doctor_Mastery_User_Snapshot tables
**/
public with sharing class demo_code_check {
    
    List<Doctor_Mastery_Center_Snapshot__c> doctorMasteryCenterSnapshots;
    List<Doctor_Mastery_User_Snapshot__c>   doctorMasteryUserSnapshots;
    
    
    // TODO: Create map<center_id, Decimal> NPS_Scores (NET PROMOTER SCORE) - these come from Opportunities
    // NPS = % of Promoters(9s and 10s) -% of Detractors(0s-6s);
    //public DoctorMasterySnapshot(){}
	
	
	public void test_here() {
		Map<String, NetPromoterScoreCalculator> nps_map = new Map<String, NetPromoterScoreCalculator> ();
		Set<Integer> promoter_scores  = new Set<Integer> {10,9};
		Set<Integer> passive_scores   = new Set<Integer> {7,8};
		Set<Integer> detractor_scores = new Set<Integer> {6,5,4,3,2,1,0};
		
		//next part is broken into 3 queries,  because Salesforce will not allow a group by on net_promoter_score__c
		//don't ask why    
		//promoters
		for(AggregateResult ar : database.query('select account.center__c center,count(id) num_scores from opportunity where net_promoter_score__c != null and net_promoter_score__c in :promoter_scores group by account.center__c')) {
		  //check if we need to create a new mapping
		  if(nps_map.get((String)ar.get('center'))==null)
		    nps_map.put((String)ar.get('center'),new NetPromoterScoreCalculator());  
		  nps_map.get((String)ar.get('center')).add_promoter((Integer)ar.get('num_scores'));
		}   
		
		//passives
		for(AggregateResult ar : database.query('select account.center__c center,count(id) num_scores from opportunity where net_promoter_score__c != null and net_promoter_score__c in :passive_scores group by account.center__c')) {
		  //check if we need to create a new mapping
		  if(nps_map.get((String)ar.get('center'))==null)
		    nps_map.put((String)ar.get('center'),new NetPromoterScoreCalculator());  
		  nps_map.get((String)ar.get('center')).add_passive((Integer)ar.get('num_scores'));
		}   
		  
		//detractor
		for(AggregateResult ar : database.query('select account.center__c center,count(id) num_scores from opportunity where net_promoter_score__c != null and net_promoter_score__c in :detractor_scores group by account.center__c')) {
		  //check if we need to create a new mapping
		  if(nps_map.get((String)ar.get('center'))==null)
		    nps_map.put((String)ar.get('center'),new NetPromoterScoreCalculator());  
		  nps_map.get((String)ar.get('center')).add_detractor((Integer)ar.get('num_scores'));
		}       
		  
		//end NPS calculation
	    
	    
	    
	    // -----------------------------------------------------------------------------------------------------------
	    // TODO: Loop through all the centers
	    // -Create a map of new Doctor Master Center Snapshots; map<center_id, Doctor Mastery Center Data>
	    // -Insert list of records
	    // -----------------------------------------------------------------------------------------------------------    
	    
	    
	    
	    // -----------------------------------------------------------------------------------------------------------
	    // TODO: Loop through ClearChoiceDoctors WHERE isActive__c == true;
	    // -Calculate Tenure Years: round down
	    // -Fill in data for record set
	    // -Insert record set
	    // -----------------------------------------------------------------------------------------------------------    
	    
	    
	    // TODO: Loop through all the centers
	    // -Create a map of new Doctor Master Center Snapshots; map<center_id, Doctor Mastery Center Data>
	    // -Insert list of records
	    
	    // TODO: Loop through ClearChoiceDoctors WHERE isActive__c == true;
	    // -Calculate Tenure Years: round down
	    // -Fill in data for record set
	    // -Insert record set
	}
    
    
    
    
    private Decimal getPercentage(Decimal numArg){
    	return numArg/100.0;
    }
    
    private Decimal calculateNetPromoterScore(Decimal numOfPromoters, Decimal numOfDetractors){
    	Decimal percentageOfPromoters  = this.getPercentage(numOfPromoters);
    	Decimal percentageOfDetractors = this.getPercentage(numOfDetractors);
    	return percentageOfPromoters - percentageOfDetractors;
    }
 
}