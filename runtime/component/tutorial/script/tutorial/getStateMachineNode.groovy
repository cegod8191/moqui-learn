import org.apache.log4j.Logger

def logger = Logger.getLogger("test")

def fileStream = this.ec.ecfi.resourceFacade.getLocationStream(context.xmlLocation)
Node xmlNode = new XmlParser().parse(fileStream)
context.xmlNode = xmlNode

logger.info(" ----------- xmlLocation:" + xmlNode)