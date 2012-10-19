/*
 * This Work is in the public domain and is provided on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied,
 * including, without limitation, any warranties or conditions of TITLE,
 * NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE.
 * You are solely responsible for determining the appropriateness of using
 * this Work and assume any risks associated with your use of this Work.
 *
 * This Work includes contributions authored by David E. Jones, not as a
 * "work for hire", who hereby disclaims any copyright to the same.
 */
package org.moqui.addons.orientdb

import org.moqui.impl.entity.EntityDefinition
import org.moqui.impl.entity.EntityFacadeImpl
import org.moqui.impl.entity.EntityFindImpl
import org.moqui.impl.entity.EntityValueImpl

import javax.sql.DataSource

import org.moqui.entity.*
import com.orientechnologies.orient.server.OServer
import com.orientechnologies.orient.server.OServerMain
import com.orientechnologies.orient.core.db.document.ODatabaseDocumentPool
import com.orientechnologies.orient.core.db.document.ODatabaseDocument
import com.orientechnologies.orient.core.db.document.ODatabaseDocumentTx
import com.orientechnologies.orient.core.metadata.schema.OClass
import com.orientechnologies.orient.core.metadata.schema.OType
import java.sql.Types
import com.orientechnologies.orient.core.metadata.schema.OProperty

/**
 * To use this:
 * 1. add a datasource under the entity-facade element in the Moqui Conf file; for example:
 *      <datasource group-name="transactional_nosql" object-factory="org.moqui.impl.entity.orientdb.OrientDatasourceFactory">
 *          <inline-other uri="local:runtime/db/orient/transactional" username="moqui" password="moqui"/>
 *      </datasource>
 *
 * 2. to get OrientDB to automatically create the database, add a corresponding "storage" element to the
 *      orientdb-server-config.xml file
 *
 * 3. add the group-name attribute to entity elements as needed to point them to the new datasource; for example:
 *      group-name="transactional_nosql"
 */
class OrientDatasourceFactory implements EntityDatasourceFactory {
    protected final static org.slf4j.Logger logger = org.slf4j.LoggerFactory.getLogger(OrientDatasourceFactory.class)

    protected EntityFacadeImpl efi
    protected Node datasourceNode
    protected String tenantId

    protected OServer oserver
    protected ODatabaseDocumentPool databaseDocumentPool

    protected String uri
    protected String username
    protected String password

    OrientDatasourceFactory() { }

    @Override
    EntityDatasourceFactory init(EntityFacade ef, Node datasourceNode, String tenantId) {
        // local fields
        this.efi = (EntityFacadeImpl) ef
        this.datasourceNode = datasourceNode
        this.tenantId = tenantId

        // init the DataSource
        EntityValue tenant = null
        EntityFacadeImpl defaultEfi = null
        if (this.tenantId != "DEFAULT") {
            defaultEfi = efi.ecfi.getEntityFacade("DEFAULT")
            tenant = defaultEfi.makeFind("moqui.tenant.Tenant").condition("tenantId", this.tenantId).one()
        }

        EntityValue tenantDataSource = null
        EntityList tenantDataSourceXaPropList = null
        if (tenant != null) {
            tenantDataSource = defaultEfi.makeFind("moqui.tenant.TenantDataSource").condition("tenantId", this.tenantId)
                    .condition("entityGroupName", datasourceNode."@group-name").one()
            tenantDataSourceXaPropList = defaultEfi.makeFind("moqui.tenant.TenantDataSourceXaProp")
                    .condition("tenantId", this.tenantId).condition("entityGroupName", datasourceNode."@group-name")
                    .list()
        }

        Node inlineOtherNode = datasourceNode."inline-other"[0]
        uri = tenantDataSource ? tenantDataSource.jdbcUri : (inlineOtherNode."@uri" ?: inlineOtherNode."@jdbc-uri")
        username = tenantDataSource ? tenantDataSource.jdbcUsername : (inlineOtherNode."@username" ?: inlineOtherNode."@jdbc-username")
        password = tenantDataSource ? tenantDataSource.jdbcPassword : (inlineOtherNode."@password" ?: inlineOtherNode."@jdbc-password")

        oserver = OServerMain.create()
        oserver.startup(Thread.currentThread().getContextClassLoader().getResourceAsStream("orientdb-server-config.xml"))
        oserver.activate()

        databaseDocumentPool = new ODatabaseDocumentPool()
        databaseDocumentPool.setup((inlineOtherNode."@pool-minsize" ?: "5") as int, (inlineOtherNode."@pool-maxsize" ?: "50") as int)

        return this
    }

