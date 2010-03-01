// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults 

//things to do when the page loads
document.observe("dom:loaded", function () {
	visualizeTables();
	hideFormFields(); 
	hideFilters();
	initSelect('languages_menu');
    hideExpandable();
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

// Hides expandable fields if Javascript is enabled
function hideExpandable() {
  var expandable = document.getElementById('expandable');
  if (expandable != null) expandable.style.display = 'none';
}

// An attempt to replace the various work form toggle methods with a more generic one
function toggleFormField(element_id) {
    if (element_id == 'number-of-chapters') {
        var item = document.getElementById('work_wip_length');
    	if (item.value == 1) {item.value = '?';}
    	else {item.value = 1;}
    }
    else {
        Element.descendants(element_id).each(function(d) {
            if (d.type == "checkbox") {d.checked = false}
            else if (d.type != "hidden" && (d.nodeName == "INPUT" || d.nodeName == "SELECT")) {d.value = ''}
        });
    }
	Element.toggle(element_id);
}

// Toggles the notes section of the work form
function showNotesOptions(modelname) {
	var worknotesoptions = $('worknotesoptions')
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
	var worknotesoptions = $('workendnotesoptions')
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
	var coAuthors = document.getElementById('co-authors');
	if (coAuthors != null) coAuthors.style.display='none';
	 
	if (document.storyForm != null) var isWip = document.storyForm.isWip;
	var chapteredOptions = document.getElementById('number-of-chapters');
	if (isWip != null && chapteredOptions != null && !isWip.checked) chapteredOptions.style.display='none';
	
	if (document.storyForm != null) var hasSeries = document.storyForm.storyseriescheck;
	var seriesOptions = document.getElementById('seriesmanage');
	if (hasSeries != null && seriesOptions != null && !hasSeries.checked) seriesOptions.style.display='none';
	
	if (document.storyForm != null) var isBackdated = document.storyForm.publicationdatecheck;
	var backdateOptions = document.getElementById('publicationdateoptions');
	if (isBackdated != null && backdateOptions != null && !isBackdated.checked) backdateOptions.style.display='none';
  
	if (document.storyForm != null) var hasNotes = document.storyForm.storynotescheck;
	var notesOptions = document.getElementById('worknotesoptions');
	if (hasNotes != null && notesOptions != null && !hasNotes.checked) notesOptions.style.display='none';
  
	if (document.storyForm != null) var hasEndnotes = document.storyForm.storyendnotescheck;
	var endnotesOptions = document.getElementById('workendnotesoptions');
	if (hasEndnotes != null && endnotesOptions != null && !hasEndnotes.checked) endnotesOptions.style.display='none';    	
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



