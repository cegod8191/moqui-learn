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
package org.moqui.impl.entity

import java.sql.Timestamp

import org.moqui.entity.EntityConditionFactory
import org.moqui.entity.EntityCondition
import org.moqui.entity.EntityCondition.JoinOperator
import org.moqui.entity.EntityCondition.ComparisonOperator
import org.moqui.impl.entity.condition.EntityConditionImplBase
import org.moqui.impl.entity.condition.BasicJoinCondition
import org.moqui.impl.entity.condition.FieldValueCondition
import org.moqui.impl.entity.condition.ConditionField
import org.moqui.impl.entity.condition.DateCondition
import org.moqui.impl.entity.condition.WhereCondition
import org.moqui.impl.entity.condition.FieldToFieldCondition
import org.moqui.impl.entity.condition.ListCondition
import org.moqui.impl.entity.condition.MapCondition
import org.moqui.impl.StupidUtilities

class EntityConditionFactoryImpl implements EntityConditionFactory {
    protected final static org.slf4j.Logger logger = org.slf4j.LoggerFactory.getLogger(EntityConditionFactoryImpl.class)

    protected final EntityFacadeImpl efi

    EntityConditionFactoryImpl(EntityFacadeImpl efi) {
        this.efi = efi
    }

    /** @see org.moqui.entity.EntityConditionFactory#makeCondition(EntityCondition, JoinOperator, EntityCondition) */
    EntityCondition makeCondition(EntityCondition lhs, JoinOperator operator, EntityCondition rhs) {
        return new BasicJoinCondition(this, (EntityConditionImplBase) lhs, operator, (EntityConditionImplBase) rhs)
    }

    /** @see org.moqui.entity.EntityConditionFactory#makeCondition(String, ComparisonOperator, Object) */
    EntityCondition makeCondition(String fieldName, ComparisonOperator operator, Object value) {
        return new FieldValueCondition(this, new ConditionField(fieldName), operator, value)
    }

    /** @see org.moqui.entity.EntityConditionFactory#makeConditionToField(String, ComparisonOperator, String) */
    EntityCondition makeConditionToField(String fieldName, ComparisonOperator operator, String toFieldName) {
        return new FieldToFieldCondition(this, new ConditionField(fieldName), operator, new ConditionField(toFieldName))
    }

    /** @see org.moqui.entity.EntityConditionFactory#makeCondition(List<EntityCondition>, JoinOperator) */
    EntityCondition makeCondition(List<EntityCondition> conditionList, JoinOperator operator) {
        return new ListCondition(this, (List<EntityConditionImplBase>) conditionList, operator)
    }

    /** @see org.moqui.entity.EntityConditionFactory#makeCondition(List<EntityCondition>) */
    EntityCondition makeCondition(List<EntityCondition> conditionList) {
        return new ListCondition(this, (List<EntityConditionImplBase>) conditionList, JoinOperator.AND)
    }

    /** @see org.moqui.entity.EntityConditionFactory#makeCondition(Map<String,?>, ComparisonOperator, JoinOperator) */
    EntityCondition makeCondition(Map<String, ?> fieldMap, ComparisonOperator comparisonOperator, JoinOperator joinOperator) {
        return new MapCondition(this, fieldMap, comparisonOperator, joinOperator)
    }

    /** @see org.moqui.entity.EntityConditionFactory#makeCondition(Map<String,?>) */
    EntityCondition makeCondition(Map<String, ?> fieldMap) {
        return new MapCondition(this, fieldMap, ComparisonOperator.EQUALS, JoinOperator.AND)
    }

    /** @see org.moqui.entity.EntityConditionFactory#makeConditionDate(String, String, Timestamp) */
    EntityCondition makeConditionDate(String fromFieldName, String thruFieldName, Timestamp compareStamp) {
        return new DateCondition(this, fromFieldName, thruFieldName, compareStamp)
    }

    /** @see org.moqui.entity.EntityConditionFactory#makeConditionWhere(String) */
    EntityCondition makeConditionWhere(String sqlWhereClause) {
        return new WhereCondition(this, sqlWhereClause)
    }

