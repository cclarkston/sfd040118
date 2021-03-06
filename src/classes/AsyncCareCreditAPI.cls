//Generated by wsdl2apex

public class AsyncCareCreditAPI {
    public class performQuickScreenResponseFuture extends System.WebServiceCalloutFuture {
        public CareCreditAPI.qsResponseParm getValue() {
            CareCreditAPI.performQuickScreenResponse response = (CareCreditAPI.performQuickScreenResponse)System.WebServiceCallout.endInvoke(this);
            return response.qsResponseParm;
        }
    }
    public class quickScreenAcceptanceResponseFuture extends System.WebServiceCalloutFuture {
        public CareCreditAPI.qsAcceptanceResponseParm getValue() {
            CareCreditAPI.quickScreenAcceptanceResponse response = (CareCreditAPI.quickScreenAcceptanceResponse)System.WebServiceCallout.endInvoke(this);
            return response.qsAcceptanceResponseParm;
        }
    }
    public class AsyncQSSoap11 {
        public String endpoint_x = 'http://localhost:7001/QuickScreenServiceV2';
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://schemas.syf.com/service/QS/java', 'CareCreditAPIErrors', 'http://schemas.syf.com/services/V2', 'CareCreditAPI'};
        public AsyncCareCreditAPI.performQuickScreenResponseFuture beginPerformQuickScreen(System.Continuation continuation,CareCreditAPI.qsRequestParm qsRequestParm) {
            CareCreditAPI.performQuickScreenRequest request_x = new CareCreditAPI.performQuickScreenRequest();
            request_x.qsRequestParm = qsRequestParm;
            return (AsyncCareCreditAPI.performQuickScreenResponseFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncCareCreditAPI.performQuickScreenResponseFuture.class,
              continuation,
              new String[]{endpoint_x,
              '',
              'http://schemas.syf.com/services/V2',
              'performQuickScreenRequest',
              'http://schemas.syf.com/services/V2',
              'performQuickScreenResponse',
              'CareCreditAPI.performQuickScreenResponse'}
            );
        }
        public AsyncCareCreditAPI.quickScreenAcceptanceResponseFuture beginQuickScreenAcceptance(System.Continuation continuation,CareCreditAPI.qsAcceptanceRequestParm qsAcceptanceRequestParm) {
            CareCreditAPI.quickScreenAcceptanceRequest request_x = new CareCreditAPI.quickScreenAcceptanceRequest();
            request_x.qsAcceptanceRequestParm = qsAcceptanceRequestParm;
            return (AsyncCareCreditAPI.quickScreenAcceptanceResponseFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncCareCreditAPI.quickScreenAcceptanceResponseFuture.class,
              continuation,
              new String[]{endpoint_x,
              '',
              'http://schemas.syf.com/services/V2',
              'quickScreenAcceptanceRequest',
              'http://schemas.syf.com/services/V2',
              'quickScreenAcceptanceResponse',
              'CareCreditAPI.quickScreenAcceptanceResponse'}
            );
        }
    }
}