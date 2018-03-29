@RestResource(urlMapping='/DragAndDrop/v1/*')
/*http://www.jitendrazaa.com/blog/salesforce/salesforce-drag-and-drop-file-uploader-component-with-progress-bar-html5-and-pure-javascript-based/*/
global with sharing class DragAndDropRESTAPI
{
    @HttpPost
    global static String attachDoc(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;

        String fName = req.params.get('FileName');
        String parId = req.params.get('parId');
        Blob postContent = req.requestBody; 

        Attachment a = new Attachment (ParentId = parId,
                                       Body = postContent,
                                       Name = fName);
        
        insert a;
        Account patient = [select id,before_photo_url__c,after_photo_url__c from Account where id = :parId];
        if(fname.contains('Before')) {          
          patient.before_photo_url__c = '/servlet/servlet.FileDownload?file='+a.id;
        } 
        if(fname.contains('After')) {          
          patient.after_photo_url__c = '/servlet/servlet.FileDownload?file='+a.id;
        }           
        return a.Id;
   }
}