    EntityCondition.ComparisonOperator comparisonOperatorFromEnumId(String enumId) {
        switch (enumId) {
            case "ENTCO_LESS": return EntityCondition.LESS_THAN
            case "ENTCO_GREATER": return EntityCondition.GREATER_THAN
            case "ENTCO_LESS_EQ": return EntityCondition.LESS_THAN_EQUAL_TO
            case "ENTCO_GREATER_EQ": return EntityCondition.GREATER_THAN_EQUAL_TO
            case "ENTCO_EQUALS": return EntityCondition.EQUALS
            case "ENTCO_NOT_EQUALS": return EntityCondition.NOT_EQUAL
            case "ENTCO_IN": return EntityCondition.IN
            case "ENTCO_NOT_IN": return EntityCondition.NOT_IN
            case "ENTCO_BETWEEN": return EntityCondition.BETWEEN
            case "ENTCO_LIKE": return EntityCondition.LIKE
            case "ENTCO_NOT_LIKE": return EntityCondition.NOT_LIKE
            default: return null
        }
    }

    EntityCondition makeActionCondition(String fieldName, String operator, String fromExpr, String value, String toFieldName, boolean ignoreCase, boolean ignoreIfEmpty, boolean ignore) {
        // logger.info("TOREMOVE makeActionCondition(fieldName ${fieldName}, operator ${operator}, fromExpr ${fromExpr}, value ${value}, toFieldName ${toFieldName}, ignoreCase ${ignoreCase}, ignoreIfEmpty ${ignoreIfEmpty}, ignore ${ignore})")

        if (ignore) return null

        if (toFieldName) {
            EntityCondition ec = makeConditionToField(fieldName, getComparisonOperator(operator), toFieldName)
            if (ignoreCase) ec.ignoreCase()
            return ec
        } else {
            Object condValue = null
            if (value) {
                // NOTE: have to convert value (if needed) later on because we don't know which entity/field this is for, or change to pass in entity?
                condValue = value
            } else if (fromExpr) {
                condValue = this.efi.ecfi.resourceFacade.evaluateContextField(fromExpr, "")
            }
            if (ignoreIfEmpty && !condValue) return null

            EntityCondition ec = makeCondition(fieldName, getComparisonOperator(operator), condValue)
            if (ignoreCase) ec.ignoreCase()
            return ec
        }
    }

    EntityCondition makeActionCondition(Node node) {
        return makeActionCondition((String) node["@field-name"],
                (String) node["@operator"] ?: "equals", (String) (node["@from"] ?: node["@field-name"]),
                (String) node["@value"], (String) node["@to-field-name"], (node["@ignore-case"] ?: "false") == "true",
                (node["@ignore-if-empty"] ?: "false") == "true", (node["@ignore"] ?: "false") == "true")
    }

    EntityCondition makeActionConditions(Node node) {
        List<EntityCondition> condList = new ArrayList()
        for (Node subCond in node.children()) condList.add(makeActionCondition(subCond))
        return makeCondition(condList, EntityConditionFactoryImpl.getJoinOperator((String) node["@combine"]))
    }

