trigger CCTestObjBefore on CCTestObj__c (before insert, before update) {
	if (trigger.isBefore && trigger.isInsert) {
		System.debug('Before insert CCTestObj');
	}
	if (trigger.isBefore && trigger.isUpdate) {
		System.debug('Before update CCTestObj');
	}
}