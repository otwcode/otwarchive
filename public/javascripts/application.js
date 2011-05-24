// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults 

//things to do when the page loads
$j(document).ready(function() {
    // visualizeTables();
    if ($('work-form')) { hideFormFields(); }; 
    if ($$('form.filters')) { hideFilters(); };
    // initSelect('languages_menu');
    hideExpandable();
    hideHideMe();
    showShowMe();
    handlePopUps();
    $j('#expandable-link').click(function(){
          expandList();
          return false;
      });
});

function visualizeTables() {
     $j("table.stats-pie").visualize({type: 'pie', width: '600px', height: '300px'});
     $j("table.stats-line").visualize({type: 'line'});
}

// Shows expandable fields when clicked on
function ShowExpandable() {
  var expandable = document.getElementById('expandable');
  if (expandable != null) expandable.style.display = 'inline';
  var collapsible = document.getElementById('collapsible');
  if (collapsible != null) collapsible.style.display = 'none';
}

// Autocomplete
// set class to "autocomplete"
// set attribute "autocomplete_method" to the action in autocomplete_controller you want to use
// you can pass extra parameters at the end of the method with ?param=value&param=value
// set attribute "autocomplete_live_params" to the ids of any attributes whose values should be read
//  as: param=attribute_id&param=attribute_id
// example: 
// <input type="text" class="autocomplete" autocomplete_method="/autocomplete/relationship?tag_set_id=#{tag_set.id}" 
//        autocomplete_live_params="fandom=work_fandom_field&character=work_character_field" 
jQuery(function($){
  $('.autocomplete').each(function(){
    var self = $(this);
    self.tokenInput(self.attr('autocomplete_method'), {
        searchingText: self.attr('autocomplete_searching_text'),
        hintText: self.attr('autocomplete_hint_text'),
        noResultsText: self.attr('autocomplete_no_results_text'),
        minChars: self.attr('autocomplete_min_chars'),
        queryParam: "term",
        preventDuplicates: true,
        tokenLimit: self.attr('autocomplete_token_limit'),
        liveParams: self.attr('autocomplete_live_params'),
        makeSortable: self.attr('autocomplete_sortable')
    });
  });
});

// Single-value autocomplete
jQuery(function($){
    $('.single_autocomplete').each(function(){
        var self = $(this);
        self.autocomplete({
            source: self.attr('autocomplete_method'),
            minLength: self.attr('autocomplete_min_chars'),
            autoFocus: true // to keep behavior similar to main autocomplete
        });
    });
});


// Hides expandable fields if Javascript is enabled
function hideExpandable() {
  var expandable = document.getElementById('expandable');
  if (expandable != null) expandable.style.display = 'none';
}

function hideHideMe() {
    nodes = $j('.hideme');
    nodes.each(function(index, node) { $j(node).hide(); });
}

function showShowMe() {
    nodes = $j('.showme');
    nodes.each(function(index, node) { $j(node).show(); });
}

function handlePopUps() {
    document.on("click", "a[data_popup]", function(event, element) {
      if (event.stopped) return;
      window.open($(element).href);
      event.stop();
    });    
}

// used in autocompleters to automatically insert comma
function addCommaToField(element, item) {
    element.value = element.value + ', '
}

// used in nested form fields for deleting a nested resource 
// see prompt form for example
function remove_section(link, class_of_section_to_remove) {
    $(link).previous("input[type=hidden]").value = "1"; // relies on the "_destroy" field being the nearest hidden field
    $(link).up("." + class_of_section_to_remove).hide();
}

// used with nested form fields for dynamically stuffing in an extra partial
// see challenge signup form and prompt form for an example
function add_section(link, nested_model_name, content) {
    // get the right new_id which should be in a div with class "last_id" at the bottom of 
    // the nearest section
    var last_id = parseInt($(link).up().previous('.last_id').innerHTML);
    var new_id = last_id + 1;
    var regexp = new RegExp("new_" + nested_model_name, "g");
    content = content.replace(regexp, new_id)
    $(link).up().insert({before: content});
}

// An attempt to replace the various work form toggle methods with a more generic one
function toggleFormField(element_id) {
    var ticky = $(element_id + '-show');
    if (ticky.checked) { $(element_id).removeClassName('hidden'); }
    else { 
        $(element_id).addClassName('hidden');
        if (element_id == 'chapters-options') {
            var item = document.getElementById('work_wip_length');
            if (item.value == 1) {item.value = '?';}
            else {item.value = 1;}
        }
        else {
            Element.descendants(element_id).each(function(d) {
                if (d.type == "checkbox") {d.checked = false}
                else if (d.type != "hidden" && (d.nodeName == "INPUT" || d.nodeName == "SELECT" || d.nodeName == "TEXTAREA")) {d.value = ''}
            });
        }
    }
}

// Toggles the notes section of the work form
function showNotesOptions(modelname) {
	var worknotesoptions = $('front-notes-options')
	worknotesoptions.toggle();
	if (!worknotesoptions.visible()) {
		$(modelname + '_notes').clear();
		$('worknoteswarning').hide();
	}
	else {
		$('worknoteswarning').show();
	}
}

// Toggles the endnotes section of the work form
function showEndnotesOptions(modelname) {
	var worknotesoptions = $('end-notes-options')
	worknotesoptions.toggle();
	if (!worknotesoptions.visible()) {
		$(modelname + '_endnotes').clear();
		$('workendnoteswarning').hide();
	}
	else {
		$('workendnoteswarning').show();
	}
}

