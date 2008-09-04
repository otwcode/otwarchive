iBox v1.2.1 - Released August 18, 2006.

Readme.txt

Just a simple file so you know what is going on.

INSTALLATION:
	
1. Upload all files to any directory
2. Include ibox.css and ibox.js on your website.
3. iBox is now ready to be utilized.
	

USAGE:
	
iBox works by looking at what is contained in the <a href=""> tag, and then modifying it as needed. The import variables inside it are:
	- Inside each link (image, HTML page, inner div) you want to appear as an overlay, you have to add rel="ibox" to the <a> tag
	- To set width/height of the inline overlay, use the following: rel="ibox&height=H&width=W" where H and W are the desired height and width respectively
	- To set a caption, use title="X" where X is the desired caption.
	- To differentiate between a JS and non JS user, set the normal href target to the non-JS page, and target="X" (where X is the desired overlay page)
	- To force a type of iBox add the type=X (X=1,2,3) to the rel. (eg if the url is www.example.com/someimage.php and you want it load it as an image, you would have rel="ibox&type=1")
	  - NUMBER CODES FOR THE FILE TYPES : 1 = image, 2 = ajax, 3 = inline
The only required element is rel="ibox" The rest are just extra features.
	
EXAMPLES:
		
	- To load an image as an overlay, set the target to be an image. Eg <a href="images/someimage.jpg" rel="ibox">An Image</a>
	- To load an external page as an overlay, set the target to any page. Eg <a href="somepage.html" rel="ibox&height=300" title="Some Random Caption">A Link</a>
	- To load an existing div on the page, set the target to its div name. Eg <div id="some_content">text inside a div</a> and then <a href="#some_content" rel="ibox">A div</a>
	- A login form - load a page using AJAX as an overlay, or point them to a different page for non-JS users. Eg <a href="/login.html" rel="ibox&height=100&width=250" target="/login-simple.html">Login</a>
	
You can also view the HTML for ibox-test.html to see various examples.


A total of 3 primary files complete the package. They are:
	
ibox.css - the CSS that controls the appearance of the overlay
ibox.js - the Javascript that drives the overlay
images/indicator.gif - the image used to show a user the image is loading

DEMO:
	
images/large and images/small folders
demo/ - ibox-test.html is the main demo page
	

Enjoy!

-Ahmed Farooq
www.iBegin.com