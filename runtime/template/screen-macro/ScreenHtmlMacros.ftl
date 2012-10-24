<#--
This Work is in the public domain and is provided on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied,
including, without limitation, any warranties or conditions of TITLE,
NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE.
You are solely responsible for determining the appropriateness of using
this Work and assume any risks associated with your use of this Work.

This Work includes contributions authored by David E. Jones, not as a
"work for hire", who hereby disclaims any copyright to the same.
-->

<#include "classpath://template/DefaultScreenMacros.html.ftl"/>


<#-- ============== Render Mode Elements ============== -->
<#macro "render-mode">
<#if .node["text"]?has_content>
    <#list .node["text"] as textNode>
        <#if textNode["@type"]?has_content && textNode["@type"] == sri.getRenderMode()><#assign textToUse = textNode/></#if>
    </#list>
    <#if !textToUse?has_content>
        <#list .node["text"] as textNode><#if !textNode["@type"]?has_content || textNode["@type"] == "any"><#assign textToUse = textNode/></#if></#list>
    </#if>
    <#if textToUse?exists>
        <#if textToUse["@location"]?has_content>
<#if sri.doBoundaryComments() && 1==2><!-- BEGIN render-mode.text[@location=${textToUse["@location"]}][@template=${textToUse["@template"]?default("true")}] --></#if>
    <#-- NOTE: this still won't encode templates that are rendered to the writer -->
    <#if .node["@encode"]!"false" == "true">${sri.renderText(textToUse["@location"], textToUse["@template"]?if_exists)?html}<#else/>${sri.renderText(textToUse["@location"], textToUse["@template"]?if_exists)}</#if>
<#if sri.doBoundaryComments() && 1==2><!-- END   render-mode.text[@location=${textToUse["@location"]}][@template=${textToUse["@template"]?default("true")}] --></#if>
        </#if>
        <#assign inlineTemplateSource = textToUse?string/>
        <#if inlineTemplateSource?has_content>
<#if sri.doBoundaryComments() && 1==2><!-- BEGIN render-mode.text[inline][@template=${textToUse["@template"]?default("true")}] --></#if>
          <#if !textToUse["@template"]?has_content || textToUse["@template"] == "true">
            <#assign inlineTemplate = [inlineTemplateSource, sri.getActiveScreenDef().location + ".render_mode.text"]?interpret>
            <@inlineTemplate/>
          <#else/>
            <#if .node["@encode"]!"false" == "true">${inlineTemplateSource?html}<#else/>${inlineTemplateSource}</#if>
          </#if>
<#if sri.doBoundaryComments() && 1==2><!-- END   render-mode.text[inline][@template=${textToUse["@template"]?default("true")}] --></#if>
        </#if>
    </#if>
</#if>
</#macro>

<#-- ================ Subscreens ================ -->
<#--<#macro "subscreens-active">-->
    <#--&lt;#&ndash; <div class="ui-tabs"> &ndash;&gt;-->
        <#--<div<#if .node["@id"]?has_content> id="${.node["@id"]}"</#if>>-->
        <#--${sri.renderSubscreen()}-->
        <#--</div>-->
    <#--&lt;#&ndash; </div> &ndash;&gt;-->
<#--</#macro>-->
<#macro "subscreens-active">
    <#if .node["@id"]?has_content>
    <div class="ui-tabs">
        <div id="${.node["@id"]}" class="ui-tabs-panel">
        ${sri.renderSubscreen()}
        </div>
    </div>
    <#else>
    ${sri.renderSubscreen()}
    </#if>
</#macro>



<#--<#macro "subscreens-panel">-->
    <#--<#assign dynamic = .node["@dynamic"]?if_exists == "true" && .node["@id"]?has_content>-->
    <#--<#assign dynamicActive = 0>-->
    <#--<#assign displayMenu = sri.activeInCurrentMenu?if_exists>&lt;#&ndash;  &ndash;&gt;-->
    <#--<#if !(.node["@type"]?has_content) || .node["@type"] == "tab">-->
    <#--<div<#if .node["@id"]?has_content> id="${.node["@id"]}"</#if> class="${.node["@tyle"]?if_exists}">-->
        <#--<#if displayMenu?if_exists>-->
            <#--<ul<#if .node["@id"]?has_content> id="${.node["@id"]}-menu"</#if> class="nav nav-tabs">-->
                <#--<#list sri.getActiveScreenDef().getSubscreensItemsSorted() as subscreensItem>-->
                    <#--<#if subscreensItem.menuInclude>-->
                        <#--<#assign urlInfo = sri.buildUrl(subscreensItem.name)>-->
                        <#--<#if urlInfo.isPermitted()>-->
                            <#--<#if dynamic>-->
                                <#--<#assign urlInfo = urlInfo.addParameter("lastStandalone", "true")>-->
                                <#--<#if urlInfo.inCurrentScreenPath>-->
                                    <#--<#assign dynamicActive = subscreensItem_index>-->
                                    <#--<#assign urlInfo = urlInfo.addParameters(ec.web.requestParameters)>-->
                                <#--</#if>-->
                            <#--</#if>-->
                            <#--<li class="<#if urlInfo.disableLink> disabled<#elseif urlInfo.inCurrentScreenPath> active</#if>">-->
                                <#--<a href="<#if urlInfo.disableLink>#<#else>${urlInfo.minimalPathUrlWithParams}</#if>">-->
                                    <#--<span>${subscreensItem.menuTitle}</span>-->
                                <#--</a>-->
                            <#--</li>-->
                        <#--</#if>-->
                    <#--</#if>-->
                <#--</#list>-->
            <#--</ul>-->
        <#--</#if>-->
        <#--<#if !dynamic || !displayMenu>-->
            <#--<div<#if .node["@id"]?has_content> id="${.node["@id"]}-active"</#if> class="ui-tabs-panel">-->
            <#--${sri.renderSubscreen()}-->
            <#--</div>-->
        <#--</#if>-->
        <#--<#if dynamic>-->
            <#--<div<#if .node["@id"]?has_content> id="${.node["@id"]}-active"</#if> class="tab-content">-->
            <#--</div>-->
            <#--<script>-->
                <#--// $("#${.node["@id"]}").tabs({ collapsible: true, selected: ${dynamicActive}, spinner: '<span class="ui-loading">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>',-->
                <#--//                                         ajaxOptions: { error: function(xhr, status, index, anchor) { $(anchor.hash).html("Error loading screen..."); } }-->
                <#--//});-->
                <#--$('#${.node["@id"]} ul.nav a').on('click', function (e) {-->
                    <#--$(this).tab('show');-->
                    <#--$('#${.node["@id"]}-active').load($(this).attr('href'));-->
                    <#--return false;-->
                <#--})-->
                <#--$(document).ready(function(){-->
                    <#--$('#${.node["@id"]} ul.nav a:first').click();-->
                <#--})-->
                <#--// $('#${.node["@id"]} ul.nav a').on('show', function (e) {-->
                <#--// 				alert('show');-->
                <#--// 			})-->
            <#--</script>-->
        <#--</#if>-->
    <#--</div>-->
    <#--<#elseif .node["@type"] == "stack">-->
    <#--<h1>LATER stack type subscreens-panel not yet supported.</h1>-->
    <#--<#elseif .node["@type"] == "wizard">-->
    <#--<h1>LATER wizard type subscreens-panel not yet supported.</h1>-->
    <#--</#if>-->
