<#include "ScreenHtmlMacros.ftl"/>

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
	<#assign _FORM_ = ec.web.parameters.get("_FORM_")?if_exists>
	<#assign formNode = sri.getFtlFormNode(.node["@name"])>
	<#assign formName = formNode["@name"]>
	<#if formName != _FORM_>
		<#return />
	</#if>
    <#assign isMulti = formNode["@multi"]?if_exists == "true">
    <#assign isMultiFinalRow = false>
    <#assign skipStart = (formNode["@skip-start"]?if_exists == "true")>
    <#assign skipEnd = (formNode["@skip-end"]?if_exists == "true")>
    <#assign urlInfo = sri.makeUrlByType(formNode["@transition"], "transition", null)>
    <#assign isDynamic = formNode["@dynamic"]?if_exists == "true">
	<#assign listName = formNode["@list"]>
	<#assign listObject = ec.resource.evaluateContextField(listName, "")?if_exists>
	<#assign formListColumnList = formNode["form-list-column"]?if_exists>
	<#assign sEcho = ec.web.parameters.get("sEcho")?if_exists>
	<#assign count = context[listName + "Count"]?if_exists>

	<#t>{"sEcho": ${sEcho}, "iTotalRecords": <#if count?has_content>${count}<#else>0</#if>, "iTotalDisplayRecords": <#if count?has_content>${count}<#else>0</#if> }
    <#if formListColumnList?exists && (formListColumnList?size > 0)>
        <#list listObject as listEntry>
            <#assign listEntryIndex = listEntry_index>
            <#-- NOTE: the form-list.@list-entry attribute is handled in the ScreenForm class through this call: -->
            ${sri.startFormListRow(formNode["@name"], listEntry)}
            <tr>
            <#list formNode["form-list-column"] as fieldListColumn>
                <td>
                    <#list fieldListColumn["field-ref"] as fieldRef>
                        <#assign fieldRefName = fieldRef["@name"]>
                        <#assign fieldNode = "invalid">
                        <#list formNode["field"] as fn><#if fn["@name"] == fieldRefName><#assign fieldNode = fn><#break></#if></#list>
                        <#if fieldNode == "invalid">
                            <div>Error: could not find field with name [${fieldRefName}] referred to in a form-list-column.field-ref.@name attribute.</div>
                        <#else>
                            <#assign formListSkipClass = true>
                            <@formListSubField fieldNode/>
                        </#if>
                    </#list>
                </td>
            </#list>
            </tr>
        ${sri.endFormListRow()}
        </#list>
    ${sri.safeCloseList(listObject)}<#-- if listObject is an EntityListIterator, close it -->
    <!-- close table -->
    ${sri.getAfterFormWriterText()}
    <#else>
        <#list listObject as listEntry>
            <#assign listEntryIndex = listEntry_index>
            <#-- NOTE: the form-list.@list-entry attribute is handled in the ScreenForm class through this call: -->
            ${sri.startFormListRow(formNode["@name"], listEntry)}
            <#if tr_class?if_exists == "even">
                <#assign tr_class = "odd">
            <#else>
                <#assign tr_class = "even">
            </#if>
            <#t><tr class="${tr_class}">
                <#t><#list formNode["field"] as fieldNode><@formListSubField fieldNode/></#list>
            <#t></tr>
            ${sri.endFormListRow()}
        </#list>
    ${sri.safeCloseList(listObject)}<#-- if listObject is an EntityListIterator, close it -->
    ${sri.getAfterFormWriterText()}
    </#if>
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

<#--<#macro fieldTitle fieldSubNode><#assign titleValue><#if fieldSubNode["@title"]?has_content>${fieldSubNode["@title"]}<#else/><#list fieldSubNode?parent["@name"]?split("(?=[A-Z])", "r") as nameWord>${nameWord?cap_first?replace("Id", "ID")}<#if nameWord_has_next> </#if></#list></#if></#assign>${ec.l10n.getLocalizedMessage(titleValue)}</#macro>-->

<#macro formListWidget fieldSubNode>
    <#if fieldSubNode["ignored"]?has_content><#return/></#if>
    <#if fieldSubNode?parent["@hide"]?if_exists == "true"><#return></#if>
