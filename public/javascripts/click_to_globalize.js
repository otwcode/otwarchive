Element.addMethods({
	getText: function(element){
		element = $(element);
		return ((element.firstChild && element.firstChild.nodeValue) ? element.firstChild.nodeValue : '').strip();
	}
});

function $$$(value) {
  return $(document.body).descendants().select(function(element){
    if($w('text/javascript textarea').include(element.type)) return false;
    return $(element).getText() == value;
  });
}

Ajax.InPlaceEditor.prototype = Object.extend(Ajax.InPlaceEditor.prototype,{
  createHiddenField: function(){
    var textField = document.createElement("input");
    textField.obj = this;
    textField.type = 'hidden';
    textField.name = 'key';
    textField.value = this.options.hiddenValue;
    var size = this.options.size || this.options.cols || 0;
    if (size != 0) textField.size = size;
    this._form.appendChild(textField);
  }
});

// Fix for: http://dev.rubyonrails.org/ticket/4579
Ajax.InPlaceEditor.prototype.initialize = Ajax.InPlaceEditor.prototype.initialize.wrap(
	function(proceed, element, url, options) {
		element = $(element);
    if($w('TD TH').include(element.tagName)){
			element.observe('click',     this.enterEditMode.bindAsEventListener(this));
			element.observe('mouseover', this.enterHover.bindAsEventListener(this));
			element.observe('mouseout',  this.leaveHover.bindAsEventListener(this));
      element.innerHTML = "<span>" + element.textContent + "</span>";
      element = element.down();
    }
		proceed(element, url, options);
	}
);

Ajax.InPlaceEditor.prototype.createForm = Ajax.InPlaceEditor.prototype.createForm.wrap(
  function(proceed) {
	  proceed();
  	this.createHiddenField();
  }
);

var ClickToGlobalize = {
  translateUrl:             '/locale/translate',
  translateUnformattedUrl:  '/locale/translate_unformatted',
  translationsUrl:          '/locale/translations',
  httpMethod:               'post',
  asynchronous:              true,
  textileElements:  [ 'a', 'acronym', 'blockquote', 'bold', 'cite', 'code',
                      'del', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'i',
                      'img', 'ins', 'span', 'strong', 'sub', 'sup', 'table',
                    ].collect(function(element){return element.toUpperCase();}),
  textarea:          {rows: 5, cols: 40},
  inputText:         {rows: 1, cols: 20},
  textLength:        160,
  clickToEditText:   'Click to globalize',
  translations:      null,
  authenticityToken: null,
  
  init: function(authenticityToken){
	  this.authenticityToken = encodeURIComponent(authenticityToken);
    this.setTranslationsFromServer();
    this.generateEditors();
  },
  generateEditors: function() {
    this.translations.keys().each(function(key){
      text = ClickToGlobalize.translations.get(key);
      $$$(text).each(function(element){
        ClickToGlobalize.bindEditor(element, key, text);
      });
    });
  },
  bindEditor: function(element, key, text) {
    dimensions = text.stripTags().length > this.textLength ? this.textarea : this.inputText;
    new Ajax.InPlaceEditor(element, this.translateUrl+'?authenticity_token='+this.authenticityToken, {
	  cancelControl: 'button',
      hiddenValue: key,
      rows: dimensions.rows > 1 ? dimensions.rows : 3,
      cols: dimensions.cols,
      ajaxOptions: {method: ClickToGlobalize.httpMethod, asynchronous: ClickToGlobalize.asynchronous},
      loadTextURL: this.translateUnformattedUrl+'?key='+encodeURIComponent(key)+'&authenticity_token='+this.authenticityToken,
      clickToEditText: ClickToGlobalize.clickToEditText,
      onComplete: function(transport, element) {
        if(transport){
          ClickToGlobalize.unbindEditor(element);
          if(ClickToGlobalize.textileElements.include(element.tagName)) {
            parent_element = element.ancestors().first();
            parent_element = ClickToGlobalize.textileElements.include(parent_element.tagName) ? parent_element : element;
            html   = transport.responseText;
            parent_element.replace(html);
            element = $$$(html.stripTags()).first();
          }
          ClickToGlobalize.bindEditor(element, key, transport.responseText);
        }
      }
    });
  },
  unbindEditor: function(element) {
		element.stopObserving('click');
  	element.stopObserving('mouseover');
		element.stopObserving('mouseout');
  },
  setTranslationsFromServer: function() {
    new Ajax.Request(this.translationsUrl, {
      onSuccess: function(transport) {
        ClickToGlobalize.translations = $H(transport.responseText.evalJSON());
      },
      method: 'get',
      // Set on false, cause we have to wait until the end of the request
      // to add the events to the elements.
      asynchronous: false
    });
  }
};