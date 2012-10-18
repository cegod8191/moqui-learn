import org.apache.log4j.Logger;
import org.apache.camel.CamelContext;

import org.apache.camel.Exchange;
import org.apache.camel.Processor;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.Endpoint;
import org.apache.camel.impl.DefaultEndpoint;
import org.apache.camel.Produce;
import org.apache.camel.ProducerTemplate;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;

class User{
	public String firstName;
}

User myUser = new User();

logger = Logger.getLogger("test");

CamelContext camelContext = ec.camelContext;

logger.info("===============camelContext routes size:" + camelContext.getRoutes().size())
logger.info("=== components:" + camelContext.componentNames);

camelContext.getRoutes().each{route->
	logger.info("=== id:" + route.getId());
}

//CamelContext camelContext = new DefaultCamelContext();
//MockEndpoint resultEndpoint = new MockEndpoint("mock:result");
//Endpoint inEndpoint = new DefaultEndpoint("direct:in");


ProducerTemplate template = camelContext.createProducerTemplate();
//template.setDefaultEndpoint(resultEndpoint);
//template.send("direct:start", new Processor() {
//	public void process(Exchange e) {
//		System.out.println(" ============================= template Received exchange: " + e.getIn());
//	}
//});

camelContext.addRoutes(new RouteBuilder() {
	public void configure() {
		//from("file:/Users/nbzx?fileName=test2.php").to("mock:result").process(new Processor() {
		//.to("moquiservice:tutorial.TutorialServices.respondDataTables")
		//.transform(body().append("aaa:'bbb'"))
//		from("direct:s6").id("route").process(new Processor() {
//			public void process(Exchange e) {
//				System.out.println(" ============================= 1Received exchange: " + e.getIn());
//			}
//		}).to("moquiservice:tutorial.TutorialServices.respondDataTables").process(new Processor() {
//			public void process(Exchange e) {
//				System.out.println(" ============================= 2Received exchange: " + e.getIn());
//			}
//		}).to("moquiservice:tutorial.TutorialServices.respondDataTables").process(new Processor() {
//			public void process(Exchange e) {
//				System.out.println(" ============================= 3Received exchange: " + e.getIn());
//			}
//		}).to("mock:result");
//		//from("direct:start");
	}
});
template.sendBody("direct:s6", ["entity": "Tutorial"]);

//camelContext.start();
//
//Thread.sleep(3000);
//
//camelContext.stop();