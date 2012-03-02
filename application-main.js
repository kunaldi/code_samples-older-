// START Callbacks
function init_page()
{
	hover_color('.hover1-js,.hover2-js');
	initialize_hover_objects();
	initialize_response_forms();
	initialize_post_forms();
	init_tab_menus();
	//init_top_menu();
	init_post_menu_items();
	init_outside_clicks();
	init_toolbar();
}
function add_remove_answer()
{
	initialize_response_forms();
	//hover_color('.hover1-js[done!=true],.hover2-js[done!=true]');
}
function reset_post_form(panel_tag)
{
	var $nvg = $('form.post .nav-group', panel_tag);
	$('.bubble-form-post', panel_tag).removeClass('visible');
	$('.add-icon a', panel_tag).removeClass('selected');
	$('.fla-box', $nvg).removeClass('visible').empty();
	$('.nav-box', $nvg).addClass('visible');
}
function create_response_after(t)
{
	i = $('form.response', t);
	$('textarea.response', i).val('').trigger('keyup').trigger('focusout');
	i[0].reset();
}



// END Callbacks




// START Variables
var tabs = [ ['#tab-apps', '#tab-menu-apps'],
			 ['#tab-dashboard', '#tab-menu-dashboard'],
			 ['#tab-search', '#tab-menu-search'],
			 ['#tab-mailbox', '#tab-menu-mailbox'],
			 ['#tab-account', '#tab-menu-account'] ]
	
var active_tab, hover_enabled, last_popup;
// END Variables





// START initializers
function init_response_form(i)
{
	i.reset();
	$('textarea.response', i)
		.focusin(function () {
			var $t = $(this);
			if ($t.val().length == 0 || $t.val() == $t.attr('defaultValue')) {
				var $elForm = $t.val('').attr('rows', 3).attr('form');
				$t.removeClass('pen-orange');
				$('.form-nav', $elForm).addClass('visible');
			}
		})
		.focusout(function() {
			var $t = $(this);
			if ($t.val().length == 0) {
				var $elForm = $t.val($t.attr('defaultValue')).attr('rows', 1).attr('form');
				$('.form-flb', $elForm).removeClass('visible');
				$('.form-nav', $elForm).removeClass('visible');
				$t.addClass('pen-orange');
			}
		})
		.keyup(function(event) {
			$(this).limit_max_char();
		});
		
	$(i).attr('done', true);
}

