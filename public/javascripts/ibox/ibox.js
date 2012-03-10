/********************************************************
For more info & download: http://www.ibegin.com/blog/p_ibox.html
Created for iBegin.com - local search done right
MIT Licensed Style
*********************************************************/
var indicator_img_path = "/images/indicator.gif",
    indicator_img_html = "<img name=\"ibox_indicator\" src=\""+indicator_img_path+"\" alt=\"Loading...\" style=\"width:128px;height:128px;\"/>", // don't remove the name
    ibAttr = "rel",     // our attribute identifier for our iBox elements
    imgPreloader = new Image(), // create an preloader object
    loadCancelled = false,
    shown = false, // whether the lightbox is currently visible
    scrollBarW, // width of browser's vertical scrollbar
    arrowKeyDown = false, // used for enabling keyboard scrolling for Opera
    scrollTimer; // used for enabling keyboard scrolling for Opera

function init_ibox() {
    // no iboxes for dead browsers
    /*@cc_on
    @if (@_jscript_version < 5.7)
        return;
    @end
    @*/

    createIbox(document.getElementsByTagName("body")[0]); //create our ibox

    //    elements here start the look up from the start non <a> tags
    //var docRoot = (document.all) ? document.all : document.getElementsByTagName("*");
    
    // Or make sure we only check <a> tags
    var docRoot = document.getElementsByTagName("a");

    var e;
    for (var i = 0; i < docRoot.length - 1; i++) {
        e = docRoot[i];
        if(e.getAttribute(ibAttr)) {
            var t = e.getAttribute(ibAttr);
            if ((t.indexOf("ibox") != -1)  ||  t.toLowerCase() == "ibox") { // check if this element is an iBox element
                e.onclick = function() { // rather assign an onclick event
                    var t = this.getAttribute(ibAttr),
                        params = parseQuery(t.substr(5,999)),
                        url = this.href;
                        
                    if(this.target != "") {url = this.target} 

                    var title = this.title;

                    if(showIbox(url,title,params)) {
                        showBG();
                    }
                    return false;
                };
            }
        }
     }
    
    // listen for ESC key to close ibox
    addEvent(document.body, "keyup", function(e) {
        e = e || window.event;
        var target = e.target || e.srcElement;
        if (e.keyCode == 27 && 
            target.tagName != "SELECT" &&
            shown) {
                hideIbox();
                hideIndicator();
                loadCancelled = true;
            }
    });
    
    // listen for clicks on ibox bg to close ibox
    addEvent(getElem("ibox_w"), "click", function () {
        if (shown) {
            hideIbox();
            hideIndicator();
            loadCancelled = true;
        }    
    });
}

showBG = function() {
    var box_w = getElem('ibox_w');    
    box_w.style.visibility = "";
    box_w.style.opacity = "0.6";
}

hideBG = function() {
    var box_w = getElem('ibox_w');
    setTimeout(function() { box_w.style.opacity = "0"; }, 0); // Firefox seems to need a delay
    setTimeout(function() { box_w.style.visibility = "hidden"; }, 400); // time should match transition-duration
}

showIndicator = function() {
    var ibox_p = getElem('ibox_progress');
    ibox_p.style.display = "";
    posToCenter(ibox_p);
    ibox_p.onclick = function() {hideIbox();hideIndicator();loadCancelled = true;}
}

hideIndicator = function() {
    var ibox_p = getElem('ibox_progress');
    ibox_p.style.display = "none";
    ibox_p.onclick = null;
}

createIbox = function(elem) {
    // a trick on just creating an ibox wrapper then doing an innerHTML on our root ibox element
    var strHTML = "<div id=\"ibox_w\" aria-live=\"assertive\" aria-relevant=\"additions removals text\" role=\"dialog\" tabindex=\"-1\" style=\"visibility:hidden;\"></div>";
    strHTML +=    "<div id=\"ibox_progress\" aria-busy=\"true\" style=\"display:none;\">" +indicator_img_html +"</div>";
    strHTML +=    "<div id=\"ibox_wrapper\" style=\"visibility:hidden;\">";    
    strHTML +=    "<div id=\"ibox_content\" class=\"userstuff\" aria-busy=\"false\"></div>";
    strHTML +=    "<div id=\"ibox_footer_wrapper\"><div id=\"ibox_close\">";
    strHTML +=    "<a id=\"ibox_close_a\" href=\"javascript:void(null);\" class=\"action\" role=\"button\">CLOSE</a></div>";
    strHTML +=  "<div id=\"ibox_footer\">&nbsp;</div></div>";    
    strHTML +=  "</div></div>";

    var docBody = document.getElementsByTagName("body")[0];
    var ibox = document.createElement("div");
    ibox.setAttribute("id","ibox");
    ibox.innerHTML = strHTML;
    elem.appendChild(ibox);
}

