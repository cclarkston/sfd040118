public class vf_email_tmpl_helper {
	private final string timezone;
	private final string timezone1;
	public String accId 
    {   get;set;    }  
    
	public vf_email_tmpl_helper() {
		string theId = userinfo.getUserId();
		user u = [select u.TimeZoneSidKey from user u where id = :theId limit 1];
		timezone = u.TimeZoneSidKey;
		campaignMember cm1 = [select cm.Lead.firstname from campaignmember cm where id = :accId];
		//Lead l = [select firstname from Lead where id = :accId limit 1]; //where firstname = :accId
		timezone1 = cm1.Lead.firstname;
	}

	public string gettheTimeZone() {
		return timezone;
	}

	public string gettheTimeZone1() {
		return timezone1;
	}

}