<#-- don't do a column for submit fields, they'll go in their own row at the bottom -->
    <#t><#if isMulti && !isMultiFinalRow && fieldSubNode["submit"]?has_content><#return/></#if>
    <#t><#if isMulti && isMultiFinalRow && !fieldSubNode["submit"]?has_content><#return/></#if>
    <#if fieldSubNode["hidden"]?has_content><#recurse fieldSubNode/><#return/></#if>
    <#if !isMultiFinalRow><td></#if>
    <#list fieldSubNode?children as widgetNode>
        <#if widgetNode?node_name == "link">
            <#assign linkNode = widgetNode>
            <#assign linkUrlInfo = sri.makeUrlByType(linkNode["@url"], linkNode["@url-type"]!"transition", linkNode)>
            <#assign linkFormId><@fieldId linkNode/></#assign>
            <#assign afterFormText><@linkFormForm linkNode linkFormId linkUrlInfo/></#assign>
            <#t>${sri.appendToAfterFormWriter(afterFormText)}
            <#t><@linkFormLink linkNode linkFormId linkUrlInfo/>
        <#else>
            <#t><#visit widgetNode>
        </#if>
    </#list>
    <#if !isMultiFinalRow></td></#if>
</#macro>

<#--<#macro formListWidget fieldSubNode>-->
    <#--<#if fieldSubNode["ignored"]?has_content || fieldSubNode["hidden"]?has_content || fieldSubNode["submit"]?has_content><#return/></#if>-->
    <#--&lt;#&ndash; <#if fieldSubNode?parent["@hide"]?if_exists == "true"><#return></#if> &ndash;&gt;-->
    <#--<#t>&lt;#&ndash; <#if hasPrevColumn>,<#else><#assign hasPrevColumn = true></#if> &ndash;&gt;<#recurse fieldSubNode>-->
<#--</#macro>-->

<#--<#macro "display">-->
    <#--<#assign fieldValue = ""/>-->
    <#--<#if .node["@text"]?has_content>-->
        <#--<#assign fieldValue = ec.resource.evaluateStringExpand(.node["@text"], "")>-->
    <#--<#else>-->
        <#--<#assign fieldValue = sri.getFieldValue(.node?parent?parent, "")>-->
    <#--</#if>-->
    <#--<#if .node["@currency-unit-field"]?has_content>-->
        <#--<#assign fieldValue = ec.l10n.formatCurrency(fieldValue, .node["@currency-unit-field"], 2)>-->
    <#--<#else>-->
        <#--<#assign fieldValue = ec.l10n.formatValue(fieldValue, .node["@format"]?if_exists)>-->
    <#--</#if>-->
    <#--<#t><#if .node["@encode"]!"true" == "false">"${fieldValue?js_string}"<#else>"${(fieldValue!" ")?html?replace("\n", "<br>")}"</#if>-->
<#--</#macro>-->

<#--<#macro "display-entity">-->
    <#--<#assign fieldValue = ""/><#assign fieldValue = sri.getFieldEntityValue(.node)/>-->
    <#--<#t><#if formNode?node_name == "form-single"><span id="<@fieldId .node/>"></#if><#if .node["@encode"]!"true" == "false">${fieldValue!"&nbsp;"}<#else>${(fieldValue!" ")?html?replace("\n", "<br>")}</#if><#if formNode?node_name == "form-single"></span></#if>-->
    <#--<#t><#if !.node["@also-hidden"]?has_content || .node["@also-hidden"] == "true">&lt;#&ndash; <input type="hidden" name="<@fieldName .node/>" value="${sri.getFieldValue(.node?parent?parent, fieldValue!"")?html}"> &ndash;&gt;</#if>-->
<#--</#macro>-->

<#--<#macro fieldName widgetNode><#assign fieldNode=widgetNode?parent?parent/>${fieldNode["@name"]?html}<#if isMulti?exists && isMulti && listEntryIndex?exists>_${listEntryIndex}</#if></#macro>-->