showIbox = function(url,title,params) {
    var ibox = getElem('ibox_wrapper'),
        ibox_type = 0,
        ibox_footer = getElem('ibox_footer'),
        // file checking code borrowed from thickbox
        urlString = /\.jpg|\.jpeg|\.png|\.gif|\.html|\.htm|\.php|\.cfm|\.asp|\.aspx|\.jsp|\.jst|\.rb|\.rhtml|\.txt/g,
        urlType = url.match(urlString);
        
    loadCancelled = false;
    
    // disable scrolling on background page and add a margin to prevent shifting layout
    if (typeof scrollBarW === "undefined") scrollBarW = getScrollBarWidth();
    document.body.style.marginRight = scrollBarW +"px";
    document.body.style.overflowY = "hidden";
    document.documentElement.style.overflowY = "hidden"; // IE7
    document.body.height = "100%";
    
    // set title here
    if(title != "") {ibox_footer.innerHTML = title;} else {ibox_footer.innerHTML = "&nbsp;";}

    if(urlType == '.jpg' || urlType == '.jpeg' || urlType == '.png' || urlType == '.gif'){
        ibox_type = 1;
    } else if(url.indexOf("#") != -1) {
        ibox_type = 2;
    } else if(urlType=='.htm'||urlType=='.html'||urlType=='.php'||
             urlType=='.asp'||urlType=='.aspx'||urlType=='.jsp'||
             urlType=='.jst'||urlType=='.rb'||urlType=='.txt'||urlType=='.rhtml'||
             urlType=='.cfm') {
        ibox_type = 3;
    } else {
        // override our ibox type if forced param exist
        if(params['type']) {ibox_type = parseInt(params['type']);}
        else{hideIbox();return false;}
    }
    
    ibox_type = parseInt(ibox_type);

    switch(ibox_type) {        
        case 1:
            showIndicator();            
            imgPreloader = new Image();            
            imgPreloader.onload = function(){
    
                imgPreloader = resizeImageToScreen(imgPreloader);
                hideIndicator();
    
                var strHTML = "<img name=\"ibox_img\" src=\""+url+"\" style=\"width:"+imgPreloader.width+"px;height:"+imgPreloader.height+"px;border:0;cursor:hand;margin:0;padding:0;position:absolute;\"/>";
    
                if(loadCancelled == false) {
                    
                    // set width and height
                    ibox.style.height = imgPreloader.height+'px';
                    ibox.style.width = imgPreloader.width+'px';
                    
                    posToCenter(ibox);

                    ibox.style.visibility = "";
                    ibox.style.opacity = "1";
                    setIBoxContent(strHTML);
                }                    
            }
            
            imgPreloader.src = url;
            
            break;
        case 2:            
            var strHTML = "";
            
            var autosize = true;
            if (params['height']) {
                ibox.style.height = params['height']+'px';
                autosize = false;
            }
            if (params['width']) {
                ibox.style.width = params['width']+'px';
                autosize = false;
            }
            posToCenter(ibox, autosize);
            
            var elemSrcId = url.substr(url.indexOf("#") + 1,1000);
            
            var elemSrc = getElem(elemSrcId);
            
            if(elemSrc) {strHTML = elemSrc.innerHTML;}
        
            ibox.style.visibility = "";
            ibox.style.opacity = "1";
            setIBoxContent(strHTML);
            
            break;            
        case 3:
            showIndicator();
            http.open('get',url,true);

            http.onreadystatechange = function() {
                if (http.readyState == 4 && loadCancelled == false) {
                    hideIndicator();
                    
                    var autosize = true;
                    if (params['height']) {
                        ibox.style.height = params['height']+'px';
                        autosize = false;
                    }            
                    if (params['width']) {
                        ibox.style.width = params['width']+'px';
                        autosize = false;
                    }
                    posToCenter(ibox, autosize);
                    
                    ibox.style.visibility = "";
                    ibox.style.opacity = "1";
                    var response = http.responseText;
                    setIBoxContent(response);
                }
            }
            
            http.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
            http.send(null);
            break;        
    }
    
    if(ibox_type == 2 || ibox_type == 3) {
        ibox.onclick = null;getElem("ibox_close_a").onclick = function() {hideIbox();}
    } else {ibox.onclick = hideIbox;getElem("ibox_close_a").onclick = null;}
    
    shown = true;
    return true;
}