<#--</#macro>-->

<#macro "subscreens-panel">
    <#assign dynamic = .node["@dynamic"]?if_exists == "true" && .node["@id"]?has_content>
    <#assign dynamicActive = 0>
    <#assign displayMenu = sri.activeInCurrentMenu?if_exists>
    <#if .node["@type"]?if_exists == "popup">
        <#assign menuId><#if .node["@id"]?has_content>${.node["@id"]}-menu<#else>subscreensPanelMenu</#if></#assign>
    <ul id="${menuId}"<#if .node["@width"]?has_content> style="width: ${.node["@menu-width"]};"</#if>>
        <#list sri.getActiveScreenDef().getSubscreensItemsSorted() as subscreensItem>
            <#assign urlInfo = sri.buildUrl(subscreensItem.name)>
            <#if urlInfo.inCurrentScreenPath><#assign currentItemName = ec.l10n.getLocalizedMessage(subscreensItem.menuTitle)></#if>
        </#list>
        <li><a data-toggle="dropdown" class="dropdown-toggle" role="button" href="#">${.node["@title"]!"Menu"}<#if currentItemName?has_content> (${currentItemName})</#if></a>
            <ul>
                <#list sri.getActiveScreenDef().getSubscreensItemsSorted() as subscreensItem><#if subscreensItem.menuInclude>
                    <#assign urlInfo = sri.buildUrl(subscreensItem.name)>
                    <#if urlInfo.isPermitted()>
                        <li class="<#if urlInfo.inCurrentScreenPath>active</#if>"><a href="<#if urlInfo.disableLink>#<#else>${urlInfo.minimalPathUrlWithParams}</#if>">${ec.l10n.getLocalizedMessage(subscreensItem.menuTitle)}</a></li>
                    </#if>
                </#if></#list>
            </ul>
        </li>
    </ul>
    <script>$("#${menuId}").menu({position: { my: "right top", at: "right bottom" }});</script>

    ${sri.renderSubscreen()}
    <#elseif .node["@type"]?if_exists == "stack">
    <h1>LATER stack type subscreens-panel not yet supported.</h1>
    <#elseif .node["@type"]?if_exists == "wizard">
    <h1>LATER wizard type subscreens-panel not yet supported.</h1>
    <#else>
    <#-- default to type=tab -->
    <div<#if .node["@id"]?has_content> id="${.node["@id"]}"</#if> class="ui-tabs ui-tabs-collapsible">
        <#if displayMenu?if_exists>
            <ul<#if .node["@id"]?has_content> id="${.node["@id"]}-menu"</#if> class="nav nav-tabs">
                <#list sri.getActiveScreenDef().getSubscreensItemsSorted() as subscreensItem><#if subscreensItem.menuInclude>
                    <#assign urlInfo = sri.buildUrl(subscreensItem.name)>
                    <#if urlInfo.isPermitted()>
                        <#if dynamic>
                            <#assign urlInfo = urlInfo.addParameter("lastStandalone", "true")>
                            <#if urlInfo.inCurrentScreenPath>
                                <#assign dynamicActive = subscreensItem_index>
                                <#assign urlInfo = urlInfo.addParameters(ec.web.requestParameters)>
                            </#if>
                        </#if>
                        <li class="<#if urlInfo.disableLink> disabled<#elseif urlInfo.inCurrentScreenPath> active</#if>"><a href="<#if urlInfo.disableLink>#<#else>${urlInfo.minimalPathUrlWithParams}</#if>"><span>${subscreensItem.menuTitle}</span></a></li>
                    </#if>
                </#if></#list>
            </ul>
        </#if>
        <#if !dynamic || !displayMenu>
            <div<#if .node["@id"]?has_content> id="${.node["@id"]}-active"</#if> class="ui-tabs-panel">
            ${sri.renderSubscreen()}
            </div>
        </#if>
    </div>
        <#if dynamic>
        <script>
            $("#${.node["@id"]}").tabs({ collapsible: true, selected: ${dynamicActive}, spinner: '<span class="ui-loading">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>',
                ajaxOptions: { error: function(xhr, status, index, anchor) { $(anchor.hash).html("Error loading screen..."); } }
            });
        </script>
        </#if>
    </#if>
</#macro>

<#--<#macro "subscreens-menu">-->
    <#--&lt;#&ndash; <div class="ui-tabs ui-tabs-collapsible"> &ndash;&gt;-->
        <#--<ul<#if .node["@id"]?has_content> id="${.node["@id"]}"</#if> class="nav">-->
	        <#--<#list sri.getActiveScreenDef().getSubscreensItemsSorted() as subscreensItem>-->
		        <#--<#if subscreensItem.menuInclude>-->
		            <#--<#assign urlInfo = sri.buildUrl(subscreensItem.name)>-->
		            <#--<#if urlInfo.isPermitted()>-->
		                <#--<li class="<#if urlInfo.inCurrentScreenPath> active</#if>">-->
		                <#--<#if urlInfo.disableLink>${ec.l10n.getLocalizedMessage(subscreensItem.menuTitle)}<#else>-->
		                <#--<a href="${urlInfo.minimalPathUrlWithParams}">-->
		                	<#--${ec.l10n.getLocalizedMessage(subscreensItem.menuTitle)}-->
		                <#--</a>-->
		                <#--</#if>-->
		                <#--</li>-->
		            <#--</#if>-->
		        <#--</#if>-->
	        <#--</#list>-->
        <#--</ul>-->
    <#--&lt;#&ndash; </div> &ndash;&gt;-->
