// Expands a group of filters options if one of that type is selected
$j(document).ready(function() {
  showFilters();
  setupNarrowScreenFilters();
});

function showFilters() {
  var filters = $j('dd.tags');

  filters.each(function(index, filter) {
    var tags = $j(filter).find('input');
    var node = $j(filter);
    var open_toggles = $j('.' + node.attr('id') + "_open");
    var close_toggles = $j('.' + node.attr('id') + "_close");

    tags.each(function(index, tag) {
      if($j(tag).is(':checked')) {
        $j(filter).show();
        $j(open_toggles).hide();
        $j(close_toggles).show();
      } //is checked
    }); //tags each
  }); //filters each 
} //showfilters

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
