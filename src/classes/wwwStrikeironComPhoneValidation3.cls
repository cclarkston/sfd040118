//Generated by wsdl2apex

public class wwwStrikeironComPhoneValidation3 {
    public class MethodStatusRecord {
        public String MethodName;
        private String[] MethodName_type_info = new String[]{'MethodName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'MethodName'};
    }
    public class GetStatusCodes_element {
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class SIWsStatus {
        public Integer StatusNbr;
        public String StatusDescription;
        private String[] StatusNbr_type_info = new String[]{'StatusNbr','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] StatusDescription_type_info = new String[]{'StatusDescription','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'StatusNbr','StatusDescription'};
    }
    public class SIWsOutputOfSIWsResultArrayOfMethodStatusRecord {
        public wwwStrikeironComPhoneValidation3.SIWsStatus ServiceStatus;
        public wwwStrikeironComPhoneValidation3.SIWsResultArrayOfMethodStatusRecord ServiceResult;
        private String[] ServiceStatus_type_info = new String[]{'ServiceStatus','http://www.strikeiron.com','SIWsStatus','0','1','false'};
        private String[] ServiceResult_type_info = new String[]{'ServiceResult','http://www.strikeiron.com','SIWsResultArrayOfMethodStatusRecord','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'ServiceStatus','ServiceResult'};
    }
    public class ServiceInfoRecord {
        public String InfoKey;
        public String InfoValue;
        private String[] InfoKey_type_info = new String[]{'InfoKey','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] InfoValue_type_info = new String[]{'InfoValue','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'InfoKey','InfoValue'};
    }
    public class ZipInfo {
        public String ZipCode;
        public Integer ZipCodeCount;
        public Integer ZipCodeFrequency;
        private String[] ZipCode_type_info = new String[]{'ZipCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] ZipCodeCount_type_info = new String[]{'ZipCodeCount','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] ZipCodeFrequency_type_info = new String[]{'ZipCodeFrequency','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'ZipCode','ZipCodeCount','ZipCodeFrequency'};
    }
    public class PhonevalSoap {
        public String endpoint_x = 'http://ws.strikeiron.com/StrikeIron/PhoneValidation3/Phoneval';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public wsStrikeironCom.SubscriptionInfo SubscriptionInfo;
        public wsStrikeironCom.LicenseInfo LicenseInfo;
        private String SubscriptionInfo_hns = 'SubscriptionInfo=http://ws.strikeiron.com';
        private String LicenseInfo_hns = 'LicenseInfo=http://ws.strikeiron.com';
        private String[] ns_map_type_info = new String[]{'http://www.strikeiron.com', 'wwwStrikeironComPhoneValidation3', 'http://ws.strikeiron.com', 'wsStrikeironCom'};
        public wwwStrikeironComPhoneValidation3.SIWsOutputOfMethodStatusRecord GetStatusCodesForMethod(String MethodName) {
            wwwStrikeironComPhoneValidation3.GetStatusCodesForMethod_element request_x = new wwwStrikeironComPhoneValidation3.GetStatusCodesForMethod_element();
            wwwStrikeironComPhoneValidation3.GetStatusCodesForMethodResponse_element response_x;
            request_x.MethodName = MethodName;
            Map<String, wwwStrikeironComPhoneValidation3.GetStatusCodesForMethodResponse_element> response_map_x = new Map<String, wwwStrikeironComPhoneValidation3.GetStatusCodesForMethodResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.strikeiron.com/GetStatusCodesForMethod',
              'http://www.strikeiron.com',
              'GetStatusCodesForMethod',
              'http://www.strikeiron.com',
              'GetStatusCodesForMethodResponse',
              'wwwStrikeironComPhoneValidation3.GetStatusCodesForMethodResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetStatusCodesForMethodResult;
        }
        public wwwStrikeironComPhoneValidation3.SIWsOutputOfSIWsResultArrayOfServiceInfoRecord GetServiceInfo() {
            wwwStrikeironComPhoneValidation3.GetServiceInfo_element request_x = new wwwStrikeironComPhoneValidation3.GetServiceInfo_element();
            wwwStrikeironComPhoneValidation3.GetServiceInfoResponse_element response_x;
            Map<String, wwwStrikeironComPhoneValidation3.GetServiceInfoResponse_element> response_map_x = new Map<String, wwwStrikeironComPhoneValidation3.GetServiceInfoResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.strikeiron.com/GetServiceInfo',
              'http://www.strikeiron.com',
              'GetServiceInfo',
              'http://www.strikeiron.com',
              'GetServiceInfoResponse',
              'wwwStrikeironComPhoneValidation3.GetServiceInfoResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetServiceInfoResult;
        }
        public void GetRemainingHits() {
            wsStrikeironCom.GetRemainingHits_element request_x = new wsStrikeironCom.GetRemainingHits_element();
            wsStrikeironCom.GetRemainingHitsResponse_element response_x;
            Map<String, wsStrikeironCom.GetRemainingHitsResponse_element> response_map_x = new Map<String, wsStrikeironCom.GetRemainingHitsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://ws.strikeiron.com/StrikeIron/PhoneValidation3/Phoneval/GetRemainingHits',
              'http://ws.strikeiron.com',
              'GetRemainingHits',
              'http://ws.strikeiron.com',
              'GetRemainingHitsResponse',
              'wsStrikeironCom.GetRemainingHitsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
        }
        public wwwStrikeironComPhoneValidation3.SIWsOutputOfSIWsResultArrayOfMethodStatusRecord GetStatusCodes() {
            wwwStrikeironComPhoneValidation3.GetStatusCodes_element request_x = new wwwStrikeironComPhoneValidation3.GetStatusCodes_element();
            wwwStrikeironComPhoneValidation3.GetStatusCodesResponse_element response_x;
            Map<String, wwwStrikeironComPhoneValidation3.GetStatusCodesResponse_element> response_map_x = new Map<String, wwwStrikeironComPhoneValidation3.GetStatusCodesResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.strikeiron.com/GetStatusCodes',
              'http://www.strikeiron.com',
              'GetStatusCodes',
              'http://www.strikeiron.com',
              'GetStatusCodesResponse',
              'wwwStrikeironComPhoneValidation3.GetStatusCodesResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.GetStatusCodesResult;
        }
        public wwwStrikeironComPhoneValidation3.SIWsOutputOfPhoneValResult ValidateNumber(String PhoneNumber) {
            wwwStrikeironComPhoneValidation3.ValidateNumber_element request_x = new wwwStrikeironComPhoneValidation3.ValidateNumber_element();
            wwwStrikeironComPhoneValidation3.ValidateNumberResponse_element response_x;
            request_x.PhoneNumber = PhoneNumber;
            Map<String, wwwStrikeironComPhoneValidation3.ValidateNumberResponse_element> response_map_x = new Map<String, wwwStrikeironComPhoneValidation3.ValidateNumberResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.strikeiron.com/ValidateNumber',
              'http://www.strikeiron.com',
              'ValidateNumber',
              'http://www.strikeiron.com',
              'ValidateNumberResponse',
              'wwwStrikeironComPhoneValidation3.ValidateNumberResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ValidateNumberResult;
        }
    }
    public class GetStatusCodesResponse_element {
        public wwwStrikeironComPhoneValidation3.SIWsOutputOfSIWsResultArrayOfMethodStatusRecord GetStatusCodesResult;
        private String[] GetStatusCodesResult_type_info = new String[]{'GetStatusCodesResult','http://www.strikeiron.com','SIWsOutputOfSIWsResultArrayOfMethodStatusRecord','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'GetStatusCodesResult'};
    }
    public class ArrayOfSIWsStatus {
        public wwwStrikeironComPhoneValidation3.SIWsStatus[] SIWsStatus;
        private String[] SIWsStatus_type_info = new String[]{'SIWsStatus','http://www.strikeiron.com','SIWsStatus','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'SIWsStatus'};
    }
    public class GetStatusCodesForMethodResponse_element {
        public wwwStrikeironComPhoneValidation3.SIWsOutputOfMethodStatusRecord GetStatusCodesForMethodResult;
        private String[] GetStatusCodesForMethodResult_type_info = new String[]{'GetStatusCodesForMethodResult','http://www.strikeiron.com','SIWsOutputOfMethodStatusRecord','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'GetStatusCodesForMethodResult'};
    }
    public class PhoneValResult {
        public String OriginalPhoneNumber;
        public String DecoratedPhoneNumber;
        public String AreaCode;
        public String Exchange;
        public String Station;
        public String Country;
        public String State;
        public String City;
        public String County;
        public Decimal Timezone;
        public Integer DST;
        public Integer CountyPopulation;
        public wwwStrikeironComPhoneValidation3.ArrayOfZipInfo ZipCodes;
        private String[] OriginalPhoneNumber_type_info = new String[]{'OriginalPhoneNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] DecoratedPhoneNumber_type_info = new String[]{'DecoratedPhoneNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] AreaCode_type_info = new String[]{'AreaCode','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Exchange_type_info = new String[]{'Exchange','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Station_type_info = new String[]{'Station','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Country_type_info = new String[]{'Country','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] State_type_info = new String[]{'State','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] City_type_info = new String[]{'City','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] County_type_info = new String[]{'County','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Timezone_type_info = new String[]{'Timezone','http://www.w3.org/2001/XMLSchema','decimal','1','1','false'};
        private String[] DST_type_info = new String[]{'DST','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] CountyPopulation_type_info = new String[]{'CountyPopulation','http://www.w3.org/2001/XMLSchema','int','1','1','false'};
        private String[] ZipCodes_type_info = new String[]{'ZipCodes','http://www.strikeiron.com','ArrayOfZipInfo','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'OriginalPhoneNumber','DecoratedPhoneNumber','AreaCode','Exchange','Station','Country','State','City','County','Timezone','DST','CountyPopulation','ZipCodes'};
    }
    public class GetServiceInfo_element {
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class SIWsOutputOfMethodStatusRecord {
        public wwwStrikeironComPhoneValidation3.SIWsStatus ServiceStatus;
        public wwwStrikeironComPhoneValidation3.MethodStatusRecord ServiceResult;
        private String[] ServiceStatus_type_info = new String[]{'ServiceStatus','http://www.strikeiron.com','SIWsStatus','0','1','false'};
        private String[] ServiceResult_type_info = new String[]{'ServiceResult','http://www.strikeiron.com','MethodStatusRecord','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'ServiceStatus','ServiceResult'};
    }
    public class ValidateNumberResponse_element {
        public wwwStrikeironComPhoneValidation3.SIWsOutputOfPhoneValResult ValidateNumberResult;
        private String[] ValidateNumberResult_type_info = new String[]{'ValidateNumberResult','http://www.strikeiron.com','SIWsOutputOfPhoneValResult','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'ValidateNumberResult'};
    }
    public class SIWsResultArrayOfSIWsStatus {
        public wwwStrikeironComPhoneValidation3.ArrayOfSIWsStatus Results;
        private String[] Results_type_info = new String[]{'Results','http://www.strikeiron.com','ArrayOfSIWsStatus','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'Results'};
    }
    public class ArrayOfMethodStatusRecord {
        public wwwStrikeironComPhoneValidation3.MethodStatusRecord[] MethodStatusRecord;
        private String[] MethodStatusRecord_type_info = new String[]{'MethodStatusRecord','http://www.strikeiron.com','MethodStatusRecord','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'MethodStatusRecord'};
    }
    public class ArrayOfZipInfo {
        public wwwStrikeironComPhoneValidation3.ZipInfo[] ZipInfo;
        private String[] ZipInfo_type_info = new String[]{'ZipInfo','http://www.strikeiron.com','ZipInfo','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'ZipInfo'};
    }
    public class SIWsOutputOfPhoneValResult {
        public wwwStrikeironComPhoneValidation3.SIWsStatus ServiceStatus;
        public wwwStrikeironComPhoneValidation3.PhoneValResult ServiceResult;
        private String[] ServiceStatus_type_info = new String[]{'ServiceStatus','http://www.strikeiron.com','SIWsStatus','0','1','false'};
        private String[] ServiceResult_type_info = new String[]{'ServiceResult','http://www.strikeiron.com','PhoneValResult','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'ServiceStatus','ServiceResult'};
    }
    public class SIWsResultArrayOfMethodStatusRecord {
        public wwwStrikeironComPhoneValidation3.ArrayOfMethodStatusRecord Results;
        private String[] Results_type_info = new String[]{'Results','http://www.strikeiron.com','ArrayOfMethodStatusRecord','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'Results'};
    }
    public class SIWsResultArrayOfServiceInfoRecord {
        public wwwStrikeironComPhoneValidation3.ArrayOfServiceInfoRecord Results;
        private String[] Results_type_info = new String[]{'Results','http://www.strikeiron.com','ArrayOfServiceInfoRecord','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'Results'};
    }
    public class ValidateNumber_element {
        public String PhoneNumber;
        private String[] PhoneNumber_type_info = new String[]{'PhoneNumber','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'PhoneNumber'};
    }
    public class ArrayOfServiceInfoRecord {
        public wwwStrikeironComPhoneValidation3.ServiceInfoRecord[] ServiceInfoRecord;
        private String[] ServiceInfoRecord_type_info = new String[]{'ServiceInfoRecord','http://www.strikeiron.com','ServiceInfoRecord','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'ServiceInfoRecord'};
    }
    public class SIWsOutputOfSIWsResultArrayOfServiceInfoRecord {
        public wwwStrikeironComPhoneValidation3.SIWsStatus ServiceStatus;
        public wwwStrikeironComPhoneValidation3.SIWsResultArrayOfServiceInfoRecord ServiceResult;
        private String[] ServiceStatus_type_info = new String[]{'ServiceStatus','http://www.strikeiron.com','SIWsStatus','0','1','false'};
        private String[] ServiceResult_type_info = new String[]{'ServiceResult','http://www.strikeiron.com','SIWsResultArrayOfServiceInfoRecord','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'ServiceStatus','ServiceResult'};
    }
    public class GetServiceInfoResponse_element {
        public wwwStrikeironComPhoneValidation3.SIWsOutputOfSIWsResultArrayOfServiceInfoRecord GetServiceInfoResult;
        private String[] GetServiceInfoResult_type_info = new String[]{'GetServiceInfoResult','http://www.strikeiron.com','SIWsOutputOfSIWsResultArrayOfServiceInfoRecord','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'GetServiceInfoResult'};
    }
    public class GetStatusCodesForMethod_element {
        public String MethodName;
        private String[] MethodName_type_info = new String[]{'MethodName','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.strikeiron.com','true','false'};
        private String[] field_order_type_info = new String[]{'MethodName'};
    }
}