<#macro "check">
    <#assign options = {"":""}/><#assign options = sri.getFieldOptions(.node)>
    <#assign currentValue = sri.getFieldValue(.node?parent?parent, "")>
    <#if !currentValue?has_content><#assign currentValue = .node["@no-current-selected-key"]?if_exists/></#if>
    <#assign id><@fieldId .node/></#assign>
    <#assign curName><@fieldName .node/></#assign>
    <#if options.size() gt 0>
        <#list (options.keySet())?if_exists as key>
        <#assign allChecked = ec.resource.evaluateStringExpand(.node["@all-checked"]?if_exists, "")>
        <span id="${id}<#if (key_index > 0)>_${key_index}</#if>"><input type="checkbox" name="${curName}" value="${key?html}"<#if allChecked?if_exists == "true"> checked="checked"<#elseif currentValue?has_content && currentValue==key> checked="checked"</#if><#if .node?parent["@tooltip"]?has_content> title="${.node?parent["@tooltip"]}"</#if>>${options.get(key)?default("")}</span>
        </#list>
    <#else>
        <input type="checkbox" name="${curName}" value="${currentValue?html}"<#if style?has_content> class="${style}"</#if>/>
    </#if>

</#macro>

<#--<#macro radio>-->
	<#--<#assign options = {"":""}/><#assign options = sri.getFieldOptions(.node)>-->
	<#--<#assign currentValue = sri.getFieldValue(.node?parent?parent, "")>-->
	<#--<#if !currentValue?has_content><#assign currentValue = .node["@no-current-selected-key"]?if_exists/></#if>-->
	<#--<#assign id><@fieldId .node/></#assign>-->
	<#--<#assign curName><@fieldName .node/></#assign>-->
	<#--<#assign style = .node["@style"]?if_exists>-->
	<#--<#if options.size() gt 0>-->
		<#--<#list (options.keySet())?if_exists as key>-->
	        <#--<#assign allChecked = ec.resource.evaluateStringExpand(.node["@all-checked"]?if_exists, "")>-->
	        <#--<span id="${id}<#if (key_index > 0)>_${key_index}</#if>"><input type="checkbox" name="${curName}" value="${key?html}"<#if allChecked?if_exists == "true"> checked="checked"<#elseif currentValue?has_content && currentValue==key> checked="checked"</#if>>${options.get(key)?default("")}</span>-->
	    <#--</#list>-->
	<#--<#else>-->
		<#--"<input type=\"radio\" name=\"${curName}\" value=\"${currentValue?html}\"<#if style?has_content> class=\"${style}\"</#if>/>"-->
	<#--</#if>-->
<#--</#macro>-->

<#--<#macro "text-line">-->
	<#--"<input type=\"text\" name=\"description\" value=\"Test one description.\" size=\"20\" id=\"ListTutorials_description_0\">"-->
<#--</#macro>-->

<#macro fieldId widgetNode><#assign fieldNode=widgetNode?parent?parent/>${fieldNode?parent["@name"]}_${fieldNode["@name"]}<#if listEntryIndex?exists>_${listEntryIndex}</#if></#macro>
<#macro fieldTitle fieldSubNode><#assign titleValue><#if fieldSubNode["@title"]?has_content>${ec.resource.evaluateStringExpand(fieldSubNode["@title"], "")}<#else/><#list fieldSubNode?parent["@name"]?split("(?=[A-Z])", "r") as nameWord>${nameWord?cap_first?replace("Id", "ID")}<#if nameWord_has_next> </#if></#list></#if></#assign>${ec.l10n.getLocalizedMessage(titleValue)}</#macro>


<#macro "container-dialog">
</#macro>

<#macro container>
</#macro>

<#--<#macro menu>-->
	<#--<#assign transition = .node["@transition"]?if_exists>-->
	<#--<#assign name = .node["@name"]?if_exists>-->
	<#--<#if transition?has_content>-->
		<#--<#t>"<div class=\"dropdown\" transition=\"${transition}\">-->
			<#--<#t><a data-toggle=\"dropdown\" class=\"dropdown-toggle\" role=\"operate-button\" href=\"#\">-->
			<#--<#t><img src=\"/images/tools_20.png\">-->
			<#--<#t><b class=\"caret\"></b></a>-->
		<#--<#t></div>"-->
	<#--<#else>-->
		<#--{-->
		<#--<#t>"name":"${name}"-->
		<#--}-->
	<#--</#if>-->
