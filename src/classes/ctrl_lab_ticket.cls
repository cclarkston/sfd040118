public with sharing class ctrl_lab_ticket {
        public boolean display_admin;
  public boolean display_standard;
        public boolean display_error_msg {get; set;}
  public String error_msgs {get; set;}
  ID ticket_id;
  public Lab_Case__c lab_ticket {get; set;}
  Lab_Case_Note__c[] lab_notes;
  public Lab_Case_Note__c[] getlab_notes() { return lab_notes;}
  public Boolean modal_display {get; set;}
  public String modal_out {get; set;}
  public Lab_Case_Note__c new_note_holder {get; set;}
  
  public class Lab_Time {
        public Lab_Case_Times__c ltime {get; set;}
        public Boolean work_inprogress {get; set;}
        
        public Lab_Time(Lab_Case_Times__c my_time) {
          this.ltime = my_time;
          if(my_time.stop_time__c==null)
            work_inprogress = true;
          else
            work_inprogress = false;
          System.debug('WIP Check Init : ' + work_inprogress);
        }
        
        //method to return boolean indicating if the work can be stopped by the current user
        public Boolean getstop_allowed() {
                if(ltime.stop_time__c==null) {
                        if(ltime.work_by__c == userinfo.getuserid())
                          return true;
                        else
                          return false;
                }
                else 
                  return false;
        }
        
        //method to get time worked
        public Decimal gettime_worked() {
                System.debug('WIP Check Time : ' + work_inprogress);
                Decimal time_worked = 0;
                if(work_inprogress)
                  time_worked = ((datetime.now().gettime() -  ltime.start_time__c.gettime()) / (1000.00 * 60.00));
                else
                  time_worked = ((ltime.stop_time__c.gettime() - ltime.start_time__c.gettime()) / (1000.00 * 60.00)); 
                return time_worked.setscale(1);
        }
  }
  Lab_Time[] lab_times;
  public Lab_Time[] getlab_times() {return lab_times;}
  
  public ctrl_lab_ticket() {    
        reset_errors();         
        modal_display = false;
        modal_out = '';
    if(Apexpages.currentPage().getParameters().get('tid')==null) {
        display_error_msg = true;
        error_msgs = '<span class="warning">Error - Ticket # was not identified.  Please contact the IT team</span>';
        lab_ticket = new lab_case__c();
    }
    else {
        ticket_id = Apexpages.currentPage().getParameters().get('tid');
        refresh_lab_ticket();
        //lab_notes = [Select l.CreatedDate, l.Case_Notes__c,l.createdby.name From Lab_Case_Note__c l where lab_case__c = :lab_ticket.id order by createddate desc];
        refresh_lab_notes();            
        //pull lab_times here
        refresh_lab_times();
    }    
  }
  
  public void refresh_lab_notes() {
        lab_notes = [Select l.CreatedDate, l.Case_Notes__c,l.createdby.name From Lab_Case_Note__c l where lab_case__c = :lab_ticket.id order by createddate desc];
  }
  
  public void refresh_lab_ticket() {
        lab_ticket = [Select l.Windent_Patient__c, l.Time_To__c, l.Time_From__c, l.SystemModstamp, l.Status__c, l.Procedure_Type__c, l.OwnerId, l.Name, l.LastModifiedDate, 
          l.LastModifiedById, l.IsDeleted, l.Id, l.Due_Date__c, l.CreatedDate, l.CreatedById, l.Clinic_Name__c, l.Case_Type__c, l.Case_Type_Map__c, l.Assigned_To__c, 
          l.Assigned_Time__c, l.Assigned_By__c, l.Apt_Type_Id__c, l.Apt_Date__c, l.assigned_to__r.name, l.assigned_by__r.name, l.windent_patient__r.name, 
          l.windent_patient__r.home_phone__c, l.windent_patient__r.work_phone__c From Lab_Case__c l where id = :ticket_id];
  }
  
  public void refresh_lab_times() {
        lab_times = new lab_time[] {}; 
        for(Lab_Case_Times__c lc : [Select l.Work_by__c, l.Stop_Time__c, l.Start_Time__c, l.Manual_Adjustment__c, l.Lab_Case__c, l.Id, work_by__r.name From Lab_Case_Times__c l
                        where l.lab_Case__c = :lab_ticket.id order by l.start_time__c desc]) {
                  Lab_Time lt = new Lab_Time(lc);
                  lab_times.add(lt);            
                }
  }
  
  public Boolean getdisplay_admin() {
        if(display_admin==null) {
                Integer admin_count = [select count() from Profile where name in ('System Administrator','RBD','New System Administrator','System Administration - Test') and id = :Userinfo.getProfileId()];
            if(admin_count>0 || Test.isRunningTest()) {
              display_admin = true;
              display_standard = false;
            }
            else
              display_admin = false;
        }       
          return display_admin;
  }
  
  public Boolean getdisplay_standard() {
        if(display_standard==null) {
                Integer admin_count = [select count() from Profile where name in ('System Administrator','RBD','New System Administrator','System Administration - Test') and id = :Userinfo.getProfileId()];
            if(admin_count==0 || Test.isRunningTest()) {
              display_standard = true;
              display_admin = false;
            }
            else
              display_standard = false;
        }       
          return display_standard;
  }
  
  public void reset_errors() {
        display_error_msg = false;
        error_msgs = '';
  }

  public String gettotal_time() {
        Decimal ttime = 0;
        for(Lab_Time lt : lab_times) {
                ttime += lt.gettime_worked();
        }
        return string.valueof(ttime);
  }
  
  public void save_ticket() {
        try {   
                Lab_Case__c old_ticket = [Select l.Windent_Patient__c, l.Time_To__c, l.Time_From__c, l.SystemModstamp, l.Status__c, l.Procedure_Type__c, l.OwnerId, l.Name, l.LastModifiedDate, 
                l.LastModifiedById, l.IsDeleted, l.Id, l.Due_Date__c, l.CreatedDate, l.CreatedById, l.Clinic_Name__c, l.Case_Type__c, l.Case_Type_Map__c, l.Assigned_To__c, 
                l.Assigned_Time__c, l.Assigned_By__c, l.Apt_Type_Id__c, l.Apt_Date__c, l.assigned_to__r.name, l.assigned_by__r.name, l.windent_patient__r.name, 
                l.windent_patient__r.home_phone__c, l.windent_patient__r.work_phone__c From Lab_Case__c l where id = :ticket_id];
            //check for an assignment change
            System.debug('Current Assignment : ' + lab_ticket.assigned_to__c + '  Old Assignment : ' + old_ticket.assigned_to__c);
            if(lab_ticket.Assigned_To__c!=old_ticket.Assigned_To__c) {
                lab_ticket.Assigned_By__c = userinfo.getUserId();
                lab_ticket.Assigned_Time__c = datetime.now();
                User u = [select name from User where id = :lab_ticket.assigned_to__c];
                                Lab_Case_Note__c ln = new Lab_Case_Note__c(Lab_Case__c = ticket_id, Case_Notes__c = 'Ticket has been assigned to ' + u.name);
                if(lab_ticket.status__c=='Unassigned')
                  lab_ticket.status__c='Assigned';
                insert ln;
                refresh_lab_notes();
            }
            update lab_ticket;
            display_error_msg = true;
            error_msgs = '<span style="font-weight:bold;color:blue;">Success - </span> Changes have been saved';
        }
        catch (Exception e) {
                display_error_msg = true;
            error_msgs = '<span class="warning">Save Failed - </span> ' + e.getmessage();
        }
  }
  
  public void start_work() {
        try {
                reset_errors();
                if(getdisplay_start_work()) {
                        Lab_Case_Times__c new_time = new Lab_Case_Times__c(start_time__c = datetime.now(),work_by__c = userinfo.getuserid(), lab_case__c = lab_ticket.id);
                        insert new_time;
                        if(lab_ticket.Status__c=='Assigned' || lab_ticket.Status__c=='Unassigned')
                          lab_ticket.status__c = 'In Progress';
                        update lab_ticket;
                        refresh_lab_times();                    
                }
        }
        catch (Exception e) {
                display_error_msg = true;
            error_msgs = '<span class="warning">Start Time Failed - </span> ' + e.getmessage();
        } 
  }
  
  public void stop_work() {
        try {
                        if(Apexpages.currentPage().getParameters().get('tnum')==null) {
                                display_error_msg = true;
              error_msgs = '<span class="warning">Stop Time Failed - </span> ID was not detected ';
                        }                               
                        else {
                                Lab_case_Times__c stop_ticket = [select id,stop_time__c from Lab_Case_Times__c where id = :Apexpages.currentPage().getParameters().get('tnum')];
                                if(stop_ticket.stop_time__c==null) {
                                  stop_ticket.stop_time__c = datetime.now();
                                  update stop_ticket;
                                }
                                refresh_lab_times();
                        }
        }
        catch(Exception e) {
                display_error_msg = true;
            error_msgs = '<span class="warning">Stop Time Failed - </span> ' + e.getmessage();
        }
  }
  
  public void close_case() {
        try {
                //make sure all times are stopped
                for(Lab_Case_Times__c lc : [Select l.Work_by__c, l.Stop_Time__c, l.Start_Time__c, l.Manual_Adjustment__c, l.Lab_Case__c, l.Id, work_by__r.name From Lab_Case_Times__c l
                                where l.lab_Case__c = :lab_ticket.id and l.stop_time__c = null]) {
                            lc.stop_time__c = datetime.now();
                            update lc;          
                        }               
                lab_ticket.Status__c = 'Completed';
                update lab_ticket;
        }
        catch (Exception e) {
                display_error_msg = true;
            error_msgs = '<span class="warning">Close Case Failed - </span> ' + e.getmessage();
        }
  }
  
  public Boolean getdisplay_start_work() {
        Boolean start_work = true;
        for(Lab_Time lt : lab_times) {
                System.debug('WIP Check : ' + lt.work_inprogress);
                System.debug('Stop Time: ' + lt.ltime.stop_time__c);
                if(lt.work_inprogress)
                  start_work = false;
        }
        refresh_lab_ticket();
        if(lab_ticket.status__c=='Completed' || lab_ticket.status__c=='Cancelled')
          start_work = false;
        return start_work;
  }
  
  public Boolean getdisplay_case_close() {
        Boolean c_display = true;
    if(lab_ticket.Status__c=='Completed' || lab_ticket.Status__c=='Cancelled')
      c_display = false;
    return c_display;   
  }
  
  public void close_modal() {
        modal_display = false;          
        modal_out = '';
  }
  
  public void display_note_form() {
        modal_out = '';
        modal_display = true;
        new_note_holder = new Lab_Case_Note__c(Lab_Case__c = lab_ticket.id);    
  } 
  
  public void add_note() {
        try {
                modal_out = '';
                insert new_note_holder;
                modal_display = false;
                lab_notes = [Select l.CreatedDate, l.Case_Notes__c,l.createdby.name From Lab_Case_Note__c l where lab_case__c = :lab_ticket.id order by createddate];           
        }
        catch (Exception e) {
                modal_out = '<span class="warning">Note Insert Failed - </span> ' + e.getmessage();
        }
  }
}