<#--</#macro>-->
<#macro "subscreens-menu">
    <#if .node["@type"]?if_exists == "popup">
        <#assign menuId = .node["@id"]!"subscreensMenu">
    <ul id="${menuId}"<#if .node["@width"]?has_content> style="width: ${.node["@width"]};"</#if> class="nav nav-pills" trigger="hover">
        <#list sri.getActiveScreenDef().getSubscreensItemsSorted() as subscreensItem>
            <#assign urlInfo = sri.buildUrl(subscreensItem.name)>
            <#if urlInfo.inCurrentScreenPath><#assign currentItemName = ec.l10n.getLocalizedMessage(subscreensItem.menuTitle)></#if>
        </#list>
        <li class="dropdown"><a data-toggle="dropdown" class="dropdown-toggle" role="button" href="#">${.node["@title"]!"Menu"}<#if currentItemName?has_content> (${currentItemName})</#if></a>
            <ul role="menu" class="dropdown-menu sub-menu">
                <#list sri.getActiveScreenDef().getSubscreensItemsSorted() as subscreensItem><#if subscreensItem.menuInclude>
                    <#assign urlInfo = sri.buildUrl(subscreensItem.name)>
                    <#if urlInfo.isPermitted()>
                        <li class="<#if urlInfo.inCurrentScreenPath>active</#if>">
                            <a href="<#if urlInfo.disableLink>#<#else>${urlInfo.minimalPathUrlWithParams}</#if>">${ec.l10n.getLocalizedMessage(subscreensItem.menuTitle)}</a>
                        </li>
                    </#if>
                </#if></#list>
            </ul>
        </li>
    </ul>
    <#--<script>$("#${menuId}").menu({position: { my: "right top", at: "right bottom" }});</script>-->
    <#elseif .node["@type"]?if_exists == "popup-tree">
    <#else>
    <#-- default to type=tab -->
    <#--<div class="ui-tabs ui-tabs-collapsible">-->
        <ul<#if .node["@id"]?has_content> id="${.node["@id"]}"</#if> class="nav" role="navigation">
            <#list sri.getActiveScreenDef().getSubscreensItemsSorted() as subscreensItem><#if subscreensItem.menuInclude>
                <#assign urlInfo = sri.buildUrl(subscreensItem.name)>
                <#if urlInfo.isPermitted()>
                    <li class="dropdown <#if urlInfo.inCurrentScreenPath> active</#if>"><#if urlInfo.disableLink>${ec.l10n.getLocalizedMessage(subscreensItem.menuTitle)}<#else>
                        <a href="${urlInfo.minimalPathUrlWithParams}" class="dropdown-toggle" data-toggle="dropdown" role="button" onclick="getSubMenu(this)">${ec.l10n.getLocalizedMessage(subscreensItem.menuTitle)}<b class="caret"></b></a></#if>
                    </li>
                </#if>
            </#if></#list>
        </ul>
    <#--</div>-->
        <script type="text/javascript">
            $(document).ready(function(){
            })
        </script>
    </#if>
</#macro>


<#-- ================ Containers ================ -->


<#macro renderFormListPaginate>
	<div class="form-list-paginate">
	    <#if (context[listName + "PageIndex"] > 0)>
	        <#assign firstUrlInfo = sri.getCurrentScreenUrl().cloneUrlInfo().addParameter("pageIndex", 0)>
	        <#assign previousUrlInfo = sri.getCurrentScreenUrl().cloneUrlInfo().addParameter("pageIndex", (context[listName + "PageIndex"] - 1))>
	        <a href="${firstUrlInfo.getUrlWithParams()}">|&lt;</a>
	        <a href="${previousUrlInfo.getUrlWithParams()}">&lt;</a>
	    <#else>
	        <span>|&lt;</span>
	        <span>&lt;</span>
	    </#if>
	    <span>${context[listName + "PageRangeLow"]} - ${context[listName + "PageRangeHigh"]} / ${context[listName + "Count"]}</span>
	    <#if (context[listName + "PageIndex"] < context[listName + "PageMaxIndex"])>
	        <#assign lastUrlInfo = sri.getCurrentScreenUrl().cloneUrlInfo().addParameter("pageIndex", context[listName + "PageMaxIndex"])>
	        <#assign nextUrlInfo = sri.getCurrentScreenUrl().cloneUrlInfo().addParameter("pageIndex", context[listName + "PageIndex"] + 1)>
	        <a href="${nextUrlInfo.getUrlWithParams()}">&gt;</a>
	        <a href="${lastUrlInfo.getUrlWithParams()}">&gt;|</a>
	    <#else>
	        <span>&gt;</span>
	        <span>&gt;|</span>
	    </#if>
	</div>
</#macro>

