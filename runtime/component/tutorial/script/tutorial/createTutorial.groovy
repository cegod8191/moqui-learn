import org.apache.log4j.Logger
logger = Logger.getLogger("createTutorial")
def tutorial = ec.entity.makeValue("Tutorial")
tutorial.setFields(context, true, null, null)
if (!tutorial.tutorialId) tutorial.setSequencedIdPrimary()
tutorial.create()