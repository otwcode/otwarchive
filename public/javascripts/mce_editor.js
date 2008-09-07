//Init script for calling tinyMCE rich text editor: basic configuration can be done here.

tinyMCE.init({
	theme:"advanced",
	mode:"none",
	editor_selector:"mce-editor",
	plugins : "paste",
	paste_insert_word_content_callback : "convertWord",
	paste_auto_cleanup_on_paste : true,


	
	// Theme options - using the advanced theme for now and just limiting the buttons used - we may want to create a custom theme in future.
	theme_advanced_buttons1 : "pasteword,|,bold,italic,underline,strikethrough,fontselect,fontsizeselect,forecolor,|,link,unlink,image,|,outdent,indent,blockquote,|,bullist,numlist,|,justifyleft,justifycenter,justifyright,justifyfull,|,undo,redo",
	theme_advanced_buttons2 : "",
	theme_advanced_buttons3 : "",
	theme_advanced_toolbar_location : "top",
	theme_advanced_toolbar_align : "left",
	theme_advanced_resizing : true

});

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




