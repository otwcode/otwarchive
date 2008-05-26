// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// These two functions allow you to collapse/show comments where necessary                                     
function hideComments() { 
	if (location.hash == "") {
		var item = document.getElementById('comments');
		if (item != null) item.style.display='none';
	} 
}

function showComments() { 
	var item = document.getElementById('comments');
	if (item != null) item.style.display='inline';
}