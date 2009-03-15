$(document).ready(function() {
	$(".tablesorter").tablesorter({
		sortColumn: 'name',			// Integer or String of the name of the column to sort by.
		cssAsc: 'sort asc',         // class name for ascending sorting action to header
		cssDesc: 'sort desc',       // class name for descending sorting action to header
		headerClass: 'header'		// class name for headers (th's)
	});
  $('#tabs-container > ul').tabs();
});

