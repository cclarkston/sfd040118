public without sharing class ServiceFinancialApiService {
  public static Boolean sandbox = Test.isRunningTest() ||
                          [SELECT IsSandbox
                           FROM Organization
                           LIMIT 1][0].IsSandbox;

  public static Lead lead {get; set;}

  @Future(callout=true)
  public static void prescreen(Id leadId){
    fetchLeadData(leadId);

    //__________________________________

    System.debug('crash: ' + 'should run PIQ');
    // ProspectIq.run_prospect_all_check(leadId);

    //__________________________________

    if (insufficientInformation()) {
      setPrescreen('Insufficient Information');
    } else if (poBox()) {
      setPrescreen('PO Box');
    } else {
      verifyPrescreenIsAllowed();
    }
  }

  @TestVisible
  private static void fetchLeadData(Id leadId) {
    lead = [SELECT Id, FirstName, LastName, Street, City,
                   State, PostalCode, Pre_Screen__c,
                   StrikeForce1__USAddress_Address_Status__c,
                   Prescreen_Street_Name__c, Pre_Screen_Time__c
            FROM Lead
            WHERE Id = :leadId
          ];
  }

  @TestVisible
  private static Boolean insufficientInformation() {
    return String.isBlank(lead.FirstName) ||
           String.isBlank(lead.LastName) ||
           String.isBlank(lead.Street) ||
           String.isBlank(lead.City) ||
           String.isBlank(lead.State) ||
           String.isBlank(lead.PostalCode);
  }

  @TestVisible
  private static Boolean poBox() {
    System.debug('pobox: ' + lead);
    String street = lead.Street.toLowerCase();
    String expected = 'po box';
    return (street.contains(expected));
  }

  @TestVisible
  private static void setPrescreen(String prescreen) {
    lead.Pre_Screen__c = prescreen;
    updateLead();
  }

  private static void verifyPrescreenIsAllowed() {
    if (prescreenIsNotPermitted()) {
      return;
    } else {
      startBuildingRequest();
    }
  }

  @TestVisible
  private static Boolean prescreenIsNotPermitted() {
    Id profileId = UserInfo.getProfileId();
    String userProfileName = [SELECT Name
                              FROM Profile
                              WHERE Id = :profileId
                            ][0].Name;

    return (userProfileName == 'Call Center Agent' &&
           lead.Pre_Screen_Time__c != null &&
           lead.Pre_Screen_Time__c > Datetime.now().addDays(-1));
  }

  private static void startBuildingRequest() {
    String requestBody;

    requestBody = buildRequestBody();
    sendRequestIfValid(requestBody);
  }

  private static void sendRequestIfValid(String requestBody) {
    HttpResponse response;
    if(requestBody != null) {
      response = sendRequest(requestBody);
      handleValidResponse(response);
    }
  }

  private static void handleValidResponse(HttpResponse response) {
    if(response != null) {
      parseResponseWithoutMessages(response);
    }
  }

  @TestVisible
  private static String buildRequestBody() {
    System.debug('building request');
    String requestBody;
    String cleanZipcode = cleanZipcode();

    try {
      requestBody = 'FirstName='+EncodingUtil.urlEncode(lead.FirstName, 'UTF-8')
                  + '&LastName='+EncodingUtil.urlEncode(lead.LastName, 'UTF-8')
                  + '&Address='+EncodingUtil.urlEncode(lead.Street, 'UTF-8')
                  + '&City='+EncodingUtil.urlEncode(lead.City, 'UTF-8')
                  + '&State='+EncodingUtil.urlEncode(lead.State, 'UTF-8')
                  + '&Zip='+EncodingUtil.urlEncode(cleanZipcode, 'UTF-8');

    } catch(Exception error) {
      sendErrorEmail('Argument cannot be null: buildRequestBody(). Lead Id: '
                     + lead.Id );
    }
    return requestBody;
  }

  @TestVisible
  private static String cleanZipcode() {
    if(lead.PostalCode != null && lead.PostalCode.length() >= 5) {
      String cleanZipcode = lead.PostalCode.substring(0,5);
      return cleanZipcode;
    }
    return null;
  }

  @TestVisible
  private static HttpResponse sendRequest(String requestBody) {
    String token = [SELECT Token__c FROM Service_Financial__c][0].Token__c;
    String requestUrl = sandbox ? 'http://sfcapitest.svcfin.com/stu/creditcheck'
                                : 'http://sfcapi.svcfin.com/stu/creditcheck';

    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    Http http = new Http();

    request.setEndpoint(requestUrl);
    request.setMethod('POST');
    request.setTimeout(90000);
    request.setHeader('Token', token);
    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.setHeader('Accept', 'application/json');
    request.setBody(requestBody);

    try {
      response = http.send(request);
    } catch(Exception error) {
      sendErrorEmail('sendRequest() failed');
    }
    System.debug('xxx: ' + response);
    return response;
  }

  @TestVisible
  private static void parseResponseWithoutMessages(HttpResponse response) {
    System.debug('status data: ' + response.getStatus());
    System.debug('status data: ' + response.getStatusCode());
    System.debug('status data: ' + response.getBody());

    System.debug('parse response method');

    Integer statusCode = response.getStatusCode();

    if(statusCode == 500) {
      handleInternalServerError();
    } else if(statusCode == 401) {
      handleUnauthorizedError();
    } else {
      parseResponseWithMessages(response, statusCode);
    }
  }

  private static void parseResponseWithMessages(HttpResponse response, Integer statusCode) {
    Map<String, Object> body =
                  (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

    System.debug('crash: ' + body); //REMOVE

    String result = (String)body.get('result');

    if(statusCode == 400) {
      handleBadRequestError();
    } else if(statusCode == 200) {
      handleSuccessfulResponse(response, body, result);
    } else {
      handleUnknownError();
    }
  }

  private static void handleInternalServerError() {
    lead.Pre_Screen__c = 'Website Down-No Prescreen';
    sendErrorEmail('500 - Website Down-No Prescreen');
    updateLead();
  }

  private static void handleUnauthorizedError() {
    lead.Pre_Screen__c = 'Website Down-No Prescreen';
    sendErrorEmail('401 - Website Down-No Prescreen: Token Invalid');
    updateLead();
  }

  private static void handleBadRequestError() {
    lead.Pre_Screen__c = 'Insufficient Information';
    sendErrorEmail('400 - Insufficinet Information: ');
    updateLead();
  }

  private static void handleUnknownError() {
    lead.Pre_Screen__c = 'Website Down-No Prescreen';
    sendErrorEmail('400 - Website Down-No Prescreen: Uknown Error');
    updateLead();
  }

  private static void handleSuccessfulResponse(HttpResponse response, Map<String, Object> body, String result) {
    if(result == 'failed') {
      sendErrorEmail('Website Down-No Prescreen: Successful (200) Response With Message: Failed');
      lead.Pre_Screen__c = 'Website Down-No Prescreen';
      updateLead();
    } else if (result == 'success') {
      assignPrescreen(body);
    }
  }

  private static void assignPrescreen(Map<String, Object> body) {
    String prescreen = (String)body.get('ColorBand');
    if (prescreen == 'Lime') {
      lead.Pre_Screen__c = 'Green';
    } else if (prescreen == 'Blue') {
      lead.Pre_Screen__c = 'Blue (No Hit)';
    } else {
      lead.Pre_Screen__c = prescreen;
    }
    System.debug('final: ' + lead.Pre_Screen__c);
    updateLead();
  }

  private static void updateLead() {
    lead.StrikeForce1__USAddress_Address_Status__c = 'Not Verified';
    lead.Pre_Screen_Time__c = Datetime.now();
    update lead;
  }

  private static void sendErrorEmail(String message) {
    Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
    String[] toAddresses = new String[] {'software-dev@clearchoice.com'};
    mail.setToAddresses(toAddresses);
    mail.setReplyTo('software-dev@clearchoice.com');
    mail.setSenderDisplayName('ServiceFinancialApiService');
    mail.setSubject(UserInfo.getOrganizationName() + ': ' + message );
    mail.setPlainTextBody(message);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
}