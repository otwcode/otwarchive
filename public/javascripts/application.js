// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//things to do when the page loads
$j(document).ready(function() {
    setupToggled();
    if ($j('form#work-form')) { hideFormFields(); }
    hideHideMe();
    showShowMe();
    handlePopUps();
    attachCharacterCounters();
    setupAccordion();
    setupDropdown();
    updateCachedTokens();

    // add clear to items on the splash page in older browsers
    $j('.splash').children('div:nth-of-type(odd)').addClass('odd');

    // make Share buttons on works and own bookmarks visible
    $j('.actions').children('.share').removeClass('hidden');

    // make Approve buttons on inbox items visible
    $j('#inbox-form, .messages').find('.unreviewed').find('.review').find('a').removeClass('hidden');

    prepareDeleteLinks();
    thermometer();
    initScrollHistory();

    $j('body').addClass('javascript');
});

///////////////////////////////////////////////////////////////////
// Autocomplete
///////////////////////////////////////////////////////////////////

function get_token_input_options(self) {
  return {
    searchingText: self.data('autocomplete-searching-text'),
    hintText: self.data('autocomplete-hint-text'),
    noResultsText: self.data('autocomplete-no-results-text'),
    minChars: self.data('autocomplete-min-chars'),
    queryParam: "term",
    preventDuplicates: true,
    tokenLimit: self.data('autocomplete-token-limit'),
    liveParams: self.data('autocomplete-live-params'),
    makeSortable: self.data('autocomplete-sortable')
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
          method = $.parseJSON(self.data('autocomplete-method'));
      } catch (err) {
          method = self.data('autocomplete-method');
      }
      self.tokenInput(method, token_input_options);
    });
  });
}

///////////////////////////////////////////////////////////////////

// expand, contract, shuffle
jQuery(function($){
  $(".expand").each(function(){
    // start by hiding the list in the page
    list = $($(this).data("action-target"));
    if (!list.data("force-expand") || list.children().size() > 25 || list.data("force-contract")) {
      list.hide();
      $(this).show();
    } else {
      // show the shuffle and contract button only
      $(this).nextAll(".shuffle").show();
      $(this).next(".contract").show();
    }

    // set up click event to expand the list
    $(this).click(function(event){
      list = $($(this).data("action-target"));
      list.show();

      // show the contract & shuffle buttons and hide us
      $(this).next(".contract").show();
      $(this).nextAll(".shuffle").show();
      $(this).hide();
    });
  });

  $(".contract").each(function(){
    $(this).click(function(event){
      // hide the list when clicked
      list = $($(this).data("action-target"));
      list.hide();

      // show the expand and shuffle buttons and hide us
      $(this).prev(".expand").show();
      $(this).nextAll(".shuffle").hide();
      $(this).hide();
    });
  });

  $(".shuffle").each(function(){
    // shuffle the list's children when clicked
    $(this).click(function(event){
      list = $($(this).data("action-target"));
      list.children().shuffle();
    });
  });

  $(".expand_all").each(function(){
      target = "." + $(this).data("target-class");
      $(this).click(function(event) {
        $(this).closest(target).find(".expand").click();
     });
  });

  $(".contract_all").each(function(){
     target = "." + $(this).data("target-class");
     $(this).click(function(event) {
        $(this).closest(target).find(".contract").click();
     });
  });
});

