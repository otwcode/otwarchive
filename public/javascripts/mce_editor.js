//Init script for calling tinyMCE rich text editor: basic configuration can be done here.

tinyMCE.init({
  plugins: "media directionality image legacyoutput link paste tabfocus",
  menubar: false,
  toolbar: "bold italic underline strikethrough | link unlink image media | blockquote | hr | bullist numlist | alignleft aligncenter alignright alignjustify | undo redo | ltr rtl",
  
  browser_spellcheck: true,
  
  // Restore URLs to their original correct value instead of using shortened broken versions some browsers produce 
  convert_urls: false,
  
  // Add a custom stylesheet with cache busting to override the way text displays in the editor
  content_css: "/stylesheets/tiny_mce_custom.css?" + new Date().getTime(),
  
  // Put the keyboard focus on the text input area rather than the first button when tabbing into the editor (requires tabfocus plugin)
	tabfocus_elements: "tinymce",
	
	// Add HTML tags the editor will accept
	// - b so it doesn't convert back and forth between b and strong when toggling editors due to the legacyoutput plugin
	// - i so it doesn't convert back and forth between i and em when toggling editors due to the legacyoutput plugin
	// - span when it contains a class or dir attribute
	extended_valid_elements: "b,i,span[!class|!dir]"
  
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