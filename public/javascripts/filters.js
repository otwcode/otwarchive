$j(document).ready(function() {
  setupFilterToggles();
  showFilters();
  setupNarrowScreenFilters();
});

// Make tag filter section names into buttons for toggling the sections
// e.g. Fandoms dt should have a button to toggle dd with Fandom tags
// (actual toggling done with setupAccordion in application.js)
function setupFilterToggles() {
  var filter_option = $j('.filters').find('dt.tags');

  filter_option.each(function() {
    var option_list_id = $j(this).next().attr("id");

    $j(this).wrapInner('<button type="button" class="expander" aria-expanded="false" aria-controls="' + option_list_id + '"></button>');
  });

  // change toggle button's aria-expanded value on click
  $j('dt.tags button').on( "click", function() {
    if ($j(this).attr('aria-expanded') == 'false') {
      $j(this).attr('aria-expanded', 'true');
    } else {
      $j(this).attr('aria-expanded', 'false');
    };
  });
}

// Expand a tag filter section if a tag of that type is selected
// e.g. if I filtered for F/F, Include Categories section is expanded
function showFilters() {
  var filters = $j('.filters').find('dd.tags');

  filters.each(function(index, filter) {
    var tags = $j(filter).find('input');
    var option_list_id = $j(filter).attr('id');
    var toggle_container = $j('#toggle_' + option_list_id);
    var toggle_button = $j('[aria-controls="' + option_list_id + '"]');

    tags.each(function(index, tag) {
      if ($j(tag).is(':checked')) {
        $j(filter).removeClass('hidden');
        $j(toggle_container).removeClass('collapsed').addClass('expanded');
        $j(toggle_button).attr('aria-expanded', 'true');
      }
    });
  });
}

function setupNarrowScreenFilters() {
  var filters = $j('form.filters');
  var outer = $j('#outer');
  var show_link = $j('#go_to_filters');
  var hide_link = $j('#leave_filters');

  show_link.click(function(e) {
    e.preventDefault();
    filters.removeClass('narrow-hidden');
    outer.addClass('filtering');
    filters.find(':focusable').first().focus();
    filters.trap();
  });

  hide_link.click(function(e) {
    e.preventDefault();
    outer.removeClass('filtering');
    filters.addClass('narrow-hidden');
    show_link.focus();
  });
}