<#macro "form-list">
	<#-- <#if ec.web.parameters.get("lastStandalone") == "true"> -->
	<#-- <#assign targetParameters = urlInfo.getParameterMap()> -->
	<#-- ${ec.web.requestParameters} -->
	<#-- <#return> -->
	<#-- </#if> -->
	<#if sri.doBoundaryComments()><!-- BEGIN form-list[@name=${.node["@name"]}] --></#if>
    <#-- Use the formNode assembled based on other settings instead of the straight one from the file: -->
    <#assign formNode = sri.getFtlFormNode(.node["@name"])>
    <#assign isMulti = formNode["@multi"]?if_exists == "true">
    <#assign isMultiFinalRow = false>
    <#assign skipStart = (formNode["@skip-start"]?if_exists == "true")>
    <#assign skipEnd = (formNode["@skip-end"]?if_exists == "true")>
	<#assign isDynamic = formNode["@dynamic"]?if_exists == "true">
	<#assign render = formNode["@render"]?if_exists>
	<#if render?has_content>
		<#assign render_data = render?eval />
		<#assign type = (render_data.type)?if_exists>
	</#if>
	<#-- <#assign type = formNode["@type"]?if_exists> -->
    <#assign urlInfo = sri.makeUrlByType(formNode["@transition"], "transition", null)>
	<#if formNode["@list"]?exists>
	    <#assign listName = formNode["@list"]>
		<#assign listObject = (ec.resource.evaluateContextField(listName, ""))!>
	</#if>
    <#assign formListColumnList = formNode["form-list-column"]?if_exists>
    <#if formListColumnList?exists && (formListColumnList?size > 0)>
	    <#if !(formNode["@paginate"]?if_exists == "false")
	 		&& context[listName + "Count"]?exists
	 		&& (context[listName + "Count"]?if_exists > 0)>
			<@renderFormListPaginate />
	    </#if>
        <div class="form-list-outer" id="${formNode["@name"]}-table">
            <div class="form-header-group">
                <#assign needHeaderForm = sri.isFormHeaderForm(formNode["@name"])>
                <#if needHeaderForm && !skipStart>
                    <#assign curUrlInfo = sri.getCurrentScreenUrl()>
                <form name="${formNode["@name"]}-header" id="${formNode["@name"]}-header" class="form-header-row" method="post" action="${curUrlInfo.url}">
                    <input type="hidden" name="moquiFormName" value="${formNode["@name"]}">
                <#else>
                <div class="form-header-row">
                </#if>
                    <#list formListColumnList as fieldListColumn>
                        <div class="form-header-cell">
                        <#list fieldListColumn["field-ref"] as fieldRef>
                            <#assign fieldRefName = fieldRef["@name"]>
                            <#assign fieldNode = "invalid">
                            <#list formNode["field"] as fn><#if fn["@name"] == fieldRefName><#assign fieldNode = fn><#break></#if></#list>
                            <#if fieldNode == "invalid">
                                <div>Error: could not find field with name [${fieldRefName}] referred to in a form-list-column.field-ref.@name attribute.</div>
                            <#else>
                                <#if !(fieldNode["@hide"]?if_exists == "true" ||
                                        ((!fieldNode["@hide"]?has_content) && fieldNode?children?size == 1 &&
                                        (fieldNode?children[0]["hidden"]?has_content || fieldNode?children[0]["ignored"]?has_content)))>
                                    <div><@formListHeaderField fieldNode/></div>
                                </#if>
                            </#if>
                        </#list>
                        </div>
                    </#list>
                <#if needHeaderForm && !skipStart>
                </form>
                <#else>
                </div>
                </#if>
            </div>
            <div class="form-body">
            <#if isMulti && !skipStart>
                <form name="${formNode["@name"]}" id="${formNode["@name"]}" method="post" action="${urlInfo.url}">
            </#if>
                <#list listObject as listEntry>
                    <#assign listEntryIndex = listEntry_index>
                    <#-- NOTE: the form-list.@list-entry attribute is handled in the ScreenForm class through this call: -->
                    ${sri.startFormListRow(formNode["@name"], listEntry)}
                    <#if isMulti>
                    <div class="form-row">
                    <#else>
                    <form name="${formNode["@name"]}_${listEntryIndex}" id="${formNode["@name"]}_${listEntryIndex}" class="form-row" method="post" action="${urlInfo.url}">
                    </#if>
                        <#list formNode["form-list-column"] as fieldListColumn>
                            <div class="form-cell">
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
                            </div>
                        </#list>
                    <#if isMulti>
                    </div>
                    <#else>
                        <script>$("#${formNode["@name"]}_${listEntryIndex}").validate();</script>
                    </form>
                    </#if>
                    ${sri.endFormListRow()}
                </#list>
            <#if isMulti && !skipEnd>
                <div class="form-row">
                    <#assign isMultiFinalRow = true>
                    <#list formNode["field"] as fieldNode><@formListSubField fieldNode/></#list>
                </div>
                </form>
            </#if>
            <#if isMulti && !skipStart>
                <script>$("#${formNode["@name"]}").validate();</script>
            </#if>
            </div><!-- close table-body -->
            ${sri.safeCloseList(listObject)}<#-- if listObject is an EntityListIterator, close it -->
        </div><!-- close table -->
        ${sri.getAfterFormWriterText()}
    <#else>
		<#if !listName?exists>
			<#return>
		</#if>
		<#if type?has_content && type == "dataTables">
			<@renderDataTables formNode />
		<#else>
		    <#if !(formNode["@paginate"]?if_exists == "false")
		 		&& context[listName + "Count"]?exists
		 		&& (context[listName + "Count"]?if_exists > 0)>
				<@renderFormListPaginate />
		    </#if>
	        <div class="form-list-outer" id="${formNode["@name"]}-table">
	            <div class="form-header-group">
	                <#assign needHeaderForm = sri.isFormHeaderForm(formNode["@name"])>
	                <#if needHeaderForm && !skipStart>
	                    <#assign curUrlInfo = sri.getCurrentScreenUrl()>
	                    <form name="${formNode["@name"]}-header" id="${formNode["@name"]}-header" class="form-header-row" method="post" action="${curUrlInfo.url}">
	                <#else>
	                    <div class="form-header-row">
	                </#if>
	                    <#list formNode["field"] as fieldNode>
	                        <#if !(fieldNode["@hide"]?if_exists == "true" ||
	                                ((!fieldNode["@hide"]?has_content) && fieldNode?children?size == 1 &&
	                                (fieldNode?children[0]["hidden"]?has_content || fieldNode?children[0]["ignored"]?has_content))) &&
	                                !(isMulti && fieldNode["default-field"]?has_content && fieldNode["default-field"][0]["submit"]?has_content)>
	                            <div class="form-header-cell"><@formListHeaderField fieldNode/></div>
	                        </#if>
	                    </#list>
	                <#if needHeaderForm && !skipStart>
	                    </form>
	                <#else>
	                    </div>
	                </#if>
	            </div>
	            <#if !skipStart>
	                <#if isMulti>
	                    <form name="${formNode["@name"]}" id="${formNode["@name"]}" class="form-body" method="post" action="${urlInfo.url}">
	                        <input type="hidden" name="moquiFormName" value="${formNode["@name"]}">
	                <#else>
	                    <div class="form-body">
	                </#if>
	            </#if>
	                <#list listObject as listEntry>
	                    <#assign listEntryIndex = listEntry_index>
	                    <#-- NOTE: the form-list.@list-entry attribute is handled in the ScreenForm class through this call: -->
	                    ${sri.startFormListRow(formNode["@name"], listEntry)}
	                    <#if isMulti>
	                        <div class="form-row">
	                    <#else>
	                        <form name="${formNode["@name"]}_${listEntryIndex}" id="${formNode["@name"]}_${listEntryIndex}" class="form-row" method="post" action="${urlInfo.url}">
	                    </#if>
	                        <#list formNode["field"] as fieldNode><@formListSubField fieldNode/></#list>
	                    <#if isMulti>
	                        </div>
	                    <#else>
	                            <script>$("#${formNode["@name"]}_${listEntryIndex}").validate();</script>
	                        </form>
	                    </#if>
	                    ${sri.endFormListRow()}
	                </#list>
	            <#if !skipEnd>
	                <#if isMulti>
	                    <div class="form-row">
	                        <#assign isMultiFinalRow = true>
	                        <#list formNode["field"] as fieldNode><@formListSubField fieldNode/></#list>
	                    </div>
	                    </form>
	                <#else>
	                    </div>
	                </#if>
	            </#if>
	            <#if isMulti && !skipStart>
	                <script>$("#${formNode["@name"]}").validate();</script>
	            </#if>
	            ${sri.safeCloseList(listObject)}<#-- if listObject is an EntityListIterator, close it -->
	        </div>
		</#if>
        ${sri.getAfterFormWriterText()}
    </#if>
<#if sri.doBoundaryComments()><!-- END   form-list[@name=${.node["@name"]}] --></#if>
</#macro>

