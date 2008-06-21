// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// Toggles the chaptered story section of the work form and resets the wip_length field
function showChapteredStoryOptions() {
	var item = document.getElementById('work_wip_length');
	if (item.value == 1) {item.value = '?';}
	else {item.value = 1;}
	Element.toggle('number-of-chapters');
}

function hideCoAuthorField() {
	var item = document.getElementById('co-authors');
	if (item != null) item.style.display='none';
}