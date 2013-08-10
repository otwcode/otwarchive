//Init script for calling tinyMCE rich text editor: basic configuration can be done here.

tinyMCE.init({
	content_css: "/stylesheets/tiny_mce_custom.css?" + new Date().getTime(),
	browser_spellcheck: true,
  plugins: "link image paste",
  menubar: false,
  toolbar: "bold italic underline strikethrough | link unlink image | blockquote | hr | bullist numlist | alignleft aligncenter | undo redo",
	extended_valid_elements: "span[!class], strike",
	// Override the default method of styling
	// - aligncenter: center tag replaces span style="text-align:center"
	// - underline: u tag replaces span style="text-decoration:underline"
	// - strikethrough: strike tag replaces span style="text-decoration:line-through" -- must add strike to extended_valid_elements
	formats: {
		aligncenter: {block: 'center', exact: true},
    underline: {inline: 'u', exact: true},
    strikethrough: {inline: 'strike', exact: true}
  }
});

// Require the user to turn the RTE on instead of loading automatically using selector option 
function addEditor(id) {
  tinyMCE.execCommand('mceAddEditor', false, id)
}
 
// Let the user turn the RTE back off        
function removeEditor(id) {
	tinyMCE.execCommand('mceRemoveEditor', false, id)
}