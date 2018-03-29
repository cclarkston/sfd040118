public with sharing class LendingClubApiService {
  CtrlLendingApp controller;
  Decimal additionalIncome;

	public LendingClubApiService(CtrlLendingApp controller) {
    this.controller = controller;
    additionalIncome = additionalIncome();
	}

  public HttpResponse submitLendingClubInquiry() {
    String lendingClubRequestBody = buildLendingClubRequest();
    HttpResponse response = sendLendingClubRequest(lendingClubRequestBody);

    return response;
  }

  @TestVisible
  private String buildLendingClubRequest() {
    JSONGenerator request = JSON.createGenerator(true);
    request.writeStartObject();

    request.writeStringField('clientId', controller.lendingClubClientId);
    request.writeNumberField('loanAmount', controller.application.Loan_Amount__c);
    request.writeStringField('appliedBy', 'Applicant');
    request.writeBooleanField('electronicConsentFlag', false);

    request.writeFieldName('borrower');
    request.writeStartObject();
    request.writeStringField('firstName', controller.patient.FirstName);
    request.writeStringField('lastName', controller.patient.LastName);
    request.writeStringField('homePhone', controller.cleanPhone(controller.patient.Phone));
    request.writeStringField('email', controller.patient.PersonEmail);
    request.writeStringField('dob', formatDate());
    request.writeStringField('ssn', controller.ssn);

    request.writeFieldName('physicalAddress');
    request.writeStartObject();
    request.writeStringField('street', controller.patient.BillingStreet);
    request.writeStringField('city', controller.patient.BillingCity);
    request.writeStringField('state', controller.patient.BillingState);
    request.writeStringField('zip', controller.patient.BillingPostalCode);
    request.writeEndObject();

    request.writeFieldName('mailingAddress');
    request.writeStartObject();
    request.writeStringField('street', controller.patient.BillingStreet);
    request.writeStringField('city', controller.patient.BillingCity);
    request.writeStringField('state', controller.patient.BillingState);
    request.writeStringField('zip', controller.patient.BillingPostalCode);
    request.writeEndObject();

    request.writeFieldName('income');
    request.writeStartObject();
    request.writeNumberField('grossYearlySalary', controller.application.Gross_Yearly_Individual_Income__c);
    request.writeNumberField('grossYearlyOtherIncome', additionalIncome);
    request.writeNumberField('monthlyResidencePayment', controller.application.Monthly_Residence_Payment__c);
    request.writeEndObject();
    request.writeEndObject();

    request.writeFieldName('recipient');
    request.writeStartObject();
    request.writeStringField('firstName', 'Approve');
    request.writeStringField('lastName', 'Bond');
    request.writeStringField('relationship', 'SELF');
    request.writeEndObject();

    request.writeEndObject();

    return request.getAsString();
  }

  @TestVisible
  private HttpResponse sendLendingClubRequest(String requestBody) {
    string requestUrl = controller.sandbox ? 'https://api-sandbox.lendingclub.com/api/pf-partner/v1/loanapp'
                                           : 'production url here';

    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    Http http = new Http();

    request.setEndpoint(requestUrl);
    request.setMethod('POST');
    request.setTimeout(60000);
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Accept-Type', 'application/json');
    request.setBody(requestBody);

    try {
      response = http.send(request);
    } catch(Exception error) {
      controller.addMessage('The Lending Club API is not responding. Please try again in 30 minutes.');
    }
    return response;
  }

  private void addMessage(String message) {
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, message));
	}

  private String formatDate() {
    Date targetDate = controller.patient.Date_of_Birth__c;
    return String.valueof(targetDate.year()) + '-'
         + String.valueof(targetDate.month()) + '-'
         + String.valueof(targetDate.day());
  }

  private Decimal additionalIncome() {
    Decimal householdIncome = controller.application.Gross_Yearly_Household_Income__c;
    Decimal individualIncome = controller.application.Gross_Yearly_Individual_Income__c;
    return (householdIncome - individualIncome);
  }

	public void saveLendingClubResponse(HttpResponse jsonResponse) {
		controller.errorMessages = new List<String>();


		String applicationResponseStatus = jsonResponse.getStatus();
    String applicationResponse = jsonResponse.getBody();

    LendingClubJsonResponse response = LendingClubJsonResponse.parse(applicationResponse);
System.debug('crash: ' + response);
    if(response.Offers[0].loanApplicationResponse == 'DECLINED') {
      controller.lendingClubDeclined = true;
    } else {
      handleApprovedOffers(response);
    }
	}

  private void handleApprovedOffers(LendingClubJsonResponse response) {
    LendingClubJsonResponse.offerItems[] responseStandardOffers = response.Offers[0].OfferItems;
    LendingClubJsonResponse.offerItems[] responsePromotionalOffers = response.Offers[1].OfferItems;

    Lending_App_Offer__c[] standardOffers = new Lending_App_Offer__c[]{};
    standardOffers = createListOfLendingClubOffers(responseStandardOffers, standardOffers);

    Lending_App_Offer__c[] promotionalOffers = new Lending_App_Offer__c[]{};
    promotionalOffers = createListOfLendingClubOffers(responsePromotionalOffers, promotionalOffers);

    try {
      insert standardOffers;
      insert promotionalOffers;
      controller.hasStandardOffers = true;
      controller.hasPromotionalOffers = true;
    } catch(DmlException error) {
      controller.addMessage('There is a problem inserting the offers. Contact ClearChoice for '+
      'more information. The specific error is: ' + error);
    }
  }

	private void handleLendingClubErrorMessages(String applicationResponse) {
		Map<String, Object> body =
									(Map<String, Object>)JSON.deserializeUntyped(applicationResponse);
		Map<String, Object> messages = (Map<String, Object>)body.get('Messages');
		Set<String> keys = messages.keySet();

		controller.addErrorMessages(messages, keys);
	}

  private Lending_App_Offer__c[] createListOfLendingClubOffers(LendingClubJsonResponse.OfferItems[] response, Lending_App_Offer__c[] offers) {
    for(LendingClubJsonResponse.OfferItems detail : response) {
      Lending_App_Offer__c offer = new Lending_App_Offer__c();
      offer.Account__c = controller.patientId;
      offer.APR__c = (Decimal.valueOf(detail.intRate) * 100);
      offer.Lender__c = 'Lending Club';
      offer.Min_Line__c = 0;
      offer.Max_Line__c = detail.amount;
      offer.Term__c = detail.term;
      offer.Loan_Application_Url__c = detail.url;
      offer.Monthly_Payment__c = detail.monthlyPayment;
      offer.Promotional_Period__c = detail.promotionalPeriod;
      offers.add(offer);
    }
    return offers;
  }
}