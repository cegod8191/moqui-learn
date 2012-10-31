/* Set the defaults for DataTables initialisation */
$.extend( true, $.fn.dataTable.defaults, {
	"sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
	"sPaginationType": "bootstrap",
	"oLanguage": {
		"sLengthMenu": "_MENU_ records per page"
	}
} );


/* Default class modification */
$.extend( $.fn.dataTableExt.oStdClasses, {
	"sWrapper": "dataTables_wrapper form-inline"
} );


/* API method to get paging information */
$.fn.dataTableExt.oApi.fnPagingInfo = function ( oSettings )
{
	return {
		"iStart":         oSettings._iDisplayStart,
		"iEnd":           oSettings.fnDisplayEnd(),
		"iLength":        oSettings._iDisplayLength,
		"iTotal":         oSettings.fnRecordsTotal(),
		"iFilteredTotal": oSettings.fnRecordsDisplay(),
		"iPage":          Math.ceil( oSettings._iDisplayStart / oSettings._iDisplayLength ),
		"iTotalPages":    Math.ceil( oSettings.fnRecordsDisplay() / oSettings._iDisplayLength )
	};
};


/* Bootstrap style pagination control */
$.extend( $.fn.dataTableExt.oPagination, {
	"bootstrap": {
		"fnInit": function( oSettings, nPaging, fnDraw ) {
			var oLang = oSettings.oLanguage.oPaginate;
			var fnClickHandler = function ( e ) {
				e.preventDefault();
				if ( oSettings.oApi._fnPageChange(oSettings, e.data.action) ) {
					fnDraw( oSettings );
				}
			};

			$(nPaging).addClass('pagination').append(
				'<ul>'+
					//'<li class="first disabled"><a href="#">'+oLang.sFirst+'</a></li>'+
					'<li class="prev disabled"><a href="#">'+oLang.sPrevious+'</a></li>'+
					'<li class="next disabled"><a href="#">'+oLang.sNext+'</a></li>'+
					//'<li class="last disabled"><a href="#">'+oLang.sLast+'</a></li>'+
				'</ul>'
			);
			var els = $('a', nPaging);
			$(els[0]).bind( 'click.DT', { action: "previous" }, fnClickHandler );
			$(els[1]).bind( 'click.DT', { action: "next" }, fnClickHandler );
		},

		"fnUpdate": function ( oSettings, fnDraw ) {
			var iListLength = 5;
			var oPaging = oSettings.oInstance.fnPagingInfo();
			var an = oSettings.aanFeatures.p;
			var i, j, sClass, iStart, iEnd, iHalf=Math.floor(iListLength/2);

			if ( oPaging.iTotalPages < iListLength) {
				iStart = 1;
				iEnd = oPaging.iTotalPages;
			}
			else if ( oPaging.iPage <= iHalf ) {
				iStart = 1;
				iEnd = iListLength;
			} else if ( oPaging.iPage >= (oPaging.iTotalPages-iHalf) ) {
				iStart = oPaging.iTotalPages - iListLength + 1;
				iEnd = oPaging.iTotalPages;
			} else {
				iStart = oPaging.iPage - iHalf + 1;
				iEnd = iStart + iListLength - 1;
			}

			for ( i=0, iLen=an.length ; i<iLen ; i++ ) {
				// Remove the middle elements
				$('li:gt(0)', an[i]).filter(':not(:last)').remove();

				// Add the new list items and their event handlers
				for ( j=iStart ; j<=iEnd ; j++ ) {
					sClass = (j==oPaging.iPage+1) ? 'class="active"' : '';
					$('<li '+sClass+'><a href="#">'+j+'</a></li>')
						.insertBefore( $('li:last', an[i])[0] )
						.bind('click', function (e) {
							e.preventDefault();
							oSettings._iDisplayStart = (parseInt($('a', this).text(),10)-1) * oPaging.iLength;
							fnDraw( oSettings );
						} );
				}

				// Add / remove disabled classes from the static elements
				if ( oPaging.iPage === 0 ) {
					$('li:first', an[i]).addClass('disabled');
				} else {
					$('li:first', an[i]).removeClass('disabled');
				}

				if ( oPaging.iPage === oPaging.iTotalPages-1 || oPaging.iTotalPages === 0 ) {
					$('li:last', an[i]).addClass('disabled');
				} else {
					$('li:last', an[i]).removeClass('disabled');
				}
			}
		}
	}
} );


