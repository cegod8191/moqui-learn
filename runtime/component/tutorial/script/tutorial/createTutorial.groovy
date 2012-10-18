def tutorial = ec.entity.makeValue("Tutorial")
tutorial.setFields(context, true, null, null)
if (!tutorial.tutorialId) tutorial.setSequencedIdPrimary()
tutorial.create()