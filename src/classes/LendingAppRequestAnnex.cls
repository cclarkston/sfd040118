// DEPRECATED

public class LendingAppRequestAnnex {
  // public String clientId {get; set;}
  // public String centerId {get; set;}
  // public String estimatedServiceDate {get; set;}
  // public String firstName {get; set;}
  // public String lastName {get; set;}
  // public String address1 {get; set;}
  // public String address2 {get; set;}
  // public String city {get; set;}
  // public String state {get; set;}
  // public String zipcode {get; set;}
  // public String country {get; set;}
  // public String email {get; set;}
  // public String phone {get; set;}
  // public String mobile {get; set;}
  // public String dateOfBirth {get; set;}
  // public Decimal appliedAmount {get; set;}
  // public String documentId {get; set;}
  // public String documentIdNumber {get; set;}
  // public String documentIdState {get; set;}
  // public String documentIssuanceDate {get; set;}
  // public String documentExpirationDate {get; set;}
  // public String employmentStatus {get; set;}
  // public Decimal grossYearlyIndividualIncome {get; set;}
  // public Decimal grossYearlyHouseholdIncome {get; set;}
  // public Decimal monthlyResidencePayment {get; set;}
  // public String ssn {get; set;}
  // public Map<String, String> centerOfficeId = new Map<String, String>{};
  // public Map<String, String> documentIdType = new Map<String, String>
  //                             {'Driver\'s License' => '01', 'State ID' => '02',
  //                              'US Passport' => '03', 'Military ID' => '04'};
  // public Map<String, String> employmentStatusId = new Map<String, String>
  //                             {'Employed' => '01', 'Retired' => '02',
  //                              'Self Employed' => '03', 'Unemployed' => '04'};
  //
  // public LendingAppRequestAnnex(Boolean sandbox, Account patient, Lending_App_Application__c application, String xssn) {
  //   if(sandbox) {
  //     centerOfficeId.put('Atlanta', 'L00569');
  //     centerOfficeId.put('Charlotte', 'L00570');
  //     centerOfficeId.put('Fort Lauderdale', 'L00568');
  //   } else {
  //     centerOfficeId.put('Denver', 'L01494');
  //   }
  //
  //   clientId = '21988C3DE0813B08C44D4DBEC7571952';
  //   centerId = centerOfficeId.get(patient.Center__r.Name);
  //   estimatedServiceDate = (Date.today() + 30).format();
  //   firstName = patient.FirstName;
  //   lastName = patient.LastName;
  //   address1 = patient.BillingStreet;
  //   address2 = '';
  //   city = patient.BillingCity;
  //   state = patient.BillingState;
  //   zipcode = patient.BillingPostalCode;
  //   country = 'United States';
  //   email = patient.PersonEmail;
  //   phone = cleanPhone(patient.Phone);
  //   mobile = verifyMobileNumber(patient);
  //   dateOfBirth = patient.Date_of_Birth__c.format();
  //   appliedAmount = application.Loan_Amount__c;
  //   documentId = documentIdType.get(application.Id_Type__c);
  //   documentIdNumber = application.Id_Number__c;
  //   documentIdState = application.Id_State__c;
  //   documentIssuanceDate = application.Id_Issuance_Date__c.format();
  //   documentExpirationDate = application.Id_Expiration_Date__c.format();
  //   employmentStatus = employmentStatusId.get(application.Employment_Status__c);
  //   grossYearlyIndividualIncome = application.Gross_Yearly_Individual_Income__c;
  //   grossYearlyHouseholdIncome = application.Gross_Yearly_Household_Income__c;
  //   monthlyResidencePayment = application.Monthly_Residence_Payment__c;
  //   ssn = xssn;
  // }
  //
  // @TestVisible
  // private String cleanPhone(String phone) {
  //   String cleanPhone = phone.replaceAll('[^0-9]', '');
  //   return cleanPhone;
  // }
  //
  // @TestVisible
  // private String verifyMobileNumber(Account patient) {
  //   if (patient.PersonMobilePhone == null || patient.PersonMobilePhone == '') {
  //     return patient.Phone;
  //   } else
  //   return patient.PersonMobilePhone;
  // }
}