resizeImageToScreen = function(objImg) {
    var pageSize = new getPageSize();
    
    var x = pagesize.width - 100;
    var y = pagesize.height - 100;

    if (objImg.width > x) { 
        objImg.height = objImg.height * (x/objImg.width); 
        objImg.width = x; 
        if(objImg.height > y) { 
            objImg.width = objImg.width * (y/objImg.height); 
            objImg.height = y; 
        }
    } else if (objImg.height > y) { 
        objImg.width = objImg.width * (y/objImg.height); 
        objImg.height = y; 
        if(objImg.width > x) { 
            objImg.height = objImg.height * (x/objImg.width); 
            objImg.width = x;
        }
    }

    return objImg;
}

hideIbox = function() {    
    hideBG();
    var ibox = getElem('ibox_wrapper');
    setTimeout(function() { ibox.style.opacity = "0"; }, 0);
    setTimeout(function() { 
        ibox.style.visibility = "hidden";

        // restore page scrolling and remove right margin
        document.body.style.overflowY = "";
        document.documentElement.style.overflowY = "";
        document.body.style.marginRight = "";
        clearIboxContent();
        
        shown = false;        
    }, 400);    
}

posToCenter = function(elem, autosize) {
    if (autosize && autosize == true) { // calculate nice margins for larger screens
        var page = new getPageSize(),
            marginX,
            marginY;
            
        elem.style.width = "";
        elem.style.height = "";
        elem.style.top = "0";
        elem.style.right = "0";
        elem.style.bottom = "0";
        elem.style.left = "0";
        
        marginX = page.width - 960;
        marginX = marginX > 0 ? Math.round(marginX/page.width/2*100) : 6;
        
        marginY = page.height - 720;
        marginY = marginY > 0 ? Math.round(marginY/page.height/4*100) : 4;
        
        elem.style.margin = marginY +"% " +marginX +"%";
    } else { // element has a set size, just center it
        var emSize = new getElementSize(elem),
            x = Math.round(emSize.width/2),
            y = Math.round(emSize.height/2);
            
        elem.style.top = "50%";
        elem.style.marginTop = "-" +y +"px";
        elem.style.left = "50%";
        elem.style.marginLeft = "-" +x +"px";
    }
}
getElementSize = function(elem) {
    this.width = elem.offsetWidth ||  elem.style.pixelWidth;
    this.height = elem.offsetHeight || elem.style.pixelHeight;
}
getPageSize = function() {
    var docElem = document.documentElement
    this.width = self.innerWidth || (docElem&&docElem.clientWidth) || document.body.clientWidth;
    this.height = self.innerHeight || (docElem&&docElem.clientHeight) || document.body.clientHeight;
}

setIBoxContent = function(str) {
    var e = getElem('ibox_content');
    
    clearIboxContent();
    e.innerHTML = str;
    e.scrollTop = 0;
    e.tabIndex = 0;
    e.focus();
    
    if (window.opera) {
        document.body.addEventListener("keydown", operaKeyDown, false);
        document.body.addEventListener("keyup", operaKeyUp, false);
        e.addEventListener("click", operaClick, false);
    }    
}

clearIboxContent = function() {
    var e = getElem('ibox_content');
    e.innerHTML = "";
    
    if (window.opera) {
        document.body.removeEventListener("keydown", operaKeyDown, false);
        document.body.removeEventListener("keyup", operaKeyUp, false);
        e.removeEventListener("click", operaClick, false);
    }
}

getElem = function(elemId) {
    return document.getElementById(elemId);    
}

/********************************************************
 Keyboard scrolling for Opera, which can't automatically focus() the ibox
*********************************************************/

