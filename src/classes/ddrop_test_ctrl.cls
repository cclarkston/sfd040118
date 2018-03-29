public with sharing class ddrop_test_ctrl {
  public Document doc {get;set;}
  public transient String photo_data {get;set;}
  public transient String photo_content_type {get;set;}
  public transient String photo_name {get;set;}
  public transient List<Attachment> last_photo_id {get;set;}
  public List<Attachment> uploaded_docs {get;set;}
  public Boolean display_photo_holder {get;set;}
  public Boolean display_attachment_holder {get; set;}
  
  
  public ddrop_test_ctrl() {
  	doc = new document();
  	last_photo_id = new List<Attachment>();
  	display_photo_holder = false;
  	display_attachment_holder = false;
  	uploaded_docs = new List<Attachment>();
  }
  
  public String gettest_id() {
  	Account a = [select id,name from Account where name = 'Mary America' limit 1];
  	return a.id;
  }
  
  @RemoteAction public static Id Save_Photo_Image(String pid, String contentType, String data) {
    try {
      Attachment a = new Attachment(parentid = pid, description = 'Patient Photo', contentType=contentType, Body=EncodingUtil.base64Decode(data));
      insert a;
      Account photo_patient = [select nickname__c,id,name,phone,email__c,billingStreet,billingcity,billingstate,billingpostalcode,personmobilephone,emergency_contact_name__c,emergency_contact_phone__c,
      clinical_notes__c,isPersonAccount,firstname,lastname,date_of_birth__c,PersonContactId,main_photo_id__c,personemail, warranty_id__c
      from Account where id = :pid];
      photo_patient.main_photo_id__c = a.id; 
      update photo_patient;
      return a.id;
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add the photo.  Please contact IT for help'));
      ApexPages.addMessages(e);
      return null;  
    }    
  }
  
  public void af_load_photo() {
  	try {
      Attachment a = new Attachment(name = photo_name,parentid = gettest_id(), description = 'Patient Photo', contentType=photo_content_type, Body=EncodingUtil.base64Decode(photo_data));
      insert a;
      Account photo_patient = [select nickname__c,id,name,phone,email__c,billingStreet,billingcity,billingstate,billingpostalcode,personmobilephone,emergency_contact_name__c,emergency_contact_phone__c,
      clinical_notes__c,isPersonAccount,firstname,lastname,date_of_birth__c,PersonContactId,main_photo_id__c,personemail, warranty_id__c
      from Account where id = :gettest_id()];
      photo_patient.main_photo_id__c = a.id; 
      update photo_patient;
      last_photo_id = [Select a.SystemModstamp, a.ParentId, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsPrivate, a.IsDeleted, a.Id, a.Description, a.CreatedDate, a.CreatedById, a.ContentType, a.BodyLength, a.Body From Attachment a
  	  where parentid = :gettest_id() and description = 'Patient Photo' order by createddate desc];
      display_photo_holder = true;
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add the photo.  Please contact IT for help'));
      ApexPages.addMessages(e);  
    }   
  }
  
  public void af_load_attachment() {
  	try {
  	  Attachment a = new Attachment(name = photo_name,parentid = gettest_id(), description = 'Attachment Test', contentType=photo_content_type, Body=EncodingUtil.base64Decode(photo_data));
      insert a;
  	  uploaded_docs = [Select a.SystemModstamp, a.ParentId, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.IsPrivate, a.IsDeleted, a.Id, a.Description, a.CreatedDate, a.CreatedById, a.ContentType, a.BodyLength, a.Body From Attachment a
  	  where parentid = :gettest_id() and description = 'Attachment Test' order by createddate desc];
  	  display_attachment_holder = true;
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to add the file.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}
  }
}