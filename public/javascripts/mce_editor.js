//Init script for calling tinyMCE rich text editor: basic configuration can be done here.

tinyMCE.init({
  plugins: "directionality image link paste tabfocus",
  menubar: false,
  toolbar: "bold italic underline strikethrough | link unlink image | blockquote | hr | bullist numlist | alignleft aligncenter alignright alignjustify | undo redo | ltr rtl",
  
  browser_spellcheck: true,
  
  // Disable inline styles, partly because our sanitizer strips them but mostly because strike and u won't work otherwise
  inline_styles: false,
  
  // Restore URLs to their original correct value instead of using shortened broken versions some browsers produce 
  convert_urls: false,
  
  // Add a custom stylesheet with cache busting to override the way text displays in the editor
  content_css: "/stylesheets/tiny_mce_custom.css?" + new Date().getTime(),
  
  // Put the keyboard focus on the text input area rather than the first button when tabbing into the editor (requires tabfocus plugin)
	tabfocus_elements: "tinymce",
	
	// Add HTML tags the editor will accept
	// - b so it doesn't convert to strong
	// - i so it doesn't convert to em
	// - span when it contains a class or dir attribute
	extended_valid_elements: "b, i, span[!class|!dir], strike, u",
	
	// Add HTML tags for the editor to remove, either for cleanup or to make the what-you-see aspect of the editor line up better with the what-you-get-after-the-sanitizer-runs aspect
	invalid_elements: "font",
	
	// Override the default method of styling
	// - align$value: align="$value" attribute replaces style="text-align: $value"
	// - underline: u tag instead of span style="text-decoration:underline"
	// - strikethrough: strike tag instead of span style="text-decoration:line-through"
	// -- strikethrough should also remove del tag
	formats: {
		alignleft: {
		  selector: 'div, h1, h2, h3, h4, h5, h6, img, p, table, td, th, ul, ol, li', 
		  attributes: { align: 'left' }
		},
    aligncenter: {
      selector: 'div, h1, h2, h3, h4, h5, h6, img, p, table, td, th, ul, ol, li',
      attributes: { align: 'center' }
    },
    alignright: {
      selector: 'div, h1, h2, h3, h4, h5, h6, img, p, table, td, th, ul, ol, li', 
      attributes: { align: 'right' }
    },
    alignjustify: {
      selector: 'div, h1, h2, h3, h4, h5, h6, img, p, table, td, th, ul, ol, li', 
      attributes: { align: 'justify' }
    },
    underline: { inline: 'u', exact: true },
    strikethrough: [
      { inline: 'strike', exact: true },
      { inline: 's', remove: "all" },
      { inline: 'del', remove: "all" }
    ]
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

// Toggle between the links
$j(document).ready(function(){
  $j(".rtf-html-switch").removeClass('hidden');
  
  $j(".html-link").addClass('current'); 
  
  $j(".rtf-link").click(function(event){
    addEditor('content');
    $j(this).addClass('current');
    $j('.rtf-notes').removeClass('hidden');
    $j('.html-link').removeClass('current');
    $j('.html-notes').addClass('hidden');
    event.preventDefault();
  });            
  
  $j('.html-link').click(function(event){
    removeEditor('content');
    $j(this).addClass('current');
    $j('.html-notes').removeClass('hidden');
    $j('.rtf-link').removeClass('current');
    $j('.rtf-notes').addClass('hidden');
    event.preventDefault();
  });
})      