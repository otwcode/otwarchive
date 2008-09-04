
var indicator_img_path="/images/indicator.gif";var indicator_img_html="<img name=\"ibox_indicator\" src=\""+indicator_img_path+"\" alt=\"Loading...\" style=\"width:128px;height:128px;\"/>";var opacity_level=8;var ibAttr="rel";var imgPreloader=new Image();function init_ibox(){var elem_wrapper="ibox";createIbox(document.getElementsByTagName("body")[0]);var docRoot=document.getElementsByTagName("a");var e;for(var i=0;i<docRoot.length-1;i++){e=docRoot[i];if(e.getAttribute(ibAttr)){var t=e.getAttribute(ibAttr);if((t.indexOf("ibox")!=-1)||t.toLowerCase()=="ibox"){e.onclick=function(){var t=this.getAttribute(ibAttr);var params=parseQuery(t.substr(5,999));var url=this.href;if(this.target!=""){url=this.target}
var title=this.title;if(showIbox(url,title,params)){showBG();window.onscroll=maintPos;window.onresize=maintPos;}
return false;};}}}}
showBG=function(){var box_w=getElem('ibox_w');box_w.style.opacity=0;box_w.style.filter='alpha(opacity=0)';setBGOpacity=setOpacity;for(var i=0;i<=opacity_level;i++){setTimeout("setIboxOpacity('ibox_w',"+i+")",70*i);}
box_w.style.display="";var pagesize=new getPageSize();var scrollPos=new getScrollPos();var ua=navigator.userAgent;if(ua.indexOf("MSIE ")!=-1){box_w.style.width=pagesize.width+'px';}
box_w.style.height=pagesize.height+scrollPos.scrollY+'px';}
hideBG=function(){var box_w=getElem('ibox_w');box_w.style.display="none";}
var loadCancelled=false;showIndicator=function(){var ibox_p=getElem('ibox_progress');ibox_p.style.display="";posToCenter(ibox_p);ibox_p.onclick=function(){hideIbox();hideIndicator();loadCancelled=true;}}
hideIndicator=function(){var ibox_p=getElem('ibox_progress');ibox_p.style.display="none";ibox_p.onclick=null;}
createIbox=function(elem){var strHTML="<div id=\"ibox_w\" style=\"display:none;\"></div>";strHTML+="<div id=\"ibox_progress\" style=\"display:none;\">";strHTML+=indicator_img_html;strHTML+="</div>";strHTML+="<div id=\"ibox_wrapper\" style=\"display:none\">";strHTML+="<div id=\"ibox_content\"></div>";strHTML+="<div id=\"ibox_footer_wrapper\"><div id=\"ibox_close\" style=\"float:right;\">";strHTML+="<a id=\"ibox_close_a\" href=\"javascript:void(null);\" >Click here to close</a></div>";strHTML+="<div id=\"ibox_footer\">&nbsp;</div></div></div></div>";var docBody=document.getElementsByTagName("body")[0];var ibox=document.createElement("div");ibox.setAttribute("id","ibox");ibox.style.display='';ibox.innerHTML=strHTML;elem.appendChild(ibox);}
var ibox_w_height=0;showIbox=function(url,title,params){var ibox=getElem('ibox_wrapper');var ibox_type=0;var ibox_footer=getElem('ibox_footer');if(title!=""){ibox_footer.innerHTML=title;}else{ibox_footer.innerHTML="&nbsp;";}
var urlString=/\.jpg|\.jpeg|\.png|\.gif|\.html|\.htm|\.php|\.cfm|\.asp|\.aspx|\.jsp|\.jst|\.rb|\.rhtml|\.txt/g;var urlType=url.match(urlString);if(urlType=='.jpg'||urlType=='.jpeg'||urlType=='.png'||urlType=='.gif'){ibox_type=1;}else if(url.indexOf("#")!=-1){ibox_type=2;}else if(urlType=='.htm'||urlType=='.html'||urlType=='.php'||urlType=='.asp'||urlType=='.aspx'||urlType=='.jsp'||urlType=='.jst'||urlType=='.rb'||urlType=='.txt'||urlType=='.rhtml'||urlType=='.cfm'){ibox_type=3;}else{if(params['type']){ibox_type=parseInt(params['type']);}
else{hideIbox();return false;}}
ibox_type=parseInt(ibox_type);switch(ibox_type){case 1:showIndicator();imgPreloader=new Image();imgPreloader.onload=function(){imgPreloader=resizeImageToScreen(imgPreloader);hideIndicator();var strHTML="<img name=\"ibox_img\" src=\""+url+"\" style=\"width:"+imgPreloader.width+"px;height:"+imgPreloader.height+"px;border:0;cursor:hand;margin:0;padding:0;position:absolute;\"/>";if(loadCancelled==false){ibox.style.height=imgPreloader.height+'px';ibox.style.width=imgPreloader.width+'px';ibox.style.display="";ibox.style.visibility="hidden";posToCenter(ibox);ibox.style.visibility="visible";setIBoxContent(strHTML);}}
loadCancelled=false;imgPreloader.src=url;break;case 2:var strHTML="";if(params['height']){ibox.style.height=params['height']+'px';}
else{ibox.style.height='280px';}
if(params['width']){ibox.style.width=params['width']+'px';}
else{ibox.style.width='450px';}
ibox.style.display="";ibox.style.visibility="hidden";posToCenter(ibox);ibox.style.visibility="visible";getElem('ibox_content').style.overflow="auto";var elemSrcId=url.substr(url.indexOf("#")+1,1000);var elemSrc=getElem(elemSrcId);if(elemSrc){strHTML=elemSrc.innerHTML;}
setIBoxContent(strHTML);break;case 3:showIndicator();http.open('get',url,true);http.onreadystatechange=function(){if(http.readyState==4){hideIndicator();if(params['height']){ibox.style.height=params['height']+'px';}
else{ibox.style.height='280px';}
if(params['width']){ibox.style.width=params['width']+'px';}
else{ibox.style.width='450px';}
ibox.style.display="";ibox.style.visibility="hidden";posToCenter(ibox);ibox.style.visibility="visible";getElem('ibox_content').style.overflow="auto";var response=http.responseText;setIBoxContent(response);}}
http.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");http.send(null);break;default:}
ibox.style.opacity=0;ibox.style.filter='alpha(opacity=0)';var ibox_op_level=10;setIboxOpacity=setOpacity;for(var i=0;i<=ibox_op_level;i++){setTimeout("setIboxOpacity('ibox_wrapper',"+i+")",30*i);}
if(ibox_type==2||ibox_type==3){ibox.onclick=null;getElem("ibox_close_a").onclick=function(){hideIbox();}}else{ibox.onclick=hideIbox;getElem("ibox_close_a").onclick=null;}
return true;}
setOpacity=function(elemid,value){var e=getElem(elemid);e.style.opacity=value/10;e.style.filter='alpha(opacity='+value*10+')';}
resizeImageToScreen=function(objImg){var pagesize=new getPageSize();var x=pagesize.width-100;var y=pagesize.height-100;if(objImg.width>x){objImg.height=objImg.height*(x/objImg.width);objImg.width=x;if(objImg.height>y){objImg.width=objImg.width*(y/objImg.height);objImg.height=y;}}
else if(objImg.height>y){objImg.width=objImg.width*(y/objImg.height);objImg.height=y;if(objImg.width>x){objImg.height=objImg.height*(x/objImg.width);objImg.width=x;}}
return objImg;}
maintPos=function(){var ibox=getElem('ibox_wrapper');var box_w=getElem('ibox_w');var pagesize=new getPageSize();var scrollPos=new getScrollPos();var ua=navigator.userAgent;if(ua.indexOf("MSIE ")!=-1){box_w.style.width=pagesize.width+'px';}
if(ua.indexOf("Opera/9")!=-1){box_w.style.height=document.body.scrollHeight+'px';}
else{box_w.style.height=pagesize.height+scrollPos.scrollY+'px';}
posToCenter(ibox);}
hideIbox=function(){hideBG();var ibox=getElem('ibox_wrapper');ibox.style.display="none";clearIboxContent();window.onscroll=null;}
posToCenter=function(elem){var scrollPos=new getScrollPos();var pageSize=new getPageSize();var emSize=new getElementSize(elem);var x=Math.round(pageSize.width/2)-(emSize.width/2)+scrollPos.scrollX;var y=Math.round(pageSize.height/2)-(emSize.height/2)+scrollPos.scrollY;elem.style.left=x+'px';elem.style.top=y+'px';}
getScrollPos=function(){var docElem=document.documentElement;this.scrollX=self.pageXOffset||(docElem&&docElem.scrollLeft)||document.body.scrollLeft;this.scrollY=self.pageYOffset||(docElem&&docElem.scrollTop)||document.body.scrollTop;}
getPageSize=function(){var docElem=document.documentElement
this.width=self.innerWidth||(docElem&&docElem.clientWidth)||document.body.clientWidth;this.height=self.innerHeight||(docElem&&docElem.clientHeight)||document.body.clientHeight;}
getElementSize=function(elem){this.width=elem.offsetWidth||elem.style.pixelWidth;this.height=elem.offsetHeight||elem.style.pixelHeight;}
setIBoxContent=function(str){clearIboxContent();var e=getElem('ibox_content');e.style.overflow="auto";e.innerHTML=str;}
clearIboxContent=function(){var e=getElem('ibox_content');e.innerHTML="";}
getElem=function(elemId){return document.getElementById(elemId);}
parseQuery=function(query){var Params=new Object();if(!query)return Params;var Pairs=query.split(/[;&]/);for(var i=0;i<Pairs.length;i++){var KeyVal=Pairs[i].split('=');if(!KeyVal||KeyVal.length!=2)continue;var key=unescape(KeyVal[0]);var val=unescape(KeyVal[1]);val=val.replace(/\+/g,' ');Params[key]=val;}
return Params;}

createRequestObject = function() {
	var xmlhttp;
	/*@cc_on
	@if (@_jscript_version>= 5)
			try {xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
			} catch (e) {try {xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");}catch (E) {xmlhttp = false;}
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

function addEvent(obj,evType,fn){if(obj.addEventListener){obj.addEventListener(evType,fn,false);return true;}else if(obj.attachEvent){var r=obj.attachEvent("on"+evType,fn);return r;}else{return false;}}
addEvent(window,'load',init_ibox);