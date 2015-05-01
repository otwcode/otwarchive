// Expands a group of filters options if one of that type is selected
$j(document).ready(function() {
  showFilters();
  setupMobileFilters();
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

function setupMobileFilters() {
  var filters = $j('form.filters');
  var outer = $j('#outer');
  var filters_link = $j('#go_to_filters');
  var leave_filters = $j('#leave_filters').find('a');
  var focusable_item = filters.find(':focusable').first();

  filters_link.click(function(e) {
    outer.addClass('filtering'); 
    focusable_item.focus();
  });
  
  leave_filters.click(function() {
    outer.removeClass('filtering');
    filters_link.focus();
  });

}
