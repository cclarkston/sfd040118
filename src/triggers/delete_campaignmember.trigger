trigger delete_campaignmember on CampaignMember (before delete) {
    if(Trigger.isBefore) {
        if(Trigger.isDelete) {
            System.debug('Trigger before delete running');
            //see if this stops the process.
            for(CampaignMember cm : trigger.old) {
              cm.adderror('You are not allowed to delete campaign members');
            }
        }
    }
}