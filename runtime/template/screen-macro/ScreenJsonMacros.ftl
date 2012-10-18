<#macro "render-mode">
</#macro>

<#macro "subscreens-active">

    ${sri.renderSubscreen()}
</#macro>

<#macro "container-panel">
    <#--<#if .node["panel-header"]?has_content>-->
        <#--<#recurse .node["panel-header"][0]>-->
    <#--</#if>-->
    <#--<#if .node["panel-left"]?has_content>-->
        <#--<#recurse .node["panel-left"][0]>-->
    <#--</#if>-->
    <#--<#if .node["panel-right"]?has_content>-->
        <#--<#recurse .node["panel-right"][0]>-->
    <#--</#if>-->
    <#recurse .node["panel-center"][0]>
</#macro>

<#macro "section-iterate">
    ${sri.renderSection(.node["@name"])}
</#macro>

<#macro "subscreens-panel">
    <#assign dynamic = .node["@dynamic"]?if_exists == "true" && .node["@id"]?has_content>
    <#assign dynamicActive = 0>
    <#assign displayMenu = sri.activeInCurrentMenu?if_exists>
    <#--<#if .node["@type"]?if_exists == "popup">-->
        <#-- 取得当前菜单名称 -->
        <#list sri.getActiveScreenDef().getSubscreensItemsSorted() as subscreensItem>
            <#assign urlInfo = sri.buildUrl(subscreensItem.name)>
            <#if urlInfo.inCurrentScreenPath><#assign currentItemName = ec.l10n.getLocalizedMessage(subscreensItem.menuTitle)></#if>
        </#list>
        <#--<li><a href="#">${.node["@title"]!"Menu"}<#if currentItemName?has_content> (${currentItemName})</#if></a>-->
            <ul role="menu" class="dropdown-menu">
                <#list sri.getActiveScreenDef().getSubscreensItemsSorted() as subscreensItem><#if subscreensItem.menuInclude>
                    <#assign urlInfo = sri.buildUrl(subscreensItem.name)>
                    <#if urlInfo.isPermitted()>
                        <li class=""><a href="<#if urlInfo.disableLink>#<#else>${urlInfo.minimalPathUrlWithParams}</#if>">${ec.l10n.getLocalizedMessage(subscreensItem.menuTitle)}</a></li>
                        <#-- <#if urlInfo.inCurrentScreenPath>ui-state-active</#if> -->
                    </#if>
                </#if></#list>
            </ul>
        <#--</li>-->
    <#--</#if>-->
</#macro>

<#macro link>
</#macro>

<#macro "form-single">
</#macro>

