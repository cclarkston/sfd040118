global class Sched_BulkPrint_Cleanup implements Schedulable {
  global void execute(SchedulableContext ctx) {
  	Ctrl_BulkPrintLetters.update_task_entries();
    lead_mail_cleanup.check_for_lead_cleanup();        
  }
  //System.schedule('Clean Bulk Queue','0 21 * * * ?',new Sched_BulkPrint_Cleanup());
}