function hide_tab_menus(except)
{
	for (j=0; j<tabs.length; j++) {
		couple = tabs[j];

		if (except != couple[0]) {
			$(couple[0]).removeClass('selected');
			$(couple[1]).removeClass('visible');
		}
	}
}
//function set_hover_tab_menus(mode)
//{
//	//console.log('set_hover_tab_menus: ' + mode);
//	for (j=0; j<tabs.length; j++) {
//		couple = tabs[j];
//		$(couple[0]).data('hover-enable', mode);
//	}
//}
function init_tab_menus()
{
	var active_item;
	for (j=0; j<tabs.length; j++) {
		var couple = tabs[j];
		$(couple[0]).data('tab-names', couple).bind('click mouseenter mouseleave', function(e) {
			//console.log(e.type + ' [tab] ' + e.currentTarget.id);
			$t = $(this);
			var skip = true;
			if (e.type == 'click' || (e.type == 'mouseenter' && !$t.hasClass('selected'))) {
				//set_hover_tab_menus(!$t.hasClass('selected'));
				hover_enabled = !$t.hasClass('selected');
				skip = false;
			}
			
			if (!skip || (e.type == 'mouseenter' &&
						  //$t.data('hover-enable') &&
						  hover_enabled &&
						  !$t.hasClass('selected')))
			{
				couple = $t.data('tab-names');
				hide_tab_menus(couple[0]);
				$(couple[1]).toggleClass('visible');
				$t.toggleClass('selected');
				active_tab = [$t, $(couple[1])];
				//console.log('tab_event: ' + e.target.id);
			}
		});
	}

	$('#tab-bar').hover(
		function(e) {
			//console.log(e.type + ' [menu] ' + e.currentTarget.nodeName);
		},
		function(e) {
			if (! $(e.relatedTarget).parent().hasClass('tab-menu') ) {
				hide_tab_menus('');
				//set_hover_tab_menus(false);
				hover_enabled = false;
				//console.log(e.type + ' [menu] ' + e.currentTarget.nodeName);
			}
		});

	$('#tab-bar .tab-menu').bind('mouseleave', function(e) {
		hide_tab_menus('');
		hover_enabled = false;
	});


	//$('#reflector-actions li.menu-item').each(function() {
	//	$(this).hover(
	//		function() {
	//			$('#action-name').text($('a.menu-action-link .menu-item-text', this).text().toLowerCase());
	//		},
	//		function() {
	//		});
	//});
}
//function init_top_menu()
//{
//	$('#main-menu-button a.menu-button').click(function(event) {
//		$('#main-menu-list').toggleClass('visible');
//		$(this).toggleClass('selected');
//	});
//}
function init_bubble_menu(c, f)
{
	$(c + ' a.menu-button').click(function(event) {
		toggle_bubble_menu( $(this),
							$(this).closest('.menu-button-parent').next('.bubble-menu'),
							$(this).id,
							f);
	});
}
function toggle_sub(i)
{
	$s = $(i).next('ul');
	$(i).toggleClass('expand').toggleClass('collapse');
	$s.toggleClass('invisible');
}
function toggle_bubble_menu(b, m, n, f)
{
	if (!b.hasClass('selected'))
		hide_bubble_menu();
		
	m.toggleClass('visible');
	b.toggleClass('selected');
	if (f == true) b.parent().toggleClass('visible-force');
	last_popup = [b, m, n];
}
function hide_bubble_menu()
{
	if (last_popup) {
		if (last_popup[0].hasClass('selected')) {
			last_popup[0].parent().removeClass('visible-force');
			last_popup[0].removeClass('selected');
			last_popup[1].removeClass('visible');
			last_popup = null;
		}
	}
}
function init_feed_filter_menu()
{
	init_bubble_menu('.feed-filter-button', false);
}
function init_post_menu_items()
{
	init_bubble_menu('.post-menu-button', true);
}
//function init_post_menu_items()
//{
//	$('.post-info-row').each(function() {
//		$t = $(this);
//		$('.post-menu-button a.menu-button', $t).click(function(event) {
//			hide_all_post_menu();
//			$('.post-menu-button', $(this).data('menu')).toggleClass('visible-force');
//			toggle_bubble_menu($(this),
//						$(this).data('menu').next('.bubble-menu-post-item'),
//						'active_post_menu');
//
//			//$(document.body).data('active_post_menu', [$(this), $m]);
//			//last_popup = [$(this), $m, 'active_post_menu'];
//		}).data('menu', $t);
//	});
//}
//function hide_all_post_menu()
//{
//	$('.post-info-row').each(function() {
//		$r = $(this);
//		$pmb = $('.post-menu-button', $r).removeClass('visible-force');
//		$r.next('.bubble-menu-post-item').removeClass('visible');
//		$('a.menu-button', $pmb).removeClass('selected');
//	});
//}
function init_post_form($i)
{
	$('.add-icon a', $i)
		.click(function(event) {
			$b = $(this);
			$t = $('.bubble-form-post', $i);
			$f = $('form.post', $t);
			$t.toggleClass('visible');
			$b.toggleClass('selected');
			
			if ($b.hasClass('selected')) {
				init_form($f);
			}
			else {
			}
		});
}
function reset_form(i, no_clear)
{
    $f = $(i);
    if (no_clear != true) $f[0].reset();
    $(':input[setfocus=true]', $f).focus();
}
function init_form(i)
{
	$f = $(i);
	reset_form(i);
	
	$('textarea.post', $f)
		//.data('t', $t)
		//.data('b', $b)
		//.focusout(function() {
		//	var $ta = $(this);
		//	if ($ta.val().length == 0) {
		//		$ta.data('t').removeClass('visible');
		//		$ta.data('b').removeClass('selected');
		//	}
		//})
		.keyup(function(event) {
			$(this).limit_max_char();
		}).limit_max_char();
}
function init_hover_object($i)
{
	$i.hover(
		function() {
			t = $('.hover-child', this);
			if (!t.hasClass('visible-force'))
				t.addClass('visible').hide().fadeIn('fast');
		},
		function() {
			t = $('.hover-child', this);
			
			if (t.hasClass('visible-force'))
				t.removeClass('visible');
			else {	
				t.fadeOut('fast', function() {
					$(this).removeClass('visible');
				});
			}
		});

	$i.attr('done', true);
}
function init_outside_clicks()
{
	$(document.body).bind('click', function(e) {
		d = last_popup;
		if (d) {
			//console.log('init_outside_clicks: active_post_menu [' + e.target + '] ' + d);
			
			if (d[0][0] != e.target) {
				if (!$.contains(d[1][0], e.target)) {
					switch (d[2]) {
						//case 'btn-feed_filter_menu':
						//	break;
						//
						//case 'active_post_menu':
						//	break;

						default:
							hide_bubble_menu();
					}
				}
			}
		}

			//d = $(document.body).data('active_post_menu');
			//if (d) {
			//	//console.log('init_outside_clicks: active_post_menu [' + e.target + '] ' + d);
			//	
			//	if (d[0][0] != e.target) {
			//		if (!$.contains(d[1][0], e.target))
			//			hide_all_post_menu();
			//	}
			//}
			//
			//d = active_tab;
			//if (d) {
			//	//console.log('init_outside_clicks: active_tab [' + e.target + '] ' + d);
			//	
			//	if (d[0][0] != e.target) {
			//		if (!$.contains(d[1][0], e.target))
			//			hide_tab_menus('');
			//			//set_hover_tab_menus(false);
			//			hover_enabled = false;
			//	}
			//}
	//}).bind('mousemove', function(e) {
		//console.log(e.type + ' ' + e.target);
	});
;
}
function init_toolbar()
{
	//$('#main-search').hover(
	//	function() {
	//		$(this).stop().animate({ opacity: 1.0 }, 300);
	//	},
	//	function() {
	//		$(this).stop().animate({ opacity: 0.1 }, 300);
	//	});

	$('#tab-bar').hover(
		function() {
			$(this).stop().animate({ opacity: 1.0 }, 150);
		},
		function() {
			$(this).stop().animate({ opacity: 0.3 }, 150);
		});

	//$('#top-main-bar').hover(
	//	function() {
	//		$('#main-search').stop().animate({ opacity: 0.1 }, 150);
	//	},
	//	function() {
	//		$('#main-search').stop().animate({ opacity: 0 }, 150);
	//	});
}
function initialize_response_forms()
{
	$('form[done!=true].response')
		.each(function() {
			init_response_form(this);
		});
}
function initialize_post_forms()
{
	$('div[panel_name]')
		.each(function() {
			init_post_form($(this));
		});
}
function initialize_hover_objects()
{
	$('[done!=true].hover-parent')
		.each(function() {
			init_hover_object($(this));
		});
}