<#-- datatables -->
<#macro renderDataTables formNode>
	<#assign curUrlInfo = sri.getCurrentScreenUrl()>
	<#assign selectMode = (render_data.selectMode)?if_exists>
    <#assign toolbar = (render_data.toolbar)?if_exists>
	<#if selectMode == 'multi'>
	<#else>
	</#if>
	<#-- var toolbar_div = $('#${formNode["@name"]}-table_length').next(); -->
    <form id="${formNode["@name"]}-form" action="${urlInfo.url}" method="post">
	<table id="${formNode["@name"]}" class="table table-bordered"<#if toolbar?has_content> toolbar="${toolbar}"</#if><#if selectMode?has_content> selectMode="${selectMode}"</#if>>
		<thead>
			<tr>
	            <#assign needHeaderForm = sri.isFormHeaderForm(formNode["@name"])>
	            <#-- <#if needHeaderForm && !skipStart>
	            	                    <#assign curUrlInfo = sri.getCurrentScreenUrl()>
	            	                    <form name="${formNode["@name"]}-header" id="${formNode["@name"]}-header" class="form-header-row" method="post" action="${curUrlInfo.url}">
	            	                <#else>
	            	                    <div class="form-header-row">
	            	                </#if> -->
	                <#list formNode["field"] as fieldNode>
						<#assign fieldStyle = fieldNode["@style"]?if_exists>
						<th<#if fieldStyle?has_content> class="${fieldStyle}"</#if>>
	                    <#if !(fieldNode["@hide"]?if_exists == "true" ||
	                            ((!fieldNode["@hide"]?has_content) && fieldNode?children?size == 1 &&
	                            (fieldNode?children[0]["hidden"]?has_content || fieldNode?children[0]["ignored"]?has_content))) &&
	                            !(isMulti && fieldNode["default-field"]?has_content && fieldNode["default-field"][0]["submit"]?has_content)>
	                        <@dataTablesHeaderField fieldNode/>
	                    </#if>
						</th>
	                </#list>
	            <#-- <#if needHeaderForm && !skipStart>
	            	                    </form>
	            	                <#else>
	            	                    </div>
	            	                </#if> -->
			</tr>
		</thead>
		<tbody>
	        <#-- <#if !skipStart>
	        	                <#if isMulti>
	        	                    <form name="${formNode["@name"]}" id="${formNode["@name"]}" class="form-body" method="post" action="${urlInfo.url}">
	        	                        <input type="hidden" name="moquiFormName" value="${formNode["@name"]}">
	        	                <#else>
	        	                    <div class="form-body">
	        	                </#if>
	        	            </#if> -->
			<#list listObject as listEntry>
	            <#assign listEntryIndex = listEntry_index>
	            <#-- NOTE: the form-list.@list-entry attribute is handled in the ScreenForm class through this call: -->
	            ${sri.startFormListRow(formNode["@name"], listEntry)}
	            <#-- <#if isMulti>
	                                    <div class="form-row">
	                                <#else>
	                                    <form name="${formNode["@name"]}_${listEntryIndex}" id="${formNode["@name"]}_${listEntryIndex}" class="form-row" method="post" action="${urlInfo.url}">
	                                </#if> -->
				<tr>
	                <#list formNode["field"] as fieldNode>
						<td><@formListSubField fieldNode/></td>
					</#list>
				</tr>
	            <#-- <#if isMulti>
	                                    </div>
	                                <#else>
	                                        <script>$("#${formNode["@name"]}_${listEntryIndex}").validate();</script>
	                                    </form>
	                                </#if> -->
	            ${sri.endFormListRow()}
			</#list>
	        <#-- <#if !skipEnd>
	       	                <#if isMulti>
	       	                    <div class="form-row">
	       	                        <#assign isMultiFinalRow = true>
	       	                        <#list formNode["field"] as fieldNode><@formListSubField fieldNode/></#list>
	       	                    </div>
	       	                    </form>
	       	                <#else>
	       	                    </div>
	       	                </#if>
	       	            </#if>
	       	            <#if isMulti && !skipStart>
	       	                <script>$("#${formNode["@name"]}").validate();</script>
	       	            </#if> -->
	        ${sri.safeCloseList(listObject)}<#-- if listObject is an EntityListIterator, close it -->				
		</tbody>
	</table>
    </form>
	<script>
		$(document).ready(function() {
			//return;
			// var nCloneTh = document.createElement( 'td' );
			// 		    var nCloneTd = document.createElement( 'td' );
			// 		    nCloneTh.innerHTML = '<input type="checkbox" name="checkbox">';
			// 			nCloneTh.className = 'th-checkbox center';
			// 		    nCloneTd.innerHTML = '<input type="checkbox" name="checkbox">';
			// 		    nCloneTd.className = "center";
			// 
			// 		    $('#${formNode["@name"]} thead tr').each( function () {
			// 		        this.insertBefore( nCloneTh, $(this).children().get(0) );
			// 		    } );
			// 
			// 		    $('#${formNode["@name"]} tbody tr').each( function () {
			// 		        this.insertBefore(  nCloneTd.cloneNode( true ), this.childNodes[0] );
			// 		    } );
			window.${formNode["@name"]} = $('#${formNode["@name"]}-form');
		    window.${formNode["@name"]}Table = $('#${formNode["@name"]}').dataTable( {
		        "bProcessing": true,
		        "bServerSide": true,
				"bFilter": false, //搜索栏
				//"bSort": false,
				"aaSortingFixed": null,
				// "aoColumnDefs": [
				// 					{ "bSortable": false, "aTargets": [ 0 ] }
				// 				],
				"aaSorting": [],
		        "sAjaxSource": "${curUrlInfo.url}",
                "fnServerData": function ( sSource, aoData, fnCallback, oSettings ) {
                    oSettings.jqXHR = $.ajax( {
                        "type": "POST",
                        "url": sSource,
                        "data": aoData,
                        "success": fnCallback
                    } );
                },
				"bDeferRender": true,
				"sServerMethod": "POST",
				<#-- "sDom": "<'row'<'span4'l<'toolbar'>><'span8'<\"toolbar\">f>r>t<'row'<'span4'i><'span8'p>>", -->
				"sDom": "<'row'fr>t<'row'<'span4'il><'span8'p>>",
				"sPaginationType": "bootstrap",
				"oLanguage": {//多语言配置
                   "sLengthMenu": "每页最多_MENU_条",
                   "sZeroRecords": "对不起，查询不到任何相关数据",  
                   "sInfo": "第_START_~_END_条/共_TOTAL_条,",
                   "sInfoEmtpy": "找不到相关数据",
                   "sInfoFiltered": "数据表中共为 _MAX_ 条记录)",
                   "sProcessing": "正在加载中...",
                   "sSearch": "搜索",
                   "sUrl": "", //多语言配置文件，可将oLanguage的设置放在一个txt文件中，例：Javascript/datatable/dtCH.txt  
                   "oPaginate": {  
                       "sFirst":    "第一页",  
                       "sPrevious": " 上一页 ",  
                       "sNext":     " 下一页 ",  
                       "sLast":     " 最后一页 "  
					}  
				},
				"fnInitComplete": function () {
		            var that = this;
		            this.$('tbody tr').hover( function () {
		                //alert( this.innerHTML );
		            } );
		        },
				"fnServerParams": function ( aoData ) {
					aoData.push( { "name": "_FORM_", "value":  "${formNode["@name"]}"} );
					aoData.push( { "name": "renderMode", "value":  "json"} );
					aoData.push( { "name": "lastStandalone", "value":  "true"} );
					var search_form = this.data('search_form');
					convertDataTablesParameters(aoData, search_form);
				},
		        "aoColumns": [
					//{"mData": null},
					<#list formNode["field"] as fieldNode>
						<#assign visable = true>
						<#assign visable = fieldNode["@hide"]?if_exists != "true">
	                    <#if !(
	                            ((!fieldNode["@hide"]?has_content) && fieldNode?children?size == 1 &&
	                            (fieldNode?children[0]["hidden"]?has_content || fieldNode?children[0]["ignored"]?has_content))) &&
	                            !(isMulti && fieldNode["default-field"]?has_content &&
	 							fieldNode["default-field"][0]["submit"]?has_content)>
						    <#if fieldNode["header-field"]?has_content>
						        <#assign fieldSubNode = fieldNode["header-field"][0]>
						    <#elseif fieldNode["default-field"]?has_content>
						        <#assign fieldSubNode = fieldNode["default-field"][0]>
						    <#else>
						        <#-- this only makes sense for fields with a single conditional -->
						        <#assign fieldSubNode = fieldNode["conditional-field"][0]>
						    </#if>
							<#assign sortAble = fieldSubNode["@show-order-by"]?if_exists != "false">
							<#if fieldNode_index gt 0>,</#if>
	                        {"mData": "${fieldSubNode?parent["@name"]}", "bSortable": <#if sortAble>true<#else>false</#if>, "bVisible": <#if visable>true<#else>false</#if>}
	                    </#if>
	                </#list>
		        ],
				"fnDrawCallback": function () {
		            // $('#${formNode["@name"]} tbody td').click(function(e){
		            // 						alert(this);
		            // 					});
		        }
		    });
			$('#${formNode["@name"]} tbody td').on('hover', function() {
				//$(this).toggleClass('row_selected');
				//alert('');
			});
		});
	</script>
