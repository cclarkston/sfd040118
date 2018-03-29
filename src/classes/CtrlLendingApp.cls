// DEPENDENCIES - see below class //

public without sharing class CtrlLendingApp {
	public Boolean sandbox =
							Test.isRunningTest() ||
							[SELECT IsSandbox
							 FROM Organization
							 LIMIT 1][0].IsSandbox;

	@TestVisible
  private String userProfileName {get; set;}
  public VirtualPatient virtualPatient {get; set;}
  public Boolean publicUser {get; private set;}
  private Account[] patientData {get; set;}
	public String page {get; set;}
	public String header {get; set;}
	public String terms {get; private set;}
	public Account patient {get; set;}
	public Lending_App_Application__c application {get; set;}
	public Lending_App_Offer__c offer {get; set;}
	public String ssn {get; set;}
	public String ssnReentry {get; set;}
	public Lending_App_Offer__c[] offers {get; set;}
	public Boolean acceptTerms1 {get; set;}
	public Boolean acceptTerms2 {get; set;}
	public Boolean acceptTerms3 {get; set;}
  public Boolean lendingClubDeclined {get; set;}
  public Boolean proceedFinanceDeclined {get; set;}
	public Boolean renderErrors {get; set;}
	public String[] errorMessages {get; set;}
	public String sortOffersBy {get; set;}
	public String loginLastName {get; set;}
	public String loginPassword {get; set;}
	public Id patientId {get; private set;}
	private String currentPage {get; set;}
	private String currentHeader {get; set;}
	public Integer declinedOffers {get; set;}
  public String loanApplicationUrl {get; set;}
  public String lendingClubClientId {get; set;}
  public Boolean hasStandardOffers {get; set;}
  public Boolean hasPromotionalOffers {get; set;}
  public Boolean noEmailAddress {get; set;}
  public Boolean generateEmailAddress {get; set;}

  public Map<String, String> centerOfficeId = new Map<String, String>{};
  public Map<String, String> documentIdType = new Map<String, String>
                              {'Driver\'s License' => '01', 'State ID' => '02',
                               'US Passport' => '03', 'Military ID' => '04'};
  public Map<String, String> employmentStatusId = new Map<String, String>
                              {'Employed' => '01', 'Retired' => '02',
                               'Self Employed' => '03', 'Unemployed' => '04'};

 	public CtrlLendingApp() {
    virtualPatient = new VirtualPatient();
    errorMessages = new String[]{};
    hasStandardOffers = false;
    hasPromotionalOffers = false;
    lendingClubDeclined = false;
    proceedFinanceDeclined = false;
    noEmailAddress = false;
    generateEmailAddress = false;
    userProfileName = fetchUserProfileName();
    setOfficeIds();
    lendingClubClientId = '21988C3DE0813B08C44D4DBEC7571952';
    validateUser(userProfileName);
    checkForExistingOffers();
	}

  private void setOfficeIds() {
    if(sandbox) {
      centerOfficeId.put('Atlanta', 'L00569');
      centerOfficeId.put('Charlotte', 'L00570');
      centerOfficeId.put('Fort Lauderdale', 'L00568');
    } else {
      centerOfficeId.put('Denver', 'L01494');
    }
  }

  // VIRTUAL PATIENT OBJECT //

  // Salesforce Sites limits access to database objects
  // This custom object holds the patient data so that updates can be made
  // from the app
	public class VirtualPatient {
		public String FirstName {get; set;}
		public String LastName {get; set;}
		public String BillingStreet {get; set;}
		public String BillingCity {get; set;}
		public String BillingState {get; set;}
		public String BillingPostalCode {get; set;}
		public String Phone {get; set;}
		public String PersonMobilePhone {get; set;}
		public String PersonEmail {get; set;}
		public Date Date_of_Birth {get; set;}
		public Date Prostho_Exam_Date {get; set;}
		public String Center_Name {get; set;}
		public String Temp_Password {get; set;}
	}

  // VERIFICATION, VALIDATION AND PAGE SETUP WITH PATIENT DATA //

  // determines if the user is accessing the app through Saleseforce or the
  // Saleforce Site URL
  @TestVisible
  private String fetchUserProfileName() {
    Id profileId = UserInfo.getProfileId();
    String userProfileName = [SELECT Name
                              FROM Profile
                              WHERE Id = :profileId
                            ][0].Name;

    return userProfileName;
  }

  private void validateUser(String userProfileName) {
    if(userProfileName == 'Lending App Profile' ||
       userProfileName == 'PreQ Profile') {
      header = 'PreQ Login';
      page = 'login';
    } else {
      bypassLoginPage();
    }
  }

  @TestVisible
  private void checkForExistingOffers() {
    Integer standardOffers = [SELECT Count()
                              FROM Lending_App_Offer__c
                              WHERE Account__c = :patientId
                              AND Promotional_Period__c = null
                             ];
    Integer promotionalOffers = [SELECT Count()
                                 FROM Lending_App_Offer__c
                                 WHERE Account__c = :patientId
                                 AND Promotional_Period__c != null
                               ];
    if(standardOffers > 0) {
      hasStandardOffers = true;
    }
    if(promotionalOffers > 0) {
      hasPromotionalOffers = true;
    }
  }

  @TestVisible
  private void bypassLoginPage() {
    String byAccountId = 'WHERE Id = :accountId';
    patientData = fetchPatient(byAccountId);
    publicUser = false;
    if(patientData.size() > 0) {
      setUpPatient(patientData[0]);
      goToMainPage();
    } else {
      addMessage('There is no patient data.');
    }
  }

	public void validateLogin() {
		verifyCredentials();

		if(!ApexPages.hasMessages()) {
			if (loginValid()) {
				redirectPatient();
			} else {
				addMessage(invalidLoginMessage());
			}
		}
	}

  @TestVisible
	private void verifyCredentials() {
    String byPassword = 'WHERE Temp_Password__c = :loginPassword';
    Account[] patientData = fetchPatient(byPassword);

    if (loginPassword != '' && patientData.size() != 0) {
      publicUser = true;
      setUpPatient(patientData[0]);
		} else {
			addMessage(invalidLoginMessage());
		}
	}

	private Boolean loginValid() {
		return loginLastName.toLowerCase() == patient.LastName.toLowerCase() &&
					 loginPassword.toLowerCase() == patient.Temp_Password__c.toLowerCase();
	}

  private void redirectPatient() {
    Integer numberOfOffers = [SELECT COUNT()
                              FROM Lending_App_Offer__c
                              WHERE Account__c = :patientId
                            ];

    if(numberOfOffers > 0) {
      goToOffersPage();
    } else {
      goToMainPage();
    }
  }

  private Account[] fetchPatient(String whereParam) {
    Id accountId = Apexpages.currentPage().getParameters().get('accountId');

    String queryParams = 'SELECT Id, FirstName, LastName, BillingStreet, '
                       + 'BillingCity, BillingState, BillingCountry, '
                       + 'BillingPostalCode, Phone, PersonMobilePhone, '
                       + 'PersonEmail, Date_of_Birth__c, Prostho_Exam_Date__c, '
                       + 'Center__r.Name, Temp_Password__c, isPersonAccount '
                       + 'FROM Account '
                       + whereParam;

		Account[] patientData = Database.query(queryParams);

    return patientData;
	}

  private void setUpPatient(Account patientData) {
    patient = patientData;
    patientId = patient.Id;
    getOrCreateApplicationForPatient();
    populateVirtualPatient();
  }

	private void getOrCreateApplicationForPatient() {
		Lending_App_Application__c[] existingApplication = [SELECT Id, Loan_Amount__c,
																													Id_Type__c, Id_Number__c,
																													Id_State__c, Id_Issuance_Date__c,
																													Home_State__c, Id_Expiration_Date__c,
																													Gross_Yearly_Individual_Income__c,
                                                          Gross_Yearly_Household_Income__c,
                                                          Employment_Status__c,
                                                          Monthly_Residence_Payment__c,
                                                          Residence_Type__c
																											  FROM Lending_App_Application__c
																										    WHERE Account__c = :patientId];

		if (existingApplication.size() == 0) {
			application = new Lending_App_Application__c(Account__c = patientId);
		} else {
			application = existingApplication[0];
		}
	}

  // UPDATE PATIENT DATA IN DATABASE VIA INDIRECT OBJECT //

	public void populateVirtualPatient() {
		virtualPatient.FirstName = patient.FirstName;
		virtualPatient.LastName = patient.LastName;
		virtualPatient.BillingStreet = patient.BillingStreet;
		virtualPatient.BillingCity = patient.BillingCity;
		virtualPatient.BillingPostalCode = patient.BillingPostalCode;
		virtualPatient.Phone = patient.Phone;
		virtualPatient.PersonMobilePhone = patient.PersonMobilePhone;
		virtualPatient.PersonEmail = patient.PersonEmail;
		virtualPatient.Date_of_Birth = patient.Date_of_Birth__c;
		virtualPatient.Prostho_Exam_Date = patient.Prostho_Exam_Date__c;
		virtualPatient.Center_Name = patient.Center__r.Name;
		virtualPatient.Temp_Password = patient.Temp_Password__c;
	}

  private void goToMainPage() {
    header = 'Inquiry Information';
    page = 'main';
  }

	private String invalidLoginMessage() {
		String message =
			'Invalid login information. Please enter correct Last Name and Password. '+
			'If you still can\'t login ClearChoice can verify your information and '+
			'even generate a new password for you.';
		return message;
	}

	public void saveApplicationInfo() {
		validateRequiredFields();

    if(noEmailAddress == true) {
      generateEmailAddress();
    }

		if (!ApexPages.hasMessages()) {
			upsertApplication();
			updatePatientWithVirtualPatient();
		}
	}

	@TestVisible
	private void upsertApplication() {
		try {
			upsert application;
		} catch(DmlException error) {
			addMessage(updateErrorMessage() + ' ' + error );
		}
	}

	@TestVisible
	private void updatePatientWithVirtualPatient() {
		patient.FirstName = virtualPatient.FirstName;
		patient.LastName = virtualPatient.LastName;
		patient.BillingStreet = virtualPatient.BillingStreet;
		patient.BillingCity = virtualPatient.BillingCity;
		patient.BillingState = application.Home_State__c;
		patient.BillingPostalCode = virtualPatient.BillingPostalCode;
		patient.Phone = virtualPatient.Phone;
		patient.PersonMobilePhone = virtualPatient.PersonMobilePhone;
    patient.PersonEmail = generateEmailAddress == false ? virtualPatient.PersonEmail : null;
		patient.Date_of_Birth__c = virtualPatient.Date_of_Birth;
		patient.Prostho_Exam_Date__c = virtualPatient.Prostho_Exam_Date;
		patient.Center__r.Name = virtualPatient.Center_Name;
		patient.Temp_Password__c = virtualPatient.Temp_Password;

		try {
			update patient;
      generateEmailAddress = false;
      page = 'confirmation';
		} catch(DmlException error) {
			addMessage(updateErrorMessage() + ' ' + error );
      goToMainPage();
		}
	}

	private static String updateErrorMessage() {
		return 'There was a problem updating the patient information. '+
		'Contact ClearChoice for more information.';
	}

  // CLIENT SIDE VALIDATIONS

	@TestVisible
	private void validateRequiredFields() {
    Date targetAge = Date.today().addYears(-18).addDays(-1);

		if (String.isBlank(virtualPatient.FirstName)) {
			addMessage('First name is a required field');
		}
		if (String.isBlank(virtualPatient.LastName)) {
			addMessage('Last name is a required field');
		}
		if (String.isBlank(virtualPatient.BillingStreet)) {
			addMessage('Street address is a required field');
		}
		if (String.isBlank(virtualPatient.BillingCity)) {
			addMessage('City is a required field');
		}
    if (String.isBlank(application.Home_State__c)) {
      addMessage('State is a required field');
    }
		if (virtualPatient.BillingPostalCode.length() != 5) {
			addMessage('Enter a 5 digit zipcode');
		}
		if (String.isBlank(virtualPatient.Phone)) {
			addMessage('Phone number is a required field');
		}
		if (cleanPhone(virtualPatient.Phone).length() != 10) {
			addMessage('Enter a valid phone number');
		}
		if (virtualPatient.PersonMobilePhone.length() != 10 &&
        virtualPatient.PersonMobilePhone.length() != 0) {
			addMessage('Enter a valid mobile phone number');
		}
		if (String.isBlank(virtualPatient.PersonEmail) &&
        noEmailAddress == false) {
			addMessage('Enter email address or check box for No Email Address');
		}
		if (String.isBlank(application.Id_Type__c)) {
			addMessage('Valid ID Type is a required field');
		}
		if (String.isBlank(application.Id_Number__c)) {
			addMessage('Valid ID Number is a required field');
		}
		if (String.isBlank(application.Id_State__c)) {
			addMessage('Valid ID State is a required field');
		}
		if (String.isBlank(application.Employment_Status__c)) {
			addMessage('Employment Status is a required field');
		}
		if (String.isBlank(application.Employment_Status__c)) {
			addMessage('Employment Status is a required field');
		}
		if (String.isBlank(application.Employment_Status__c)) {
			addMessage('Employment Status is a required field');
		}
		if (virtualPatient.Date_of_Birth == null) {
			addMessage('Date of birth is a required field');
		}
		if (virtualPatient.Date_of_Birth > targetAge) {
			addMessage('Must be 18 years old. Check Date of Birth');
		}
		if (virtualPatient.Date_of_Birth > Date.today()) {
			addMessage('Date of birth must be in the past');
		}
		if (application.Id_Issuance_Date__c > Date.today()) {
			addMessage('ID Issuance Date must be in the past');
		}
		if (application.Id_Expiration_Date__c < Date.today()) {
			addMessage('ID Expiration Date must be in the future');
		}
		if (application.Gross_Yearly_Individual_Income__c <= 0 ||
        application.Gross_Yearly_Individual_Income__c ==null) {
			addMessage('Please enter your yearly individual income');
		}
		if (application.Gross_Yearly_Household_Income__c <
        application.Gross_Yearly_Individual_Income__c &&
        application.Gross_Yearly_Household_Income__c > 0) {
			addMessage('Gross Yearly Household Income is individual income plus ' +
                 'any addition income, so the value of household income ' +
                 'must be greater than Gross Yearly Individual Income. ' +
                 'If none, enter 0');
		}
    if(application.Gross_Yearly_Household_Income__c == 0) {
      application.Gross_Yearly_Household_Income__c = application.Gross_Yearly_Individual_Income__c;
    }
    if(application.Residence_Type__c != null) {
      if (application.Monthly_Residence_Payment__c <= 0 ||
          application.Monthly_Residence_Payment__c == null) {
          addMessage('Please enter your monthly rent/mortgage payment');
        }
    }
		if (application.Loan_Amount__c < 750 ||
			  application.Loan_Amount__c > 99999 ||
		 	  application.Loan_Amount__c == null) {
			addMessage('Please enter a prequalification amount between $750 and $99,999');
		}
    if (!ssnValid()) {
			addMessage('A valid Social Security Number is a required');
		}
    if (!ssnMatching()) {
			addMessage('Social security numbers do not match. '+
			'Please re-enter correct, matching social security numbers.');
		}
	}

  @TestVisible
  private void generateEmailAddress() {
    generateEmailAddress = true;
    String emailAddress = '';
    Long randomLong = Crypto.getRandomLong();

    emailAddress += virtualPatient.FirstName;
    emailAddress += virtualPatient.LastName;
    emailAddress += randomLong;
    emailAddress += '@';
    emailAddress += 'email.com';
    virtualPatient.PersonEmail = emailAddress;
  }

	public void addMessage(String message) {
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, message));
	}

  // ENSURES CHECKBOXES ON CONFIRMATION PAGE HAVE BEEN CHECKED BEFORE PROCEEDING

	public void acceptTermsAndConditions () {
		if (!termsAccepted()) {
			addMessage('Please check each checkbox to agree to terms and conditions');
		} else {
			submitInquiryApplication();
		}
	}

  @TestVisible
	private Boolean ssnValid() {
		String cleanSsn = sanitizeSsn(ssn);
		return cleanSsn.length() == 9 && cleanSsn.isNumeric();
	}

	private Boolean ssnMatching() {
		String cleanSsn = sanitizeSsn(ssn);
		String cleanSsnReentry = sanitizeSsn(ssnReentry);
		return cleanSsn == cleanSsnReentry;
	}

	private String sanitizeSsn(String cleanSsn) {
		return cleanSsn.replaceAll('[^0-9]', '');
	}

	private Boolean termsAccepted() {
		return acceptTerms1 == true && acceptTerms2 == true && acceptTerms3 == true;
	}

  // API REQUEST RESPONSE RUNNER

  // this method is a switch that contains groups of methods that can be
  // commented out/deleted to disable specific lenders

  public void submitInquiryApplication () {
		// CareCreditAPIService careCreditService = new CareCreditAPIService(this).submitCareCreditInquiry();

    // LendingClubApiService lendingClubApiService = new LendingClubApiService(this);
    // HttpResponse lendingClubResponse = lendingClubApiService.submitLendingClubInquiry();


    // ProceedFinanceApiService proceedFinanceApiService = new ProceedFinanceApiService(this);
    // HttpResponse proceedFinanceResponse = proceedFinanceApiService.submitProceedFinanceInquiry();
    // System.debug('proceedFinanceResponse CtrlLendingApp: ' + proceedFinanceResponse);
    //
    // // if(careCreditResponse != null) {
    // // careCreditService.handleCareCreditResponse(careCreditResponse);
    // // }
    // if(lendingClubResponse != null) {
    //   lendingClubApiService.saveLendingClubResponse(lendingClubResponse);
    // }
    // if(proceedFinanceResponse != null) {
    //   proceedFinanceApiService.saveProceedFinanceResponse(proceedFinanceResponse);
    // }

    // if apexpages.hasMessages {go home and render errors};
    if(ApexPages.hasMessages()) {
      goToMainPage();
    } else {
      goToOffersPage();
    }
  }

  public String verifyMobileNumber() {
    if (patient.PersonMobilePhone == null || patient.PersonMobilePhone == '') {
      return cleanPhone(patient.Phone);
    } else
    return cleanPhone(patient.PersonMobilePhone);
  }

  public String cleanPhone(String phoneNumber) {
    String cleanPhone = phoneNumber.replaceAll('[^0-9]', '');
    return cleanPhone;
  }

	public void addErrorMessages(Map<String, Object> messages, Set<String> keys) {
		for(String key : keys) {
			String message = String.valueOf(messages.get(key));
			errorMessages.add(message);
			page = 'main';
			renderErrors = true;
		}
	}

  // GET ALL OFFERS FOR A PATIENT TO DISPLAY ON OFFERS PAGE
  // Offers can be sorted

	public Lending_App_Offer__c[] getStandardOffers() {
		if (sortOffersBy != '' && sortOffersBy != null) {
			String query = 'SELECT Account__c, APR__c, Lender__c, ' +
										 'Max_Line__c, Term__c, Monthly_Payment__c, ' +
                     'Promotional_Period__c, ' +
										 'Loan_Application_Url__c FROM Lending_App_Offer__c ' +
										 'WHERE Account__c = :patientId ' +
                     'AND Promotional_Period__c = null ' +
                     'ORDER BY ';

			query += sortOffersBy;
			offers = Database.query(query);
		} else {
			String query = 'SELECT Account__c, APR__c, Lender__C, Monthly_Payment__c, ' +
			 							 'Max_Line__c, Term__c, Loan_Application_Url__c, ' +
                     'Promotional_Period__c ' +
										 'FROM Lending_App_Offer__c WHERE Account__c = :patientId ' +
                     'AND Promotional_Period__c = null ' +
										 'ORDER BY Max_Line__c DESC';
			offers = Database.query(query);
		}
		return offers;
	}

	public Lending_App_Offer__c[] getPromotionalOffers() {
		if (sortOffersBy != '' && sortOffersBy != null) {
			String query = 'SELECT Account__c, APR__c, Lender__C, ' +
										 'Max_Line__c, Term__c, Monthly_Payment__c, ' +
                     'Promotional_Period__c, ' +
										 'Loan_Application_Url__c FROM Lending_App_Offer__c ' +
										 'WHERE Account__c = :patientId ' +
                     'AND Promotional_Period__c != null ' +
                     'ORDER BY ';

			query += sortOffersBy;
			offers = Database.query(query);
		} else {
			String query = 'SELECT Account__c, APR__c, Lender__C, Monthly_Payment__c, ' +
			 							 'Max_Line__c, Term__c, Loan_Application_Url__c, ' +
                     'Promotional_Period__c ' +
										 'FROM Lending_App_Offer__c WHERE Account__c = :patientId ' +
                     'AND Promotional_Period__c != null ' +
										 'ORDER BY Max_Line__c DESC';
			offers = Database.query(query);
		}
		return offers;
	}

  // SETUP/NAVIGATE TO PAGES

  public void goToOffersPage() {
    header = 'Pre-qualification Inquiry Offers*';
    page = 'offers';
  }

	public void ccPrivacyPolicy() {
		if (currentPage()) {
      currentHeader = header;
			currentPage = page;
			page = 'privacy-policy';
      header = 'PreQ Privacy Policy';
		} else {
			page = currentPage;
      header = currentHeader;
		}
	}

	private Boolean currentPage() {
		return (page == 'main' || page == 'confirmation' || page == 'offers');
	}

  public void selectOffer() {
    header = 'Leaving ClearChoice PreQ';
    page = 'leaving-clearchoice';
    loanApplicationUrl = ApexPages.currentPage().getParameters().get('loanApplicationUrl');
  }
}

// ALL FILES
// TestCtrlLendingApp
// LendingClubApiService
  // TestLendingClubAPIService
// LendingClubJsonResponse
  // TestLendingClubJsonResponse
// CareCreditAPIService
  // TestCareCreditApiService
// Proceed Finanace APIService
  // TestProceedFinanceApiService
  // MockProceedFinanceHttpResponseGenerator
// TempPasswordGenerator
  // TestTempPasswordGenerator

// PAGES //
// lending_app

// ASSETS
  // Assets.resource/css/lending-app.css