// check all or none within the parent fieldset, optionally with a string to match on the id attribute of the checkboxes
// stored in the "data-checkbox-id-filter" attribute on the all/none links.
// allow for some flexibility by checking the next and previous fieldset if the checkboxes aren't in this one
jQuery(function($){
  $('.check_all').each(function(){
    $(this).click(function(event){
      var filter = $(this).data('checkbox-id-filter');
      var checkboxes;
      if (filter) {
        checkboxes = $(this).closest('fieldset').find('input[id*="' + filter + '"][type="checkbox"]');
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
      var filter = $(this).data('checkbox-id-filter');
      var checkboxes;
      if (filter) {
        checkboxes = $(this).closest('fieldset').find('input[id*="' + filter + '"][type="checkbox"]');
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
// - You don't have to use div and a, those are just examples. Anything you put the toggled and _open/_close classes on will work.
// - If you want the toggled item not to be visible to users without JavaScript by default, add the class "hidden" to the toggled item as well.
//   (and you can then add an alternative link for them using <noscript>)
// - Generally reserved for toggling complex elements like bookmark forms and challenge sign-ups; for simple elements like lists use setupAccordion.
function setupToggled(){
  $j('.toggled').filter(function(){
    return $j(this).closest('.userstuff').length === 0;
  }).each(function(){
    var node = $j(this);
    var open_toggles = $j('.' + node.attr('id') + "_open");
    var close_toggles = $j('.' + node.attr('id') + "_close");

    if (node.hasClass('open')) {
      close_toggles.each(function(){$j(this).show();});
      open_toggles.each(function(){$j(this).hide();});
    } else {
      node.hide();
      close_toggles.each(function(){$j(this).hide();});
      open_toggles.each(function(){$j(this).show();});
    }

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
  var section = $j(link).closest("." + class_of_section_to_remove);
  section.find(".required input, .required textarea").each(function(index) {
    var element = eval('validation_for_' + $j(this).attr('id'));
    element.disable();
  });
  section.hide();
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
  if ($j('form#work-form') != null) {
    var toHide = ['#co-authors-options', '#front-notes-options', '#end-notes-options', '#chapters-options',
      '#parent-options', '#series-options', '#backdate-options', '#override_tags-options'];

    $j.each(toHide, function(index, name) {
      if ($j(name)) {
        if (!($j(name + '-show').is(':checked'))) { $j(name).addClass('hidden'); }
      }
    });
    $j('form#work-form').className = $j('form#work-form').className;
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

const SCROLL_DISTANCE_MINIMUM_FOR_HISTORY = 300;
const SCROLL_HISTORY_MAX_SIZE = 20;

function getScrollHistory(return_default = true) {
  const scroll_history_json = window.localStorage.getItem("scroll position history for " + new URL(document.URL).pathname);
  var scroll_history = return_default ? {"index": 0, "list": [0]} : undefined;

  try {
    if (scroll_history_json !== null) {
      scroll_history = JSON.parse(
        scroll_history_json,
        // validate shape on load
        function (key, value) {
          // we only care about the root object
          if (key !== "") {
            return value;
          }

          if (
            value.list instanceof Array
            && value.index >= 0
            && value.index < value.list.length
          ) {
            return value;
          }

          return undefined;
        }
      );
    }
  } catch (e) {
    if (e instanceof SyntaxError) {
      // we can ignore this and return the default scroll_history
    } else {
      throw e;
    }
  }

  return scroll_history;
}

function saveScrollHistory(scroll_history) {
  try {
    window.localStorage.setItem("scroll position history for " + new URL(document.URL).pathname, JSON.stringify(scroll_history));
  } catch (e) {
    // swallow quota exceeded errors to avoid breaking the page; we just break scroll history
    if (e instanceof DOMException && e.name === "QuotaExceededError") {
      console.error("localStorage quota exceeded; not saving scroll history", scroll_history)
      return;
    }
    throw e;
  }

}

function scrollHistoryPreferencePrompt() {
  try {
    window.localStorage.setItem("__storage_test_of_at_least_64_bytes__", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    window.localStorage.removeItem("__storage_test_of_at_least_64_bytes__");
  } catch (e) {
    // something wrong with localStorage, no point prompting if we can't even save the preference
    return;
  }

  const dialog = document.createElement("dialog");
  const dialog_p = document.createElement("p");
  const dialog_yes = document.createElement("button");
  const dialog_no = document.createElement("button");

  dialog_p.innerText = SCROLL_HISTORY_DIALOG_PROMPT;
  dialog.appendChild(dialog_p);

  dialog_yes.innerText = SCROLL_HISTORY_DIALOG_YES;
  // this can throw if we somehow ran out of storage between the check at the top of this function and now, but that seems a reasonable case for an unhandled exception
  dialog_yes.onclick = (e) => { dialog.close(); window.localStorage.setItem("save scroll history?", "yes"); actuallyInitScrollHistory(); };
  dialog.appendChild(dialog_yes);

  dialog_no.innerText = SCROLL_HISTORY_DIALOG_NO;
  // this can throw, similar to above
  dialog_no.onclick = (e) => { dialog.close(); window.localStorage.setItem("save scroll history?", "no"); };
  dialog.appendChild(dialog_no);

  document.querySelector("body").appendChild(dialog);

  dialog.showModal();
}

function initScrollHistory() {
  try {
    const x = "__storage_test__";
    window.localStorage.setItem(x, x);
    window.localStorage.removeItem(x);
  } catch (e) {
    // localStorage is not available, nothing more to do
    delete document.querySelector("body").dataset.scrollHistoryEnabled;
    return;
  }

  if (!('onscrollend' in window)) {
    // onscrollend event is not supported, nothing more to do
    return;
  }

  const preference = window.localStorage.getItem("save scroll history?");

  if (preference === null && document.querySelector("body").dataset.scrollHistoryEnabled !== undefined) {
    // Prompt user for preference; this will call actuallyInitScrollHistory() if appropriate.
    scrollHistoryPreferencePrompt();
  } else if (preference === "yes") {
    actuallyInitScrollHistory();
  } else {
    delete document.querySelector("body").dataset.scrollHistoryEnabled;
  }
}

function actuallyInitScrollHistory() {
  const scroll_history = getScrollHistory(false);
  if (scroll_history !== undefined) {
    window.scrollTo({"top": scroll_history.list[scroll_history.index], behavior: "instant"});
  }

  document.addEventListener("scrollend", function() {
    if (document.querySelector("body").dataset.scrollHistoryEnabled === undefined) {
      return;
    }

    const scroll_history = getScrollHistory();
    const previous_position = scroll_history.list[scroll_history.index];
    const new_position = document.scrollingElement?.scrollTop ?? 0;

    if (Math.abs(new_position - previous_position) < SCROLL_DISTANCE_MINIMUM_FOR_HISTORY) {
      // If we haven't scrolled that far, don't save the position
      return;
    }

    // if we're at an index other than zero, we're saving new history,
    // so we gotta trash the old stuff.
    // this whole section will be a no-op if scroll_history.index === 0.
    for (var i = 0; i < scroll_history.index; i++) {
      scroll_history.list.shift();
    }
    scroll_history.index = 0;

    // add the current position to the list.
    // unshift() returns the new length of the array; if that's > max size,
    // pop something off the end.
    if (scroll_history.list.unshift(new_position) > SCROLL_HISTORY_MAX_SIZE) {
      scroll_history.list.pop();
    }

    saveScrollHistory(scroll_history);
  });
}

function scrollHistoryGoBack() {
  var scroll_history = getScrollHistory();

  // If we have no history, or if we're at the end of history, bail
  if (scroll_history.list.length < 1 || scroll_history.index === scroll_history.list.length - 1) {
    return;
  }

  delete document.querySelector("body").dataset.scrollHistoryEnabled;
  scroll_history.index = scroll_history.index + 1; // we know this is a valid index, we checked above
  document.scrollingElement.scrollTo({top: scroll_history.list[scroll_history.index], behavior: "smooth"});
  document.querySelector("body").dataset.scrollHistoryEnabled = "true";

  saveScrollHistory(scroll_history);
}

function scrollHistoryGoForward() {
  var scroll_history = getScrollHistory();

  // If we have no history, or if we're at the start of history, bail
  if (scroll_history.list.length < 1 || scroll_history.index === 0) {
    return;
  }

  delete document.querySelector("body").dataset.scrollHistoryEnabled;
  scroll_history.index = scroll_history.index - 1; // we know this is a valid index, we checked above
  document.scrollingElement.scrollTo({top: scroll_history.list[scroll_history.index], behavior: "smooth"});
  document.querySelector("body").dataset.scrollHistoryEnabled = "true";

  saveScrollHistory(scroll_history);
}

// add attributes that are only needed in the primary menus and when JavaScript is enabled
function setupDropdown(){
  $j('#header').find('.dropdown').attr("aria-haspopup", true);
  $j('#header').find('.dropdown, .dropdown .actions').children('a').attr({
    'class': 'dropdown-toggle',
    'data-toggle': 'dropdown',
    'data-target': '#'
  });
  $j('.dropdown').find('.menu').addClass("dropdown-menu");
}

// Accordion-style collapsible widgets
// The pane element can be shown or hidden using the expander (link)
// Apply hidden to the pane element if it shouldn't be visible when JavaScript is disabled
// Typical set up:
// <li aria-haspopup="true">
//  <a href="#">Expander</a>
//  <div class="expandable">
//    foo!
//  </div>
// </li>
function setupAccordion() {
  $j(".expandable").filter(function() {
    return $j(this).closest(".userstuff").length === 0;
  }).each(function() {
    var pane = $j(this);
    // hide the pane element if it's not hidden by default
    if ( !pane.hasClass("hidden") ) {
      pane.addClass("hidden");
    };

    // make the expander visible
    // add the default collapsed state
    // make it do the expanding and collapsing
    pane.prev().removeClass("hidden").addClass("collapsed").click(function(e) {
      var expander = $j(this);
      if (expander.attr('href') == '#') {
        e.preventDefault();
      };

      // change the classes upon clicking the expander
      expander.toggleClass("collapsed").toggleClass("expanded").next().toggleClass("hidden");
    });
  });
}

// Remove the /confirm_delete portion of delete links so user who have JS enabled will
// be able to delete items via hyperlink (per rails/jquery-ujs) rather than a dedicated
// form page.
function prepareDeleteLinks() {
  $j('a[href$="/confirm_delete"][data-confirm]').each(function(){
    this.href = this.href.replace(/\/confirm_delete$/, "");
    $j(this).attr("data-method", "delete");
  });

  // Removing non-default orphan_account pseuds from works
  $j('a[href$="/confirm_remove_pseud"][data-confirm]').each(function() {
    this.href = this.href.replace(/\/confirm_remove_pseud$/, "/remove_pseud");
    $j(this).attr("data-method", "put");
  });

  // For purging assignments in gift exchanges. This is only on one page and easy to
  // check, so don't worry about adding a fallback data-confirm message.
  $j('a[href$="/confirm_purge"][data-confirm]').each(function() {
    this.href = this.href.replace(/\/confirm_purge$/, "/purge");
    $j(this).attr("data-method", "post");
  });
}

/// Kudos
$j(document).ready(function() {
  $j('input#kudo_submit').on("click", function(event) {
    event.preventDefault();

    $j.ajax({
      type: 'POST',
      url: '/kudos.js',
      data: jQuery('#new_kudo').serialize(),
      error: function(jqXHR, textStatus, errorThrown) {
        var msg = 'Sorry, we were unable to save your kudos';

        // When we hit the rate limit, the response from Rack::Attack is a plain text 429.
        if (jqXHR.status == "429") {
          msg = "Sorry, you can't leave more kudos right now. Please try again in a few minutes.";
        } else {
          var data = $j.parseJSON(jqXHR.responseText);
          if (data.error_message) {
            msg = data.error_message;
          }
        }

        $j('#kudos_message').addClass('kudos_error').text(msg);
      },
      success: function(data) {
        $j('#kudos_message').addClass('notice').text('Thank you for leaving kudos!');
      }
    });
  });

  // Scroll to the top of the comments section when loading additional pages via Ajax in comment pagination.
  $j('#comments_placeholder').on('click.rails', '.pagination a[data-remote]', function(e){
    $j.scrollTo('#comments_placeholder');
  });

  // Scroll to the top of the comments section when loading comments via AJAX
  $j("#show_comments_link_top").on('click.rails', 'a[href*="show_comments"]', function(e){
    $j.scrollTo('#comments');
  });
});

// For simple forms that appear to toggle between creating and destroying records
// e.g. favorite tags, subscriptions
// <form> needs ajax-create-destroy class, data-create-value, data-destroy-value
// data-create-value: text of the button for creating, e.g. Favorite, Subscribe
// data-destroy-value: text of button for destroying, e.g. Unfavorite, Unsubscribe
// controller needs item_id and item_success_message for save success and
// item_success_message for destroy success
$j(document).ready(function() {
  $j('form.ajax-create-destroy').on("click", function(event) {
    event.preventDefault();

    var form = $j(this);
    var formAction = form.attr('action');
    var formSubmit = form.find('[type="submit"]');
    var createValue = form.data('create-value');
    var destroyValue = form.data('destroy-value');
    var flashContainer = $j('.flash');

    $j.ajax({
      type: 'POST',
      url: formAction,
      data: form.serialize(),
      dataType: 'json',
      success: function(data) {
        flashContainer.removeClass('error').empty();
        if (data.item_id) {
          flashContainer.addClass('notice').html(data.item_success_message);
          formSubmit.val(destroyValue);
          form.append('<input name="_method" type="hidden" value="delete">');
          form.attr('action', formAction + '/' + data.item_id);
        } else {
          flashContainer.addClass('notice').html(data.item_success_message);
          formSubmit.val(createValue);
          form.find('input[name="_method"]').remove();
          form.attr('action', formAction.replace(/\/\d+/, ''));
        }
      },
      error: function(xhr, textStatus, errorThrown) {
        flashContainer.empty();
        flashContainer.addClass('error notice');
        try {
          jQuery.parseJSON(xhr.responseText);
        } catch (e) {
          flashContainer.append("We're sorry! Something went wrong.");
          return;
        }
        $j.each(jQuery.parseJSON(xhr.responseText).errors, function(index, error) {
          flashContainer.append(error + " ");
        });
      }
    });
  });
});

// For simple forms that update or destroy records and remove them from a listing
// e.g. delete from history, mark as read, delete invitation request
// <form> needs ajax-remove class
// controller needs item_success_message
$j(document).ready(function() {
  $j('form.ajax-remove').on("click", function(event) {
    event.preventDefault();

    var form = $j(this);
    var formAction = form.attr('action');
    // The record we're removing is probably in a list, but might be in a table
    if (form.closest('li.group').length !== 0) {
      formParent = form.closest('li.group');
    } else { formParent = form.closest('tr'); };
    // The admin div does not hold a flash container
    var parentContainer = formParent.closest('div:not(.admin)');
    var flashContainer = parentContainer.find('.flash');

    $j.ajax({
      type: 'POST',
      url: formAction,
      data: form.serialize(),
      dataType: 'json',
      success: function(data) {
        flashContainer.removeClass('error').empty();
        flashContainer.addClass('notice').html(data.item_success_message);
      },
      error: function(xhr, textStatus, errorThrown) {
        flashContainer.empty();
        flashContainer.addClass('error notice');
        try {
          jQuery.parseJSON(xhr.responseText);
        } catch (e) {
          flashContainer.append("We're sorry! Something went wrong.");
          return;
        }
        $j.each(jQuery.parseJSON(xhr.responseText).errors, function(index, error) {
          flashContainer.append(error + " ");
        });
      }
    });

    $j(document).ajaxSuccess(function() {
      formParent.slideUp(function() {
        $j(this).remove();
      });
    });
  });
});

// FUNDRAISING THERMOMETER adapted from http://jsfiddle.net/GeekyJohn/vQ4Xn/
function thermometer() {
  var banners = $j('.announcement').filter(function(){
                  return $j(this).closest('.userstuff').length === 0;
                });

  banners.has('.goal').each(function(){
    var banner_content = $j(this).find('blockquote');
        banner_goal_text = banner_content.find('span.goal').html();
        banner_progress_text = banner_content.find('span.progress').html();
        if ($j(this).find('span.goal').hasClass('stretch')){
          stretch = true
        } else { stretch = false }

        goal_amount = parseFloat(banner_goal_text.replace(/\.(?![0-9])|[^\.0-9]/g, ''));
        progress_amount = parseFloat(banner_progress_text.replace(/\.(?![0-9])|[^\.0-9]/g, ''));
        percentage_amount = Math.min( Math.round(progress_amount / goal_amount * 1000) / 10, 100);

    // add thermometer markup (with amounts)
    banner_content.append('<div class="thermometer-content"><div class="thermometer"><div class="track"><div class="goal"><span class="amount">' + banner_goal_text +'</span></div><div class="progress"><span class="amount">' + banner_progress_text + '</span></div></div></div></div>');

    // set the progress indicator
    // darker green for over 100% stretch goals
    // green for 100%
    // yellow-green for 85-99%
    // yellow for 30-84%
    // orange for 0-29%
    if ( stretch == true ) {
      banner_content.find('div.track').css({
        'background': '#8eb92a',
        'background-image': 'linear-gradient(to bottom, #bfd255 0%, #8eb92a 50%, #72aa00 51%, #9ecb2d 100%)'
      });
      banner_content.find('div.progress').css({
        'width': percentage_amount + '%',
        'background': '#4d7c10',
        'background-image': 'linear-gradient(to bottom, #6e992f 0%, #4d7c10 50%, #3b7000 51%, #5d8e13 100%)'
      });
    } else if (percentage_amount >= 100) {
      banner_content.find('div.progress').css({
        'width': '100%',
        'background': '#8eb92a',
        'background-image': 'linear-gradient(to bottom, #bfd255 0%, #8eb92a 50%, #72aa00 51%, #9ecb2d 100%)'
      });
    } else if (percentage_amount >= 85) {
      banner_content.find('div.progress').css({
        'width': percentage_amount + '%',
        'background': '#d2e638',
        'background-image': 'linear-gradient(to bottom, #e6f0a3 0%, #d2e638 50%, #c3d825 51%, #dbf043 100%)'
      });
    } else if (percentage_amount >= 30) {
      banner_content.find('div.progress').css({
        'width': percentage_amount + '%',
        'background': '#fccd4d',
        'background-image': 'linear-gradient(to bottom, #fceabb 0%, #fccd4d 50%, #f8b500 51%, #fbdf93 100%)'
      });
    } else {
      banner_content.find('div.progress').css({
        'width': percentage_amount + '%',
        'background': '#f17432',
        'background-image': 'linear-gradient(to bottom, #feccb1 0%, #f17432 50%, #ea5507 51%, #fb955e 100%)'
      });
    }
  });
}

function updateCachedTokens() {
  // we only do full page caching when users are logged out
  if ($j('#small_login').length > 0) {
    $j.getJSON("/token_dispenser.json", function( data ) {
      var token = data.token;
      // set token on fields
      $j('input[name=authenticity_token]').each(function(){
        $j(this).attr('value', token);
      });
      $j('meta[name=csrf-token]').attr('content', token);
      $j.event.trigger({ type: "loadedCSRF" });
    });
  } else {
    $j.event.trigger({ type: "loadedCSRF" });
  }
}