<#-- 
bRegex	false
bRegex_0	false
bRegex_1	false
bRegex_2	false
bSearchable_0	true
bSearchable_1	true
bSearchable_2	true
bSortable_0	true
bSortable_1	true
bSortable_2	true
iColumns	3
iDisplayLength	10
iDisplayStart	0
iSortCol_0	0
iSortingCols	1
mDataProp_0	tutorialId
mDataProp_1	description
mDataProp_2	lastUpdatedStamp
sColumns
sEcho	1
sSearch
sSearch_0
sSearch_1
sSearch_2
sSortDir_0	asc
-->
<#macro "form-list">
	<#assign _FORM_ = ec.web.parameters.get("_FORM_")>
	<#assign formNode = sri.getFtlFormNode(.node["@name"])>
	<#assign formName = formNode["@name"]>
	<#if formName != _FORM_>
		<#return>
	</#if>
	<#assign isDynamic = formNode["@dynamic"]?if_exists == "true">
	<#assign listName = formNode["@list"]>
	<#assign listObject = ec.resource.evaluateContextField(listName, "")>
	<#assign formListColumnList = formNode["form-list-column"]?if_exists>
	
	<#assign sEcho = ec.web.parameters.get("sEcho")?if_exists>
	<#assign count = context[listName + "Count"]>
	<#t>{"sEcho": ${sEcho}, "iTotalRecords": ${count}, "iTotalDisplayRecords": ${count},"aaData":[
	<#if formListColumnList?exists && (formListColumnList?size > 0)>
	    <#assign hasPrevColumn = false>
	    <#list formListColumnList as fieldListColumn>
	        <#list fieldListColumn["field-ref"] as fieldRef>
	            <#assign fieldRef = fieldRef["@name"]>
	            <#assign fieldNode = "invalid">
	            <#list formNode["field"] as fn><#if fn["@name"] == fieldRef><#assign fieldNode = fn><#break></#if></#list>
	            <#if !(fieldNode["@hide"]?if_exists == "true" ||
	                    ((!fieldNode["@hide"]?has_content) && fieldNode?children?size == 1 &&
	                    (fieldNode?children[0]["hidden"]?has_content || fieldNode?children[0]["ignored"]?has_content)))>
	                <#t><@formListHeaderField fieldNode/>
	            </#if>
	        </#list>
	    </#list>

	    <#list listObject as listEntry>
	        <#assign listEntryIndex = listEntry_index>
	        <#-- NOTE: the form-list.@list-entry attribute is handled in the ScreenForm class through this call: -->
	        ${sri.startFormListRow(formNode["@name"], listEntry)}<#t>
	        <#assign hasPrevColumn = false>
	        <#list formNode["form-list-column"] as fieldListColumn>
	            <#list fieldListColumn["field-ref"] as fieldRef>
	                <#assign fieldRef = fieldRef["@name"]>
	                <#assign fieldNode = "invalid">
	                <#list formNode["field"] as fn><#if fn["@name"] == fieldRef><#assign fieldNode = fn><#break></#if></#list>
	                <#t><@formListSubField fieldNode/>
	            </#list>
	        </#list>

	        ${sri.endFormListRow()}<#t>
	    </#list>
	    ${sri.safeCloseList(listObject)}<#t><#-- if listObject is an EntityListIterator, close it -->
	<#else>
	    <#assign hasPrevColumn = false>
	    <#-- <#list formNode["field"] as fieldNode>
	    	        <#if !(fieldNode["@hide"]?if_exists == "true" ||
	    	                ((!fieldNode["@hide"]?has_content) && fieldNode?children?size == 1 &&
	    	                (fieldNode?children[0]["hidden"]?has_content || fieldNode?children[0]["ignored"]?has_content)))>
	    	            <#t><@formListHeaderField fieldNode/>
	    	        </#if>
	    	    </#list> -->
	    <#list listObject as listEntry>
	        <#assign listEntryIndex = listEntry_index>
			<#t><#if listEntryIndex gt 0>,</#if><#t>
	        <#-- NOTE: the form-list.@list-entry attribute is handled in the ScreenForm class through this call: -->
	        ${sri.startFormListRow(formNode["@name"], listEntry)}<#t>
	        <#assign hasPrevColumn = false>
			<#t>{
			<#t><#list formNode["field"] as fieldNode>
				<#assign field_name = fieldNode["@name"]?if_exists>
				<#if fieldNode_index gt 0>, </#if><#t>"${field_name}":<@formListSubField fieldNode/>
	        <#t></#list>
			<#t>}
	        ${sri.endFormListRow()}<#t>
	    </#list>
	    ${sri.safeCloseList(listObject)}<#t><#-- if listObject is an EntityListIterator, close it -->
	</#if>
	<#t>]}
</#macro>


<#macro formListHeaderField fieldNode>
    <#if fieldNode["header-field"]?has_content>
        <#assign fieldSubNode = fieldNode["header-field"][0]>
    <#elseif fieldNode["default-field"]?has_content>
        <#assign fieldSubNode = fieldNode["default-field"][0]>
    <#else>
        <#-- this only makes sense for fields with a single conditional -->
        <#assign fieldSubNode = fieldNode["conditional-field"][0]>
    </#if>
    <#if fieldSubNode["ignored"]?has_content || fieldSubNode["hidden"]?has_content || fieldSubNode["submit"]?has_content><#return/></#if>
    <#t><#if hasPrevColumn>,<#else><#assign hasPrevColumn = true></#if><@fieldTitle fieldSubNode/>
