// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults 

//things to do when the page loads
$j(document).ready(function() {
    // visualizeTables();
    // initSelect('languages_menu');
    setupToggled();
    if ($j('#work-form')) { hideFormFields(); };
    hideHideMe();
    showShowMe();
    handlePopUps();
    generateCharacterCounters();
    $j('#expandable-link').click(function(e){
          e.preventDefault();
          expandList();
          return false;
      });
    $j('#hide-notice-banner').click(function (e) { 
      $j('#notice-banner').hide();
      e.preventDefault(); 
    });
    setupTooltips();

    // replace all GET delete links with their AJAXified equivalent
    $j('a[href$="/confirm_delete"]').each(function(){
        this.href = this.href.replace(/\/confirm_delete$/, "");
        $j(this).attr("data-method", "delete").attr("data-confirm", "Are you sure? This CANNOT BE UNDONE!");
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
    if (!list.attr('force_expand') || list.children().size() > 25 || list.attr('force_contract')) {
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
  
  $('.expand_all').each(function(){
      target = "." + $(this).attr('target_class');
     $(this).click(function(event) {
        $(this).closest(target).find(".expand").click();
        event.preventDefault();
     }); 
  });
  
  $('.contract_all').each(function(){
     target = "." + $(this).attr('target_class');
     $(this).click(function(event) {
        $(this).closest(target).find(".contract").click();
        event.preventDefault();
     }); 
  });
  
});

// check all or none within the parent fieldset, optionally with a string to match on the name field of the checkboxes
// stored in the "checkbox_name_filter" attribute on the all/none links.
// allow for some flexibility by checking the next fieldset if the checkboxes aren't in this one
jQuery(function($){
  $('.check_all').each(function(){
    $(this).click(function(event){
      var filter = $(this).attr('checkbox_name_filter');
      var checkboxes;
      if (filter) {
        checkboxes = $(this).closest('fieldset').find('input[name*="' + filter + '"][type="checkbox"]');
      } else {
        checkboxes = $(this).closest("fieldset").find(':checkbox');
        if (checkboxes.length == 0) { checkboxes = $(this).closest("fieldset").next().find(':checkbox'); }
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
        if (checkboxes.length == 0) { checkboxes = $(this).closest("fieldset").next().find(':checkbox'); }
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


// Set up open and close toggles for a given object
// Typical setup (this will leave the toggled item open for users without javascript but hide the controls from them):
// <a class="foo_open hidden">Open Foo</a>
// <div id="foo" class="toggled">
//   foo!
//   <a class="foo_close hidden">Close</a>
// </div>
// 
// Notes:
// - The open button CANNOT be inside the toggled div, the close button can be (but doesn't have to be)
// - You can have multiple open and close buttons for the same div since those are labeled with classes
// - You don't have to use div and a, those are just examples. anything you put the toggled and _open/_close classes on will work.
// - If you want the toggled thing not to be visible to users without javascript by default, add the class "hidden" to the toggled item as well
//   (and you can then add an alternative link for them using <noscript>)
function setupToggled(){
  $j('.toggled').each(function(){
    var node = $j(this);
    var open_toggles = $j('.' + node.attr('id') + "_open");
    var close_toggles = $j('.' + node.attr('id') + "_close");
    
    if (!node.hasClass('open')) {node.hide();}
    close_toggles.each(function(){$j(this).hide();});
    open_toggles.each(function(){$j(this).show();});

    open_toggles.each(function(){
      $j(this).click(function(e){
        if ($j(this).attr('href') == '#') {e.preventDefault();}
        node.show();
        open_toggles.each(function(){$j(this).hide();});
        close_toggles.each(function(){$j(this).show();});
      });
    });
    
    close_toggles.each(function(){
      $j(this).click(function(e){
        if ($j(this).attr('href') == '#') {e.preventDefault();}
        node.hide();
        close_toggles.each(function(){$j(this).hide();});
        open_toggles.each(function(){$j(this).show();});
      });
    });
  });  
}


// Hides expandable fields if Javascript is enabled
function hideExpandable() {
  var expandable = document.getElementById('expandable');
  if (expandable != null) expandable.style.display = 'none';
}

function hideHideMe() {
    $j('.hideme').each(function() { $j(this).hide(); });
}

function showShowMe() {
    $j('.showme').each(function() { $j(this).show(); });
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
    content = content.replace(regexp, new_id);
    // kludgy: show the hidden remove_section link (we don't want it showing for non-js users)
    content = content.replace('class="hidden showme"', '');
    $j(link).parent().before(content);
}

// An attempt to replace the various work form toggle methods with a more generic one
function toggleFormField(element_id) {
    var ticky = $j('#' + element_id + '-show');
    if (ticky.is(':checked')) { 
      $j('#' + element_id).removeClass('hidden'); 
    }
    else { 
        $j('#' + element_id).addClass('hidden');
        if (element_id != 'chapters-options') {
            $j('#' + element_id).find(':input[type!="hidden"]').each(function(index, d) {
                if ($j(d).attr('type') == "checkbox") {$j(d).attr('checked', false);}
                else {$j(d).val('');}
            });
        }
    }
    // We want to check this whether the ticky is checked or not
    if (element_id == 'chapters-options') {
        var item = document.getElementById('work_wip_length');
        if (item.value == 1 || item.value == '1') {item.value = '?';}
        else {item.value = 1;}
    }
}

function showOptions(idToCheck, idToShow) {
    var checkbox = document.getElementById(idToCheck);
    var areaToShow = document.getElementById(idToShow);
    if (checkbox.checked) {
        Element.toggle(idToShow);
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

// Hides the extra checkbox fields in prompt form
function hideField(id) {
  $j('#' + id).toggle();
}

function updateCharacterCounter(counter) {
    var input_id = '#' + $j(counter).attr('id');
    var maxlength = $j(input_id + '_counter').attr('data-maxlength');
    var input_value = $j(input_id).val();
    input_value = (input_value.replace(/\r\n/g,'\n')).replace(/\r|\n/g,'\r\n'); 
    var remaining_characters = maxlength - input_value.length;
    $j(input_id + '_counter').html(remaining_characters);
    $j(input_id + '_counter').attr("aria-valuenow", remaining_characters);
}

function generateCharacterCounters() {
  $j(".observe_textlength").each(function(){
      updateCharacterCounter(this);
  });
  $j(".observe_textlength").live("keyup keydown mouseup mousedown change", function(){
      updateCharacterCounter(this);
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
