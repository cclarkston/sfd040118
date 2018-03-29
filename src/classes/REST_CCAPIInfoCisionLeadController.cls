@RestResource(urlMapping='/CCAPI/InfoCision/*')
global class REST_CCAPIInfoCisionLeadController{    
    @HttpGet
    global static Map<String, String> getLead() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();
        
        String LeadId = req.params.get('LeadId');
        return API.returnLead(LeadId);
    }
	@HttpPost
    global static Map<String, String> newLead(
    		String FirstName, 
    		String LastName, 
    		String Email,
			String Street,
			String City,
			String State,
			String Zip,
			String Country,
			String Phone,
			String LastMarketingSource,
			String DistanceToCenter,
			String SalesAlert,
			String ExternalID,
			String MarketingSource,
			String InboundCall,
			String CallResult,
			String DateCallBackScheduled,
			String Gender,
			String CenterLocation,
			String LanguageSpoken ) {
        CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();
        
		return API.insertLead(
				FirstName, 
				LastName, 
				Email,
				Street,
				City,
				State,
				Zip,
				Country,
				Phone,
				LastMarketingSource,
				DistanceToCenter,
				SalesAlert,
				ExternalID,
				MarketingSource,
				InboundCall,
				CallResult,
				DateCallBackScheduled,
				Gender,
				CenterLocation,
				LanguageSpoken );
	}
    @HttpPatch
    global static Map<String, String> currentLead(
    		String LeadId,
    		String FirstName, 
    		String LastName, 
    		String Email,
			String Street,
			String City,
			String State,
			String Zip,
			String Country,
			String Phone,
			String LastMarketingSource,
			String DistanceToCenter,
			String SalesAlert,
			String ExternalID,
			String MarketingSource,
			String InboundCall,
			String CallResult,
			String DateCallBackScheduled,
			String Gender,
			String CenterLocation,
			String LanguageSpoken ) {
        CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();
        
		return API.updateLead(
				LeadId,
				FirstName, 
				LastName, 
				Email,
				Street,
				City,
				State,
				Zip,
				Country,
				Phone,
				LastMarketingSource,
				DistanceToCenter,
				SalesAlert,
				ExternalID,
				MarketingSource,
				InboundCall,
				CallResult,
				DateCallBackScheduled,
				Gender,
				CenterLocation,
				LanguageSpoken );
	}
}