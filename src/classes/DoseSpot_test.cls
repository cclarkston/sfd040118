public class DoseSpot_test {
    public class BadPatientDataException extends Exception {}
    public class DoseSpotSubmissionException extends Exception {}

    final String DoseSpot_server = 'https://my.staging.dosespot.com';
    public final String single_signon_location = DoseSpot_server + '/LoginSingleSignOn.aspx';

    String key;
    String user_id;
    public String clinician_id;
    String clinic_id;
    String phrase;
    Integer phrase_length;

    Account patient = new Account();


    public DoseSpot_test() {
        load_api_values();
    }

    public DoseSpot_test(ID patient_ID) {
        load_api_values();
        patient = patient(patient_ID);
    }

            private void load_api_values() {
                key               = Test.isRunningTest() ? 'abcdefghijklmnopqrstuvwxyzabcdef' : 'Dt5K6ktpZWYMFkK6tWJVhGdyR7KsjdYP';
                User current_user = [SELECT DoseSpot_User_ID__c, Clinic_Calendar__c FROM User WHERE ID = :UserInfo.getUserId()];
                clinic_ID         = [SELECT DoseSpot_Clinic_ID__c FROM Center_Information__c WHERE Name = :current_user.Clinic_Calendar__c].DoseSpot_Clinic_ID__c;
                user_ID           = current_user.DoseSpot_User_ID__c;
                clinician_id      = user_ID;
                phrase_length     = 32;
                phrase            = Test.isRunningTest() ? '12345678901234567890123456789012' : random_string(phrase_length);
                // phrase            = 'H3KYX9VQkl87S4U64IXH30FROOR560gC'; // This line is only for development. Should use random phrase in production.
            }


    public String DoseSpot_patient_URL() {
        try {
            Boolean is_new_to_DoseSpot = (patient.DoseSpot_Patient_ID__c == null || patient.DoseSpot_Patient_ID__c == '');
            System.debug('Boolean : ' + is_new_to_DoseSpot);
            final String endpoint = patient_detail_URL();

            if (is_new_to_DoseSpot) {
                HttpRequest     request     = new HttpRequest();
                HttpResponse    response    = new HttpResponse();
                Http            http        = new Http();

                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setTimeout(120000);
                request.setBody('');

                response = http.send(request);
                // 302 is the desired status code - DoseSpot redirects to the patient's information page if successful. Status code 200 could indicate a failed login or other error.
                if (response.getStatusCode() == 302) {
                    final String redirect_location = response.getHeader('Location');
                    final String DoseSpot_patient_ID = DoseSpot_patient_ID_parameter(redirect_location);
                    patient.DoseSpot_Patient_ID__c = DoseSpot_patient_ID;
                    try {
                        update patient;
                        return endpoint.replace('PatientID=', 'PatientID=' + DoseSpot_patient_ID);} catch (DMLException e) {String error = 'Failed to update Salesforce with the new patient ID provided by DoseSpot.'; patient.addError(error); return error;}
                }
                else {
                    String error = 'Submission to DoseSpot failed.';
                    throw new DoseSpotSubmissionException(error);
                    return error;
                }
            }
            return endpoint;
        }
        catch (BadPatientDataException error) {
            String message = 'Failed to submit patient data to DoseSpot: ' + error.getMessage();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, message));
            return message;}
    }

    public Map<String, String> signon_details() {
        return new Map<String, String>{'ClinicId'       => clinic_id,
                                       'UserId'         => user_id,
                                       'Code'           => single_signon_code(),
                                       'UserIdVerify'   => single_signon_user_id_verify(),
                                       'PhraseLength'   => String.valueOf(phrase_length),
                                       'ClinicianId'    => clinician_id};
    }

    public String refill_requests_and_transmission_errors_URL() {
        return single_signon_location + '?' + signon_attributes() + '&RefillsErrors=1';
    }


        private Account patient(ID patient_ID) {
            return [SELECT  DoseSpot_Patient_ID__c,
                            Salutation,
                            FirstName,
                            LastName,
                            Date_of_Birth__c,
                            Gender__c,
                            BillingStreet,
                            BillingCity,
                            BillingState,
                            BillingPostalCode,
                            Phone,
                            PersonMobilePhone
                    FROM Account
                    WHERE ID = :patient_ID];
        }

        public String patient_detail_URL() {
            return single_signon_location + '?' + signon_attributes() + '&' + patient_attributes();
        }

        private String DoseSpot_patient_ID_parameter(String redirect_location) {
            //Based on DoseSpot's PHP example...
            //Expecting a location string with only PatientID parameter... Split string on '=' and provide the second piece.
            return redirect_location.split('=')[1];
        }

        private String signon_attributes() {
            return
                'SingleSignOnClinicId=' + clinic_id +
                '&SingleSignOnUserId=' + user_id +
                '&SingleSignOnPhraseLength=' + String.valueOf(phrase_length) +
                '&SingleSignOnCode=' + single_signon_code_url_encoded() +
                '&SingleSignOnUserIdVerify=' + single_signon_user_id_verify_url_encoded();
        }

        private String patient_attributes() {
            Map<String, String> required_patient_info = new Map<String, String>{'First Name'    => truncate(patient.FirstName, 35),
                                                                                'Last Name'     => truncate(patient.LastName, 35),
                                                                                'Date of Birth' => DoseSpot_DOB(patient.Date_of_Birth__c),
                                                                                'Gender'        => DoseSpot_gender(patient.Gender__c),
                                                                                'Street'        => DoseSpot_street(patient.BillingStreet),
                                                                                'City'          => truncate(patient.BillingCity, 35),
                                                                                'State'         => patient.BillingState,
                                                                                'Zip Code'      => DoseSpot_zipcode(patient.BillingPostalCode),
                                                                                'Phone Number'  => DoseSpot_phone(patient.Phone, patient.PersonMobilePhone)};

            Map<String, String> optional_patient_info = new Map<String, String>{'Patient ID'    => DoseSpot_patient_ID(patient.DoseSpot_patient_ID__c),
                                                                                'Prefix'        => DoseSpot_patient_prefix(patient.Salutation)};

            String[] missing_info = missing_patient_info(required_patient_info);
            if (missing_info.size() > 0) {throw new BadPatientDataException( 'Missing (or malformed) data: ' + String.join(missing_info, ', ') );}
            else {
                return
                    'PatientID='    + optional_patient_info.get('Patient ID') +
                    '&Prefix='      + optional_patient_info.get('Prefix') +
                    '&FirstName='   + required_patient_info.get('First Name') +
                    '&MiddleName='  +
                    '&LastName='    + required_patient_info.get('Last Name') +
                    '&Suffix='      +
                    '&DateOfBirth=' + required_patient_info.get('Date of Birth') +
                    '&Gender='      + required_patient_info.get('Gender') +
                    '&MRN='         +
                    '&Address1='    + required_patient_info.get('Street') +
                    '&Address2='    +
                    '&City='        + required_patient_info.get('City') +
                    '&State='       + required_patient_info.get('State') +
                    '&ZipCode='     + required_patient_info.get('Zip Code') +
                    '&PrimaryPhone='+ required_patient_info.get('Phone Number') +
                    '&PrimaryPhoneType=Primary' +
                    '&PharmacyID=';
            }
        }

        private String[] missing_patient_info(Map<String, String> patient_info) {
            String[] missing_info = new String[]{};
            for (String key : patient_info.keySet()) {
                if (String.isBlank(patient_info.get(key))) {missing_info.add(key);}
            }
            return missing_info;
        }

        private String single_signon_code() {
            final String base = phrase + key;
    		return phrase + encoded_base64(base);
        }

        private String single_signon_code_url_encoded() {
            return EncodingUtil.urlEncode(single_signon_code(), 'UTF-8');
        }

        private String single_signon_user_id_verify() {
            final String base = user_id + phrase.substring(0,22) + key;
            return encoded_base64(base);
        }

        private String single_signon_user_id_verify_url_encoded() {
            return EncodingUtil.urlEncode(single_signon_user_id_verify(), 'UTF-8');
        }

		private String random_string(Integer output_length) {
		    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
		    String result = '';
		    while (result.length() < output_length) {
		       Integer i = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
		       result += chars.substring(i, i + 1);
		    }
		    return result;
		}

        private String encoded_base64(String input) {
            Blob bytes                  = Blob.valueOf(input);
            Blob hash					= Crypto.generateDigest('SHA-512', bytes);
            final String base64_string	= EncodingUtil.base64Encode(hash);
            return string_without_trailing_equals(base64_string);
        }

		private String string_without_trailing_equals(String input) {
			Integer string_length = input.length();
			return input.substring(string_length - 2, string_length) == '==' ? input.substring(0, string_length - 2) : input;
		}

        private String DoseSpot_patient_ID(String DoseSpot_patient_ID) {
            // PatientId is left blank when adding a new patient, and a new DoseSpot record is created in that case.
            // If the patient is already in DoseSpot's system, the PatientId must be provided to avoid creation of a duplicate DoseSpot record.
            return (DoseSpot_patient_ID == null) ? '' : DoseSpot_patient_ID;
        }

        private String DoseSpot_patient_prefix(String prefix) {
            // DoseSpot prefix can have up to 10 characters. If our salutation is longer, remove it (opting to remove rather than risk bad truncation)
            return (prefix == null || prefix.length() > 10) ? '' : prefix;
        }

        private String DoseSpot_DOB(Date birthday) {
            // DOB must be on or before today
            if (birthday == null || birthday > Date.today()) {return null;}
            else {
                String month    = (birthday.month() <= 9) ? '0' + String.valueOf(birthday.month()) : String.valueOf(birthday.month());
                String day      = (birthday.day() <= 9) ? '0' + String.valueOf(birthday.day()) : String.valueOf(birthday.day());
                String year     = String.valueOf(birthday.year());

                return month + '-' + day + '-' + year;
            }
        }

        private String DoseSpot_gender(String gender) {
            return (gender != null && (gender.toLowerCase() == 'male' || gender.toLowerCase() == 'female')) ? gender.toLowerCase().capitalize() : 'Unknown';
        }

        private String DoseSpot_street(String street) {
            street = street.replaceAll('[\\t\\n\\x0B\\f\\r]', '--');
            return truncate(street, 35);
        }

        private String DoseSpot_zipcode(String zipcode) {
            // Must be five-digit or five-digit plus four - Ex. 01234 or 01234-0123
            return (zipcode != null && Pattern.matches('\\d{5}(-\\d{4})?', zipcode)) ? zipcode : '';
        }

        private String DoseSpot_phone(String phone, String mobile) {
            // Assign Phone as 'primary' number unless it's blank and mobile number is present. If the area code is acceptable, return the primary phone number.
            String primary;
            if (String.isNotBlank(phone))       {primary = phone;}
            else if (String.isNotBlank(mobile)) {primary = mobile;}
            else return '';

            Integer area_code = Integer.valueOf(primary.substring(1,4));
            if (area_code_is_valid(area_code)) {return primary;}
            else {
                throw new BadPatientDataException('The provided area code, ' + area_code + ', is not in our list of valid area codes.');
                return '';
            }
        }

        private Boolean area_code_is_valid(Integer area_code) {
            Set<Integer> valid_area_codes = new Set<Integer>{201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 212, 213, 214, 215, 216, 217, 218, 219, 224, 225, 226, 228, 229, 231, 234,
                                                             239, 240, 242, 246, 248, 250, 251, 252, 253, 254, 256, 260, 262, 264, 267, 268, 269, 270, 276, 281, 284, 289, 301, 302, 303,
                                                             304, 305, 306, 307, 308, 309, 310, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 323, 325, 330, 331, 334, 336, 337, 339,
                                                             340, 343, 345, 347, 351, 352, 360, 361, 385, 386, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 412, 413, 414, 415, 416,
                                                             417, 418, 419, 423, 424, 425, 430, 432, 434, 435, 438, 440, 441, 442, 443, 450, 456, 458, 469, 470, 473, 475, 478, 479, 480,
                                                             484, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 512, 513, 514, 515, 516, 517, 518, 519, 520, 530, 533, 534, 540,
                                                             541, 551, 559, 561, 562, 563, 567, 570, 571, 573, 574, 575, 579, 580, 581, 585, 586, 587, 600, 601, 602, 603, 604, 605, 606,
                                                             607, 608, 609, 610, 612, 613, 614, 615, 616, 617, 618, 619, 620, 623, 626, 630, 631, 636, 641, 646, 647, 649, 650, 651, 657,
                                                             660, 661, 662, 664, 670, 671, 678, 681, 682, 684, 700, 701, 702, 703, 704, 705, 706, 707, 708, 709, 710, 712, 713, 714, 715,
                                                             716, 717, 718, 719, 720, 724, 727, 731, 732, 734, 740, 747, 754, 757, 758, 760, 762, 763, 765, 767, 769, 770, 772, 773, 774,
                                                             775, 778, 779, 780, 781, 784, 785, 786, 787, 800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 812, 813, 814, 815, 816,
                                                             817, 818, 819, 828, 829, 830, 831, 832, 843, 845, 847, 848, 849, 850, 855, 856, 857, 858, 859, 860, 862, 863, 864, 865, 866,
                                                             867, 868, 869, 870, 872, 876, 877, 878, 888, 900, 901, 902, 903, 904, 905, 906, 907, 908, 909, 910, 912, 913, 914, 915, 916,
                                                             917, 918, 919, 920, 925, 928, 931, 936, 937, 938, 939, 940, 941, 947, 949, 951, 952, 954, 956, 970, 971, 972, 973, 978, 979,
                                                             980, 985, 989};
            return valid_area_codes.contains(area_code);
        }

        private String truncate(String input, Integer max) {
            return (input != null) ? input.left(max) : '';
        }
}