/*
 * TableTools Bootstrap compatibility
 * Required TableTools 2.1+
 */
if ( $.fn.DataTable.TableTools ) {
	// Set the classes that TableTools uses to something suitable for Bootstrap
	$.extend( true, $.fn.DataTable.TableTools.classes, {
		"container": "DTTT btn-group",
		"buttons": {
			"normal": "btn",
			"disabled": "disabled"
		},
		"collection": {
			"container": "DTTT_dropdown dropdown-menu",
			"buttons": {
				"normal": "",
				"disabled": "disabled"
			}
		},
		"print": {
			"info": "DTTT_print_info modal"
		},
		"select": {
			"row": "active"
		}
	} );

	// Have the collection use a bootstrap compatible dropdown
	$.extend( true, $.fn.DataTable.TableTools.DEFAULTS.oTags, {
		"collection": {
			"container": "ul",
			"button": "li",
			"liner": "a"
		}
	} );
}


/*
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
*/

//ie fix
if(typeof String.prototype.trim !== 'function') {
    String.prototype.trim = function() {
        return this.replace(/^\s+|\s+$/g, '');
    }
}

$.fn.dataTableExt.oApi.fnAjaxUpdateDraw = function ( oSettings, html )
{
    var pos = html.indexOf("}");
    var json_string = html.substr(0, pos + 1);
    var json = jQuery.parseJSON(json_string);

    if ( json.sEcho !== undefined )
    {
        /* Protect against old returns over-writing a new one. Possible when you get
         * very fast interaction, and later queries are completed much faster
         */
        if ( json.sEcho*1 < oSettings.iDraw ){
            return;
        }
        else{
            oSettings.iDraw = json.sEcho * 1;
        }
    }

    if ( !oSettings.oScroll.bInfinite ||
        (oSettings.oScroll.bInfinite && (oSettings.bSorted || oSettings.bFiltered)) )
    {
        this._fnClearTable( oSettings );
    }
    oSettings._iRecordsTotal = parseInt(json.iTotalRecords, 10);
    oSettings._iRecordsDisplay = parseInt(json.iTotalDisplayRecords, 10);

    /* Determine if reordering is required */
    var sOrdering = this._fnColumnOrdering(oSettings);
    var bReOrder = (json.sColumns !== undefined && sOrdering !== "" && json.sColumns != sOrdering );
    var aiIndex;
    if ( bReOrder )
    {
        aiIndex = _fnReOrderIndex( oSettings, json.sColumns );
    }

    oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();

    var body_html = html.substring(pos + 1);
    if (body_html == null || body_html.trim() == ''){
        body_html = '<tr><td colspan="100" style="text-align: center">未找到数据</td></tr>';
    }
    $(oSettings.nTBody).html(body_html);

    oSettings.bAjaxDataGet = false;
    //this._fnDraw( oSettings );

    this._fnCallbackFire( oSettings, 'aoDrawCallback', 'draw', [oSettings] );

    /* Draw is complete, sorting and filtering must be as well */
    oSettings.bSorted = false;
    oSettings.bFiltered = false;
    oSettings.bDrawing = false;

    if ( oSettings.oFeatures.bServerSide )
    {
        this._fnProcessingDisplay( oSettings, false );
        if ( !oSettings._bInitComplete )
        {
            this._fnInitComplete( oSettings );
        }
    }

    oSettings.bAjaxDataGet = true;


    this._fnProcessingDisplay( oSettings, false );
};