</#macro>

<#-- datatables 表头字段 -->
<#macro dataTablesHeaderField fieldNode>
    <#if fieldNode["header-field"]?has_content>
        <#assign fieldSubNode = fieldNode["header-field"][0]>
    <#elseif fieldNode["default-field"]?has_content>
        <#assign fieldSubNode = fieldNode["default-field"][0]>
    <#else>
        <#-- this only makes sense for fields with a single conditional -->
        <#assign fieldSubNode = fieldNode["conditional-field"][0]>
    </#if>
    <#if fieldNode["header-field"]?has_content && fieldNode["header-field"][0]?children?has_content>
	    <#-- <div class="form-header-field"> -->
	        <#recurse fieldNode["header-field"][0]/>
	    <#-- </div> -->
	<#else>
	    <div class="form-title">
	        <#if fieldSubNode["submit"]?has_content>&nbsp;<#else/><@fieldTitle fieldSubNode/></#if>
	    </div>
    </#if>
</#macro>

<#macro check>
    <#assign currentValue = sri.getFieldValue(.node?parent?parent, "")>
	<#assign style = .node["@style"]?if_exists>
    <#if !currentValue?has_content><#assign currentValue = .node["@no-current-selected-key"]?if_exists/></#if>
    <#assign id><@fieldId .node/></#assign>
    <#assign curName><@fieldName .node/></#assign>
	<#if .node?parent?node_name == "header-field">
		<input type="checkbox" name="${curName}" value="${currentValue?html}"<#if style?has_content> class="${style}"</#if> />
	<#elseif .node?parent?node_name == "default-field">
		<input type="checkbox" name="${curName}" value="${currentValue?html}"<#if style?has_content> class="${style}"</#if> />
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
    <div class="form-title">
        <#if fieldSubNode["submit"]?has_content>&nbsp;<#else/><@fieldTitle fieldSubNode/></#if>
        <#if fieldSubNode["@show-order-by"]?if_exists == "true">
            <#assign orderByField = ec.web.requestParameters.orderByField?if_exists>
            <#assign ascActive = orderByField?has_content && orderByField?contains(fieldNode["@name"]) && !orderByField?starts_with("-")>
            <#assign ascOrderByUrlInfo = sri.getCurrentScreenUrl().cloneUrlInfo().addParameter("orderByField", "+" + fieldNode["@name"])>
            <#assign descActive = orderByField?has_content && orderByField?contains(fieldNode["@name"]) && orderByField?starts_with("-")>
            <#assign descOrderByUrlInfo = sri.getCurrentScreenUrl().cloneUrlInfo().addParameter("orderByField", "-" + fieldNode["@name"])>
            <a href="${ascOrderByUrlInfo.getUrlWithParams()}" class="form-order-by<#if ascActive> active</#if>">+</a><a href="${descOrderByUrlInfo.getUrlWithParams()}" class="form-order-by<#if descActive> active</#if>">-</a>
            <#-- the old way, show + or -:
            <#if !orderByField?has_content || orderByField?starts_with("-") || !orderByField?contains(fieldNode["@name"])><#assign orderByField = ("+" + fieldNode["@name"])><#else><#assign orderByField = ("-" + fieldNode["@name"])></#if>
            <#assign orderByUrlInfo = sri.getCurrentScreenUrl().cloneUrlInfo().addParameter("orderByField", orderByField)>
            <a href="${orderByUrlInfo.getUrlWithParams()}" class="form-order-by">${orderByField?substring(0,1)}</a>
            -->
        </#if>
    </div>
    <#if fieldNode["header-field"]?has_content && fieldNode["header-field"][0]?children?has_content>
    <div class="form-header-field">
        <#recurse fieldNode["header-field"][0]/>
    </div>
    </#if>
</#macro>
<#macro formListSubField fieldNode>
    <#list fieldNode["conditional-field"] as fieldSubNode>
        <#if ec.resource.evaluateCondition(fieldSubNode["@condition"], "")>
            <@formListWidget fieldSubNode/>
            <#return>
        </#if>
    </#list>
    <#if fieldNode["default-field"]?has_content>
        <@formListWidget fieldNode["default-field"][0]/>
        <#return>
    </#if>
</#macro>
<#macro formListWidget fieldSubNode>
    <#if fieldSubNode["ignored"]?has_content><#return/></#if>
    <#if fieldSubNode["hidden"]?has_content><#recurse fieldSubNode/><#return/></#if>
    <#if fieldSubNode?parent["@hide"]?if_exists == "true"><#return></#if>
    <#-- don't do a column for submit fields, they'll go in their own row at the bottom -->
    <#t><#if isMulti && !isMultiFinalRow && fieldSubNode["submit"]?has_content>&nbsp;<#return/></#if>
    <#t><#if isMulti && isMultiFinalRow && !fieldSubNode["submit"]?has_content>&nbsp;<#return/></#if>
    <div<#if !formListSkipClass?if_exists> class="form-cell"</#if>>
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
    </div>
