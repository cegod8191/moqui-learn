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
package org.moqui.impl.entity.condition

import org.moqui.entity.EntityCondition
import org.moqui.impl.entity.EntityQueryBuilder.EntityConditionParameter
import org.moqui.impl.entity.EntityConditionFactoryImpl
import org.moqui.impl.entity.EntityQueryBuilder

import static org.moqui.entity.EntityCondition.ComparisonOperator.*

class FieldValueCondition extends EntityConditionImplBase {
    protected Class localClass = null
    protected ConditionField field
    protected EntityCondition.ComparisonOperator operator
    protected Object value
    protected boolean ignoreCase = false

    FieldValueCondition(EntityConditionFactoryImpl ecFactoryImpl,
            ConditionField field, EntityCondition.ComparisonOperator operator, Object value) {
        super(ecFactoryImpl)
        this.field = field
        this.operator = operator ?: EQUALS
        this.value = value
    }

    Class getLocalClass() { if (this.localClass == null) this.localClass = this.getClass(); return this.localClass }

    @Override
    void makeSqlWhere(EntityQueryBuilder eqb) {
        StringBuilder sql = eqb.getSqlTopLevel()
        if (this.ignoreCase) sql.append("UPPER(")
        sql.append(field.getColumnName(eqb.getMainEd()))
        if (this.ignoreCase) sql.append(')')
        sql.append(' ')
        boolean valueDone = false
        if (this.value == null) {
            if (this.operator == EQUALS || this.operator == LIKE ||
                    this.operator == IN) {
                sql.append(" IS NULL")
                valueDone = true
            } else if (this.operator == NOT_EQUAL || this.operator == NOT_LIKE ||
                    this.operator == NOT_IN) {
                sql.append(" IS NOT NULL")
                valueDone = true
            }
        }
        if (!valueDone) {
            sql.append(EntityConditionFactoryImpl.getComparisonOperatorString(this.operator))
            if ((this.operator == IN || this.operator == NOT_IN) &&
                    this.value instanceof Collection) {
                sql.append(" (")
                boolean isFirst = true
                for (Object curValue in this.value) {
                    if (isFirst) isFirst = false else sql.append(", ")
                    sql.append("?")
                    if (this.ignoreCase && (curValue instanceof String || curValue instanceof GString)) curValue = ((String) curValue).toUpperCase()
                    eqb.getParameters().add(new EntityConditionParameter(field.getFieldNode(eqb.mainEntityDefinition), curValue, eqb))
                }
                sql.append(')')
            } else if (this.operator == BETWEEN &&
                    this.value instanceof Collection && ((Collection) this.value).size() == 2) {
                sql.append(" ? AND ?")
                Iterator iterator = ((Collection) this.value).iterator()
                Object value1 = iterator.next()
                if (this.ignoreCase && (value1 instanceof String || value1 instanceof GString)) value1 = ((String) value1).toUpperCase()
                Object value2 = iterator.next()
                if (this.ignoreCase && (value2 instanceof String || value2 instanceof GString)) value2 = ((String) value2).toUpperCase()
                eqb.getParameters().add(new EntityConditionParameter(field.getFieldNode(eqb.mainEntityDefinition), value1, eqb))
                eqb.getParameters().add(new EntityConditionParameter(field.getFieldNode(eqb.mainEntityDefinition), value2, eqb))
            } else {
                if (this.ignoreCase && (this.value instanceof String || this.value instanceof GString)) this.value = ((String) this.value).toUpperCase()
                sql.append(" ?")
                eqb.getParameters().add(new EntityConditionParameter(field.getFieldNode(eqb.mainEntityDefinition), this.value, eqb))
            }
        }
    }

    @Override
    boolean mapMatches(Map<String, ?> map) { return EntityConditionFactoryImpl.compareByOperator(map.get(field.fieldName), operator, value) }

    void getAllAliases(Set<String> entityAliasSet, Set<String> fieldAliasSet) {
        // this will only be called for view-entity, so we'll either have a entityAlias or an aliased fieldName
        if (field.entityAlias) {
            entityAliasSet.add(field.entityAlias)
        } else {
            fieldAliasSet.add(field.fieldName)
        }
    }

    @Override
    EntityCondition ignoreCase() { this.ignoreCase = true; return this }

    @Override
    String toString() {
        return (field as String) + " " + EntityConditionFactoryImpl.getComparisonOperatorString(this.operator) + " " + (value as String)
    }

    @Override
    int hashCode() {
        return (field ? field.hashCode() : 0) + operator.hashCode() + (value ? value.hashCode() : 0) + ignoreCase.hashCode()
    }

    @Override
    boolean equals(Object o) {
        if (o == null || o.getClass() != this.getLocalClass()) return false
        FieldValueCondition that = (FieldValueCondition) o
        if (!this.field.equalsConditionField(that.field)) return false
        // NOTE: for Java Enums the != is WAY faster than the .equals
        if (this.operator != that.operator) return false
        if (this.value == null && that.value != null) return false
        if (this.value != null) {
            if (that.value == null) {
                return false
            } else {
                if (!this.value.equals(that.value)) return false
            }
        }
        if (this.ignoreCase != that.ignoreCase) return false
        return true
    }
}
