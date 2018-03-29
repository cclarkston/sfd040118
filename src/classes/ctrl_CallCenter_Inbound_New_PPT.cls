public class ctrl_CallCenter_Inbound_New_PPT {
	public Lead lead {get; set;}
    // ApexPages.Standardcontroller controller;
	public Integer page_number {get; private set;}

	public Boolean display_address_modal {get; set;} {display_address_modal = false;}
	public VerifiedAddress verified_address {get; set;}

	public ID selected_center_ID {get; set;}
	public Map<ID, Map<String, String[]>> center_roster {get; private set;}

	// public ctrl_CallCenter_Inbound_New_PPT(ApexPages.StandardController standard_controller) {
	// this.lead  = (Lead)standard_controller.getRecord();
	// controller = standard_controller;
	public ctrl_CallCenter_Inbound_New_PPT() {
		fetch_lead(Apexpages.currentPage().getParameters().get('id'));
		page_number = 1;
	}

	public void next_page() {
		// controller.save();
		// lead = (Lead)controller.getRecord();
		update lead;
		fetch_lead(lead.id);
		page_number++;
	}

	private void fetch_lead(ID lead_ID) {
		lead = [SELECT ID,
					Inbound_Call__c, FirstName, LastName, Gender__c, Email, Refused_to_give_email__c, Phone, MobilePhone, Phone_Notes__c, Street, City, State, PostalCode,
					latlong__Latitude__s, latlong__Longitude__s,
					Center__r.Name,
					Dental_Conditions_Upper__c, Dental_Conditions_Lower__c, Check_Medical_History__c, Missing_Upper__c, Missing_Lower__c, Description, Patient_History__c, Patient_Future__c, Fees_Quoted__c
				FROM Lead
				WHERE ID = :lead_ID];
	}

	public ID getcurrent_saved_center_ID() {
		return [SELECT Center__c FROM Lead WHERE ID = :lead.id].Center__c;
	}

	public Boolean getok_to_proceed() {
		if      (page_number == 1) {return true;}
		else if (page_number == 2) {return true;}
		else if (page_number == 3) {return selected_center_ID != null;}
		else if (page_number == 4) {return true;}
		else if (page_number == 5) {return true;}
		else                       {return false;}
	}

	public void go_to_page_1() {page_number = 1;}
	public void go_to_page_2() {page_number = 2;}
	public void go_to_page_3() {page_number = 3;}
	public void go_to_page_4() {page_number = 4;}
	public void go_to_page_5() {page_number = 5;}


	// PAGE 1 START
	public class VerifiedAddress {
		public Boolean successful {get; set;}
		public String street1  {get; set;}
		public String street2  {get; set;}
		public String city     {get; set;}
		public String state    {get; set;}
		public String zip_code {get; set;}
	}
	public List<Selectoption> getcall_type_options() {
		String[] values = Utilities.picklist_values('Lead', 'Inbound_Call__c');
		List<SelectOption> options = new List<SelectOption>();
		for (Integer i = 0; i < values.size(); i++) {options.add(new SelectOption(values[i], values[i]));}
		return options;
	}
	public List<Selectoption> getgender_options() {
		String[] values = Utilities.picklist_values('Lead', 'Gender__c');
		List<SelectOption> options = new List<SelectOption>();
		for (Integer i = 0; i < values.size(); i++) {options.add(new SelectOption(values[i], values[i]));}
		return options;
	}

	public void open_address_modal() {
		verify_address();
		display_address_modal = true;
	}
	public void close_address_modal() {
		display_address_modal = false;
	}
	public void approve_verified_address() {
		copy_verified_address_to_lead();
		close_address_modal();
		next_page();
	}
			private void copy_verified_address_to_lead() {
				lead.Street     = verified_address.street1;
				lead.City       = verified_address.city;
				lead.State      = verified_address.state;
				lead.PostalCode = verified_address.zip_code;
			}

	private void verify_address() {
		// This is where we access some address verification service to get an official version of the patient's address.
		// From that, we should construct the necessary elements for the Address class and return an address.
		verified_address = new VerifiedAddress();

		verified_address.successful = true;
		verified_address.street1    = '1313 Mockingbird Lane';
		verified_address.street2    = '';
		verified_address.city       = 'Springfield';
		verified_address.state      = 'New Hampshire';
		verified_address.zip_code   = '90210';
	}
	// PAGE 1 END


	// PAGE 3 START

	public class CenterWrapper
	{
		public Center_Information__c record { get; private set; }
		public Decimal distance { get; private set; }
		public CenterWrapper(Center_Information__c record)
		{
			this.record = record;
			this.distance = (Decimal)record.get('distance');
			this.distance = this.distance.round();
		}
	}

	public CenterWrapper[] getcenter_wrappers() {
		Integer max_distance = 1500;
		Location lead_latlong = Location.newInstance(lead.latlong__Latitude__s, lead.latlong__Longitude__s);
		Center_Information__c[] centers = [SELECT ID, Name, Street_1__c, Street_2__c, City__c, State__c, Zip_Code__c, DISTANCE(latlong__c, :lead_latlong, 'mi') distance, Center_Alerts__c, Directions__c, Call_Center_Marketing__c, Local_Front_Desk__c FROM Center_Information__c WHERE DISTANCE(latlong__c, :lead_latlong, 'mi') < :max_distance ORDER BY DISTANCE(latlong__c, :lead_latlong, 'mi') LIMIT 5];
		build_center_staff_hovers(centers);

		CenterWrapper[] wrappers = new CenterWrapper[]{};
		for (Center_Information__c center : centers) {wrappers.add(new CenterWrapper(center));}
		return wrappers;
	}
			private void build_center_staff_hovers(Center_Information__c[] centers) {
				center_roster = new Map<ID, Map<String, String[]>>{};
				Set<ID> center_IDs = new Set<ID>{};
				for (Center_Information__c center : centers) {center_IDs.add(center.ID);}

				ClearChoice_Doctor__c[] doctors = doctors(center_IDs);
				User[] pecs = pecs(center_IDs);
				// String dec = lead.Center__r.DEC__c;
				User[] cas = cas(center_IDs);
				for (Center_Information__c center : centers) {
					center_roster.put(center.ID, hover_output(doctors, pecs,/* dec*/ cas));
				}
			}

			private ClearChoice_Doctor__c[] doctors(Set<ID> center_IDs) {
				try {return [SELECT Last_Name__c, First_Name__c, Doctor_type__c, Center_Information__c FROM ClearChoice_Doctor__c WHERE Center_Information__c IN :center_IDs AND Active__c = true];}
				catch (Exception e) {return new ClearChoice_Doctor__c[]{};}
			}

			private User[] pecs(Set<ID> center_IDs) {
				try {return [SELECT Name, Center_PEC__c FROM User WHERE Center_PEC__c IN :center_IDs AND Center_Administrator__c = false AND isActive = true];}
				catch (Exception e) {return new User[]{};}
			}

			private User[] cas(Set<ID> center_IDs) {
				try {return [SELECT Name, Center_PEC__c FROM User WHERE Center_PEC__c IN :center_IDs AND Center_Administrator__c = true AND isActive = true];}
				catch (Exception e) {return new User[]{};}
			}

			private Map<String, String[]> hover_output(ClearChoice_Doctor__c[] doctors, User[] pecs,/* String dec,*/ User[] cas) {
					Map<String, String[]> staff_map = new Map<String, String[]>{'doctors' => new String[]{String.valueOf(doctors.size())},
																				'pecs'	  => new String[]{String.valueOf(pecs.size())},
																				// 'decs'	  => new String[]{String.isBlank(dec) ? '0' : '1', dec},
																				'cas'	  => new String[]{String.valueOf(cas.size())}};
					staff_map.get('doctors').addAll(staff_names(doctors));
					staff_map.get('pecs').addAll(staff_names(pecs));
					staff_map.get('cas').addAll(staff_names(cas));
					return staff_map;
			}

			private String[] staff_names(ClearChoice_Doctor__c[] doctors) {
				String[] names = new String[]{};
				for (ClearChoice_Doctor__c doctor : doctors) {names.add(doctor.First_Name__c + ' ' + doctor.Last_Name__c + ' - ' + doctor.Doctor_type__c);}
				return names;
			}

			private String[] staff_names(User[] users) {
				String[] names = new String[]{};
				for (User user : users) {names.add(user.Name);}
				return names;
			}

	public void select_center() {
		lead.Center__c = selected_center_ID;
	}

	// PAGE 3 END

	// PAGE 4 START
	private String[] dental_conditions = Utilities.picklist_values('Lead', 'Dental_Conditions_Upper__c');
	public Map<String, Boolean> dental_conditions_upper {get; set;} {dental_conditions_upper = dental_conditions_map();}
	public Map<String, Boolean> dental_conditions_lower {get; set;} {dental_conditions_lower = dental_conditions_map();}

	private Map<String, Boolean> dental_conditions_map() {
		Map<String, Boolean> conditions_map = new Map<String, Boolean>{};
		for (Integer i = 0; i < dental_conditions.size(); i++) {conditions_map.put(dental_conditions[i], false);}
		return conditions_map;
	}

	// PAGE 4 END

}