@isTest
private class TestLeadTrigger {
  static Lead lead;
  static Contact contact;
  static List<RecordType> recordTypes;
  static Campaign campaign;
  static CampaignMember campaignMember;
  static Center_Information__c center;
  static Sales_Region__c region;

  @testSetup static void setup() {
    Id userId = UserInfo.getUserId();

    region = new Sales_Region__c(Name ='Test Region',
                                 RBD__c = UserId
                               );

    insert region;

    center = new Center_Information__c(Name = 'Atlanta',
                                       Sales_Region__c = region.ID,
                                       Latlong__Longitude__s = 30,
                                       Latlong__Latitude__s = 30,
                                       Street_1__c = '123 Main St',
                                       City__c = 'Atlanta',
                                       State__c = 'GA'
                                     );

    insert center;

    insert new Contact(LastName = 'User');
    Lead lead = new Lead(FirstName = 'Test',
                         LastName = 'User',
                         Street = '1313 Test Lane',
                         City = 'Test City',
                         State = 'AL',
                         PostalCode = '01234-5678',
                         Date_of_Birth__c = Date.newInstance(2000, 1, 1),
                         Center__c = center.Id
                       );
   insert lead;
   insert new Consult_Camera_Video__c(Lead__c = lead.Id);
  }

  static void init() {
    contact = [SELECT Id
               FROM Contact
               LIMIT 1
             ];

    lead = [SELECT Id, Call_Result__c, Distance_To_Center__c, Pre_Screen__c
            FROM Lead
            WHERE  IsConverted =:false
            LIMIT 1
          ];

    recordTypes = [SELECT Name, Id
                   FROM RecordType
      		         WHERE sObjectType='Campaign'
                   AND (DeveloperName='Seminar' or DeveloperName='Seminars')
                   LIMIT 1
                 ];

   center = [SELECT Id FROM Center_Information__c];
   region = [SELECT Id FROM Sales_Region__c];

   campaign = new Campaign();
   campaign.name = 'test';
   campaign.RecordTypeId = recordTypes[0].id;
   insert campaign;

   campaignMember = new CampaignMember();
   campaignMember.CampaignId  = campaign.id;
   campaignMember.LeadId = lead.id;
   insert campaignMember;
  }

  testMethod static void testCallResult(){
    init();

    Test.startTest();
    lead.Call_Result__c = 'Consultation Scheduled';
    lead.DateTime_Consult_Scheduled__c = datetime.newInstance(2008, 12, 1, 10, 10, 10);
    lead.phone='1111111111';
    lead.Refused_to_give_email__c=true;
    lead.Original_Phone__c = NULL;
    update lead;

    lead.Status = 'Not Scheduled';

    // lead.Call_Result__c = 'Same Day Cancellation Appointment';
    // update lead;

    // lead.Call_Result__c = 'Seminar Scheduled';
    // update lead;
    //
    // lead.Call_Result__c = 'Same Day Cancellation Appointment';
    // update lead;
    //
    // lead.Call_Result__c = 'Consult Scheduled';
    // update lead;
    //
    // lead.Call_Result__c = 'Cancelled Appointment';
    // update lead;
    //
    // lead.Status = 'Consult Scheduled';
    // lead.Call_Result__c = 'Same Day Rescheduled Consult';
    // update lead;
    //
    // lead.Status = 'No Show';
    // lead.Call_Result__c = 'Consultation Scheduled';
    // update lead;

    Test.stopTest();
  }

  testMethod static void testUpdatesConsultCameraLinks() {
    init();
    // convert lead
    Database.LeadConvert leadConvert = new database.LeadConvert();
    leadConvert.setLeadId(lead.Id);

    LeadStatus convertStatus = [SELECT Id, MasterLabel
                                FROM LeadStatus
                                WHERE IsConverted=true
                                LIMIT 1
                              ];
    leadConvert.setConvertedStatus(convertStatus.MasterLabel);
    Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
    System.assert(leadConvertResult.isSuccess());
  }

