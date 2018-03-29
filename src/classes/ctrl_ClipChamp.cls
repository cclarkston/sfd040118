public class ctrl_ClipChamp {
	User current_user            {get; private set;}
	Center_Information__c center {get; private set;}

	public ctrl_ClipChamp(ApexPages.StandardController account) {
		current_user = [SELECT Clinic_Calendar__c FROM User WHERE ID = :UserInfo.getUserId()];
		center       = [SELECT Sales_Region__C FROM Center_Information__c WHERE Name = :current_user.Clinic_Calendar__c];
	}
}