function comm(a, e, o)
{
	a = a.split("?");
	p = a[1];
	if (!o) o = [];
	if (o['form'] == true) {
		f = $(e).closest("form." + o['form_type']);		
		p = f.serialize() + '&' + p;
	}

	//var parent, $nvb, $flb, $imb;
	//
	//if (a['flb'] || a['nvb']) {
	//	// direct definitions
	//	$flb = $(a['flb']);
	//	$nvb = $(a['nvb']);
	//} else {
	//	var prefix = '#' + p['tag'] + '_' + p['id'];
	//	var relative_pos = (a['relative'] != false);
	//	
	//	if (relative_pos) {
	//		if (a['spn_group'])
	//			parent = $(a['spn_group']);
	//		else
	//			parent = $(e).closest('.nav-group');
	//
	//		if (parent) {
	//			$nvb = $('.nav-box', parent);
	//			$flb = $('.fla-box', parent);
	//			$imb = $('.img-box', parent);
	//		}
	//	} else {
	//		$nvb = $(prefix + 'n');
	//		$flb = $(prefix + 'f');
	//		$imb = $(prefix + 'i');
	//	}
	//}
	
	var res = $.ajax({
		url: a[0],
		global: true,
		type: "POST",
		data: p,
		dataType: "json",
		beforeSend: function() {
			if (o['before_send']) {
				eval(o['before_send']);
			}		
			
			//var spn = ''
			//if (a['spn'])
			//	spn = create_spinner(a['spn'], a['spn_text']);
			//
			//$nvb.removeClass('visible');
			//$imb.addClass('invisible');
			//
			//if (a['dialog'] == true) {
			//	$('div.dialog', '#' + p['tag']).empty();
			//}
			//
			//if (a['form'] == true)	
			//	$flb.addClass('visible').html(spn);
			//else {			
			//	$flb.html(spn).removeClass('visible').addClass('visible');
			//		//.parent()
			//		//.removeClass('hover').addClass('hover');
			//}
		},
		complete: function() {
			//$nvb.addClass('visible');
			//$flb.empty().removeClass('visible');
			//$imb.removeClass('invisible');
		},
		success: function(r) {
			process_cmd(r);
		}
	}).responseText;
}
function process_cmd(r) {
	var $i, action, data, target, prefix, keep_data;
	
	$.each(r.cmds, function(idx, cmd) {
		data = null;
		
		if (cmd.data)
			data = cmd.data;
		if (cmd.action)
			action = cmd.action;
		if (cmd.target)
			target = '#' + cmd.target;
		else {
			if (cmd.object)
				target = eval(cmd.object);
			else {
				if (cmd.parent_key) {
					var par = '#' + r.prefix + cmd.parent_key;
					target = $(cmd.child, par);
				} else
					target = '#' + r.prefix + cmd.key;
			}
		}
		
		$i = $(target);
		if ($i.length && data) {
			$i.data('data', data);
			keep_data = false;
		}
		
		switch(action) {
		case 'custom-js':
			var res = eval(data);
			break;
		case 'add':
			//var $item = $(data);
			$i.append(data);
			//$item.fadeIn('slow');
			break;
		case 'add-before':
			keep_data = true;
			$i.fadeOut('slow', function() {
				var $t = $(this);
				$t.before($t.data('data')).hide().fadeIn('slow').removeData('data');
			});
			break;
		case 'add-top':
			$i.prepend(data).hide().fadeIn('slow');
			break;
		case 'replace':
			keep_data = true;
			$i.fadeOut('slow', function() {
				var $t = $(this);
				$t.replaceWith($t.data('data')).fadeIn('slow').removeData('data');
			});
			break;
		case 'replace-quick':
			$i.replaceWith(data);
			break;
		case 'replace-add':
			if ($(cmd.new_id).length) {
				$(cmd.new_id).replaceWith(data);
			} else {
				$i.append(data);
			}
			break;
		case 'text':
			keep_data = true;
			$i.fadeOut('slow', function() {
				var $t = $(this);
				$t.text($t.data('data')).fadeIn('slow').removeData('data');
			});
			break;
		case 'html':
			$i.html(data).hide().fadeIn('slow');
			break;
		case 'html-slide':
			$i.html(data).hide().slideDown('slow');
			break;
		case 'html-quick':
			$i.html(data);
			break;
		case 'text-quick':
			$i.text(data);
			break;
		case 'remove-add':
			keep_data = true;
			$i.fadeOut('slow', function() {
				var $t = $(this);
				$t.removeData('data').remove()
									 .parent().append($t.data('data'))
									 .fadeIn('slow');;
			});
			break;
		case 'fadeout':
			$i.removeClass('visible').show()
				.fadeOut('slow', function() {
				});
			break;
		case 'remove':
			keep_data = true;
			$i.fadeOut('slow', function() {
				$(this).removeData('data').remove();
			});
			break;
		case 'add-class':
			$i.addClass(data);
			break;
		case 'remove-class':
			$i.removeClass(data);
			break;
		case 'empty':
			$i.empty();
			break;
		case 'trigger-event':
			$i.trigger(data);
			break;
		case 'scroll-top':
			window.scroll(0, 0);
			break;
		}
		
		if (!keep_data) $i.removeData('data');
		replace_onclick($i);
	});
}




