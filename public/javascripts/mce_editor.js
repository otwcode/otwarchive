//Init script for calling tinyMCE rich text editor: basic configuration can be done here.

tinyMCE.init({
  plugins: "link image paste tabfocus",
  menubar: false,
  toolbar: "bold italic underline strikethrough | link unlink image | blockquote | hr | bullist numlist | alignleft aligncenter alignright alignjustify | undo redo",
  
  browser_spellcheck: true,
  
  // Restore URLs to their original correct value instead of using shortened broken versions some browsers produce 
  convert_urls: false,
  
  // Add a custom stylesheet with cache busting to override the way text displays in the editor
  content_css: "/stylesheets/tiny_mce_custom.css?" + new Date().getTime(),
  
  // Put the keyboard focus on the text input area rather than the first button when tabbing into the editor (requires tabfocus plugin)
	tabfocus_elements: "tinymce",
	
	// Add HTML tags the editor will accept
	// - span when it contains a class attribute
	// - strike for strikethrough formatting
	extended_valid_elements: "span[!class], strike",
	
	// Override the default method of styling
	// - align$value: align="$value" attribute replaces style="text-align: $value"
	// - underline: u tag replaces span style="text-decoration:underline"
	// - strikethrough: strike tag replaces span style="text-decoration:line-through" -- must add strike to extended_valid_elements
	formats: {
		alignleft: {selector: 'p,h1,h2,h3,h4,h5,h6,td,th,div,ul,ol,li,table,img', attributes: {align: 'left'}},
    aligncenter: {selector: 'p,h1,h2,h3,h4,h5,h6,td,th,div,ul,ol,li,table,img', attributes: {align: 'center'}},
    alignright: {selector: 'p,h1,h2,h3,h4,h5,h6,td,th,div,ul,ol,li,table,img', attributes: {align: 'right'}},
    alignjustify: {selector: 'p,h1,h2,h3,h4,h5,h6,td,th,div,ul,ol,li,table,img', attributes: {align: 'justify'}},
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

// Toggle between the links
$j(document).ready(function(){
  $j(".rtf-html-switch").removeClass('hidden');
  
  $j("#plainTextLink").addClass('current');

  // close! we need a way to toggle between add and remove editor
  //$j(".rtf-html-switch").on('click', 'a', function(event){
    //addEditor('content');
    //$j(this).addClass('current');
    //$j(this).closest('fieldset').children('.rtf-html-instructions').find('span').toggleClass('hidden');
    //$j(this).siblings().removeClass('current');
    //event.preventDefault();
  //});    
  
  $j("#richTextLink").click(function(event){
    addEditor('content');
    $j(this).addClass('current').closest('fieldset').children('.rtf-html-instructions').find('span').toggleClass('hidden');
    $j('#plainTextLink').removeClass('current');
    event.preventDefault();
  });            
  
  $j('#plainTextLink').click(function(event){
    removeEditor('content');
    $j(this).addClass('current').closest('fieldset').children('.rtf-html-instructions').find('span').toggleClass('hidden');
    $j('#richTextLink').removeClass('current');
    event.preventDefault();
  });
})      