</#macro>

<#macro fieldTitle fieldSubNode><#assign titleValue><#if fieldSubNode["@title"]?has_content>${fieldSubNode["@title"]}<#else/><#list fieldSubNode?parent["@name"]?split("(?=[A-Z])", "r") as nameWord>${nameWord?cap_first?replace("Id", "ID")}<#if nameWord_has_next> </#if></#list></#if></#assign>${ec.l10n.getLocalizedMessage(titleValue)}</#macro>

<#macro formListSubField fieldNode>
    <#list fieldNode["conditional-field"] as fieldSubNode>
        <#if ec.resource.evaluateCondition(fieldSubNode["@condition"], "")>
            <#t><@formListWidget fieldSubNode/>
            <#return>
        </#if>
    </#list>
    <#if fieldNode["default-field"]?has_content>
        <#t><@formListWidget fieldNode["default-field"][0]/>
        <#return>
    </#if>
</#macro>

<#macro formListWidget fieldSubNode>
    <#if fieldSubNode["ignored"]?has_content || fieldSubNode["hidden"]?has_content || fieldSubNode["submit"]?has_content><#return/></#if>
    <#-- <#if fieldSubNode?parent["@hide"]?if_exists == "true"><#return></#if> -->
    <#t><#-- <#if hasPrevColumn>,<#else><#assign hasPrevColumn = true></#if> --><#recurse fieldSubNode>
</#macro>

<#macro "display">
    <#assign fieldValue = ""/>
    <#if .node["@text"]?has_content>
        <#assign fieldValue = ec.resource.evaluateStringExpand(.node["@text"], "")>
    <#else>
        <#assign fieldValue = sri.getFieldValue(.node?parent?parent, "")>
    </#if>
    <#if .node["@currency-unit-field"]?has_content>
        <#assign fieldValue = ec.l10n.formatCurrency(fieldValue, .node["@currency-unit-field"], 2)>
    <#else>
        <#assign fieldValue = ec.l10n.formatValue(fieldValue, .node["@format"]?if_exists)>
    </#if>
    <#t><#if .node["@encode"]!"true" == "false">"${fieldValue?js_string}"<#else>"${(fieldValue!" ")?html?replace("\n", "<br>")}"</#if>
</#macro>

<#macro "display-entity">
    <#assign fieldValue = ""/><#assign fieldValue = sri.getFieldEntityValue(.node)/>
    <#t><#if formNode?node_name == "form-single"><span id="<@fieldId .node/>"></#if><#if .node["@encode"]!"true" == "false">${fieldValue!"&nbsp;"}<#else>${(fieldValue!" ")?html?replace("\n", "<br>")}</#if><#if formNode?node_name == "form-single"></span></#if>
    <#t><#if !.node["@also-hidden"]?has_content || .node["@also-hidden"] == "true"><#-- <input type="hidden" name="<@fieldName .node/>" value="${sri.getFieldValue(.node?parent?parent, fieldValue!"")?html}"> --></#if>
</#macro>

<#macro fieldName widgetNode><#assign fieldNode=widgetNode?parent?parent/>${fieldNode["@name"]?html}<#if isMulti?exists && isMulti && listEntryIndex?exists>_${listEntryIndex}</#if></#macro>


