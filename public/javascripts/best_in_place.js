/*
        BestInPlace (for jQuery)
        version: 0.1.0 (01/01/2011)
        @requires jQuery >= v1.4
        @requires jQuery.purr to display pop-up windows

        By Bernat Farrero based on the work of Jan Varwig.
        Examples at http://bernatfarrero.com

        Licensed under the MIT:
          http://www.opensource.org/licenses/mit-license.php

        Usage:

        Attention.
        The format of the JSON object given to the select inputs is the following:
        [["key", "value"],["key", "value"]]
        The format of the JSON object given to the checkbox inputs is the following:
        ["falseValue", "trueValue"]
*/

function BestInPlaceEditor(e) {
  this.element = jQuery(e);
  this.initOptions();
  this.bindForm();
  this.initNil();
  $(this.activator).bind('click', {editor: this}, this.clickHandler);
}

BestInPlaceEditor.prototype = {
  // Public Interface Functions //////////////////////////////////////////////

  activate : function() {
    var elem = this.isNil ? "" : this.element.html();
    this.oldValue = elem;
    $(this.activator).unbind("click", this.clickHandler);
    this.activateForm();
  },

  abort : function() {
    if (this.isNil) this.element.html(this.nil);
    else            this.element.html(this.oldValue);
    $(this.activator).bind('click', {editor: this}, this.clickHandler);
  },

  update : function() {
    var editor = this;
    if (this.formType in {"input":1, "textarea":1} && this.getValue() == this.oldValue)
    { // Avoid request if no change is made
      this.abort();
      return true;
    }
    this.isNil = false;
    editor.ajax({
      "type"       : "post",
      "dataType"   : "text",
      "data"       : editor.requestData(),
      "success"    : function(data){ editor.loadSuccessCallback(data); },
      "error"      : function(request, error){ editor.loadErrorCallback(request, error); }
    });
    if (this.formType == "select") {
      var value = this.getValue();
      $.each(this.values, function(i, v) {
        if (value == v[0]) {
          editor.element.html(v[1]);
        }
      }
    );
    } else if (this.formType == "checkbox") {
      editor.element.html(this.getValue() ? this.values[1] : this.values[0]);
    } else {
      editor.element.html(this.getValue() != "" ? this.getValue() : this.nil);
    }
  },

  activateForm : function() {
    alert("The form was not properly initialized. activateForm is unbound");
  },

  // Helper Functions ////////////////////////////////////////////////////////

  initOptions : function() {
    // Try parent supplied info
    var self = this;
    self.element.parents().each(function(){
      self.url           = self.url           || jQuery(this).attr("data-url");
      self.collection    = self.collection    || jQuery(this).attr("data-collection");
      self.formType      = self.formType      || jQuery(this).attr("data-type");
      self.objectName    = self.objectName    || jQuery(this).attr("data-object");
      self.attributeName = self.attributeName || jQuery(this).attr("data-attribute");
      self.nil           = self.nil           || jQuery(this).attr("data-nil");
      self.inner_class   = self.inner_class   || jQuery(this).attr("data-inner-class");
    });

    // Try Rails-id based if parents did not explicitly supply something
    self.element.parents().each(function(){
      var res = this.id.match(/^(\w+)_(\d+)$/i);
      if (res) {
        self.objectName = self.objectName || res[1];
      }
    });

    // Load own attributes (overrides all others)
    self.url           = self.element.attr("data-url")          || self.url      || document.location.pathname;
    self.collection    = self.element.attr("data-collection")   || self.collection;
    self.formType      = self.element.attr("data-type")         || self.formtype || "input";
    self.objectName    = self.element.attr("data-object")       || self.objectName;
    self.attributeName = self.element.attr("data-attribute")    || self.attributeName;
    self.activator     = self.element.attr("data-activator")    || self.element;
    self.nil           = self.element.attr("data-nil")          || self.nil      || "-";
    self.inner_class   = self.element.attr("data-inner-class")  || self.inner_class   || null;

    if (!self.element.attr("data-sanitize")) {
      self.sanitize = true;
    }
    else {
      self.sanitize = (self.element.attr("data-sanitize") == "true");
    }

    if ((self.formType == "select" || self.formType == "checkbox") && self.collection !== null)
    {
      self.values = jQuery.parseJSON(self.collection);
    }
  },

  bindForm : function() {
    this.activateForm = BestInPlaceEditor.forms[this.formType].activateForm;
    this.getValue     = BestInPlaceEditor.forms[this.formType].getValue;
  },

  initNil: function() {
    if (this.element.html() == "")
    {
      this.isNil = true
      this.element.html(this.nil)
    }
  },

  getValue : function() {
    alert("The form was not properly initialized. getValue is unbound");
  },

  // Trim and Strips HTML from text
  sanitizeValue : function(s) {
    if (this.sanitize)
    {
      var tmp = document.createElement("DIV");
      tmp.innerHTML = s;
      s = tmp.textContent || tmp.innerText;
    }
   return jQuery.trim(s);
  },

  /* Generate the data sent in the POST request */
  requestData : function() {
    // To prevent xss attacks, a csrf token must be defined as a meta attribute
    csrf_token = $('meta[name=csrf-token]').attr('content');
    csrf_param = $('meta[name=csrf-param]').attr('content');

    var data = "_method=put";
    data += "&" + this.objectName + '[' + this.attributeName + ']=' + encodeURIComponent(this.getValue());

    if (csrf_param !== undefined && csrf_token !== undefined) {
      data += "&" + csrf_param + "=" + encodeURIComponent(csrf_token);
    }
    return data;
  },

  ajax : function(options) {
    options.url = this.url;
    options.beforeSend = function(xhr){ xhr.setRequestHeader("Accept", "application/json"); };
    return jQuery.ajax(options);
  },

  // Handlers ////////////////////////////////////////////////////////////////

  loadSuccessCallback : function(data) {
    this.element.html(data[this.objectName]);
    // Binding back after being clicked
    $(this.activator).bind('click', {editor: this}, this.clickHandler);
  },

  loadErrorCallback : function(request, error) {
    this.element.html(this.oldValue);

    // Display all error messages from server side validation
    $.each(jQuery.parseJSON(request.responseText), function(index, value) {
      var container = $("<span class='flash-error'></span>").html(value);
      container.purr();
    });

    // Binding back after being clicked
    $(this.activator).bind('click', {editor: this}, this.clickHandler);
  },

  clickHandler : function(event) {
    event.data.editor.activate();
  }
};


