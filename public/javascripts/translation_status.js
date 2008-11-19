/**
 * @author Enigel, the purveyor of quick ugly hacks and frankensteined code
 * Replaces the text of the translation key with a waiting message,
 * to let the user know that stuff is happening
 * Calling file: translate.html.erb
 */
function tr_status(node)
{
  if (!node) return false;
  if (typeof node == 'string')
    node = document.getElementById(node);
  //alert("Loading...");
  if (node) node.innerHTML = "Loading..."
}