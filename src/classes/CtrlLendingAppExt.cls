public class CtrlLendingAppExt {
	private CtrlLendingApp controller;

	public CtrlLendingAppExt(CtrlLendingApp controller) {
		this.controller = controller;
	}

	public static Map<String, String> termsPages() {
		Map<String, String> pages = new Map<String, String>
											{ 'terms0' => 'terms0',
												'terms0' => 'terms1',
												'terms1' => 'terms2',
												'terms2' => 'terms3',
												'terms3' => 'terms4',
												'terms4' => 'terms5',
												'terms5' => 'terms6',
												'terms6' => 'terms7',
												'terms7' => 'main'
											};
		return pages;
	}

	public static Map<String, String> termsHeaders() {
		Map<String, String> headers = new Map<String, String>
											{ 'terms0' => 'Welcome to PreQ',
												'terms1' => 'Step 1 of 7: No Obligation',
												'terms2' => 'Step 2 of 7: Your Decision',
												'terms3' => 'Step 3 of 7: Pre-Approval Process',
												'terms4' => 'Step 4 of 7: Truthful Application',
												'terms5' => 'Step 5 of 7: Use of Information',
												'terms6' => 'Step 6 of 7: ClearChoice is Not a Lender',
												'terms7' => 'Step 7 of 7: Voluntary Agreement',
												'main'   => 'Inquiry Information'
											};
		return headers;
	}

	public static Map<String, String> termsText() {
		Map<String, String> text = new Map<String, String>
			{ 'terms0' => 'Welcome to PreQ&trade;, a loan pre-qualification system ' +
										'designed to help you better understand and assess ' +
										'your financing options. The information you share ' +
										'here will be submitted to select financing partners ' +
										'for their review and quotation.' +
										'<p>To access PreQ, please review and approve the ' +
										'following (7) steps:</p>',
				'terms1' => 'PreQ is an optional loan pre-qualification system ' +
										'limited to participating lending partners. You are under no ' +
										'obligation to use any of the participating lending partners  ' +
										'and are free to explore other financing options  ' +
										'outside of the PreQ system.',
				'terms2' => 'Choosing a lender that best meets your specific ' +
										'needs is your decision. ClearChoice does not ' +
										'arrange for your financing.',
				'terms3' => 'PreQ allows you to submit a request for pre- ' +
										'approval from participating lenders. It is not a loan ' +
										'application. Applying for your loan is a separate  ' +
										'process.',
				'terms4' => 'The information you enter into the PreQ system ' +
										'must be your own and must not contain any false ' +
										'or misleading information.',
				'terms5' => 'By submitting your information in the PreQ system, ' +
										'you are asking participating lenders to review it and ' +
										'to determine their willingness to pre-approve a ' +
										'future loan to you.',
				'terms6' => 'ClearChoice is not a lender, creditor, or broker. ' +
										'ClearChoice makes no recommendations or ' +
										'assurances about the financing partners participating in the ' +
										'PreQ system.',
				'terms7' => 'You give up claims against ClearChoice related to ' +
										'your use of the PreQ system and the acts, ' +
										'omissions, or statements of participating lenders.'
			};

		return text;
	}

	public static String getCcPrivacyPolicyTerms() {
		String terms = 'To effectively develop and improve the Loan ' +
									  'Prequalification Inquiry System (“LPI System”) ' +
										'and to identify or contact a particular person ' +
										'(“Personal Information”), ClearChoice Management ' +
										'Services, LLC, and its network of affiliated dental ' +
										'practices (“ClearChoice”) may collect the personally ' +
										'identifiable information entered into the LPI System. ' +
										'ClearChoice collects Personal Information to provide ' +
										'prospective patients with information that may allow ' +
										'them to make better informed decisions about potential ' +
										'financing options; facilitate provision of Loan Prequalification ' +
										'Inquiry System; and document and measure use of the ' +
										'LPI System to enhance customer service, internal ' +
										'analysis, and other lawful purposes.  Personal ' +
										'Information may be retained by ClearChoice to the ' +
										'greatest extent permitted under the law. ClearChoice ' +
										'communicates information provided on the Lending App ' +
										'to Participating Lenders.  ClearChoice does not ' +
										'disseminate to or share Personal Information with ' +
										'other third parties for direct marketing activities. ' +
										'Statistical or general outcomes analysis may be shared ' +
										'with trusted third parties who assist us in operating ' +
										'the LPI System and in conducting our business, and we ' +
										'share it in such a way that Personal Information is not ' +
										'unnecessarily disclosed.  We may also disclose ' +
										'information as required by law, such as to comply ' +
										'with a subpoena or similar legal process. We maintain ' +
										'efforts to protect against access of electronic ' +
										'communications by unaffiliated third parties, however, ' +
										'since information in electronic communications can ' +
										'sometimes be intercepted by a third party, ClearChoice ' +
										'cannot provide any assurance that the information entered ' +
										'into the LPI System will not become known or accessible ' +
										'to unintended third parties. By entering information ' +
										'into the LPI System, users acknowledges ClearChoice’s ' +
										'policy regarding the collection, use, and transfer of ' +
										'Personal Information and accepts ClearChoice’s ' +
										'collection and processing of Personal Information.';

		return terms;
	}

	public static String getConfirmationTerms1() {
		String terms = 'I affirm that I am at least 18 years of age and a citizen ' +
		 								'or permanent resident of the United States; and that ' +
										'the information I entered is true and correct. I ' +
										'authorize the Participating Lenders to verify the ' +
										'information I entered. I authorize the Participating ' +
										'Lenders to share information concerning the status of ' +
										'this Loan Prequalification Inquiry with the ClearChoice ' +
										'Dental Implant Center that I designate.';
		return terms;
	}

	public static String getConfirmationTerms2() {
		String terms = 'I understand that by clicking on the I AGREE button ' +
									 'immediately following this notice that I am ' +
	                 'providing ‘written instructions’ to each Participating ' +
									 'Lender under the Fair Credit Reporting Act authorizing ' +
									 'the Participating Lender to obtain information from ' +
									 'my personal credit profile or other information from one ' +
									 'or more credit reporting agencies. I authorize the ' +
									 'Participating Lender to obtain such information solely ' +
									 'to prequalify me for credit options. According to the ' +
									 'Participating Lenders, submitting this information will ' +
									 'not impact your credit score.';

		return terms;
	}

	public static String getHcsElectronicTransactionAndDisclosures() {
		String terms = 'We are required by law to provide you with certain ' +
									 'disclosures and information about the products, services ' +
									 'or accounts you may receive or access in connection with ' +
									 'your relationship with us (\'Required Information\'). With ' +
									 'your consent, we can deliver Required Information to ' +
									 'you by: a) displaying or delivering the Required Information ' +
                   'electronically; and b) requesting that you print or ' +
									 'download the Required Information and retain it for ' +
									 'your records. This notice contains important information ' +
									 'that you are entitled to receive before you consent to ' +
									 'electronic delivery of Required Information. Your consent ' +
									 'also permits the general use of electronic records and ' +
									 'electronic signatures in connection with the Required ' +
									 'Information. After you have read this information, if ' +
									 'you agree to receive Required Information from us ' +
									 'electronically, and if you agree to the general use of ' +
									 'electronic records and electronic signatures in ' +
									 'connection with our relationship, please click the ' +
									 '\'I ACCEPT\' button below. In this consent, “we”, “us”, ' +
									 '“our”, and “HCS” means Health Credit Services, LLC (HCS) ' +
									 'and each and every current and future affiliate of HCS. ' +
									 '“You” and “your” means the person giving this consent in ' +
									 'connection with an application submitted to the HCS Loan ' +
									 'Program. Scope of Consent Any disclosures will be provided ' +
									 'to you electronically, either on our website or via ' +
									 'electronic mail to the verified email address you provided. ' +
                   'If you consent to electronic disclosures, that consent ' +
									 'applies to all Required Information we give you or receive ' +
									 'from you in connection with our relationship and the ' +
									 'associated notices, disclosures, and other documents. Your ' +
									 'consent will remain in effect until such time as you are ' +
									 'no longer an account holder or you have withdrawn your ' +
									 'consent pursuant to the withdrawal procedures below. Once ' +
									 'you are no longer an account holder, your consent will ' +
									 'continue until such time that all disclosures relevant ' +
									 'to your account have been made. You agree to print out ' +
									 'or download Required Information when we advise you to ' +
									 'do so and keep it for your records. If you are unable to ' +
									 'print or download any Required Information, you may call ' +
									 'us and request paper copies. If you need to update your ' +
									 'e-mail address or other contact information with us, you ' +
									 'may do so by calling us and requesting the necessary ' +
									 'updates. Your consent does not mean that we must ' +
									 'provide the Required Information electronically. We may, ' +
									 'at our option, deliver Required Information on paper. ' +
									 'We may also require that certain communications from you ' +
									 'be delivered to us on paper at a specified address. ' +
									 'Technology Requirements Before you consent to receiving ' +
									 'electronic disclosures, you should consider whether ' +
									 'you have the required hardware and software capabilities. ' +
									 'In order to access and retain disclosures electronically, ' +
									 'your device must meet the following requirements: access ' +
									 'to the internet; a valid email account and related software ' +
									 'capable of receiving email via the internet; Current Version ' +
									 'of a PDF reader (such as Adobe® Acrobat); Current Version of ' +
									 'supported web browsing software (Google Chrome; Mozilla ' +
									 'Firefox; Internet Explorer; or Safari); and hardware ' +
									 'capable of running this software. “Current Version” means ' +
									 'a version of the hardware or software that is currently ' +
									 'being supported by its publisher. If a change in the ' +
									 'hardware or software requirements needed to access or ' +
									 'retain electronic records, we will provide you with a ' +
									 'statement of: (a) the revised hardware and software  ' +
									 'requirements for access to and retention of electronic ' +
									 'records, and (b) the right to withdraw consent without ' +
									 'the imposition of any condition, consequence, or ' +
                   'fee for such withdrawal. If you are accessing our site ' +
									 'and the electronic disclosures via a mobile device ' +
									 '(such as a smart phone or tablet), in addition to the ' +
									 'above requirements, you must ensure that you have ' +
									 'software on your mobile device that allows you to print ' +
									 'and save the electronic disclosures presented to you ' +
									 'during the application process. These applications can ' +
                   'typically be found in the device’s application store ' +
									 '(“app store”). If you do not have these capabilities on ' +
									 'your mobile device, please access our site and the ' +
									 'electronics disclosures through a device that provides ' +
									 'these capabilities. Withdrawing Consent If you consent ' +
									 'to electronic delivery of Required Information, you may ' +
									 'withdraw that consent at any time. However, if you ' +
									 'withdraw your consent, we may not be able to continue a ' +
									 'relationship with you in connection to the products, ' +
                   'services or account. Your withdrawal of consent will ' +
									 'become effective after we have had a reasonable ' +
									 'opportunity to act upon it. If you wish to withdraw your ' +
									 'consent to electronic disclosures, you may do so by ' +
									 'calling us and requesting withdrawal of consent. After ' +
									 'consenting to receive and deliver Required Information ' +
									 'electronically, you may request a paper copy of the ' +
									 'Required Information by calling us. You may be charged ' +
									 'a fee for a paper copy of the Required Information ' +
                   'unless prohibited by applicable law. If you do not have ' +
									 'the required software and/or hardware, or if you do not ' +
									 'wish to use electronic records and signatures for any ' +
									 'other reason, you can request paper copies of the Required ' +
									 'Information to be sent to you by contacting us at via the ' +
									 'methods of communication below. TCPA Consent You provide ' +
									 'your consent and agree that we may contact you for ' +
									 'any lawful reason, including, but not limited to, in ' +
                   'connection with your application and Account, including ' +
									 'for the collection of amounts owed to us under any loan ' +
                   'granted, and to market goods and services of your lender, ' +
									 'its servicer, or any unaffiliated third-party. We may contact ' +
									 'you at such addresses or numbers (including wireless ' +
									 'cellular telephone numbers and ported landline numbers) as you ' +
									 'may provide to us from time to time. We may use any means ' +
									 'of communication, including, but not limited to, postal ' +
                   'mail, telephone, electronic mail, text messaging, voice' +
									 'messages, or other technology, to reach you. You agree that we ' +
                   'may use automated dialing and announcing devices which ' +
									 'may play recorded messages. We may also send text ' +
                   'messages to your telephone. You are not required to ' +
									 'provide your mobile telephone number as a condition of ' +
                   'receiving credit, and you may withdraw your consent to ' +
									 'use automated dialing systems and pre-recorded messages in ' +
									 'connection with your mobile telephone number at any time ' +
									 'by contacting us at the number listed below in Contact ' +
                   'Information. Contact Us You can contact us via email at ' +
									 'info@hcsloans.com or by calling Support at 888-568-0186. ' +
									 'You may also reach us in writing at the following address: ' +
									 'Health Credit Services P.O. Box 85130 Sioux Falls, SD 57118. ' +
                   'You will keep us informed of any change in your email or ' +
									 'home mailing address to ensure timely delivery of ' +
									 'disclosures. Please call us at 888-568-0186 to inform ' +
									 'of us of any such changes. I have read the information ' +
									 'about the use of electronic records, disclosures, notices, ' +
									 'and e- mail, and consent to the use of electronic ' +
									 'records for the delivery of Required Information in ' +
									 'connection with our relationship. I have been able ' +
									 'to view this information using my computer and software. ' +
									 'I have an account with an internet service provider, ' +
                   'and I am able to send e-mail and receive e-mail with ' +
									 'hyperlinks to websites and attached files. I also consent ' +
									 'to the use of electronic records and electronic signatures ' +
									 'in place of written documents and handwritten signatures.';

		return terms;
	}
}