public without sharing class disable_demo {
  Center_Information__c center {get;set;}
  public String disable_style {get;set;}
  public String disable_script {get;set;}
  public Boolean input_disabled {get;set;}
    
  public disable_demo() {
    center = [select id,name,sales_region__c,use_alternate_url__c,icat_flex_center__c,calendar_name__c from Center_Information__c where name = 'Denver'];
    input_disabled = false;
    disable_style = '';
    disable_script = '';
    if(apexpages.currentpage().getparameters().get('disable')!=null) {
      disable_style = 'input_disabled';
      disable_script = 'return false;';
      input_disabled = true;	
    }
  }
  
  public List<Selectoption> getyes_no_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('Yes','Yes'));
  	clist.add(new Selectoption('No','No'));
	return clist;
  }
  
  public Component.Apex.Outputpanel getdynamic_input_line(String target_field) {
  	Component.Apex.Outputpanel input_line = new Component.Apex.Outputpanel(styleclass='input_line',layout='block');
  	Component.Apex.Outputpanel input_text = new Component.Apex.Outputpanel(styleclass='input_text');
  	Component.Apex.OutputText input_text_label = new Component.Apex.OutputText(escape=false,value='Calendar Name (text) :');
  	input_text.childcomponents.add(input_text_label);
  	input_line.childcomponents.add(input_text);  	
  	Component.Apex.Outputpanel input_value = new Component.Apex.Outputpanel(styleclass='input_val');
  	if(input_disabled) {
  	  Component.Apex.Outputfield our_field = new Component.Apex.outputfield();
  	  our_field.expressions.value = '{!center.' + target_field + '}';
  	  input_value.childcomponents.add(our_field);  
  	  input_line.childcomponents.add(input_value);
  	}
  	else {
  	  Component.Apex.Inputfield our_field = new Component.Apex.Inputfield();
  	  our_field.expressions.value = '{!center.' + target_field + '}';
  	  our_field.onclick = 'save_function_name_here();';
  	  input_value.childcomponents.add(our_field);  
  	  input_line.childcomponents.add(input_value);
  	}
  	return input_line;
  }
  
  public Component.Apex.Outputpanel getdynamic_disable() {
  	Component.Apex.Outputpanel section_holder = new Component.Apex.Outputpanel(styleclass='input_section',layout='block');
  	Component.Apex.OutputText html_out = new Component.Apex.OutputText(escape=false,value='Test');  	  	
  	section_holder.childcomponents.add(html_out);  	
 
  	section_holder.childcomponents.add(getdynamic_input_line('calendar_name__c'));
  	section_holder.childcomponents.add(getdynamic_input_line('use_alternate_url__c'));  	
  	section_holder.childcomponents.add(getdynamic_input_line('sales_region__c'));
  	
  	Component.Apex.Outputpanel input_line = new Component.Apex.Outputpanel(styleclass='input_line',layout='block');
  	Component.Apex.Outputpanel input_text = new Component.Apex.Outputpanel(styleclass='input_text');
  	Component.Apex.Outputtext input_text_label = new Component.Apex.OutputText(escape=false,value='Icat Flex Center (radio) :');
  	input_text.childcomponents.add(input_text_label);
  	input_line.childcomponents.add(input_text);  	
  	Component.Apex.Outputpanel input_value = new Component.Apex.Outputpanel(styleclass='input_val');
    Component.Apex.selectRadio dynamic_radio = new Component.Apex.selectRadio();  	
  	dynamic_radio.expressions.value = '{!center.icat_flex_center__c}';
  	if(input_disabled)
  	  dynamic_radio.disabled = true;
  	dynamic_radio.childcomponents.add(new Component.Apex.SelectOption(itemvalue='Yes',itemlabel='Yes'));
  	dynamic_radio.childcomponents.add(new Component.Apex.SelectOption(itemvalue='No',itemlabel='No'));

  	input_value.childcomponents.add(dynamic_radio);  
  	input_line.childcomponents.add(input_value);
  	  	  	
  	section_holder.childcomponents.add(input_line);
  	  	
  	return section_holder;
  }
}