</#macro>

<#macro linkFormForm linkNode linkFormId urlInfo>
	<#assign style = linkNode["@style"]?if_exists>
    <#if urlInfo.disableLink>
        <#-- do nothing -->
    <#else>
        <#if (linkNode["@link-type"]?if_exists == "anchor") ||
            ((!linkNode["@link-type"]?has_content || linkNode["@link-type"] == "auto") &&
             ((linkNode["@url-type"]?has_content && linkNode["@url-type"] != "transition") || (!urlInfo.hasActions)))>
            <#-- do nothing -->
        <#else>
            <form method="post" action="${urlInfo.url}" name="${linkFormId!""}"<#if linkFormId?has_content> id="${linkFormId}"</#if><#if linkNode["@target-window"]?has_content> target="${linkNode["@target-window"]}"</#if> onsubmit="javascript:submitFormDisableSubmit(this)">
                <#assign targetParameters = urlInfo.getParameterMap()>
                <#-- NOTE: using .keySet() here instead of ?keys because ?keys was returning all method names with the other keys, not sure why -->
                <#if targetParameters?has_content><#list targetParameters.keySet() as pKey>
                    <input type="hidden" name="${pKey?html}" value="${targetParameters.get(pKey)?default("")?html}"/>
                </#list></#if>
                <#if !linkFormId?has_content>
                    <#if linkNode["image"]?has_content><#assign imageNode = linkNode["image"][0]/>
                        <input type="image" src="${sri.makeUrlByType(imageNode["@url"],imageNode["@url-type"]!"content",null)}"<#if imageNode["@alt"]?has_content> alt="${imageNode["@alt"]}"</#if><#if linkNode["@confirmation"]?has_content> onclick="return confirm('${linkNode["@confirmation"]?js_string}')"</#if>>
                    <#else>
                        <input type="submit" value="${ec.resource.evaluateStringExpand(linkNode["@text"], "")}"<#if linkNode["@confirmation"]?has_content> onclick="return confirm('${linkNode["@confirmation"]?js_string}')"</#if> class="btn<#if style?has_content> ${style}</#if>">
                    </#if>
                </#if>
            </form>
        </#if>
    </#if>
</#macro>


<#macro submit>
	<#assign style = .node["@style"]?if_exists>
	<#assign forDataTableId = .node["@for"]?if_exists>
	<#if .node["image"]?has_content><#assign imageNode = .node["image"][0]/>
	    <input type="image" src="${sri.makeUrlByType(imageNode["@url"],imageNode["@url-type"]!"content",null)}" alt="<#if imageNode["@alt"]?has_content>${imageNode["@alt"]}<#else/><@fieldTitle .node?parent/></#if>"<#if imageNode["@width"]?has_content> width="${imageNode["@width"]}"</#if><#if imageNode["@height"]?has_content> height="${imageNode["@height"]}"</#if>
	<#elseif forDataTableId?has_content>
		<input type="submit" name="<@fieldName .node/>" value="<@fieldTitle .node?parent/>" onclick="dataTablesFlush(${forDataTableId}Table, this);return false;" id="<@fieldId .node/>" class="btn<#if style?has_content> ${style}</#if>">
		<script>
			function dataTablesFlush(dataTable, input){
				dataTable.data('search_form', input.form);
				dataTable.fnClearTable();
			}
		</script>
	<#else><input type="submit" name="<@fieldName .node/>" value="<@fieldTitle .node?parent/>"<#if .node["@confirmation"]?has_content> onclick="return confirm('${.node["@confirmation"]?js_string}');"</#if> id="<@fieldId .node/>" class="btn<#if style?has_content> ${style}</#if>">
	</#if>
</#macro>

<#macro "container-dialog">
    <#assign buttonText = ec.resource.evaluateStringExpand(.node["@button-text"], "")>
	<#assign style = .node["@style"]?if_exists>
	<a id="${.node["@id"]}-button" class="btn<#if style?has_content> ${style}</#if>" data-toggle="modal" href="#${.node["@id"]}">${buttonText}</a>
	<div id="${.node["@id"]}" class="modal hide" style="display: none;">
		<div class="modal-header">
			<button type="btn" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
			<h3>${buttonText}</h3>
		</div>
		<div class="modal-body">
    		<#recurse>
		</div>
    </div>
</#macro>

<#macro link>
    <#assign urlInfo = sri.makeUrlByType(.node["@url"], .node["@url-type"]!"transition", .node)>
    <#assign linkNode = .node>
	<#assign style = .node["@style"]?if_exists>
    <@linkFormForm linkNode linkNode["@id"]?if_exists urlInfo/>
    <@linkFormLink linkNode linkNode["@id"]?if_exists urlInfo/>
</#macro>

<#macro linkFormLink linkNode linkFormId urlInfo>
    <#if urlInfo.disableLink>
        <span<#if linkFormId?has_content> id="${linkFormId}"</#if>>${ec.resource.evaluateStringExpand(linkNode["@text"], "")}</span>
    <#else>
        <#if (linkNode["@link-type"]?if_exists == "anchor") ||
            ((!linkNode["@link-type"]?has_content || linkNode["@link-type"] == "auto") &&
             ((linkNode["@url-type"]?has_content && linkNode["@url-type"] != "transition") || (!urlInfo.hasActions)))>
            <a href="${urlInfo.urlWithParams}"<#if linkFormId?has_content> id="${linkFormId}"</#if><#if linkNode["@target-window"]?has_content> target="${linkNode["@target-window"]}"</#if><#if linkNode["@confirmation"]?has_content> onclick="return confirm('${linkNode["@confirmation"]?js_string}')"</#if> class="btn<#if style?has_content> ${style}</#if>">
            <#t><#if linkNode["image"]?has_content><#visit linkNode["image"]><#else/>${ec.resource.evaluateStringExpand(linkNode["@text"], "")}</#if>
            <#t></a>
        <#else>
            <#if linkFormId?has_content>
            <a href="javascript:document.${linkFormId}.submit()" class="btn<#if style?has_content> ${style}</#if>">
                <#if linkNode["image"]?has_content>
                <#t><img src="${sri.makeUrlByType(imageNode["@url"],imageNode["@url-type"]!"content",null)}"<#if imageNode["@alt"]?has_content> alt="${imageNode["@alt"]}"</#if>/>
                <#else>
                <#t>${ec.resource.evaluateStringExpand(linkNode["@text"], "")}
                </#if>
            </a>
            </#if>
        </#if>
    </#if>
</#macro>


