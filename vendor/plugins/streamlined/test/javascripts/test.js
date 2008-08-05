crosscheck.onSetup(function(){
  crosscheck.load("../../files/public/windows_js/javascripts/prototype.js");
  crosscheck.load("../../files/public/javascripts/streamlined.js");
});
crosscheck.addTest({
  test_libs_available: function () {
    assertDefined(Prototype);
    assertDefined(Streamlined);
  }
});