//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

public class ProceedFinanceJsonResponse {

	public class twentyFour {
		public Double emi;
		public String rate;
		public Double dti;
	}

	// public class ProceedFinanceJsonResponse {
		public Integer statusCode;
		public String message;
		public Data data;
	// }

	public class Data {
		public EmiData emiData;
		public Integer loanAmonutApproved;
		public String authId;
	}

	public class EmiData {
		public String twentyFour;
		public String thirtySix;
		public String fortyEight;
		public String sixty;
		public String seventyTwo;
	}


	public static ProceedFinanceJsonResponse parse(String json) {
		return (ProceedFinanceJsonResponse) System.JSON.deserialize(json, ProceedFinanceJsonResponse.class);
	}
}