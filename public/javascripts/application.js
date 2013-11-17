// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//things to do when the page loads
$j(document).ready(function() {
    setupToggled();
    if ($j('#work-form')) { hideFormFields(); };
    hideHideMe();
    showShowMe();
    handlePopUps();
    attachCharacterCounters();
    setupAccordion();
    $j('#hide-notice-banner').click(function(e){
      $j('#notice-banner').hide();
      e.preventDefault();
    });
    setupDropdown();

    // replace all GET delete links with their AJAXified equivalent
    $j('a[href$="/confirm_delete"]').each(function(){
        this.href = this.href.replace(/\/confirm_delete$/, "");
        $j(this).attr("data-method", "delete").attr("data-confirm", "Are you sure? This CANNOT BE UNDONE!");
    });

    // remove final comma from comma lists in older browsers
    $j('.commas li:last-child').addClass('last');

    // make Share buttons on works and own bookmarks visible
    $j('.actions').children('.share').removeClass('hidden');
});

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
var input = $j('input.autocomplete');
if (input.livequery) {
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
}

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
// allow for some flexibility by checking the next and previous fieldset if the checkboxes aren't in this one
jQuery(function($){
  $('.check_all').each(function(){
    $(this).click(function(event){
      var filter = $(this).attr('checkbox_name_filter');
      var checkboxes;
      if (filter) {
        checkboxes = $(this).closest('fieldset').find('input[name*="' + filter + '"][type="checkbox"]');
      } else {
        checkboxes = $(this).closest("fieldset").find(':checkbox');
        if (checkboxes.length == 0) {
          checkboxes = $(this).closest("fieldset").next().find(':checkbox');
          if (checkboxes.length == 0) {
            checkboxes = $(this).closest("fieldset").prev().find(':checkbox');
          }
        }
      }
      checkboxes.prop('checked', true);
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
        if (checkboxes.length == 0) {
          checkboxes = $(this).closest("fieldset").next().find(':checkbox');
          if (checkboxes.length == 0) {
            checkboxes = $(this).closest("fieldset").prev().find(':checkbox');
          }
        }
      }
      checkboxes.prop('checked', false);
      event.preventDefault();
    });
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
// - Generally reserved for toggling complex elements like bookmark forms and challenge sign-ups; for simple elements like lists use setupAccordion
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
        if (element_id != 'chapters-options' && element_id != 'backdate-options') {
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

function attachCharacterCounters() {
    var countFn = function() {
        var counter = (function(input) {
                /* Character-counted inputs do not always have the same hierarchical relationship
                to their associated counter elements in the DOM, and some cc-inputs have
                duplicate ids. So search for the input's associated counter element first by id,
                then by checking the input's siblings, then by checking its cousins. */
                var cc = $j('.character_counter [id='+input.attr('id')+'_counter]');
                if (cc.length === 1) { return cc; } // id search, use attribute selector rather 
                // than # to check for duplicate ids

                cc = input.nextAll('.character_counter').first().find('.value'); // sibling search
                if (cc.length) { return cc; } 

                var parent = input.parent(); // 2 level cousin search
                for (var i = 0; i < 2; i++) {
                    cc = parent.nextAll('.character_counter').find('.value');                    
                    if (cc.length) { return cc; }
                    parent = parent.parent();
                }

                return $j(); // return empty jquery element if search found nothing
            })($j(this)),
            max = parseInt(counter.attr('data-maxlength'), 10),
            val = $j(this).val().replace(/\r\n/g,'\n').replace(/\r|\n/g,'\r\n'),
            remaining = max - val.length;

        counter.html(remaining).attr("aria-valuenow", remaining);
    };

    $j(document).on('keyup keydown mouseup mousedown change', '.observe_textlength', countFn);
    $j('.observe_textlength').each(countFn);
}

// prevent double submission for JS enabled
jQuery.fn.preventDoubleSubmit = function() {
  jQuery(this).submit(function() {
    if (this.beenSubmitted)
      return false;
    else
      this.beenSubmitted = true;
  });
};

// add attributes that are only needed in the primary menus and when JavaScript is enabled
function setupDropdown(){
  $j('#header .dropdown').attr("aria-haspopup", true);
  $j('#header .dropdown > a, #header .dropdown .actions > a').attr({
    'class': 'dropdown-toggle',
    'data-toggle': 'dropdown',
    'data-target': '#'
  });
  $j('.dropdown .menu').addClass("dropdown-menu");
  $j('.dropdown .menu li').attr("role", "menu-item");
}

// Accordion-style collapsible widgets
// The pane element can be showen or hidden using the expander (link)
// Apply hidden to the pane element if it shouldn't be visible when JavaScript is disabled
// Typical set up:
// <li aria-haspopup="true">
//  <a href="#">Expander</a>
//  <div class="expandable">
//    foo!
//  </div>
// </li>
function setupAccordion() {
  var panes = $j(".expandable");
  panes.hide().prev().removeClass("hidden").addClass("expanded").click(function(e) {
    var expander = $j(this);
    if (expander.attr('href') == '#') {
      e.preventDefault();
    }
    expander.toggleClass("expanded").toggleClass("collapsed").next().toggle();
  });
}