    ODatabaseDocumentPool getDatabaseDocumentPool() { return databaseDocumentPool }

    /** Returns the main database access object for OrientDB.
     * Remember to call close() on it when you're done with it (preferably in a try/finally block)!
     */
    ODatabaseDocumentTx getDatabase() { return databaseDocumentPool.acquire(uri, username, password) }

    @Override
    void destroy() {
        databaseDocumentPool.close()
        oserver.shutdown()
    }

    @Override
    EntityValue makeEntityValue(String entityName) {
        EntityDefinition entityDefinition = efi.getEntityDefinition(entityName)
        if (!entityDefinition) {
            throw new EntityException("Entity not found for name [${entityName}]")
        }
        return new OrientEntityValue(entityDefinition, efi, this)
    }

    @Override
    EntityFind makeEntityFind(String entityName) {
        return new OrientEntityFind(efi, entityName, this)
    }

    @Override
    DataSource getDataSource() { return null }


    void checkCreateDocumentClass(ODatabaseDocumentTx oddt, EntityDefinition ed) {
        // TODO: do something with view entities
        if (ed.isViewEntity()) return

        OClass oc = oddt.getMetadata().getSchema().getClass(ed.getTableName())
        if (oc == null) {
            logger.info("Creating OrientDB class for entity [${ed.getEntityName()}] for database at [${uri}]")
            oc = oddt.getMetadata().getSchema().createClass(ed.getTableName())

            // create all properties
            List<String> pkFieldNames = ed.getPkFieldNames()
            for (Node fieldNode in ed.getFieldNodes(true, true)) {
                String fieldName = fieldNode."@name"
                OProperty op = oc.createProperty(ed.getColumnName(fieldName, false), getFieldType(fieldName, ed.getEntityName()))
                if (pkFieldNames.contains(fieldName)) op.setMandatory(true).setNotNull(true)
            }

            // create "pk" index
            // this silly API uses the Java ellipses syntax for a variable number of arguments instead of allowing an array or list to be passed in, so do a silly mini-script...
            StringBuilder createIndexSb = new StringBuilder("oc.createIndex(ed.getTableName() + \"_PK\", OClass.INDEX_TYPE.UNIQUE")
            for (String pkFieldName in pkFieldNames) createIndexSb.append(", \"").append(ed.getColumnName(pkFieldName, false)).append("\"")
            createIndexSb.append(")")
            Eval.me(createIndexSb.toString())

            // TODO: create other indexes

            // TODO: create relationships
        }
    }

    OType getFieldType(String fieldName, String entityName) {
        EntityDefinition ed = efi.getEntityDefinition(entityName)
        Node fieldNode = ed.getFieldNode(fieldName)
        String javaType = efi.getFieldJavaType(fieldNode."@type", entityName)
        if (!javaType) throw new IllegalArgumentException("Could not find Java type for field [${fieldName}] on entity [${entityName}]")
        int javaTypeInt = efi.getJavaTypeInt(javaType)

        OType fieldType = null
        switch (javaTypeInt) {
            case 1: fieldType = OType.STRING; break
            case 2: fieldType = OType.DATETIME; break
            case 3: fieldType = OType.STRING; break // NOTE: there doesn't seem to be a time only type...
            case 4: fieldType = OType.DATE; break
            case 5: fieldType = OType.INTEGER; break
            case 6: fieldType = OType.LONG; break
            case 7: fieldType = OType.FLOAT; break
            case 8: fieldType = OType.DOUBLE; break
            case 9: fieldType = OType.DECIMAL; break
            case 10: fieldType = OType.BOOLEAN; break
            case 11: fieldType = OType.BINARY; break // NOTE: looks like we'll have to take care of the serialization for objects
            case 12: fieldType = OType.BINARY; break
            case 13: fieldType = OType.STRING; break
            case 14: fieldType = OType.DATETIME; break
            case 15: fieldType = OType.EMBEDDEDLIST; break
        }

        return fieldType
    }
}
