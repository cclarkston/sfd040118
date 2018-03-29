global with sharing class AnyObjectSignatureController {
  public Boolean modal_display {get;set;}

  public AnyObjectSignatureController() {
    modal_display = true;
  }

  public void display_signature_pop() {
    modal_display = true;
  }

  public void display_signature_form() {
        modal_display = true;           
  }
  
  public void close_modal() {
        modal_display = false;
  }
  
  public String getparent_id() {
    Account act = [SELECT Id, Name FROM account where name like 'Chris Alert test%' limit 1];
    return act.id;
  }
  
  public String getsignature_image() {
        Account act = [SELECT Id, Name FROM account where name like 'Chris Alert test%' limit 1];
        try {
          Attachment a = [select body from Attachment where parentid = :act.id and name = 'Signature Capture.png' order by createddate desc limit 1];
          return EncodingUtil.base64encode(a.body);
        } catch (Exception e) {
                return 'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAzklEQVQ4y2P4//8/AyWYgWoGwMEFBi0g' +
      'XgLEb4H4FxD/BuLXQNwHxPwwZdgNuMDgDcS3GR4w7Gf4yfCE4T8UgtggsQsMH4DYHrsBFxiUgfgVw1eG' +
      'm3CN6BAkd4HhGhArYTNgDtiW/wQgxCVTsBnwCcXZuCBIzQWGB9gM+EdQMwxeYPiGzYD/JBjwFZsBz0jw' +
      'wh1sBswiIRAbsBkgDsTviIjGpyC1uBKSJRBfx5OQLgOxLu6UCDFEEYh7oQnmCyjEgfgeELcAsSzOpDxg' +
      'uREA1co5dU5YrgAAAAAASUVORK5CYII=';
        }
  }
  
  /*@RemoteAction global static RemoteSaveResult saveSignature(Id ehsId, String signatureBody) {
        Account act = [SELECT Id, Name FROM account where name like 'Chris Alert test%' limit 1];
        System.debug('Account : ' + act);
        System.debug('signatureBody : ' + signatureBody);               
    Attachment a = new Attachment(ParentId=act.id, name='Signature.png', ContentType='image/png', Body=EncodingUtil.base64Decode(signatureBody));
    System.debug('Attachment ' + a);
    Database.saveResult result = Database.insert(a,false);
    RemoteSaveResult newResult = new RemoteSaveResult();
    newResult.success = result.isSuccess();
    newResult.attachmentId = a.Id;
    newResult.errorMessage = result.isSuccess()?'':result.getErrors()[0].getMessage();
    return newResult;
  }

  global class RemoteSaveResult {
    public Boolean success;
    public Id attachmentId;
    public String errorMessage;
  }*/
  
  @RemoteAction
  global static String saveSignature(String signatureBody, String parentId) {
    try {
      system.debug('Record Id == ' + parentId);
      system.debug(signatureBody);
      Attachment a = new Attachment();
      a.ParentId = parentId;
      a.Body = EncodingUtil.base64Decode(signatureBody);
      a.ContentType = 'image/png';
      a.Name = 'Signature Capture.png';
      insert a;
      return '{success:true, attachId:' + a.Id + '}';
    }  catch(Exception e) {
      return JSON.serialize(e);
    }    
    return null;
  }

}