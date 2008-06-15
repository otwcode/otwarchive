/* 
 * Use this file to override the default configuration settings.
 * This file is read right after the default config.js is read
 * but before anything else is done, so you can override anything you need.
 * Since these only gets read at server startup, you'll need to restart Jaxer
 * after modifying this file for those modifications to have an effect.
 */
(function(){

	// Use the following to override where some of your local overrides are located:
//	Config.LOCAL_CONFIG_LOG = 		"../local_jaxer/conf/configLog.js";
//	Config.LOCAL_CONFIG_ROUTES = 	"../local_jaxer/conf/configRoutes.js";
//	Config.LOCAL_EXTENSIONS_DIR = 	"../local_jaxer/extensions";
	
	// Use the following to override some of the default error-handling settings:
//	Config.UNCAUGHT_ERRORS_ARE_RESPONSE_ERRORS = true;
//	Config.INCLUDE_ERRORS_ARE_RESPONSE_ERRORS = true;
//	Config.RESPONSE_ERROR_PAGE = "resource:///content/responseError.html"; 
//	Config.FATAL_ERROR_PAGE = "resource:///content/fatalError.html";
//	Config.CALLBACK_ERROR_MESSAGE = "Error on server during callback - further information has been logged";
//	Config.CALLBACK_FATAL_ERROR_MESSAGE = "Callback could not be processed due to server error - further information has been logged";
//	Config.DISPLAY_ERRORS = true; // set to true only in development/debug stage: some error messages may be displayed within the served page or in callbacks
//	Config.ALERT_CALLBACK_ERRORS = true; // whether to popup a window.alert(...) when a callback returns an error

//	Config.RELOAD_AUTOLOADS_EVERY_PAGE_REQUEST = false; // set to false when in production, to minimize script fetching and optimize performance
//	Config.CACHE_USING_SOURCE_CODE = false; // set to false in production, to optimize performance by caching bytecode
	
	// To include scripts and access files and so on, Jaxer may need to get that content from the web server.
	// If your web server needs to be reached via a different domain/port than the incoming request,
	// uncomment and change the following to replace the protocol://domain:port with this value
//	Config.REWRITE_RELATIVE_URL = "http://192.168.0.1:8082"; // If your web server is reachable at IP 192.168.0.1 on port 8082
//	Config.REWRITE_RELATIVE_URL_REGEX = "^http\\:\\/\\/my.domain.com"; // Optional -- if e.g. you only want to replace URLs that start with this

	// To set any of Mozilla preferences, add properties to Config.MOZ_PREFS.
	// The name of each property should correspond exactly to the Mozilla preference,
	// and the value should be an integer, boolean, or string.
	// To see some of the available options, launch Firefox and browse to about:config
	// E.g., the following configures the proxy settings to be used for HTTP requests,
	// say when Jaxer.Web.get(...) is used. 
	// See http://developer.mozilla.org/en/docs/Mozilla_Networking_Preferences#Proxy
//	Config.MOZ_PREFS["network.proxy.type"] = 1; // manual
//	Config.MOZ_PREFS["network.proxy.http"] = "127.0.0.1";
//	Config.MOZ_PREFS["network.proxy.http_port"] = 8888;

	// To have Jaxer use MySQL rather than SQLite, for its own needs or your applications or both,
	// use settings similar to the following:
//	Config.DB_IMPLEMENTATION = "MySQL";
//	Config.DB_CONNECTION_PARAMS =
//	{
//		HOST: "127.0.0.1",
//		PORT: 4417,        // This uses a port different than the default of 3306, to minimize conflicts with existing installs
//		NAME: "demos",
//		USER: "root",
//		PASS: "",
//		CLOSE_AFTER_EXECUTE: false,
//		CLOSE_AFTER_REQUEST: true
//	};
//	Config.DB_FRAMEWORK_IMPLEMENTATION = "MySQL";
//	Config.DB_FRAMEWORK_CONNECTION_PARAMS =
//	{
//		HOST: "127.0.0.1",
//		PORT: 4417,        // This uses a port different than the default of 3306, to minimize conflicts with existing installs
//		NAME: "jaxer",
//		USER: "root",
//		PASS: "",
//		CLOSE_AFTER_EXECUTE: false,
//		CLOSE_AFTER_REQUEST: true
//	};

	// To embed the client part of the Jaxer framework in the web page, 
	// specify its location in EMBEDDED_CLIENT_FRAMEWORK_SRC
	// Alternatively, to have the web server serve its contents, 
	// 1) comment out EMBEDDED_CLIENT_FRAMEWORK_SRC,
	// 2) copy the client framework to somewhere the web server can reach it, and
	// 3) use CLIENT_FRAMEWORK_SRC to specify the src of the <SCRIPT> element that will be inserted into the page
//	Config.EMBEDDED_CLIENT_FRAMEWORK_SRC = "resource:///framework/clientFramework_compressed.js";
//	// Config.CLIENT_FRAMEWORK_SRC = "/aptana/clientFramework.js";
	
	// If you are modifying the Jaxer framework, you may want to use the modified copy, so you
	// can quickly test out your modifications. Here's how (replace <...> with the right values:
//	var depotDir = "file:///C:/Documents and Settings/<username>/My Documents/Aptana Studio/<framework_project>";
//	var depotConfigPath = depotDir + "/config.js";
//	// Get the latest config settings from the local depot copy, not the install directory
//	Jaxer.include(depotConfigPath);
//	// But the depot's config will point back to the install directory, so override that explicitly
//	Config.FRAMEWORK_DIR = depotDir;

})();