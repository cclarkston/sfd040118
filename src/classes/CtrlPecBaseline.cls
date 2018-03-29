public with sharing class CtrlPecBaseline {
 public String pecSearch {get; set;}
 public String centerId {get; set;}
 public String regionId {get; set;}
 public User[] pecs {get; private set;}
 public User[] displayPecs {get; private set;}
 public Integer pageCount {get; private set;}
 public Integer totalPages {get; private set;}
 public Boolean disableNext {get; private set;}
 public Boolean disablePrevious {get; private set;}

 public DisplayUser pecInfo {get; set;}

 private Integer interval = 5;
 private Integer lastPage = 0;
 private Integer startingIndex = 0;
 private Integer endingIndex = 0;

 public CtrlPecBaseline() {
 	pecs = new User[] {};
 }

  // DisplayUser Wrapper for pecBaseline //

 public DisplayUser[] pecBaseline;
 public class DisplayUser {
 	public PEC_Baseline__c pecBaseline {get; set;}
 	public Center_Information__c center {get; set;}

 	public DisplayUser(PEC_Baseline__c pec, Center_Information__c center) {
 		this.pecBaseline = pec;
 		this.center = center;
 	}
 }

 // dynamic search by pec //

 public void searchPecs() {
 	pecs = [SELECT Id, Name
 					FROM User
 					WHERE IsActive = true
 					AND Name LIKE :('%' + pecSearch + '%')
 					AND User_Role__c LIKE '%PEC%'
 					ORDER BY Name];

 	setPageVariables();
 }

 public void setPageVariables() {
 	totalPages = (pecs.size() / interval) + 1;
 	lastPage = (Math.mod(pecs.size(), interval));
 	adjustTotalPages();
 	startingIndex = 0;
 	endingIndex = 4;
 	disableNext = false;
 	disablePrevious = false;
 	firstPage();
 }

 private void adjustTotalPages() {
 	if (lastPage == 0) { totalPages -= 1; }
 }

 public void firstPage() {
 	pageCount = 1;

 	addPecsForDisplay();
 }

 public void nextPage() {
 	pageCount += 1;

 	if (pageCount < totalPages) {
 		startingIndex += interval;
 		endingIndex += interval;
 	} else {
 		startingIndex += interval;
 		endingIndex += lastPage;
 	}
 	addPecsForDisplay();
 }

 public void previousPage() {

 	if(pageCount < totalPages) {
 		pageCount -= 1;
 		startingIndex -= interval;
 		endingIndex -= interval;
 	} else {
 		pageCount -= 1;
 		startingIndex -= interval;
 		endingIndex -= lastPage;
 	}
 	addPecsForDisplay();
 }

 private void addPecsForDisplay() {
 	displayPecs = new User[]{};

 	adjustEndingIndex();

 	for (Integer i = startingIndex; i <= endingIndex; i++) {
 		system.debug(pecs);
 		displayPecs.add(pecs[i]);
 	}
 	togglePageButtons();
 }

 private void adjustEndingIndex() {
 	if (endingIndex > (pecs.size() - 1)) {
 		endingIndex = (pecs.size() - 1);
 	}
 }

 private void togglePageButtons() {
 	if (pageCount == totalPages && pageCount == 1) {
 		disableNext = true;
 	  disablePrevious = true;
 	} else if (pageCount == totalPages) {
 		disableNext = true;
 	} else if (pageCount == 1) {
 		disablePrevious = true;
 	} else {
 		disableNext = false;
 		disablePrevious = false;
 	}
 }

 // query pecs and return for display //

 public void pecBaselinesByPec() {
 	String userId = ApexPages.currentPage().getParameters().get('userId');
 	if (!pecBaselineRecordExists(userId)){
 		createPecBaseline(userId);
 	} else {
 		fetchPecBaselineAndCenter(userId);
 	}
 }

 private Boolean pecBaselineRecordExists(String userId) {
 	PEC_Baseline__c[] baseline = [SELECT Id FROM PEC_Baseline__c
 															  WHERE User__c = :userId];
 	return (baseline.size() > 0);
 }

 private void createPecBaseline(String UserId) {
 	PEC_Baseline__c pec = new PEC_Baseline__c(User__c = userId);
 	insert pec;
 }

 private void fetchPecBaselineAndCenter(String UserId) {
 	pecBaseline = new DisplayUser[] {};
 							// change pec to pecBaseline
 	PEC_Baseline__c[] pecBaselines = [SELECT Id, Year__c, Month__c, TCR__c, CPC__c,
 																									 User__r.Name,
 																									 User__r.Department,
 																									 User__r.Center_PEC__c,
 																									 User__r.Goal_Type__c
                                    FROM PEC_Baseline__c
								 				            WHERE User__c = :userId];

 	String pecCenterId = pecBaselines[0].User__r.Center_PEC__c;

 	Center_Information__c center = [SELECT Id, Name
 																	FROM Center_Information__c
 																	WHERE Id = :pecCenterId];


  for (PEC_Baseline__c baseline : pecBaselines) {
    DisplayUser pecData;
    pecData = new DisplayUser(baseline, center);
    pecBaseline.add(pecData);
  }
  pecInfo = pecBaseline[0];
  System.debug(pecBaseline);
 }

  public DisplayUser[] getPecData() {
   return pecBaseline;
 }

 // search by center //

 public selectOption[] getCenterOptions() {
 	List<SelectOption> options = new List<SelectOption>{new SelectOption('', '')};

 	Center_Information__c[] centers = [SELECT Id, Name
 																		 FROM Center_Information__c
 																		 WHERE Active__c = true
 																		 ORDER BY Name];

 	for(Center_Information__c center : centers) {
 		options.add(new SelectOption(center.Id, center.Name));
 	}
 	return options;
 }

 // query pecBaselines by center for display //

 public void pecBaselinesByCenter() {
 	pecBaseline = new DisplayUser[] {};

 	User[] pecIds = [SELECT Id
 									 FROM User
 									 WHERE Center_Pec__c = :centerId];

 	PEC_Baseline__c[] pecBaselines = [SELECT Id, Year__c, Month__c, TCR__c, CPC__c,
 																												User__r.Name,
 																												User__r.Department,
 																												User__r.Center_PEC__c,
 																												User__r.Goal_Type__c
 																		FROM PEC_Baseline__c
 																		WHERE User__c IN :pecIds];

 	Center_Information__c center = [SELECT Name
 	                                FROM Center_Information__c
 																	WHERE Id = :centerId];

 	for (PEC_Baseline__c baseline : pecBaselines) {
 		DisplayUser pecData;
 		pecData = new DisplayUser(baseline, center);
 		pecBaseline.add(pecData);
 	}
 }

 // search by region

 public SelectOption[] getRegionOptions() {
 	List<SelectOption> options = new List<SelectOption>{new SelectOption('', '')};

 	Sales_Region__c[] regions = [SELECT Id, Name
 													 	   FROM Sales_Region__c
 													 	 	 WHERE Active__c = true
 													 	 	 ORDER BY Name];

  for(Sales_Region__c region : regions) {
 	 options.add(new SelectOption(region.Id, region.Name));
  }
  return options;
 }

 // query pecBaselines by region for display

  public void pecBaselinesByRegion() {
 	pecBaseline = new DisplayUser[] {};
 	Set<Id> centerIds = new Set<Id>();
 	Map<Id, Center_Information__c> centersById = new Map<Id, Center_Information__c>();
 	Map<Id, List<Center_Information__c>> centerByRegionId
 																			 = new Map<Id, List<Center_Information__c>>();
 	Sales_Region__c[] regions = [SELECT Id, Name,
 																(SELECT Id, Name FROM Center_Information__r)
 															 FROM Sales_Region__c];

 	for(Sales_Region__c region : regions) {
 		centerByRegionId.put(region.Id, region.Center_Information__r);
 	}

 	Center_Information__c[] centers = centerByRegionId.get(regionId);

 	for(Center_Information__c center : centers) {
 		centersById.put(center.Id, center);
 	}

 	centerIds = centersById.keySet();

 	User[] pecIds = [SELECT Id
 									 FROM User
 									 WHERE Center_PEC__c
 									 IN :centerIds];

 	PEC_Baseline__c[] pecBaselines = [SELECT Id, Year__c, Month__c, TCR__c, CPC__c,
 																												User__r.Name,
 																												User__r.Department,
 																												User__r.Center_PEC__c,
 																												User__r.Goal_Type__c
 																		FROM PEC_Baseline__c
 																		WHERE User__c IN :pecIds];

 	for(PEC_Baseline__c baseline : pecBaselines) {
 		DisplayUser pecData;
 		Center_Information__c center = centersById.get(baseline.User__r.Center_PEC__c);
 		pecData = new DisplayUser(baseline, center);
 		pecBaseline.add(pecData);
 	}
 }
}