// START Util
function hover_nav(objHover, objShow)
{
	$(objHover).hover(
		function() {
			$(objShow).addClass('visible');
		},
		function() {
			$(objShow).removeClass('visible');
		});
}

function hover_color(objHover)
{
	$(objHover).hover(
		function() {
			$(this).addClass('hover');
		},
		function() {
			$(this).removeClass('hover');
		}).attr('done', true);
}

function create_spinner(img, text)
{
	if (!text) text = '';
	return 	"<img src=\"/images/" + img + ".gif\"><span class=\"spinner-text\">&nbsp;&nbsp;" + text + '</span>';
}
function close_dialog(i)
{
	$(i).closest('div.bubble-delete-dialog')
		.fadeOut('slow', function() {
			$(this).remove();
		});
}
function collapse_responses(p, $i, d)
{
	$('#' + p['target']).empty();//slideUp('slow', function() {
		//$(this).empty();
		$i.closest("div.nav-bar").removeClass('nav-bar-panelized');
		$('.nav-box', $i.closest("ul.nav-group")).html(d);
	//});
}
function remove_form($f)
{
	
}
function is_valid_email(email) {
	var pattern = new RegExp(/^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i);
	return pattern.test(email);
}
function is_valid_login(name) {
	var pattern = new RegExp(/^[\w\d\_\.\-]{4,}$/);
	return pattern.test(name);
}
function is_valid_page(name) {
	return is_valid_login(name);
}
function toggle_db_menu(i) {
	var $sub_menu = $(i).closest('li.menu-item').find('ul.sub-action-menu');
	if ($sub_menu.hasClass('visible') == false) $('.action-menu-items ul.sub-action-menu').removeClass('visible');
	$sub_menu.toggleClass('visible');
}
function toggle_db_menu_selected(i) {
	$('#menu_items ul.sub-action-menu li.selected').removeClass('selected');
	$(i).closest('li').first().addClass('selected');
	toggle_db_menu_arrow(i);
}
function toggle_db_menu_arrow(i) {
	$('#menu_items li.menu-item span:first-child').removeClass('tab-arrow');
	$(i).closest('li.menu-item').children('span:first').addClass('tab-arrow');
}
function deselect_db_tabs() {
	$('#db-top-menu li.selected').removeClass('selected');
}
function toggle_db_tabs(i) {
	deselect_db_tabs();
	$(i).closest('li').addClass('selected');
}
function fetch_tags($i, cm) {
	comm({"cm":cm, "oi":$i.context.options[$i.context.selectedIndex].value, "args":{"url":"/profile"} }, $i)
}
function limit_checkboxes($i, max) {
	if ($('input:checkbox:checked', $i.closest('.checkboxSet')).length > max) {
		alert('You can select max ' + max + ' items.');
		$i.attr('checked', false);
	}
}
function toggle_apps_panel() {
	$('#apps-zone').toggleClass('invisible');
	$('#panels-zone').toggleClass('invisible');
}
function show_apps_panel(i) {
	$('#apps-zone').removeClass('invisible');
	$('#panels-zone').removeClass('invisible').addClass('invisible');
	$('#form-zone').removeClass('invisible').addClass('invisible');
	toggle_db_tabs(i);
}
function show_app_tab(i) {
	$('#panels-zone').removeClass('invisible');
	$('#apps-zone').removeClass('invisible').addClass('invisible');
	$('#form-zone').removeClass('invisible').addClass('invisible');
	toggle_db_tabs(i);
}
function replace_onclick($i) {
	$('[data-onclick]', $i).each(function() {
		var onclickString = $(this).attr('data-onclick');
		var fn = new Function(onclickString);
		$(this).removeAttr('data-onclick').click(fn);
	});

	
}







