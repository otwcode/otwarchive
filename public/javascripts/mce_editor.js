//Init script for calling tinyMCE rich text editor: basic configuration can be done here.

tinyMCE.init({
	theme:"advanced",
	mode:"none",
	editor_selector:"mce-editor",
	plugins : "paste, directionality",
	paste_insert_word_content_callback : "convertWord",
	paste_auto_cleanup_on_paste : true,
    extended_valid_elements : "span[!class]",

    // TinyMCE default behaviour uses CSS styling for most things; this is disabled for now
	// because we're stripping those tags out.
	inline_styles : false,

	// Theme options - using the advanced theme for now and just limiting the buttons used - we may want to create a custom theme in future.
	theme_advanced_buttons1 : "pasteword,|,bold,italic,underline,strikethrough,|,link,unlink,image,|,blockquote,|,hr,|,bullist,numlist,|,justifyleft,justifycenter,|,undo,redo, | ltr, rtl",
	theme_advanced_buttons2 : "",
	theme_advanced_buttons3 : "",
	theme_advanced_toolbar_location : "top",
	theme_advanced_toolbar_align : "left",
	theme_advanced_resizing : true,
	
	//content_css : "css/custom_content.css",
	theme_advanced_font_sizes: "10px,12px,13px,14px,16px,18px,20px",
	font_size_style_values : "10px,12px,13px,14px,16px,18px,20px",

	formats : {
		aligncenter : {block : 'center', exact : true},
        underline : {inline : 'u', exact : true},
        strikethrough : {inline : 'strike', exact : true}
        }

});
 
//Changes the labels and info at the top to Story Text section in _works_form and _chapter_form
  
  //function toggle() {
  //    var ele = document.getElementById("toggleText");
  //    var text = document.getElementById("displayText");
  //    if(ele.style.display == "block") {
  //  		ele.style.display = "none";
  //    text.innerHTML = "Rich text";
  //    }
  //    else {
  //    ele.style.display = "block";
  //    text.innerHTML = "Rich text";
  //    }
  //  }

  function toggle() {
    var elems = new Array();
    elems[0] = document.getElementById("richTextLink");
    elems[1] = document.getElementById("plainTextLink");
    elems[2] = document.getElementById("richTextNotes");
    elems[3] = document.getElementById("plainTextNotes");
    for (i=0; i<elems.length; i++) {
        if (elems[i].style.display == "block" || elems[i].style.display == "inline") {
            elems[i].style.display = "none";
        }
        else {
            if (elems[i].parentNode.className == "rtf-html-switch" ) {
                elems[i].style.display = "inline";
            }
            else {
                elems[i].style.display = "block";
            }
        }
    }
  }

    
//Allows the user to turn the rich text editor off and on. 
  function addEditor(id) {
    tinyMCE.execCommand('mceAddControl', false, id)
  }
        
  function removeEditor(id) {
		tinyMCE.execCommand('mceRemoveControl', false,  id)
  }


function convertWord (type, content) {
    switch (type) {
        // Gets executed before the built in logic performs it's cleanups
        case "before":
            //content = content.toLowerCase(); // Some dummy logic
            //alert(content);
            break;
        // Gets executed after the built in logic performs it's cleanups
        case "after":
            //alert(content);
            content = content.replace(/<!(?:--[\s\S]*?--\s*)?>\s*/g,'');
            //content = content.toLowerCase(); // Some dummy logic
            //alert(content);
            break;
    }
    return content;
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
