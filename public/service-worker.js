/** ultra minimal service worker which does nothing
 * we need this to meet the installation requirements in Chrome Android
 * https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Installable_PWAs#requirements
 */
self.addEventListener('fetch', function() {
  return;
});