// END Util

































function fixParamaters(params)
{
	return params.substr(1);	
}

function addToParams(key, val, params)
{
	if (params.length == 0)
		params = '?';
	else params += '&';
	
	return params +key+'='+val;
}

function createElementByFBML(data)
{
	item = document.createElement('div');
	return item.setInnerFBML(data).getFirstChild();	
}

function parseParameters(params)
{
   	parameters={};
	pairs=params.split('&');
	for (var i=0; i<pairs.length; i++) {
		kv=pairs[i].split('=');
		if (kv == '') continue;
		key=kv[0].replace('%3D','=').replace('%26','&');
		val=kv[1].replace('%3D','=').replace('%26','&');
		parameters[key]=val;
    }
    return parameters;
}

function visible_set(set_list)
{
	for (var i=0; i<set_list.length; i++) {
		var _elem = visible(set_list[i++], set_list[i]);
	}
}

function visible(obj_id, value)
{
    var $elem = $(obj_id);
	if (!$elem) return null;
	
    if (value==-1)
        $elem.toggleClass('invisible');	
    else if (value)
        $elem.removeClass('invisible');
    else
        $elem.addClass('invisible');
    
    return $elem;
}

function showhide_set(prefix, suffix, flash, nav, target)
{
	if (nav != -1) visible(prefix+'_navBox_'+suffix, nav)
	if (flash != -1) visible(prefix+'_flashBox_'+suffix, flash)
	if (target != -1) visible(prefix+'_targetBox_'+suffix, target)	
	//visible_set([prefix+'_targetBox_'+suffix, value, prefix+'_navBox_'+suffix, !value]);
}

function show_spinner(prefix, id)
{
	visible(prefix+'_flashBox_'+id, true).setInnerFBML(spinner_comm);
}





function comm_fbml(div, url, params)
{
    var ajax = new Ajax();
    ajax.responseType = Ajax.FBML;
    ajax.ondone = function(data)
    {
      document.getElementById(div).setInnerFBML(data);
      //document.getElementById('ajax2').setTextValue('');
    }

    ajax.onerror = function()
    {
        show_error_dialog(div);
        div.removeClassName('loading');	
    }
    
    ajax.requireLogin = false;
    ajax.post(url, params);
}