<#-- =================================== 菜单 ============================= -->
<#macro menu>
	<#assign name = .node["@name"]>
	<#assign style = .node["@style"]?default("nav")>
	<#assign title = .node["@title"]?if_exists>
	<#assign downArrow = .node["@down-arrow"]?default("true")>
	<#assign parent_node_name = .node?parent?node_name>
	<#if parent_node_name!="menu-item">
		<#if !hasParent?if_exists>
			<ul class="${style}" id="menu-${name}">
		</#if>
			<#if type?if_exists == "button">
				<button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><#if title?has_content>${title}<#else>${name}</#if><#if downArrow == "true" && parent_node_name!="menu-item"><b class="caret"></b></#if></button>
			<#else>
				<li class="dropdown"<#if hasParent?if_exists> id="menu-${name}"</#if>>
				<a href="#" role="button" class="<#if type?if_exists == "button">btn btn-small </#if>dropdown-toggle" data-toggle="dropdown" ><#if title?has_content>${title}<#else>${name}</#if><#if downArrow == "true" && parent_node_name!="menu-item"><b class="caret"></b></#if></a>
			</#if>
	<#else>
			<a href="#"><#if title?has_content>${title}<#else>${name}</#if><#-- <i class="icon-arrow-right"></i> --><#if downArrow == "true" && parent_node_name!="menu-item"><b class="caret"></b></#if></a>
	</#if>
        <ul class="dropdown-menu sub-menu" role="menu" aria-labelledby="drop1">
			<#recurse />
        </ul>
	<#assign parent_node_name = .node?parent?node_name>
	<#if parent_node_name!="menu-item">
		</li>
		<#if !hasParent?if_exists>
		</ul>
		</#if>
	</#if>
</#macro>

<#macro "menu-item">
	<#assign name = .node["@name"]>
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
			<#recurse />
		</li>
	<#else>
	    <li<#if style?has_content> class="${style}"</#if>>
			<#if transition?has_content || click?has_content>
				<a tabindex="-1" href="${urlInfo.url}"<#if click?has_content> onclick="${click?html};return false;"</#if>><#if title?has_content>${title}<#else>${name}</#if></a>
				<#-- <a tabindex="-1" href="<#if click?has_content>javascript:${click?html};return false;<#else>${urlInfo.url}</#if>"><#if title?has_content>${title}<#else>${name}</#if></a> -->
			</#if>
		</li>
	</#if>
</#macro>



<#macro "date-find">
<span class="form-date-find">
    <#assign curFieldName><@fieldName .node/></#assign>
    <#if .node["@type"]?if_exists == "time"><#assign size=9/><#assign maxlength=12/><#elseif .node["@type"]?if_exists == "date"><#assign size=10/><#assign maxlength=10/><#else><#assign size=22/><#assign maxlength=19/></#if>
    <#assign id><@fieldId .node/></#assign>
	<#assign format = "yyyy-MM-dd HH:mm:ss">
	<#if .node["@type"]?if_exists == "date">
		<#assign format = "yyyy-MM-dd">
	</#if>
    <span>${ec.l10n.getLocalizedMessage("From")}&nbsp;</span><input type="text" name="${curFieldName}_from" value="${ec.web.parameters.get(curFieldName + "_from")?if_exists?default(.node["@default-value-from"]!"")?html}" size="${size}" maxlength="${maxlength}" id="${id}_from" class="Wdate" onfocus="WdatePicker({startDate:'%y-%M-%d 00:00:00',dateFmt:'${format}'})">
    <span>${ec.l10n.getLocalizedMessage("Through")}&nbsp;</span><input type="text" name="${curFieldName}_thru" value="${ec.web.parameters.get(curFieldName + "_thru")?if_exists?default(.node["@default-value-thru"]!"")?html}" size="${size}" maxlength="${maxlength}" id="${id}_thru" class="Wdate" onfocus="WdatePicker({startDate:'%y-%M-%d 00:00:00',dateFmt:'${format}'})">
    <#-- <#if .node["@type"]?if_exists != "time">
    <#if .node["@type"]?if_exists == "date"> -->
</span>
</#macro>
<#macro "date-time">
    <#assign fieldValue = sri.getFieldValue(.node?parent?parent, .node["@default-value"]!"")>
    <#if .node["@format"]?has_content><#assign fieldValue = ec.l10n.formatValue(fieldValue, .node["@format"])></#if>
    <#if .node["@type"]?if_exists == "time"><#assign size=9/><#assign maxlength=12/><#elseif .node["@type"]?if_exists == "date"><#assign size=10/><#assign maxlength=10/><#else><#assign size=23/><#assign maxlength=23/></#if>
    <#assign id><@fieldId .node/></#assign>
	<#assign format = "yyyy-MM-dd HH:mm:ss">
	<#if .node["@type"]?if_exists == "date">
		<#assign format = "yyyy-MM-dd">
	</#if>
    <input type="text" name="<@fieldName .node/>" value="${fieldValue?html}" size="${size}" maxlength="${maxlength}" id="${id}" class="Wdate" onfocus="WdatePicker({startDate:'%y-%M-%d 00:00:00',dateFmt:'${format}'})">
    <#-- <#if .node["@type"]?if_exists != "time">
    <#if .node["@type"]?if_exists == "date"> -->
</#macro>

<#-- ============================= 导航条 ================================ -->
<#macro nav>
	<#assign fieldStyle = .node["@style"]?if_exists>
	<#assign trigger = .node["@trigger"]?if_exists>
	<#assign hasParent = true>

	<ul class="nav<#if fieldStyle?has_content> ${fieldStyle}</#if>"<#if trigger?has_content> trigger="${trigger}"</#if>>
		<#recurse>
	</ul>	
</#macro>


<#-- ============================= 工具条 ================================ -->
<#macro toolbar>
    <#assign id = .node["@id"]?if_exists>
    <#assign fieldStyle = .node["@style"]?if_exists>
	<div<#if id?has_content> id="${id}"</#if> class="btn-toolbar<#if fieldStyle?has_content> ${fieldStyle}</#if>"<#if trigger?has_content> trigger="${trigger}"</#if>>
		<#recurse>
	</div>	
</#macro>

<#macro "button-group">
	<#assign fieldStyle = .node["@style"]?if_exists>
	<#assign hasParent = true>
	<#assign type = "button">
	<div class="btn-group<#if fieldStyle?has_content> ${fieldStyle}</#if>">
		<#recurse>
	</div>
</#macro>

<#macro button>
	<#assign fieldStyle = .node["@style"]?if_exists>
	<#assign click = .node["@click"]?if_exists>
    <#assign validchecked = .node["@validchecked"]?if_exists>
    <#assign id = .node["@id"]?if_exists>
	<button
        <#t><#if id?has_content> id="${id}"</#if>
        <#t><#if validchecked?has_content> validchecked="${validchecked}" disabled="disabled"</#if>
        <#t> class="btn<#if fieldStyle?has_content> ${fieldStyle}</#if>"
        <#t><#if click?has_content> onclick="${click}"</#if>
        <#t>><#recurse></button>
</#macro>
