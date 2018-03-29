global with sharing class Utilities {

	global static String[] picklist_values(String object_name, String fieldname){
        String[] values = new String[]{};
		try {
			Schema.PicklistEntry[] pick_list_entries = Schema.getGlobalDescribe().get(object_name).newSObject().getSObjectType().getDescribe().fields.getMap().get(fieldname).getDescribe().getPickListValues();
			for (Schema.PicklistEntry picklist_entry : pick_list_entries) {values.add(picklist_entry.getValue());}
			return values;
		} catch(Exception e) {return new String[]{'Failure: Probably gave a bad name for the object and/or field'};}
    }

}