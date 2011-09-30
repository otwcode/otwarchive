// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults 

//things to do when the page loads
$j(document).ready(function() {
    // visualizeTables();
    $j('#signin_open').click(function() {
          $j('#signin').toggle();
          $j('#signin_closed').toggle();
          $j('#signin_open').toggle();
      });
    $j('#signin_closed').click(function() {
          $j('#signin').toggle();
          $j('#signin_open').toggle();
          $j('#signin_closed').toggle();
      });
    if ($j('#work-form')) { hideFormFields(); };     
    if ($j('form.filters')) { hideFilters(); };
    // initSelect('languages_menu');
    hideExpandable();
    hideHideMe();
    showShowMe();
    handlePopUps();
    generateCharacterCounters();
    $j('.subnav_toggle').click(function(){
          $j('#subnav').toggle();
      });
    $j('#expandable-link').click(function(){
          expandList();
          return false;
      });
    $j('#chapter_index_toggle').click(function() { $j('#chapter-index').toggle(); });
    $j(".toggle_filters").click(function(){
          target_id = "#" + $j(this).attr("id").replace("toggle_", "");
          $j(target_id).toggle();
          $j(target_id + "_open").toggle();
          $j(target_id + "_closed").toggle();
    });
    $j('#hide-notice-banner').click(function () { $j('#notice-banner').hide(); });
    setupTooltips();

    // Activating Best In Place 
    jQuery(".best_in_place").best_in_place();
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


///////////////////////////////////////////////////////////////////
// Autocomplete
///////////////////////////////////////////////////////////////////

function get_token_input_options(self) {
  return {
    searchingText: self.attr('autocomplete_searching_text'),
    hintText: self.attr('autocomplete_hint_text'),
    noResultsText: self.attr('autocomplete_no_results_text'),
    minChars: self.attr('autocomplete_min_chars'),
    queryParam: "term",
    preventDuplicates: true,
    tokenLimit: self.attr('autocomplete_token_limit'),
    liveParams: self.attr('autocomplete_live_params'),
    makeSortable: self.attr('autocomplete_sortable')
  };
}

// Look for autocomplete_options in application helper and throughout the views to
// see how to use this!
jQuery(function($) {
  $('input.autocomplete').livequery(function(){
    var self = $(this);
    var token_input_options = get_token_input_options(self);
    var method;
    try {
        method = $.parseJSON(self.attr('autocomplete_method'));
    } catch (err) {
        method = self.attr('autocomplete_method');
    }
    self.tokenInput(method, token_input_options);
  });
});

///////////////////////////////////////////////////////////////////

// expand, contract, shuffle
jQuery(function($){
  $('.expand').each(function(){
    // start by hiding the list in the page
    list = $($(this).attr('action_target'));
    if (list.children().size() > 25 || list.attr('force_contract')) {
      list.hide();
      $(this).show();      
    } else {
      // show the shuffle and contract button only
      $(this).nextAll(".shuffle").show();
      $(this).next(".contract").show();
    }    
    
    // set up click event to expand the list 
    $(this).click(function(event){
      list = $($(this).attr('action_target'));
      list.show();
      
      // show the contract & shuffle buttons and hide us
      $(this).next(".contract").show();
      $(this).nextAll(".shuffle").show();
      $(this).hide();
      
      event.preventDefault(); // don't want to actually click the link
    });
  });
  
  $('.contract').each(function(){
    $(this).click(function(event){
      // hide the list when clicked
      list = $($(this).attr('action_target'));
      list.hide();

      // show the expand and shuffle buttons and hide us
      $(this).prev(".expand").show();
      $(this).nextAll(".shuffle").hide();
      $(this).hide();
      
      event.preventDefault(); // don't want to actually click the link
    });
  });
  
  $('.shuffle').each(function(){
    // shuffle the list's children when clicked
    $(this).click(function(event){
      list = $($(this).attr('action_target'));
      list.children().shuffle();
      event.preventDefault(); // don't want to actually click the link
    });
  });
  
});

// check all or none within the parent fieldset, optionally with a string to match on the name field of the checkboxes
// stored in the "checkbox_name_filter" attribute on the all/none links. 
jQuery(function($){
  $('.check_all').each(function(){
    $(this).click(function(event){
      var filter = $(this).attr('checkbox_name_filter');
      var checkboxes;
      if (filter) {
        checkboxes = $(this).closest('fieldset').find('input[name*="' + filter + '"][type="checkbox"]');
      } else {
        checkboxes = $(this).closest("fieldset").find(':checkbox');
      }
      checkboxes.attr('checked', true);
      event.preventDefault();   
    });
  });
  
  $('.check_none').each(function(){
    $(this).click(function(event){
      var filter = $(this).attr('checkbox_name_filter');
      var checkboxes;
      if (filter) {
        checkboxes = $(this).closest('fieldset').find('input[name*="' + filter + '"][type="checkbox"]');
      } else {
        checkboxes = $(this).closest("fieldset").find(':checkbox');
      }
      checkboxes.attr('checked', false);
      event.preventDefault();      
    });
  });
});

// Timepicker
jQuery(function($) {
  $('.timepicker').datetimepicker({
    ampm: true,
    dateFormat: 'yy-mm-dd',
    timeFormat: 'hh:mmTT',
    hourGrid: 5,
    minuteGrid: 10
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
    $j("a[data_popup]").click(function(event, element) {
      if (event.stopped) return;
      window.open($j(element).attr('href'));
      event.stop();
    });    
}

// used in nested form fields for deleting a nested resource 
// see prompt form for example
function remove_section(link, class_of_section_to_remove) {
    $j(link).siblings(":input[type=hidden]").val("1"); // relies on the "_destroy" field being the nearest hidden field
    $j(link).closest("." + class_of_section_to_remove).hide();
}

// used with nested form fields for dynamically stuffing in an extra partial
// see challenge signup form and prompt form for an example
function add_section(link, nested_model_name, content) {
    // get the right new_id which should be in a div with class "last_id" at the bottom of 
    // the nearest section
    var last_id = parseInt($j(link).parent().siblings('.last_id').last().html());
    var new_id = last_id + 1;
    var regexp = new RegExp("new_" + nested_model_name, "g");
    content = content.replace(regexp, new_id)
    $j(link).parent().before(content);
}

// An attempt to replace the various work form toggle methods with a more generic one
function toggleFormField(element_id) {
    var ticky = $j('#' + element_id + '-show');
    if (ticky.is(':checked')) { $j('#' + element_id).removeClass('hidden'); }
    else { 
        $j('#' + element_id).addClass('hidden');
        if (element_id == 'chapters-options') {
            var item = document.getElementById('work_wip_length');
            if (item.value == 1) {item.value = '?';}
            else {item.value = 1;}
        }
        else {
            $j('#' + element_id).find(':input[type!="hidden"]').each(function(index, d) {
                if ($j(d).attr('type') == "checkbox") {$j(d).attr('checked', false);}
                else {$j(d).val('');}
            });
        }
    }
}

function showOptions(idToCheck, idToShow) {
    var checkbox = document.getElementById(idToCheck);
    var areaToShow = document.getElementById(idToShow);
    if (checkbox.checked) {
        Element.toggle(idToShow)
    }
}

// Hides expandable form field options if Javascript is enabled
function hideFormFields() {
    if ($j('#work-form') != null) {
        var toHide = ['#co-authors-options', '#front-notes-options', '#end-notes-options', '#chapters-options', '#parent-options', '#series-options', '#backdate-options'];
        $j.each(toHide, function(index, name) {
            if ($j(name)) {
                if (!($j(name + '-show').is(':checked'))) { $j(name).addClass('hidden'); }
            }
        });
        $j('#work-form').className = $j('#work-form').className;
    }
}

// TODO: combine and simplify during Javascript review
// Currently used to expand/show fandoms on the user dashboard
function expandList() {
    var hidden_lis = $j('li.hidden');
    hidden_lis.each(function(index, li) {
        $j(li).removeClass('hidden');
        $j(li).addClass('not-hidden');
    });
    $j('#expandable-link').text("\< Hide full list");
    $j('#expandable-link').unbind('click');
    $j('#expandable-link').click(function(){
        contractList();
        return false;
    });
}

function contractList() {
    var hidden_lis = $j('li.not-hidden');
    hidden_lis.each(function(index, li) {
        $j(li).removeClass('not-hidden');
        $j(li).addClass('hidden');  
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
    $j(filter).toggle();
    $j(filter_open).toggle();
    $j(filter_closed).toggle();
  }
}

// Collapses filter list if Javascript is enabled, unless an input from that filter is selected
function hideFilters() {
  var filters = $j('dd.tags');
  filters.each(function(index, filter) {
    var tags = $j(filter).find('input');
    var selected = false;
    tags.each(function(index, tag) {if ($j(tag).is(':checked')) selected=true});
    if (selected != true) {toggleFilters(filter.id, 0);}
  });  
}

// Toggles login block
function toggleLogin(id, blind_duration) {
  //blind_duration = (blind_duration == null ? 0.2 : blind_duration)
  if ($j(id) != null) {
    $j(id).toggle();
    $j(id + "_open").toggle();
    $j(id + "_closed").toggle();
  }
}

// Rolls up Login if Javascript is enabled
function hideLogin() {
  var signin = $j('#signin');
  signin.each(function(index, signin) {
    var tags = $j(signin).find('input');
    var selected = false;
    tags.each(function(index, tag) {if ($j(tag).is(':checked')) selected=true});
    if (selected != true) {toggleLogin('#signin', 0.0);}
  });  
}

// Hides the extra checkbox fields in prompt form
function hideField(id) {
  $j('#' + id).toggle();
}

function generateCharacterCounters() {
  $j(".observe_textlength").each(function(){
        //update relevant character counter span
        var input_id = '#' + $j(this).attr('id');
        var maxlength = $j(input_id + '_counter').attr('data-maxlength');
        var input_value = $j(input_id).val();
        input_value = (input_value.replace(/\r\n/g,'\n')).replace(/\r|\n/g,'\r\n'); 
        $j(input_id + '_counter').html(maxlength - input_value.length);
  });
  $j(".observe_textlength").live("keyup keydown mouseup mousedown change", function(){
        var input_id = '#' + $j(this).attr('id');
        var maxlength = $j(input_id + '_counter').attr('data-maxlength');
        var input_value = $j(input_id).val();
        input_value = (input_value.replace(/\r\n/g,'\n')).replace(/\r|\n/g,'\r\n'); 
        //$j(input_id).val(input_value); //this had really bad effects, don't do it
        $j(input_id + '_counter').html(maxlength - input_value.length);
    });
}

function setupTooltips() {
    $j('span[tooltip]').each(function(){
       $j(this).qtip({
          content: $j(this).attr('tooltip'),
          position: {corner: {target: 'topMiddle'}}
       });
    });    
}