function convertDataTablesParameters(params, form){
	var m = {};
	for (var i = 0; i < params.length; i ++){
		m[params[i].name] = params[i].value;
	}
	
	var prop_index = m.iSortCol_0;
	if (m.sSortDir_0 == 'asc'){
		params.push({name: 'orderByField', value: '+' + m["mDataProp_" + prop_index]});
	}
	if (m.sSortDir_0 == 'desc'){
		params.push({name: 'orderByField', value: '-' + m["mDataProp_" + prop_index]});
	}
	
	if (m.iDisplayLength){
		params.push({name: 'pageSize', value: m.iDisplayLength});
	}
	if (m.iDisplayStart){
		params.push({name: 'pageIndex', value: m.iDisplayStart / m.iDisplayLength});
	}
	
	if (form){
		var form_data = $(form).serializeArray();
		for (var i = 0; i < form_data.length; i ++){
			params.push(form_data[i]);
		}
		//params.concat(form_data);
		//params = form_data;
		//alert(params);
	}
    //附加当前url查询参数
    var qs = (function(a) {
        if (a == "") return {};
        var b = {};
        for (var i = 0; i < a.length; ++i)
        {
            var p=a[i].split('=');
            if (p.length != 2) continue;
            b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
        }
        return b;
    })(window.location.search.substr(1).split('&'));

    for(var q in qs){
        params.push({name: q, value: qs[q]});
    }
}

function validchecked(button, checked_count){
    var validchecked = $(button).attr('validchecked');
    if (validchecked){
        if (validchecked == 'have' && checked_count > 0){
            $(button).attr('disabled', false);
        }
        else if (validchecked == checked_count){
            $(button).attr('disabled', false);
        }
        else{
            $(button).attr('disabled', true);
        }
    }
}


function dataTablesSelectAll(table_id){
    var $table = $('#' + table_id);
    var checked_count = 0;
    $('#' + table_id + ' input[type=checkbox]').each(function(i, checkbox){
		checkbox.checked = true;
		$(checkbox).parents('tr').addClass('row_selected');
        checked_count ++;
	});
    $table.data('checked_count', checked_count);
    var toolbar = $table.attr('toolbar');
    $('#' + toolbar).find('button').each(function(i, button){
        validchecked(button, checked_count);
    });
}

function dataTablesReverseSelect(table_id){
    var $table = $('#' + table_id);
    var checked_count = $table.data('checked_count');
    if (checked_count == null) checked_count = 0;
    $table.find('input[type=checkbox]').each(function(i, checkbox){
		checkbox.checked = !checkbox.checked;
		if (checkbox.checked){
            $(checkbox).parents('tr').addClass('row_selected');
            checked_count ++;
        }
		else{
            checked_count --;
            $(checkbox).parents('tr').removeClass('row_selected');
        }
    });
    $table.data('checked_count', checked_count);
    var toolbar = $table.attr('toolbar');
    $('#' + toolbar).find('button').each(function(i, button){
        validchecked(button, checked_count);
    });
}



