public with sharing class MicroSite {
	private PageReference Page;
	private String Url;
	private Map<String, String> Parameters = new Map<String,String>();
	
	private Cookie Trackers;
	private Map<String, Object> TrackerObject;
	
	private Cookie Referers;
	private Map<String, Object> RefererObject;
	
	private Datetime myDatetime = Datetime.now();
	public MicroSite(){
		Page = ApexPages.currentPage();
		Url = Page.getURL();
		Map<String, String> PageParameters = Page.getParameters();
		Trackers = Page.getCookies().get('Trackers');
		Referers = Page.getCookies().get('Referers');
		
		if(Trackers != null){
			TrackerObject = (Map<String,Object>) JSON.deserializeUntyped(Trackers.getValue());
		} else {
			TrackerObject = new Map<String,Object>();
		}
		
		for (String Key:PageParameters.KeySet()){
			if(Key == null || Key == 'core.apexpages.devmode.url'){
				continue;
			}
			String Value = PageParameters.get(Key);
			Parameters.put(Key,Value);
			TrackerObject.put(Key,Value);
		}
		
		TrackerObject.put('timestamp', myDatetime.formatLong() );
		Trackers = new Cookie('Trackers', JSON.serialize(TrackerObject), null, ( 30 * 24 * 60 ), false);
		
		
		String PageReferer = getReferer();
		Boolean inArray = false;
		Integer lArray = 0;
		if(Referers != null){
			RefererObject = (Map<String,Object>) JSON.deserializeUntyped(Referers.getValue());
			for(String Key:RefererObject.KeySet()){
				if(Key == null){
					continue;
				}
				if(RefererObject.get(Key) == PageReferer){
					inArray = true;
				}
				lArray ++;
			}
		} else {
			RefererObject = new Map<String,Object>();
		}
		if(inArray == false){
			RefererObject.put(''+lArray, PageReferer);
		}
		Referers = new Cookie('Referers', JSON.serialize(RefererObject), null, ( 30 * 24 * 60 ), false);
		
		Page.setCookies(new Cookie[]{ Trackers , Referers });
		Trackers = Page.getCookies().get('Trackers');
		Referers = Page.getCookies().get('Referers');
	}
	public String getURL(){
		return Url;
	}
	public String getParams(){
		String PageParameters = '';
		Integer Count = 1;
		for (String Key:Parameters.KeySet()){
			PageParameters += ((Count>1)?'&':'')+Key+'='+Parameters.get(Key);
			Count++;
		}
		return PageParameters;
	}
	public String getCookie(){
		return Trackers.getValue();
	}
	public string getReferer(){
		if(System.URL.getSalesforceBaseUrl().toExternalForm()+getURL().replace('&core.apexpages.devmode.url=1','') == Page.getHeaders().get('Referer')){
			return 'Direct';
		} else {
			return Page.getHeaders().get('Referer');
		}
	}
	public string getReferes(){
		return Referers.getValue();
	}
}