BestInPlaceEditor.forms = {
  "input" : {
    activateForm : function() {
      var output = '<form class="form_in_place" action="javascript:void(0)" style="display:inline;">';
      output += '<input type="text" name="'+ this.attributeName + '" value="' + this.sanitizeValue(this.oldValue) + '"';
      if (this.inner_class != null) {
        output += ' class="' + this.inner_class + '"';
      }
      output += '></form>'
      this.element.html(output);
      this.element.find('input')[0].select();
      this.element.find("form").bind('submit', {editor: this}, BestInPlaceEditor.forms.input.submitHandler);
      this.element.find("input").bind('blur',   {editor: this}, BestInPlaceEditor.forms.input.inputBlurHandler);
      this.element.find("input").bind('keyup', {editor: this}, BestInPlaceEditor.forms.input.keyupHandler);
    },

    getValue :  function() {
      return this.sanitizeValue(this.element.find("input").val());
    },

    inputBlurHandler : function(event) {
      event.data.editor.update();
    },

    submitHandler : function(event) {
      event.data.editor.update();
    },

    keyupHandler : function(event) {
      if (event.keyCode == 27) {
        event.data.editor.abort();
      }
    }
  },

  "select" : {
    activateForm : function() {
      var output = "<form action='javascript:void(0)' style='display:inline;'><select>";
      var selected = "";
      var oldValue = this.oldValue;
      $.each(this.values, function(index, value) {
        selected = (value[1] == oldValue ? "selected='selected'" : "");
        output += "<option value='" + value[0] + "' " + selected + ">" + value[1] + "</option>";
       });
      output += "</select></form>";
      this.element.html(output);
      this.element.find("select").bind('change', {editor: this}, BestInPlaceEditor.forms.select.blurHandler);
      this.element.find("select").bind('blur', {editor: this}, BestInPlaceEditor.forms.select.blurHandler);
      this.element.find("select").bind('keyup', {editor: this}, BestInPlaceEditor.forms.select.keyupHandler);
      this.element.find("select")[0].focus();
    },

    getValue : function() {
      return this.sanitizeValue(this.element.find("select").val());
    },

    blurHandler : function(event) {
      event.data.editor.update();
    },

    keyupHandler : function(event) {
      if (event.keyCode == 27) event.data.editor.abort();
    }
  },

  "checkbox" : {
    activateForm : function() {
      var newValue = Boolean(this.oldValue != this.values[1]);
      var output = newValue ? this.values[1] : this.values[0];
      this.element.html(output);
      this.update();
    },

    getValue : function() {
      return Boolean(this.element.html() == this.values[1]);
    }
  },

  "textarea" : {
    activateForm : function() {
      // grab width and height of text
      width = this.element.css('width');
      height = this.element.css('height');

      // construct the form
      var output = '<form action="javascript:void(0)" style="display:inline;"><textarea>';
      output += this.sanitizeValue(this.oldValue);
      output += '</textarea></form>';
      this.element.html(output);

      // set width and height of textarea
      jQuery(this.element.find("textarea")[0]).css({ 'min-width': width, 'min-height': height });
      jQuery(this.element.find("textarea")[0]).elastic();

      this.element.find("textarea")[0].focus();
      this.element.find("textarea").bind('blur', {editor: this}, BestInPlaceEditor.forms.textarea.blurHandler);
      this.element.find("textarea").bind('keyup', {editor: this}, BestInPlaceEditor.forms.textarea.keyupHandler);
    },

    getValue :  function() {
      return this.sanitizeValue(this.element.find("textarea").val());
    },

    blurHandler : function(event) {
      event.data.editor.update();
    },

    keyupHandler : function(event) {
      if (event.keyCode == 27) {
        BestInPlaceEditor.forms.textarea.abort(event.data.editor);
      }
    },

    abort : function(editor) {
      if (confirm("Are you sure you want to discard your changes?")) {
        editor.abort();
      }
    }
  }
};

