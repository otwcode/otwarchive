// Expands a group of filters options if one of that type is selected
$j(document).ready(function() {
  showFilters();
  addFilterCloser();
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
  });  //filters each 
}; //showfilters

function addFilterCloser() {
  $j('dl.filters').before( $j('<p class="mobile-shown hidden"><button class="close action" aria-label="close">&times;</button></p>') );
};

function setupMobileFilters() {
  var filters = $j('form.filters');
  var outer = $j('#outer');
  var show_link = $j('#go_to_filters');
  var hide_link = $j(filters).find('.close');
  
  show_link.click(function(e) {
    e.preventDefault();
    filters.removeClass('mobile-hidden');
    outer.addClass('filtering'); 
    hide_link.first().focus();
    filters.trap();
  });
    
  hide_link.each(function() {
    $j(this).click(function(e) {
      e.preventDefault();
      filters.addClass('mobile-hidden');
      show_link.focus();
      outer.removeClass('filtering');
    });
  });
}