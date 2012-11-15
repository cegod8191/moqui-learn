import spock.lang.*

import org.moqui.context.ExecutionContext
import org.moqui.entity.EntityValue
import org.moqui.Moqui
import java.sql.Timestamp
import java.text.SimpleDateFormat
import org.moqui.entity.EntityCondition

class EntityFind extends Specification {
    @Shared
    ExecutionContext ec
    @Shared
    Timestamp timestamp

    def setupSpec() {
        // init the framework, get the ec
        ec = Moqui.getExecutionContext()
        timestamp = new Timestamp(System.currentTimeMillis())//.valueOf("2012-11-13 10:21:32")
    }

    def cleanupSpec() {
        ec.destroy()
    }

    def setup() {
        ec.artifactExecution.disableAuthz()
        ec.transaction.begin(null)
        ec.entity.makeValue("Example").setAll([exampleId:"TEST1", exampleName:"Test Name", exampleSize: 100, exampleDate: timestamp]).createOrUpdate()
    }

    def cleanup() {
        ec.entity.makeValue("Example").setAll([exampleId:"TEST1"]).delete()
        ec.artifactExecution.enableAuthz()
        ec.transaction.commit()
    }

//    def "change tenant"() {
//        when:
//            ec.changeTenant("EXAMPLE1")
//        then:
//            ec.entity.makeFind("Example").count() > 0
//    }

    @Unroll
    def "find Example by single condition:#cond"() {
        expect:
        EntityValue example = ec.entity.makeFind("Example").condition(fieldName, value).one()
        example != null
        example.exampleId == "TEST1"

        where:
        fieldName | value
        "exampleId" | "TEST1"
        "exampleSize" | "100"
        "exampleSize" | 100
        "exampleDate" | new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(timestamp)
        "exampleDate" | timestamp
    }

    @Unroll
    def "find Example by operator condition:#cond"(){
        expect:
        EntityValue example = ec.entity.makeFind("Example").condition(fieldName, operator, value).one()
        example != null
        example.exampleId == "TEST1"

        where:
        fieldName | operator | value
        "exampleId" | EntityCondition.ComparisonOperator.LIKE | "%EST%"
    }
}
