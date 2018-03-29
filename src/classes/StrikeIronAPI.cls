public class StrikeIronAPI {
	@Future(callout=true)
	public static void phoneValidate(String LeadId, String phoneNumber){
		String UserId = 'vlarson@clearchoice.com';
		String Password = 'vince123';
		
		System.debug('Phone Validate');
		
		wwwStrikeironComPhoneValidation3.PhonevalSoap PhoneStub = new wwwStrikeironComPhoneValidation3.PhonevalSoap();
		PhoneStub.LicenseInfo = new wsStrikeironCom.LicenseInfo();
		PhoneStub.LicenseInfo.RegisteredUser = new wsStrikeironCom.RegisteredUser();
		PhoneStub.LicenseInfo.RegisteredUser.UserID = UserId;
		PhoneStub.LicenseInfo.RegisteredUser.Password = Password;
			
		wwwStrikeironComPhoneValidation3.SIWsOutputOfPhoneValResult info = PhoneStub.ValidateNumber(phoneNumber);
		System.debug(info);
	}
}