  testMethod static void testAssignsPrositeReferrals() {
    init();
    lead.Marketing_Source__c = 'CSITES_';
    lead.ClearSites_Id__c = '123';

    update lead;

    Lead updatedLead = [SELECT Inbound_Call__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assertEquals('Prosites Referrals', updatedLead.Inbound_Call__c);
  }

  testMethod static void testAssignsWarrantyId() {
    init();
    lead.Warranty_Id__c = null;
    update lead;

    Lead updatedLead = [SELECT Warranty_Id__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assert(updatedLead.Warranty_Id__c != null);
  }

  testMethod static void testUpcaseCityName() {
    init();
    lead.City = 'case city';
    update lead;

    Lead updatedLead = [SELECT City
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assertEquals('Case city', updatedLead.City);
  }

  testMethod static void testAddsDistanceToCenterIfUpdatedDistanceToCenterIsZero() {
    init() ;
    lead.Distance_To_Center__c = 42;
    update lead;
    lead.Distance_To_Center__c = 0;
    update lead;

    Lead updatedLead = [SELECT Distance_To_Center__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assertEquals(42, updatedLead.Distance_To_Center__c);
  }

  testMethod static void testItChecksUpdatedPostalCodeZipDemographic() {
    init();
    Zip_Demographic__c demographic = new Zip_Demographic__c(Zipcode__c = '80111');
    insert demographic;
    lead.PostalCode = '80111'; // different from original PostalCode
    update lead;

    Lead updatedLead = [SELECT Zip_Demographic__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];
    Integer length = String.valueOf(updatedLead.Zip_Demographic__c).length();
    System.assert(updatedLead.Zip_Demographic__c != null);
    System.assertEquals(18, length);
  }

  testMethod static void testZipDemographicException() {
    // hits code but makes no assertions

    init();
    lead.PostalCode = '80111'; // different from original PostalCode
                               // zip not in Zip_Demographic__c
    update lead;

    Lead updatedLead = [SELECT Zip_Demographic__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assertEquals(null, updatedLead.Zip_Demographic__c);
  }

  testMethod static void testCatchersMittWasAddedToAlert() {
    init();

    // FIXME: can't add campaign name

    // Campaign catchersMitt = new Campaign(Name = 'Infocision- Catcher\'s Mitt Leads',
    //                                      Status = 'In Progress',
    //                                      StartDate = Date.today()
    //                                    );
    // insert catchersMitt;
    // Campaign[] cmitt = [select id, name, status, startdate from Campaign];
    // for (Campaign campaign : cmitt) {
    //   System.debug('crash: ' + campaign.Id);
    //   System.debug('crash: ' + campaign.Name);
    //   System.debug('crash: ' + campaign.Status);
    //   System.debug('crash: ' + campaign.StartDate);
    // }

    lead.Sales_Alert__c = 'test alert';
    update lead;
    lead.Sales_Alert__c = 'CONTACT-CM';
    update lead;

    Lead updatedLead = [SELECT Zip_Demographic__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];
  }

  testMethod static void testReferralOfficeValue() {
    // hits code but makes no assertions

    init();
    // create 2 dental practices
    Dental_Practice__c practice = new Dental_Practice__c(
                                            Center_Information__c = center.Id);
    insert practice;

    Dental_Practice__c second_practice = new Dental_Practice__c(
                                            Center_Information__c = center.Id);
    insert second_practice;

    // set first practice on lead and update
    lead.Referral_Office__c = practice.Id;
    update lead;

    // created dependencies
    String recordId = [SELECT Id
                       FROM RecordType
                       WHERE SobjectType = 'Account'
                       AND Name = 'Prospective Patients'].Id;

    Account account = new Account(FirstName = 'Test',
                                  LastName = 'Account',
                                  Center__c = center.Id,
                                  PersonMobilePhone = '3033333333',
                                  RecordTypeId = recordId,
                                  Language_Spoken__c = 'Spanish',
                                  Dental_Practice_Partner__c = second_practice.Id
                                );

    insert account;

    Contact contact = new Contact(FirstName = 'Test',
                                  LastName = 'Contact',
                                  Account = account
                                );
    insert contact;

    Profile standardProfile = [SELECT Id
                               FROM Profile
                               WHERE Name = 'Standard User'
                               LIMIT 1
                             ];

    User user = new User(FirstName = 'Test',
                         LastName = 'User',
                         Alias = 'alias',
                         UserName = 'test-leadbefore-user@clearchoice.com',
                         ProfileId = standardProfile.Id,
                         Email = 'software-dev@clearchoice.com',
                         TimeZoneSidKey = 'America/Los_Angeles',
                         EmailEncodingKey = 'UTF-8',
                         LanguageLocaleKey = 'en_US',
                         LocaleSidKey = 'en_US',
                         Contact = contact
                       );
    insert user;

    lead.Referral_Office__c = second_practice.Id;
    update lead;
  }

  testMethod static void testIfCenterChangedCheckRecordType() {
    init();
    Center_Information__c secondCenter = new Center_Information__c(
                                                   Name = 'Denver',
                                                   Sales_Region__c = region.ID,
                                                   Latlong__Longitude__s = 30,
                                                   Latlong__Latitude__s = 30,
                                                   Type__c = ''
                                                 );
    insert secondCenter;

    lead.Center__c = secondCenter.Id;
    update lead;
    Lead updatedLead = [SELECT RecordTypeId
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];
    // System.assertEquals('012V00000004TMKIA2', updatedLead.RecordTypeId);

    Center_Information__c thirdCenter = new Center_Information__c(
                                                   Name = 'Philadelphia',
                                                   Sales_Region__c = region.ID,
                                                   Latlong__Longitude__s = 30,
                                                   Latlong__Latitude__s = 30,
                                                   Type__c = 'Network Center'
                                                 );
    insert thirdCenter;

    lead.Center__c = thirdCenter.Id;
    update lead;
    Lead updatedLead2 = [SELECT RecordTypeId
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];
    // System.assertEquals('012V00000004TMUIA2', updatedLead2.RecordTypeId);
  }

  testMethod static void testDistanceToCenter() {
    init();
    System.assertEquals(null, lead.Distance_To_Center__c);

    lead.Street = '456 Main St';
    update lead;

    // NOTE: this doesn't test anything
    System.assertEquals(null, lead.Distance_To_Center__c);
  }

  testMethod static void testSetPrescreenToInsufficientInformation() {
    init();
    System.assertEquals('Insufficient Information', lead.Pre_Screen__c);
  }

  testMethod static void testSetPrescreenToPoBox() {
    init();
    System.assertEquals('Insufficient Information', lead.Pre_Screen__c);

    lead.Street = 'Po Box 12345';
    update lead;

    Lead updatedLead = [SELECT Pre_Screen__c
                        FROM Lead
                        WHERE Id = :lead.Id
                      ];

    System.assertEquals('PO Box', updatedLead.Pre_Screen__c);
  }
}