$(document).ready(function(){
	//取得菜单父级
	function getParent($this) {
	    var selector = $this.attr('data-target'), $parent;

	    if (!selector) {
	      selector = $this.attr('href');
	      selector = selector && /#/.test(selector) && selector.replace(/.*(?=#[^\s]*$)/, ''); //strip for ie7
	    }

	    $parent = $(selector);
	    $parent.length || ($parent = $this.parent());

	    return $parent;
	}

	//绑定菜单hover事件
    $('ul.nav[trigger=hover]').on('hover.dropdown.data-api', '[data-toggle=dropdown]', function(e){
    	if (e.type == "mouseleave"){
    		var $this = $(this);
    		window._time_handle = setTimeout(function(){
    			$this.dropdown('toggle');
    		}, 200);
    	}
    	if (e.type == "mouseenter"){
    		clearTimeout(window._time_handle);
        	$(this).dropdown('toggle');
    	}
    });
    $('ul.nav[trigger=hover]').on('hover.dropdown', '[role=menu]', function(e){
    	if (e.type == "mouseenter"){
    		clearTimeout(window._time_handle);
    	}
    	if (e.type == "mouseleave"){
        	var $this = $(this);
    		//window._time_handle_leave = setTimeout(function(){
    			getParent($this).removeClass('open');
    		//}, 200);
    	}
    });
	
    
   $('.table tbody tr').live('hover', function(){
	   //$(this).toggleClass('row_selected');
   });
   
   $('.table tbody td').live('click', function(e){
	});
    
    //checkbox框单击事件
    $('.table tbody td input[type=checkbox]').live('click', function(){
	    var $tr = $(this).parents('tr');
        var $table = $(this).parents('table');
        var checked_count = $table.data('checked_count');
        if (checked_count == null) checked_count = 0;
        var selectMode = $table.attr('selectMode');
        var current_input = this;
        if (selectMode == 'single'){
            $table.find('input[type=checkbox]').each(function(i, input){
                if (current_input != input && input.checked == true){
                    input.checked = false;
                    $(input).parents('tr').removeClass('row_selected');
                }
            });
            checked_count = 0;
        }
        if(this.checked){
            this.checked = true;
		    $tr.addClass('row_selected');
            checked_count ++;
        }
	    else{
		    $tr.removeClass('row_selected');
            checked_count --;
	    }
        $table.data('checked_count', checked_count);
        var toolbar = $table.attr('toolbar');
        $('#' + toolbar).find('button').each(function(i, button){
            validchecked(button, checked_count);
        });
    });
   
   $('.table tbody td div.dropdown').live('focus', function(){
	   if ($(this).children('ul.dropdown-menu').length == 0 && !$(this).hasClass('loading')){
		   $(this).addClass('loading');
           var name = $(this).attr('name');
		   $this = $(this);
		   $.ajax({
			   url: $(this).children('a.dropdown-toggle').attr('href'),
			   data: {_MENU_NAME_: name, lastStandalone: 'true', renderMode: 'json'},
			   success: function(html) {
                   $this.append('<ul role="menu" class="dropdown-menu sub-menu">' +
                       html + '</ul>');
               }
		   }).always(function(){
			   $this.removeClass('loading');
		   });
		   return;
		   $(this).append([''
               ,'<ul aria-labelledby="drop1" role="menu" class="dropdown-menu sub-menu">'
       	    ,'<li>'
       				,'<a onclick="return false;" href="http://localhost:8080/apps/tutorial/FindTutorial" tabindex="-1">全选</a>'
       		,'</li>'
       	    ,'<li>'
       				,'<a onclick="return false;" href="http://localhost:8080/apps/tutorial/FindTutorial" tabindex="-1">反选</a>'
       		,'</li>'
               ,'</ul>'
           ].join(''));
	   }
   }).live('hover', function(e){
   	if (e.type == "mouseenter"){
		clearTimeout(window._time_handle_leave);
	}
   	if (e.type == "mouseleave"){
    	var $this = $(this);
		window._time_handle_leave = setTimeout(function(){
			$this.removeClass('open');
			//$this.children('ul.dropdown-menu').css('display', 'none');
		}, 200);
	}
   });
});


function getSubMenu(a){
    var href = $(a).attr('href');
    var $li = $(a).parent();
    if ($li.children('ul.dropdown-menu').length == 0 && !$li.hasClass('loading')){
        $li.addClass('loading');
        $.ajax({
            url: href,
            data: {renderMode: 'json', 'submenu': true},
            success: function(html) {
                $li.append(html);
            }
        }).always(function(){
            $li.removeClass('loading');
        });
    }
}