function fetch_album(aid, params)
{
    var ajax = new Ajax();
    ajax.responseType = Ajax.FBML;
    ajax.ondone = function(data)
    {
        visible('pnlAlbumsListEdit', false);
        visible('pnlSelectedAlbumPhotosEdit', true).setInnerFBML(data)
        visible('pBtn_'+aid, true)
        visible('pBtnSpinner_'+aid, false)
    }

    ajax.onerror = function()
    {
        show_error_dialog(div);
        div.removeClassName('loading');	
    }
    
    ajax.requireLogin = false;
    visible('pBtn_'+aid, false)
    visible('pBtnSpinner_'+aid, true).setInnerFBML(spinner3)
    ajax.post(getURL('/profile/edit/fetch_album/'+aid), fixParamaters(params));
}

function fetch_paginate(params)
{
    var parameters = parseParameters(params);
	target = parameters['update']
    var ajax = new Ajax();
    ajax.responseType = Ajax.JSON;
    ajax.ondone = function(data)
    {
        $(target).setInnerFBML(data.fbml_data)
        $('PGNAV_'+target).setInnerFBML(data.fbml_paginate)
		visible('PGSPN_'+target, false)
    }

    ajax.onerror = function()
    {
    }
    
    ajax.requireLogin = false;
    visible('PGSPN_'+target, true)

    ajax.post(getURL(parameters['url']), fixParamaters(params));
}

function add_photo_from_album(div, pid, params) // profile name is temporary
{
    var ajax = new Ajax();
    ajax.responseType = Ajax.JSON;
    ajax.ondone = function(data)
    {
        visible('lstUserPhotosEdit_ntfc', false);
        
		var result_code = data.result_code
		if (result_code == 0) {
			var item = createElementByFBML(data.fbml_result); //getValidChildNode(tmp_item);
			$(div).insertBefore(item, $(div).getFirstChild()); //$(div).appendChild(tmp_item);
		}
		
        $('pBtn_'+pid).setInnerFBML([iconOk, iconError][result_code]);
        $('pCell_'+pid).setStyle('backgroundColor', '#ffffff');
    }

    ajax.onerror = function()
    {
    }
    
    ajax.requireLogin = false;
    $('pBtn_'+pid).setInnerFBML(spinner3);
    ajax.post(getURL('/profile/edit/photos/import_fb/'+pid), fixParamaters(params));
}

function set_profile_photo(pid, params)
{
    var ajax = new Ajax();
    ajax.responseType = Ajax.JSON;
    ajax.ondone = function(data)
    {
		var result_code = data.result_code
		if (result_code == 0) {
		}
				
        $('pBtn_'+pid).setInnerFBML([iconOk, iconError][result_code]);
        $('pCell_'+pid).setStyle('backgroundColor', '#ffffff');
    }

    ajax.onerror = function()
    {
    }
    
    ajax.requireLogin = false;
    $('pBtn_'+pid).setInnerFBML(spinner3);
    ajax.post(getURL('/profile/edit/photos/profile_pic/set/'+pid), fixParamaters(params));
}

function edr_photo(pid, cmd, params) // edr: enable, disable or remove
{
    var ajax = new Ajax();
    ajax.responseType = Ajax.JSON;
    ajax.ondone = function(data)
    {
		var result_code = data.result_code
		if (result_code == 0) {
		}
				
        $('pBtn_'+pid).setInnerFBML(data.fbml_result);
    }

    ajax.onerror = function()
    {
    }
    
    ajax.requireLogin = false;
    $('pBtn_'+pid).setInnerFBML(spinner3);
    ajax.post(getURL('/profile/edit/photos/'+cmd+'/'+pid), fixParamaters(params));
}

function remove_photo(div, pid)
{
    var ajax = new Ajax();
    ajax.responseType = Ajax.FBML;
    ajax.ondone = function(data)
    {
        var ntfc = document.getElementById('lstUserPhotosEdit_ntfc');
        if (ntfc != null)
            ntfc.setStyle('display', 'none')
        
        var tmp_item = document.createElement('div');
        tmp_item.setInnerFBML(data);
        tmp_item = tmp_item.getFirstChild() //getValidChildNode(tmp_item);        
        //$(div).appendChild(tmp_item);        
        document.getElementById(div).appendChild(tmp_item);
    }

    ajax.onerror = function()
    {
        show_error_dialog(div);
        div.removeClassName('loading');	
    }
    
    ajax.requireLogin = false;
    ajax.post(getURL('/profile/edit/photos/add/'+pid));
}

