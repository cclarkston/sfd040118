// is actually controlling the LeadScore__c color

public with sharing class CtrlPrescreenColor {

	private Lead lead;
  private Id leadId;
  private String prescreen;
  public String leadScore {get; private set;}
  public String color {get; private set;}
  public Boolean loadingLeadscore {get; set;}
  public Map<String,String> leadScoreColors {
   get {
       return new Map<String, String> {
           'Green' => 'green',
           'Yellow' => 'yellow',
           'Red' => 'red',
           'Blue (No Hit)' => 'blue',
           'Insufficient Information' => 'dark-gray',
           'Website Down-No Prescreen' => 'black',
           'PO Box' => 'purple',
           'Not Checked' => 'gray'
       };
     }
   set;
  }

  public CtrlPrescreenColor(ApexPages.StandardController standardController) {
      this.lead = (Lead)standardController.getRecord();
      leadId = lead.Id;
      Set<String> picklistValues = fetchLeadScoreValues();
      setLeadscore();
      loadingLeadscore = true;
      setPrescreenColor(picklistValues);
  }

  private void setLeadscore() {
    lead = [SELECT Pre_Screen__c, LeadScore__c FROM LEAD WHERE Id = :leadId];
    prescreen = lead.Pre_Screen__c;
    System.debug('crash: ' + prescreen);
    leadScore = lead.LeadScore__c;
    System.debug('crash: ' + leadScore);
  }

  public PageReference loadingLeadscoreStatus() {
    setLeadscore();
    loadingLeadscore = false;
    return null;
  }

  private Set<String> fetchLeadScoreValues() {
    Set<String> picklistValues = new Set<String>();
		Schema.DescribeFieldResult result = Schema.Lead.Pre_Screen__c.getDescribe();
		List<Schema.PicklistEntry> values = result.getPicklistValues();
		for(Schema.PicklistEntry value : values){
			picklistValues.add(value.getLabel());
		}
    return picklistValues;
  }

  private void setPrescreenColor(Set<String> picklistValues) {
    String leadScoreColor = leadScore;
    if (picklistValues.Contains(leadScoreColor)) {
      assignColor();
    } else {
      color = 'Not Checked';
    }
  }

  private void assignColor() {
    if(prescreen == 'Website Down-No Prescreen' ||
       prescreen == 'Insufficient Information' ||
       prescreen == 'PO Box') {
      color = leadScoreColors.get(prescreen);
    } else {
      color = leadScoreColors.get(leadScore);
    }
  }
}