jQuery.fn.best_in_place = function() {
  this.each(function(){
    jQuery(this).data('bestInPlaceEditor', new BestInPlaceEditor(this));
  });
  return this;
};



/**
* @name             Elastic
* @descripton           Elastic is Jquery plugin that grow and shrink your textareas automaticliy
* @version            1.6.5
* @requires           Jquery 1.2.6+
*
* @author             Jan Jarfalk
* @author-email         jan.jarfalk@unwrongest.com
* @author-website         http://www.unwrongest.com
*
* @licens             MIT License - http://www.opensource.org/licenses/mit-license.php
*/

(function(jQuery){
  jQuery.fn.extend({
    elastic: function() {
      //  We will create a div clone of the textarea
      //  by copying these attributes from the textarea to the div.
      var mimics = [
        'paddingTop',
        'paddingRight',
        'paddingBottom',
        'paddingLeft',
        'fontSize',
        'lineHeight',
        'fontFamily',
        'width',
        'fontWeight'];

      return this.each( function() {

        // Elastic only works on textareas
        if ( this.type != 'textarea' ) {
          return false;
        }

        var $textarea = jQuery(this),
          $twin   = jQuery('<div />').css({'position': 'absolute','display':'none','word-wrap':'break-word'}),
          lineHeight  = parseInt($textarea.css('line-height'),10) || parseInt($textarea.css('font-size'),'10'),
          minheight = parseInt($textarea.css('height'),10) || lineHeight*3,
          maxheight = parseInt($textarea.css('max-height'),10) || Number.MAX_VALUE,
          goalheight  = 0,
          i       = 0;

        // Opera returns max-height of -1 if not set
        if (maxheight < 0) { maxheight = Number.MAX_VALUE; }

        // Append the twin to the DOM
        // We are going to meassure the height of this, not the textarea.
        $twin.appendTo($textarea.parent());

        // Copy the essential styles (mimics) from the textarea to the twin
        var i = mimics.length;
        while(i--){
          $twin.css(mimics[i].toString(),$textarea.css(mimics[i].toString()));
        }


        // Sets a given height and overflow state on the textarea
        function setHeightAndOverflow(height, overflow){
          curratedHeight = Math.floor(parseInt(height,10));
          if($textarea.height() != curratedHeight){
            $textarea.css({'height': curratedHeight + 'px','overflow':overflow});

          }
        }


        // This function will update the height of the textarea if necessary
        function update() {

          // Get curated content from the textarea.
          var textareaContent = $textarea.val().replace(/&/g,'&amp;').replace(/  /g, '&nbsp;').replace(/<|>/g, '&gt;').replace(/\n/g, '<br />');

          // Compare curated content with curated twin.
          var twinContent = $twin.html().replace(/<br>/ig,'<br />');

          if(textareaContent+'&nbsp;' != twinContent){

            // Add an extra white space so new rows are added when you are at the end of a row.
            $twin.html(textareaContent+'&nbsp;');

            // Change textarea height if twin plus the height of one line differs more than 3 pixel from textarea height
            if(Math.abs($twin.height() + lineHeight - $textarea.height()) > 3){

              var goalheight = $twin.height()+lineHeight;
              if(goalheight >= maxheight) {
                setHeightAndOverflow(maxheight,'auto');
              } else if(goalheight <= minheight) {
                setHeightAndOverflow(minheight,'hidden');
              } else {
                setHeightAndOverflow(goalheight,'hidden');
              }

            }

          }

        }

        // Hide scrollbars
        $textarea.css({'overflow':'hidden'});

        // Update textarea size on keyup, change, cut and paste
        $textarea.bind('keyup change cut paste', function(){
          update();
        });

        // Compact textarea on blur
        // Lets animate this....
        $textarea.bind('blur',function(){
          if($twin.height() < maxheight){
            if($twin.height() > minheight) {
              $textarea.height($twin.height());
            } else {
              $textarea.height(minheight);
            }
          }
        });

        // And this line is to catch the browser paste event
        $textarea.live('input paste',function(e){ setTimeout( update, 250); });

        // Run update once when elastic is initialized
        update();

      });

        }
    });
})(jQuery);