/*
function reply_message(prefix, thread_id, profile_name, options)
{
    var tg_div = prefix+'_flashBox_'+thread_id;
    var ajax = new Ajax();
    ajax.responseType = Ajax.FBML;
    ajax.ondone = function(data)
    {
		visible_set([tg_div, false, 'nmsg'+thread_id, true]);
		
        //$('frm'+prefix+'_SendMessage_'+thread_id).getForm.reset();
        var tmp_item = document.createElement('div');
        tmp_item.setInnerFBML(data);
        tmp_item = tmp_item.getFirstChild()
        $('msgContainer_'+thread_id).appendChild(tmp_item);
    }

    ajax.onerror = function()
    {
        show_error_dialog(div);
        $(tg_div).removeClassName('loading');
    }
    
	visible_set([tg_div, true, 'rmsg'+thread_id, false]);
    
    var parameters = parseParameters(options['parameters']);
    
    //$('frmGC_messageBox').reset();
    ajax.requireLogin = false; //K: true?
    ajax.post(getURL('/'+profile_name+'/send_message'), parameters);
}
*/
function send_message(prefix, profile_name, options)
{
    var tg_div = prefix+'_flashBox';
    var ajax = new Ajax();
    ajax.responseType = Ajax.FBML;
    ajax.ondone = function(data)
    {
        $(tg_div).setInnerFBML(data);
        //$(tg_div).addClassName('invisible');
    }

    ajax.onerror = function()
    {
        show_error_dialog(div);
        $(tg_div).removeClassName('loading');
    }
    
    visible(prefix+'_messageBox', false);
    visible(tg_div, true).setInnerFBML(spinner3);
    
    var parameters = parseParameters(options['parameters']);
    
    //$('frmGC_messageBox').reset();
    ajax.requireLogin = false; //K: true?
    ajax.post(getURL('/'+profile_name+'/send_message'), parameters);
}

function comm_fbjs(flb, tgb, url, parameters)
{
    //var parameters = parseParameters(parameters);
    
	var ajax = new Ajax();
    ajax.responseType = Ajax.JSON;
    ajax.ondone = function(data)
    {	
		var result_code = data.result_code;
		if (result_code == 0) { // success
			visible(flb, false);
			if (data.fbml_result != '')
				$(tgb).setInnerFBML(data.fbml_result);
			
		} else { // failed
			if (data.fbml_flash_text != '')
				$(flb).setInnerFBML(data.fbml_flash_text);
		}
    }

    ajax.onerror = function()
    {
    }    
	
    visible(flb, true).setInnerFBML(spinner_comm);    
    
    ajax.requireLogin = false;
    ajax.post(getURL(url), parameters);
}

function post_answer(prefix, options)
{
    var parameters = parseParameters(options['parameters']);
	var qid = parameters['qid'];
    var flb = prefix+'_flashBox_'+qid;
    
	var ajax = new Ajax();
    ajax.responseType = Ajax.JSON;
    ajax.ondone = function(data)
    {	
		var result_code = data.result_code;
		if (result_code == 0) {
			var item = createElementByFBML(data.fbml_result);
			var parent_list = $(prefix+'_answerList_'+qid)
			parent_list.insertBefore(item, parent_list.getFirstChild());
			$(prefix+'_numAnswers_'+qid).setTextValue(data.num_answers);
		}
		
        $(flb).setInnerFBML(data.fbml_flash_text);
    }

    ajax.onerror = function()
    {
    }    
	
    //visible(prefix+'_nqst'+qid, false);
    visible(prefix+'_answerBox_'+qid, false);
    visible(flb, true).setInnerFBML(spinner5);    
    
    ajax.requireLogin = false;
    ajax.post(getURL('/answers/new'), parameters);
}

function post_ho_response(prefix, options)
{
    var parameters = parseParameters(options['parameters']);
	var id = parameters['hid'];
    var flb = prefix+'_flashBox_'+id;
    
	var ajax = new Ajax();
    ajax.responseType = Ajax.JSON;
    ajax.ondone = function(data)
    {	
		var result_code = data.result_code;
		if (result_code == 0) {
		}
		
        $(flb).setInnerFBML(data.fbml_flash_text);
    }

    ajax.onerror = function()
    {
    }    
	
    visible(prefix+'_requestBox_'+id, false);
    visible(flb, true).setInnerFBML(spinner5);    
    
    ajax.requireLogin = false;
    ajax.post(getURL('/hangout_response/new'), parameters);
}