<#--</#macro>-->

<#macro nav>
</#macro>

<#--<#macro image>-->
	<#--""-->
<#--</#macro>-->

<#macro toolbar>
</#macro>

<#macro "button-group">
</#macro>

<#--<#macro button>-->
<#--</#macro>-->

<#-- =================================== 菜单 ============================= -->
<#macro menu>
    <#assign name = .node["@name"]?if_exists>
    <#--<#assign parent_node_name = .node?parent?node_name?default()>-->
    <#assign _MENU_NAME_ = context._MENU_NAME_?if_exists>
    <#if parent_node_name?if_exists !="menu-item" && _MENU_NAME_?has_content && name != _MENU_NAME_>
        <#return />
    </#if>
    <#assign style = .node["@style"]?default("nav")>
    <#assign title = .node["@title"]?if_exists>
    <#assign downArrow = .node["@down-arrow"]?if_exists>
    <#assign transition = .node["@transition"]?if_exists>
    <#assign menuItem = .node["menu-item"]?default()>
    <#if transition?has_content>
        <#assign urlInfo = sri.makeUrlByType(transition, "transition", null)>
    </#if>
    <#if parent_node_name?if_exists !="menu-item" && _MENU_NAME_?has_content>
        <#recurse />
        <#return />
    </#if>
    <#if parent_node_name?if_exists != "menu-item">
        <#if menuItem?has_content>
                <li class="dropdown"<#if hasParent?if_exists> id="menu-${name}""</#if>>
        <#else>
        <div class="dropdown"<#if hasParent?if_exists> id="menu-${name}"</#if> name="${name}">
        </#if>
        <a href="<#if urlInfo?has_content>${urlInfo.url}<#else>#</#if>" role="button" class="<#if type?if_exists == "button">btn btn-small </#if>dropdown-toggle" data-toggle="dropdown" ><#if title?has_content>${title}<#else>${name}</#if><#if downArrow == "true" && parent_node_name?if_exists != "menu-item"><b class="caret"></b></#if></a>
    <#else>
        <a href="<#if urlInfo?has_content>${urlInfo.url}<#else>#</#if>"><#if title?has_content>${title}<#else>${name}</#if><#-- <i class="icon-arrow-right"></i> --><#if downArrow == "true" && parent_node_name?if_exists != "menu-item"><b class="caret"></b></#if></a>
    </#if>
    <#if menuItem?has_content>
        <ul class="dropdown-menu sub-menu" role="menu" aria-labelledby="drop1">
            <#recurse />
        </ul>
    </#if>
    <#assign parent_node_name = .node?parent?node_name>
    <#if parent_node_name!="menu-item">
        <#if menuItem?has_content>
            </li>
        <#else>
        </div>
        </#if>
    </#if>
</#macro>

<#macro "menu-item">
    <#assign name = .node["@name"]?if_exists>
    <#assign transition = .node["@transition"]?if_exists>
    <#if transition?has_content>
        <#assign urlInfo = sri.makeUrlByType(transition, "transition", null)>
    </#if>
    <#assign submenu = .node["menu"][0]?if_exists>
    <#assign style = .node["@style"]?if_exists>
    <#assign title = .node["@title"]?if_exists>
    <#assign click = .node["@click"]?if_exists>
    <#if submenu?has_content>
    <li class="dropdown-submenu">
        <#assign parent_node_name = "menu-item">
        <#recurse />
    </li>
    <#else>
        <#assign parent_node_name = "">
        <li<#if style?has_content> class="${style}"</#if>>
            <#if name?has_content>
                <#if transition?has_content || click?has_content>
                    <a href="<#if urlInfo?has_content>${urlInfo.url}<#else>#</#if>"<#if click?has_content> onclick="${click?html};return false;"</#if>><#if title?has_content>${title}<#else>${name}</#if></a>
                <#else>
                    <a href="#"><#if title?has_content>${title}<#else>${name}</#if></a>
                </#if>
            </#if>
        </li>
    </#if>
</#macro>
