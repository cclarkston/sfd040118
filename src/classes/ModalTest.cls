public with sharing class ModalTest {
  public String modal_out {get; set;}
  public Boolean modal_display {get; set;}
  
  public ModalTest() {
        modal_out = '';         
        modal_display = false;
  } 
  
  public Pagereference close_modal() {
        modal_display = false;
        modal_out = '';
        return null;
  }
  
  public Pagereference deactivate_test() {
        modal_out = '<p style="padding-top:1em;margins:auto;text-align:center;">Deactivating this appointment will remove any unscheduled blocks from the calendar.<br /><br />Are you sure you want to continue?<br /><br /><apex:commandButton value="Hide Pop up" action="{!closePopup}" rerender="tstpopup"/>';
        modal_display = true;
        return null;
  }
}