function toggle_favorite(tg_div, profile_name, fav_icon, params)
{
    var ajax = new Ajax();
    ajax.responseType = Ajax.JSON;
    ajax.ondone = function(data)
    {
        $(tg_div).setInnerFBML(data.fbml_flash_text);
		if (fav_icon)
			$(fav_icon).setTextValue(data.icon_text);
    }

    ajax.onerror = function()
    {
    }
    
    visible(tg_div, true).setInnerFBML(spinner3).addClassName('flashBox');	
    
    ajax.requireLogin = false; //K: true?
    ajax.post(getURL('/'+profile_name+'/favorite'), fixParamaters(params));
}

function comm2(params)
{
	prefix = '#' + params['item_tag'] + '_' + params['id'];
	$nvb = $(prefix + '_n');
	$tgb = $(prefix + '_t');
	$par = $(prefix + '_p');
	
	var res = $.ajax({
		url: params['url'],
		global: false,
		type: "POST",
		data: params,
		dataType: "json",
		beforeSend: function(){
			$nvb.html($('#spinner1').html()).toggleClass('visible-force').parent().toggleClass('hover-force');
		},
		complete: function(){
			//$nvb.toggleClass('visible-force').parent().toggleClass('hover-force');
		},
		success: function(data) {
			if (data) {
				if (data.result_code == 0) { // success
					if (data.result_data != '' || data.action == 'remove') {
						switch(data.action) {
						case 'add':
							if ($par.length)
								$par.append(data.result_data).hide().fadeIn('slow');
							break;
						case 'replace':
							$tgb.fadeOut('slow', function() {
								$(this).replaceWith(data.result_data).fadeIn('slow');
							})
							break;
						case 'remove':
							$tgb.fadeOut('slow', function() {
								$(this).remove();
							})
							break;
						}
					}
					
					if (data.flash_text != '' && data.action != 'remove')
						$nvb.text(data.flash_text);
				}
				else { // failed
					if (data.flash_text != '')
						$nvb.text(data.flash_text);
				}
			}
		}
	}).responseText;
}

function fetch_answers(qst_id, params)
{
    var ajax = new Ajax();
    ajax.responseType = Ajax.FBML;
    ajax.ondone = function(data)
    {
		visible('VA_flashBox_'+qst_id, true).setInnerFBML(data);
		visible('VA_answerTitle_'+qst_id, true);		
    }

    ajax.onerror = function()
    {
    }
    
	visible('VA_answerTitle_'+qst_id, false);
	visible('VA_flashBox_'+qst_id, true).setInnerFBML(spinner5);
    
    ajax.requireLogin = false; //K: true?
    ajax.post(getURL('/myself/fetch_answers/'+qst_id), fixParamaters(params));
}
/*
function fetch_thread(thr_id, msg_id, params)
{
    var ajax = new Ajax();
    ajax.responseType = Ajax.FBML;
    ajax.ondone = function(data)
    {
        //$('IB_flashBox_'+thr_id).hide();
        visible('MRM_spinner', false);
        $('dynamic-content-mailbox').setInnerFBML(data);
        //$('firstMessage_'+thr_id).toggleClassName('rowSeparator');
        //$('threadItem_'+thr_id).toggleClassName('threadBorder');
        //$('messageHeader_'+msg_id).toggleClassName('viewThread');
        //
        ////$('messageItem'+msg_id).addClassName('readMsg');
        //$('vmsg'+msg_id).toggleClassName('invisible');
        //$('nmsg'+msg_id).toggleClassName('invisible');
        ////$('msgEnv'+msg_id).setSrc('http://localhost:3000/images/iconMailRead.png');        
    }

    ajax.onerror = function()
    {
    }
    
    visible('MRM_spinner', true);
    
    ajax.requireLogin = false; //K: true?
    ajax.post(getURL('/myself/fetch_thread/'+thr_id), fixParamaters(params));
}
*/
//function get_mails(params)
//{
//    var ajax = new Ajax();
//    ajax.responseType = Ajax.FBML;
//    ajax.ondone = function(data)
//    {		
//        visible('MRM_spinner', false);
//        $('dynamic-content-mailbox').setInnerFBML(data);
//    }
//
//    ajax.onerror = function()
//    {
//    }
//    
//    visible('MRM_spinner', true);
//    
//    //if (mailbox == '') {
//    //    mailbox = $('dynamic-content-mailbox').getName();
//    //    if (mailbox == undefined)
//    //        mailbox = 'inbox';
//    //}
//    //else {
//    //    $('dynamic-content-mailbox').setName(mailbox);
//    //}
//    
//    ajax.requireLogin = false; //K: true?
//    ajax.post(getURL('/myself/fetch_mailbox'), fixParamaters(params));
//}