<#macro check>
    <#assign options = {"":""}/><#assign options = sri.getFieldOptions(.node)>
    <#assign currentValue = sri.getFieldValue(.node?parent?parent, "")>
    <#if !currentValue?has_content><#assign currentValue = .node["@no-current-selected-key"]?if_exists/></#if>
    <#assign id><@fieldId .node/></#assign>
    <#assign curName><@fieldName .node/></#assign>
	<#assign style = .node["@style"]?if_exists>
	<#if options.size() gt 0>
    	<#list (options.keySet())?if_exists as key>
	        <#assign allChecked = ec.resource.evaluateStringExpand(.node["@all-checked"]?if_exists, "")>
	        <span id="${id}<#if (key_index > 0)>_${key_index}</#if>"><input type="checkbox" name="${curName}" value="${key?html}"<#if allChecked?if_exists == "true"> checked="checked"<#elseif currentValue?has_content && currentValue==key> checked="checked"</#if>>${options.get(key)?default("")}</span>
	    </#list>
	<#else>
		"<input type=\"checkbox\" name=\"${curName}\" value=\"${currentValue?html}\"<#if style?has_content> class=\"${style}\"</#if>/>"
	</#if>
</#macro>

<#macro radio>
	<#assign options = {"":""}/><#assign options = sri.getFieldOptions(.node)>
	<#assign currentValue = sri.getFieldValue(.node?parent?parent, "")>
	<#if !currentValue?has_content><#assign currentValue = .node["@no-current-selected-key"]?if_exists/></#if>
	<#assign id><@fieldId .node/></#assign>
	<#assign curName><@fieldName .node/></#assign>
	<#assign style = .node["@style"]?if_exists>
	<#if options.size() gt 0>
		<#list (options.keySet())?if_exists as key>
	        <#assign allChecked = ec.resource.evaluateStringExpand(.node["@all-checked"]?if_exists, "")>
	        <span id="${id}<#if (key_index > 0)>_${key_index}</#if>"><input type="checkbox" name="${curName}" value="${key?html}"<#if allChecked?if_exists == "true"> checked="checked"<#elseif currentValue?has_content && currentValue==key> checked="checked"</#if>>${options.get(key)?default("")}</span>
	    </#list>
	<#else>
		"<input type=\"radio\" name=\"${curName}\" value=\"${currentValue?html}\"<#if style?has_content> class=\"${style}\"</#if>/>"
	</#if>
</#macro>

<#macro "text-line">
	"<input type=\"text\" name=\"description\" value=\"Test one description.\" size=\"20\" id=\"ListTutorials_description_0\">"
</#macro>

<#macro fieldId widgetNode><#assign fieldNode=widgetNode?parent?parent/>${fieldNode?parent["@name"]}_${fieldNode["@name"]}<#if listEntryIndex?exists>_${listEntryIndex}</#if></#macro>
<#macro fieldTitle fieldSubNode><#assign titleValue><#if fieldSubNode["@title"]?has_content>${ec.resource.evaluateStringExpand(fieldSubNode["@title"], "")}<#else/><#list fieldSubNode?parent["@name"]?split("(?=[A-Z])", "r") as nameWord>${nameWord?cap_first?replace("Id", "ID")}<#if nameWord_has_next> </#if></#list></#if></#assign>${ec.l10n.getLocalizedMessage(titleValue)}</#macro>


<#macro "container-dialog">
</#macro>

<#macro container>
</#macro>

<#macro menu>
	<#assign transition = .node["@transition"]?if_exists>
	<#assign name = .node["@name"]?if_exists>
	<#if transition?has_content>
		<#t>"<div class=\"dropdown\" transition=\"${transition}\">
			<#t><a data-toggle=\"dropdown\" class=\"dropdown-toggle\" role=\"operate-button\" href=\"#\">
			<#t><img src=\"/images/tools_20.png\">
			<#t><b class=\"caret\"></b></a>
		<#t></div>"
	<#else>
		{
		<#t>"name":"${name}"
		}
	</#if>
</#macro>

<#macro nav>
</#macro>

<#macro image>
	""
</#macro>

<#macro toolbar>
</#macro>

<#macro "button-group">
</#macro>

<#macro button>
</#macro>