function operaKeyDown(e) {
    clearInterval(scrollTimer);
    
    switch (e.keyCode) {
        case 38: // UP arrow key
            getElem("ibox_content").scrollTop -= 60;
            arrowKeyDown = true;
            scrollTimer = setInterval(timerScrollUp, 50);
            break;
        case 40: // DOWN arrow key
            getElem("ibox_content").scrollTop += 60;
            arrowKeyDown = true;
            scrollTimer = setInterval(timerScrollDown, 50);
            break;
        case 33: // PAGE UP
            getElem("ibox_content").scrollTop -= 150;
            arrowKeyDown = true;
            scrollTimer = setInterval(timerPageUp, 50);
            break;
        case 34: // PAGE DOWN
            getElem("ibox_content").scrollTop += 150;
            arrowKeyDown = true;
            scrollTimer = setInterval(timerPageDown, 50);
            break;
        default:
            arrowKeyDown = false;
    }
}

function operaKeyUp(e) {
    clearInterval(scrollTimer);    
    if (e.keyCode == 38 ||
        e.keyCode == 40 ||
        e.keyCode == 33 ||
        e.keyCode == 34) {
        arrowKeyDown = false;  
    }
}

function operaClick() {
    clearInterval(scrollTimer);
    
    document.body.removeEventListener("keydown", operaKeyDown, false);
    document.body.removeEventListener("keyup", operaKeyUp, false);
    getElem("ibox_content").removeEventListener("click", operaClick, false);
}

function timerScrollUp() {
    if (arrowKeyDown)
        getElem("ibox_content").scrollTop -= 40;
    else
        clearInterval(scrollTimer);
}
function timerScrollDown() {
    if (arrowKeyDown)
        getElem("ibox_content").scrollTop += 40;
    else
        clearInterval(scrollTimer);
}
function timerPageUp() {
    if (arrowKeyDown)
        getElem("ibox_content").scrollTop -= 100;
    else
        clearInterval(scrollTimer);
}
function timerPageDown() {
    if (arrowKeyDown)
        getElem("ibox_content").scrollTop += 100;
    else
        clearInterval(scrollTimer);
}

/********************************************************
 Get scrollbar width to set page margin
 http://www.alexandre-gomes.com/?p=115
*********************************************************/
function getScrollBarWidth() {
    var inner = document.createElement('p');
    inner.style.width = "100%";
    inner.style.height = "200px";

    var outer = document.createElement('div');
    outer.style.position = "absolute";
    outer.style.top = "0px";
    outer.style.left = "0px";
    outer.style.visibility = "hidden";
    outer.style.width = "200px";
    outer.style.height = "150px";
    outer.style.overflow = "hidden";
    outer.appendChild (inner);

    document.body.appendChild (outer);
    var w1 = inner.offsetWidth;
    outer.style.overflow = 'scroll';
    var w2 = inner.offsetWidth;
    if (w1 == w2) w2 = outer.clientWidth;

    document.body.removeChild (outer);

    return (w1 - w2);
};

// parseQuery code borrowed from thickbox, Thanks Cody!
parseQuery = function(query) {
   var Params = new Object ();
   if (!query) return Params; 
   var Pairs = query.split(/[;&]/);
   for ( var i = 0; i < Pairs.length; i++ ) {
      var KeyVal = Pairs[i].split('=');
      if ( ! KeyVal || KeyVal.length != 2 ) continue;
      var key = unescape( KeyVal[0] );
      var val = unescape( KeyVal[1] );
      val = val.replace(/\+/g, ' ');
      Params[key] = val;
   }
   
   return Params;
}

/********************************************************
 Make this IE7 Compatible ;)
 http://ajaxian.com/archives/ajax-on-ie-7-check-native-first
*********************************************************/
createRequestObject = function() {
    var xmlhttp;
        /*@cc_on
    @if (@_jscript_version>= 5)
            try {xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
            } catch (e) {
                    try {xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");}
                    catch (E) {xmlhttp = false;}
            }
    @else
        xmlhttp = false;
    @end @*/
    if (!xmlhttp && typeof XMLHttpRequest != "undefined") {
            try {xmlhttp = new XMLHttpRequest();} catch (e) {xmlhttp = false;}
    }
    return xmlhttp;
}

var http = createRequestObject();

function addEvent(obj, evType, fn) { 
    if (obj.addEventListener) { 
        obj.addEventListener(evType, fn, false); 
        return true; 
    } else if (obj.attachEvent) { 
        var r = obj.attachEvent("on"+evType, fn); 
        return r; 
    } else { 
        return false; 
    } 
}

addEvent(window, 'load', init_ibox);
