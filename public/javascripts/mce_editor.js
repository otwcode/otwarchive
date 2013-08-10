//Init script for calling tinyMCE rich text editor: basic configuration can be done here.

tinyMCE.init({
  selector: ".mce-editor",
  plugins: "link image paste",
  menubar: false,
  toolbar: "bold italic underline strikethrough | link unlink image | blockquote | hr | bullist numlist | alignleft aligncenter | undo redo",
	inline_styles: false,
	extended_valid_elements: "span[!class], strike",
	
	// To use the deprecated strike tag for strikethrough, don't forget to extend the valid elements.
	formats: {
		aligncenter: {block: 'center', exact: true},
    underline: {inline: 'u', exact: true},
    strikethrough: {inline: 'strike', exact: true}
  }
});

// Allow the user to turn the rich text editor off and on. 
function addEditor(id) {
  tinyMCE.execCommand('mceAddEditor', false, id)
}
        
function removeEditor(id) {
	tinyMCE.execCommand('mceRemoveEditor', false, id)
}
