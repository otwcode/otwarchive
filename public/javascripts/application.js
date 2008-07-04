// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// Toggles the chaptered story section of the work form and resets the wip_length field
function showChapteredStoryOptions() {
	var item = document.getElementById('work_wip_length');
	if (item.value == 1) {item.value = '?';}
	else {item.value = 1;}
	Element.toggle('number-of-chapters');
}

// Hides expandable form field options if Javascript is enabled
function hideFormFields() {
	var coAuthors = document.getElementById('co-authors');
	if (coAuthors != null) coAuthors.style.display='none';
	 
	if (document.storyForm != null) var isWip = document.storyForm.isWip;
	var chapteredOptions = document.getElementById('number-of-chapters');
	if (isWip != null && chapteredOptions != null && !isWip.checked) chapteredOptions.style.display='none';
}