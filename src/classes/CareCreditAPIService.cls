public class CareCreditAPIService {
	private CtrlLendingApp controller;
	String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
	String serviceNS = 'http://schemas.syf.com/services/V2';
	String elementNS = 'http://schemas.syf.com/service/QS/java';

	public CareCreditAPIService(CtrlLendingApp controller) {
		this.controller = controller;
	}

	public HttpResponse submitCareCreditInquiry() {
		String careCreditRequest = buildCareCreditRequest();
		HttpResponse careCreditResponse = sendCareCreditRequest(careCreditRequest);
		return careCreditResponse;
	}

	private String buildCareCreditRequest() {
		// String merchantNumber;

		String firstName = controller.patient.FirstName;
		String lastName = controller.patient.LastName;
		String address1 = controller.patient.BillingStreet;
		String address2 = '';
		String city = controller.patient.BillingCity;
		String state = controller.patient.BillingState;
		String zipcode = controller.patient.BillingPostalCode;
		String phone = controller.cleanPhone(controller.patient.Phone);
		Decimal appliedAmount = controller.application.Loan_Amount__c;

		String nonce = generateNonce();
		String timestamp = generateTimestamp();
		String username = '5348120284876083';
		String password = '76083$Test';

		String request =
		'<?xml version="1.0" encoding="UTF-8"?>' +
		'<soapenv:Envelope xmlns:java="http://schemas.syf.com/service/QS/java" ' +
											 'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
											 'xmlns:v2="http://schemas.syf.com/services/V2">' +
			'<soapenv:Header>' +
				'<wsse:Security soapenv:mustUnderstand="1" ' +
											 'xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" ' +
											 'xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
					 '<wsse:UsernameToken wsu:Id="UsernameToken-648AC0BF70B2958130149876448244239">' +
							'<wsse:Username>' + username + '</wsse:Username>' +
							'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + password + '</wsse:Password>' +
							'<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + nonce + '</wsse:Nonce>' +
							'<wsu:Created>' + timestamp + '</wsu:Created>' +
					 '</wsse:UsernameToken>' +
				'</wsse:Security>' +
			'</soapenv:Header>' +
			'<soapenv:Body>' +
				'<v2:performQuickScreenRequest>' +
					'<v2:qsRequestParm>' +
						'<java:merchantNumber>5348120286517826</java:merchantNumber>' +
						'<java:client>CC</java:client>' +
						'<java:anlFlag>N</java:anlFlag>' + // needs to be yes in production ***requires phone number
						'<java:productCode>SB</java:productCode>' +
						'<java:origination>B</java:origination>' +
						'<java:firstName>' + firstName + '</java:firstName>' +
						'<java:lastName>' + lastName + '</java:lastName>' +
						'<java:address1>' + address1 + '</java:address1>' +
						'<java:address2>' + address2 + '</java:address2>' +
						'<java:city>' + city + '</java:city>' +
						'<java:state>' + state + '</java:state>' +
						'<java:zipCode>' + zipcode + '</java:zipCode>' +
						'<java:phoneNumber>' + phone + '</java:phoneNumber>' +
						'<java:estimatedFee>' + appliedAmount + '</java:estimatedFee>' +
					'</v2:qsRequestParm>' +
				'</v2:performQuickScreenRequest>' +
			'</soapenv:Body>' +
		'</soapenv:Envelope>';

		return request;
	}

	@TestVisible
	public void handleCareCreditResponse(HttpResponse response) {
		String approvalAmount;
		String authorizationNumber;

		Dom.Document document = response.getBodyDocument();
		Dom.XMLNode envelope = document.getRootElement();
		Dom.XmlNode header = envelope.getChildElement('Header', soapNS);
		Dom.XmlNode body = envelope.getChildElement('Body', soapNS);
		Dom.XmlNode performQuickScreenResponse = body.getChildElement('performQuickScreenResponse', serviceNS);
		Dom.XmlNode qsResponseParm = performQuickScreenResponse.getChildElement('qsResponseParm', serviceNS);
		System.debug('qsResponseParm: ' + qsResponseParm);
		String responseCode = qsResponseParm.getChildElement('responseCode', elementNS).getText();
		System.debug('responseCode: ' + responseCode);
		String responseText = qsResponseParm.getChildElement('responseText', elementNS).getText();

		if (responseCode == '400') {
			handleCareCreditErrors(qsResponseParm);
		} else if (responseCode == '000') {
			approvalAmount = qsResponseParm.getChildElement('approvalAmount', elementNS).getText();
			authorizationNumber = qsResponseParm.getChildElement('authorizationNumber', elementNS).getText();
			saveCareCreditResponse(responseText, approvalAmount, authorizationNumber);
		} else {
			handleCareCreditService(responseText);
		}
	}

	@TestVisible
	private void handleCareCreditErrors(Dom.XmlNode qsResponseParm) {

		Dom.XmlNode errorList = qsResponseParm.getChildElement('errorList', elementNS);

		List<Dom.XmlNode> errors = errorList.getChildElements();
		System.debug(errors);

		for(Dom.XmlNode error : errors) {
			controller.errorMessages.add(error.getText());
		}
		controller.page = 'main';
		controller.renderErrors = true;
	}

	@TestVisible
	private void handleCareCreditService(String responseText) {
		controller.errorMessages.add(responseText);
		controller.declinedOffers += 1;
		controller.renderErrors = true;
	}

	@TestVisible
	private void saveCareCreditResponse(String responseText, String approvalAmount, String authorizationNumber) {
		Lending_App_Offer__c offer = new Lending_App_Offer__c();
		offer.Account__c = controller.patientId;
		offer.Lender__c = 'CareCredit';
		offer.Max_Line__c = sanitizeAndStringifyApprovalAmount(approvalAmount);
		offer.Loan_Application_Url__c = 'https://www.carecredit.com/';
		offer.Authorization_Number__c = authorizationNumber;

		try {
			insert offer;
			controller.page = 'offers';
			controller.header = 'Pre-qualification Inquiry Offers*';
		} catch(DmlException error) {
			controller.addMessage('There was a problem updating the CareCredit offer record.' + error);
		}
	}

	@TestVisible
	private Integer sanitizeAndStringifyApprovalAmount(String approvalAmount) {
		Integer amount = Integer.valueOf(approvalAmount);
		return amount;
	}

	private String generateNonce() {
			Integer length = 24;
			Long randomLong = Crypto.getRandomLong();
			String key = EncodingUtil.base64Encode(Blob.valueOf(String.valueOf(randomLong)));
			return key.substring(0, length);
	}

	private String generateTimestamp() {
			return Datetime.now().formatGmt('yyyy-MM-dd\'T\'kk:mm:ss.SSS\'Z\'');
	}

	private HttpResponse sendCareCreditRequest(String requestBody) {
		String requestUrl = controller.sandbox ? 'https://iwww.b2bcreditservices.com/QuickScreenService'
																					 : 'https://www.b2bcreditservices.com/QuickScreenService';

		HttpRequest request = new HttpRequest();
		HttpResponse response = new HttpResponse();
		Http http = new Http();

		request.setEndpoint(requestUrl);
		request.setMethod('POST');
		request.setTimeout(60000);
		request.setHeader('Content-Type', 'text/xml');
		request.setHeader('SOAPAction', '');
		request.setBody(requestBody);

		response = http.send(request);

		return response;
	}
}