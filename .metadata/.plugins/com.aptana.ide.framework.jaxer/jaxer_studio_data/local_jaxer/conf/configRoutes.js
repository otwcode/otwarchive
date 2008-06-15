(function() {
	
/**
 * Use this to add, alter, or delete the simple built-in route rules.
 * The route rules are used by Jaxer to determine from the URL of a request
 * what application and page is being requested, which are in turn used to
 * load the appropriate application- and page-level containers (session-type stores).
 * 
 * Each of the functions in the configRoutes array will be called in turn, 
 * with the single argument being the page's url object as returned by Util.parseUrl().
 * They need to return either null, to indicate they don't match,
 * or an an array of the string that identifies the app and the string that identifies the page.
 * 
 * The following example adds the following rules:
 * 1) demos.aptana.com/XXX/YYY...	-> is the "XXX" app in Aptana demos, and YYY... identifies the page
 * 2) XXX.aptana.com/YYY...			-> is the "XXX" app in Aptana, and YYY... identifies the page
 * Note that, in this case, rule 1 isn't needed because it's covered by the (default) rule 2
 */
//Jaxer.Config.routes = // add the following to the top (beginning) of routes:
//[
//	function(url) { return (
//		url.host == "demos.aptana.com" && url.pathParts.length > 0 ?
//		[url.hostAndPort + "/" + url.pathParts[0],
//		 url.hostAndPort + url.pathAndFile]
//		: null
//	)}, 
//	function(url) { return (
//		url.domain == "aptana.com" && url.subdomain != "" ?
//		[url.hostAndPort,
//		 url.hostAndPort + url.pathAndFile]
//		: null
//	)}, 
//].concat(Jaxer.Config.routes);
	
})()