function showOptions(idToCheck, idToShow) {
    var checkbox = document.getElementById(idToCheck);
    var areaToShow = document.getElementById(idToShow);
    if (checkbox.checked) {
        Element.toggle(idToShow)
    }
}

function selectAllCheckboxes(basefield, count, checked) {
    var checkbox;
    for (i=1; i<=count; i++) {
        checkbox = document.getElementById(basefield + '_' + i);
        if (checked == 'invert') {
            checkbox.checked = !checkbox.checked
        } else {
            checkbox.checked = checked
        }
    }
}

// Hides expandable form field options if Javascript is enabled
function hideFormFields() {
    if ($('work-form') != null) {
        var toHide = ['co-authors-options', 'front-notes-options', 'end-notes-options', 'chapters-options', 'parent-options', 'series-options', 'backdate-options']
        toHide.each(function(name) {
            if ($(name)) {
                if ($(name + '-show').checked == false) { $(name).addClassName('hidden'); }
            }
        });
        $('work-form').className = $('work-form').className;
    }
}

// TODO: combine and simplify during Javascript review
// Currently used to expand/show fandoms on the user dashboard
function expandList() {
    var hidden_lis = $$('li.hidden');
    hidden_lis.each(function(li) {
        li.removeClassName('hidden');
        li.addClassName('not-hidden');
    });
    $j('#expandable-link').text("\< Hide full list");
    $j('#expandable-link').unbind('click');
    $j('#expandable-link').click(function(){
        contractList();
        return false;
    });
}

function contractList() {
    var hidden_lis = $$('li.not-hidden');
    hidden_lis.each(function(li) {
        li.removeClassName('not-hidden');
        li.addClassName('hidden');  
    });
    $j('#expandable-link').text("\> Expand full list");    
    $j('#expandable-link').unbind('click');
    $j('#expandable-link').click(function(){
        expandList();
        return false;
    });
}


// Toggles items in filter list
function toggleFilters(id, blind_duration) {
    
	blind_duration = (blind_duration == null ? 0.2 : blind_duration = 0.2)
    var filter = document.getElementById(id);
	var filter_open = document.getElementById(id + "_open")
	var filter_closed = document.getElementById(id + "_closed")
	if (filter != null) {
		Effect.toggle(filter, 'blind', {duration: blind_duration});
		Effect.toggle(filter_open, 'appear', {duration: 0})
		Effect.toggle(filter_closed, 'appear', {duration: 0})
	}
}

// Collapses filter list if Javascript is enabled
function hideFilters() {
	var filters = $$('dd.tags');
	filters.each(function(filter) {
		var tags = filter.select('input');
		var selected = false;
		tags.each(function(tag) {if (tag.checked) selected=true});
		if (selected != true) {toggleFilters(filter.id, 0);}
	});	
}

// Toggles login block
function toggleLogin(id, blind_duration) {
	blind_duration = (blind_duration == null ? 0.2 : blind_duration)
    var signin = document.getElementById(id);
	var signin_open = document.getElementById(id + "_open")
	var signin_closed = document.getElementById(id + "_closed")
	if (signin != null) {
		Effect.toggle(signin, 'blind', {duration: blind_duration});
		Effect.toggle(signin_open, 'appear', {duration: 0.0})
		Effect.toggle(signin_closed, 'appear', {duration: 0.0})
	}
}

// Rolls up Login if Javascript is enabled
function hideLogin() {
	var signin = $$('#signin');
	signin.each(function(signin) {
		var tags = signin.select('input');
		var selected = false;
		tags.each(function(tag) {if (tag.checked) selected=true});
		if (selected != true) {toggleLogin(signin.id, 0.0);}
	});	
}

// Hides the extra checkbox fields in prompt form
function hideField(id) {
    var id_to_hide =  document.getElementById(id);
    Effect.toggle(id_to_hide, 'blind', {duration: 0.0});
}


//generic show hide toggler

function ViewToggle(el_selector, show_link_selector, hide_link_selector, effect_duration, start_shown) {
  this.el = el_selector
  this.show_el = show_link_selector
  this.hide_el = hide_link_selector
  this.options = {
    duration: effect_duration || 0.2
  }
  if (!start_shown) { // this is null == false, if not provided
    // Call on body DOM loaded event courtesy of jQuery
    var thisone = this
    jQuery(function(){thisone.hide()})
  }
}
ViewToggle.prototype = {
  toggle: function toggle() {
    var el = $(this.el)
    if (el) Effect.toggle(el, 'blind', this.options)
    this._toggle_el(this.show_el)
    this._toggle_el(this.hide_el)
  },
  hide: function hide() {
    var el = $(this.el)
    if (el) Effect.BlindUp(el, this.options)
    this._show_el(this.show_el)
    this._hide_el(this.hide_el)
  },
  show: function show() {
    var el = $(this.el)
    if (el) Effect.BlindDown(el, this.options)
    this._show_el(this.hide_el)
    this._hide_el(this.show_el)
  },
  _hide_el: function(el) {
    el = $(el)
    if (el) Effect.Fade(el, {duration:0})
  },
  _toggle_el: function(el) {
    el = $(el)
    if (el) Effect.toggle(el, 'appear', {duration:0})
  },
  _show_el: function(el) {
    el = $(el)
    if (el) Effect.Appear(el, {duration:0})
  }
}

// commented out for now as it is inadvertently disabling sessions view login login_view = new ViewToggle('signin', 'signin_closed', 'signin_open')
subnav_view = new ViewToggle('subnav');
flash_view = new ViewToggle('flash');