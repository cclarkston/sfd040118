public class DentalPracticeDistanceToCenter {

	@InvocableMethod(label='Set Dental Practices Distance to Center' description='Uses Google to determine distance to centers and assigns to Distance_To_Center__c')
    public static void set_distance_to_center(Dental_Practice__c[] practices) {
		Dental_Practice__c[] writable_practices = writable_practices(practices);
		for (Dental_Practice__c practice : writable_practices) {
			if (practice_address_OK(practice) && center_is_known(practice)) {
				Map<String, String> practice_address = practice_address(practice);
				Map<String, String> center_address	 = center_address(practice);
				// String distance_description			 = distance_description(practice_address, center_address);
				// Decimal distance					 = distance_from_string(distance_description);
				// practice.Distance_To_Center__c = distance;
			}
			else {practice.Distance_To_Center__c = null;}
		}
		try {update writable_practices;} catch (DMLException error) {}
    }

			private static Dental_Practice__c[] writable_practices(Dental_Practice__c[] the_practices) {
				Set<ID> practice_IDs = new Set<ID>{};
				for (Dental_Practice__c practice : the_practices) {
					practice_IDs.add(practice.ID);
				}
				return [SELECT Street__c, City__c, State_Province__c, Center_Information__c,
					 		   Center_Information__r.Street_1__c, Center_Information__r.City__c, Center_Information__r.State__c
						FROM Dental_Practice__c WHERE ID IN :practice_IDs];
			}

			private static Boolean practice_address_OK(Dental_Practice__c practice) {
				return  !String.isBlank(practice.Street__c) &&
						!String.isBlank(practice.City__c) &&
						!String.isBlank(practice.State_Province__c);
			}

			private static Boolean center_is_known(Dental_Practice__c practice) {
				return practice.Center_Information__c != null;
			}

			private static Map<String, String> practice_address(Dental_Practice__c practice) {
				return new Map<String, String>{'street' => practice.Street__c,
												'city'  => practice.City__c,
												'state' => practice.State_Province__c};
			}

			private static Map<String, String> center_address(Dental_Practice__c practice) {
				// Center_Information__c center = [SELECT Street_1__c, City__c, State__c FROM Center_Information__c WHERE ID = :practice.Center_Information__c];
				// return new Map<String, String>{'street' => center.Street_1__c,
				// 								'city'  => center.City__c,
				// 								'state' => center.State__c};
				return new Map<String, String>{'street' => practice.Center_Information__r.Street_1__c,
												'city'  => practice.Center_Information__r.City__c,
												'state' => practice.Center_Information__r.State__c};
			}

			private static String distance_description(Map<String, String> origin, Map<String, String> destination) {
				String response = myWS.getDistanceToCenter(origin.get('street'), origin.get('city'), origin.get('state'),
														   destination.get('street'), destination.get('city'), destination.get('state'));

				Map<String, Object> response_map = (Map<String, Object>)JSON.deserializeUntyped(response);
				Object[] routes = (Object[])response_map.get('routes');

				Map<String, Object> route_map = (Map<String, Object>)routes[0];
				Object[] legs = (Object[])route_map.get('legs');

				Map<String, Object> leg_map = (Map<String, Object>)legs[0];
				Map<String, Object> distance_map = (Map<String, Object>)leg_map.get('distance');

				return String.valueOf(distance_map.get('text'));
			}

			private static Decimal distance_from_string(String distance_description) {
				String number_part = distance_description.split(' ')[0].replace(',', '');
				return Decimal.valueOf(number_part);
			}
}