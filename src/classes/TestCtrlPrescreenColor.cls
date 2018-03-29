@isTest
private class TestCtrlPrescreenColor {
  static Lead lead;
  static PageReference pageReference;
  static CtrlPrescreenColor extension;

  @testSetup static void setup() {
    insert new Lead(
      FirstName = 'Test',
      LastName = 'Patient',
      Street = '123 Main St',
      City = 'Denver',
      State = 'CO',
      PostalCode = '80111'
    );
  }

  private static void init() {
    lead = [SELECT Id, Pre_Screen__c, LeadScore__c
            FROM Lead
            LIMIT 1
          ];

    pageReference = Page.PreScreenPage;
    pageReference.getParameters().put('id', lead.Id);
    Test.setCurrentPage(pageReference);

    ApexPages.StandardController controller =
                                        new ApexPages.standardController(lead);
    extension = new CtrlPrescreenColor(controller);
  }

  static TestMethod void testAssignsColor() {
    lead = [SELECT Id, Pre_Screen__c, LeadScore__c
            FROM Lead
            LIMIT 1
          ];
    lead.Pre_Screen__c = 'Red';
    update lead;

    init();

    System.assertEquals('Red', lead.Pre_Screen__c);
    System.assertEquals('Red', lead.LeadScore__c);
    System.assertEquals(extension.color, 'red');
  }

  static TestMethod void testAssignsPoBox() {
    lead = [SELECT Id, Pre_Screen__c, LeadScore__c
            FROM Lead
            LIMIT 1
          ];
    lead.Pre_Screen__c = 'PO Box';
    update lead;

    init();

    System.assertEquals('PO Box', lead.Pre_Screen__c);
    System.assertEquals('PO Box', lead.LeadScore__c);
    System.assertEquals(extension.color, 'purple');
  }
}