    protected static final Map<ComparisonOperator, String> comparisonOperatorStringMap = new HashMap()
    static {
        comparisonOperatorStringMap.put(ComparisonOperator.EQUALS, "=")
        comparisonOperatorStringMap.put(ComparisonOperator.NOT_EQUAL, "<>")
        comparisonOperatorStringMap.put(ComparisonOperator.LESS_THAN, "<")
        comparisonOperatorStringMap.put(ComparisonOperator.GREATER_THAN, ">")
        comparisonOperatorStringMap.put(ComparisonOperator.LESS_THAN_EQUAL_TO, "<=")
        comparisonOperatorStringMap.put(ComparisonOperator.GREATER_THAN_EQUAL_TO, ">=")
        comparisonOperatorStringMap.put(ComparisonOperator.IN, "IN")
        comparisonOperatorStringMap.put(ComparisonOperator.NOT_IN, "NOT IN")
        comparisonOperatorStringMap.put(ComparisonOperator.BETWEEN, "BETWEEN")
        comparisonOperatorStringMap.put(ComparisonOperator.LIKE, "LIKE")
        comparisonOperatorStringMap.put(ComparisonOperator.NOT_LIKE, "NOT LIKE")
    }
    protected static final Map<String, ComparisonOperator> stringComparisonOperatorMap = [
            "=":ComparisonOperator.EQUALS,
            "equals":ComparisonOperator.EQUALS,

            "not-equals":ComparisonOperator.NOT_EQUAL,
            "not-equal":ComparisonOperator.NOT_EQUAL,
            "!=":ComparisonOperator.NOT_EQUAL,
            "<>":ComparisonOperator.NOT_EQUAL,

            "less-than":ComparisonOperator.LESS_THAN,
            "less":ComparisonOperator.LESS_THAN,
            "<":ComparisonOperator.LESS_THAN,

            "greater-than":ComparisonOperator.GREATER_THAN,
            "greater":ComparisonOperator.GREATER_THAN,
            ">":ComparisonOperator.GREATER_THAN,

            "less-than-equal-to":ComparisonOperator.LESS_THAN_EQUAL_TO,
            "less-equals":ComparisonOperator.LESS_THAN_EQUAL_TO,
            "<=":ComparisonOperator.LESS_THAN_EQUAL_TO,

            "greater-than-equal-to":ComparisonOperator.GREATER_THAN_EQUAL_TO,
            "greater-equals":ComparisonOperator.GREATER_THAN_EQUAL_TO,
            ">=":ComparisonOperator.GREATER_THAN_EQUAL_TO,

            "in":ComparisonOperator.IN,
            "IN":ComparisonOperator.IN,

            "not-in":ComparisonOperator.NOT_IN,
            "NOT IN":ComparisonOperator.NOT_IN,

            "between":ComparisonOperator.BETWEEN,
            "BETWEEN":ComparisonOperator.BETWEEN,

            "like":ComparisonOperator.LIKE,
            "LIKE":ComparisonOperator.LIKE,

            "not-like":ComparisonOperator.LIKE,
            "NOT LIKE":ComparisonOperator.NOT_LIKE
    ]

    static String getJoinOperatorString(JoinOperator op) {
        return op == JoinOperator.OR ? "OR" : "AND"
    }
    static JoinOperator getJoinOperator(String opName) {
        if (!opName) return JoinOperator.AND
        switch (opName) {
            case "or":
            case "OR": return JoinOperator.OR
            case "and":
            case "AND":
            default: return JoinOperator.AND
        }
    }
    static String getComparisonOperatorString(ComparisonOperator op) {
        return comparisonOperatorStringMap.get(op)
    }
    static ComparisonOperator getComparisonOperator(String opName) {
        return stringComparisonOperatorMap.get(opName)
    }

    static boolean compareByOperator(Object value1, ComparisonOperator op, Object value2) {
        switch (op) {
        case ComparisonOperator.EQUALS:
            return value1 == value2
        case ComparisonOperator.NOT_EQUAL:
            return value1 != value2
        case ComparisonOperator.LESS_THAN:
            return value1 < value2
        case ComparisonOperator.GREATER_THAN:
            return value1 > value2
        case ComparisonOperator.LESS_THAN_EQUAL_TO:
            return value1 <= value2
        case ComparisonOperator.GREATER_THAN_EQUAL_TO:
            return value1 >= value2
        case ComparisonOperator.IN:
            if (value2 instanceof Collection) {
                return ((Collection) value2).contains(value1)
            } else {
                // not a Collection, try equals
                return value1 == value2
            }
        case ComparisonOperator.NOT_IN:
            if (value2 instanceof Collection) {
                return !((Collection) value2).contains(value1)
            } else {
                // not a Collection, try not-equals
                return value1 != value2
            }
        case ComparisonOperator.BETWEEN:
            if (value2 instanceof Collection && ((Collection) value2).size() == 2) {
                Iterator iterator = ((Collection) value2).iterator()
                Object lowObj = iterator.next()
                Object highObj = iterator.next()
                return lowObj <= value1 && value1 < highObj
            } else {
                return false
            }
        case ComparisonOperator.LIKE:
            return StupidUtilities.compareLike(value1, value2)
        case ComparisonOperator.NOT_LIKE:
            return !StupidUtilities.compareLike(value1, value2)
        }
        // default return false
        return false
    }
}
