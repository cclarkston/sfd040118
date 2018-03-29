// DEPRICATED IN FAVOR OF A REPORT
// DEPRICATED
// DEPRICATED

global class CenterSupportRequestWeeklyReport implements Schedulable {
	global void execute(SchedulableContext context) {
    String emailBody = '';
    String[] emailAddresses = new String[]{
                                          // 'tdeyoung@clearchoice.com',
                                          // 'rgreenawalt@clearchoice.com',
                                          // 'mburke@clearchoice.com',
                                          // 'hali@clearchoice.com',
                                          // 'smccarthy@clearchoice.com',
                                          // 'rsutula@clearchoice.com'
                                        };

    Center_Support_Request__c[] requestsThisWeek = [SELECT Owner.Name, Approver__c, Approved__c,
                                                           Center_Information__r.Name, Type__c,
                                                           Status__c, Declined__c
                                                    FROM Center_Support_Request__c
                                                    WHERE CreatedDate > LAST_WEEK
                                                  ];

    emailBody += '<h4 style="font-style: bold;">REQUESTS THIS WEEK</h4>'
              + '<table><tr>'
              + '<th>Owner</th>'
              + '<th>Approver</th>'
              + '<th>Center</th>'
              + '<th>Support Type</th>'
              + '<th>Status</th>'
              + '<th>Approved</th>'
              + '<th>Declined</th>'
              + '</tr>';

    for(Center_Support_Request__c request : requestsThisWeek) {
      emailBody += '<tr><td style="padding: 0 30px 0 30px;">'
                + request.Owner.Name
                + '</td><td style="padding: 0 30px 0 30px;">'
                + request.Approver__c
                + '</td><td style="padding: 0 30px 0 30px;">'
                + request.Center_Information__r.Name
                + '</td><td style="padding: 0 30px 0 30px;">'
                + request.Type__c
                + '</td><td style="padding: 0 30px 0 30px;">'
                + request.Status__c
                + '</td><td style="padding: 0 30px 0 30px;">'
                + request.Approved__c
                + '</td><td style="padding: 0 30px 0 30px;">'
                + request.Declined__c
                + '</td></tr>';
    }

    emailBody += '</table>';

    Center_Support_Request__c[] requestsThisMonth = [SELECT Owner.Name, Approver__c, Approved__c,
                                                           Center_Information__r.Name, Type__c,
                                                           Status__c, Declined__c
                                                     FROM Center_Support_Request__c
                                                     WHERE CreatedDate <= LAST_WEEK
                                                     AND CreatedDate >= LAST_MONTH
                                                   ];

    emailBody += '<h4 style="font-style: bold;">REQUESTS THIS MONTH</h4>'
              + '<table><tr>'
              + '<th>Owner</th>'
              + '<th>Approver</th>'
              + '<th>Center</th>'
              + '<th>Support Type</th>'
              + '<th>Status</th>'
              + '<th>Approved</th>'
              + '<th>Declined</th>'
              + '</tr>';

    for(Center_Support_Request__c request : requestsThisMonth) {
      emailBody += '<tr><td style="padding: 0 30px 0 30px;">'
                + request.Owner.Name
                + '</td><td style="padding: 0 30px 0 30px;">'
                + request.Approver__c
                + '</td><td style="padding: 0 30px 0 30px;">'
                + request.Center_Information__r.Name
                + '</td><td style="padding: 0 30px 0 30px;">'
                + request.Type__c
                + '</td><td style="padding: 0 30px 0 30px;">'
                + request.Status__c
                + '</td><td style="padding: 0 30px 0 30px;">'
                + request.Approved__c
                + '</td><td style="padding: 0 30px 0 30px;">'
                + request.Declined__c
                + '</td></tr>';
    }

    emailBody += '</table>';

    System.debug('crash: ' + emailBody);

    if(requestsThisWeek.size() != 0 || requestsThisMonth.size() != 0) {
      try {
        CenterSupportRequestNotification.sendWeeklyReport(emailAddresses, emailBody);
      } catch(DmlException error) {
        System.debug('There was an error sending the Center Support Request '
        + 'Weekly Report: ' + error);
      }
    }
	}
}

// Executed in the console to initialize CronTrigger:

// CenterSupportRequestWeeklyReport centerSupportRequestWeeklyNotes = new CenterSupportRequestWeeklyReport();
// String CRON_EXP = '0 0 6 ? * MON-FRI';
// String jobID = System.schedule('Center Support Request Weekly Report', CRON_EXP, centerSupportRequestWeeklyNotes);
//
// To delete the CronTrigger, run the following the dev console:
//
// CronTrigger cron = [SELECT Id
//                     FROM CronTrigger
//                     WHERE CronJobDetail.Name = 'Center Support Request Weekly Report'];
// System.abortJob(cron.Id);