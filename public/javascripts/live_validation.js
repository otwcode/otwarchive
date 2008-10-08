// LiveValidation 1.3 (prototype.js version)
// Copyright (c) 2007-2008 Alec Hill (www.livevalidation.com)
// LiveValidation is licensed under the terms of the MIT License

var LiveValidation = Class.create();

/*********************************************** LiveValidation class ***********************************/

/*** static ***/

Object.extend(LiveValidation, {
  
  VERSION: '1.3 prototype',
  
  /*** element types constants ***/
  TEXTAREA:  1,
  TEXT:         2,
  PASSWORD: 3,
  CHECKBOX:  4,
  SELECT:      5,
  FILE:          6,

  /**
   *	pass an array of LiveValidation objects and it will validate all of them
   *	
   *	@var validations {Array} - an array of LiveValidation objects
   *	@return {Bool} - true if all passed validation, false if any fail						
   */
  massValidate: function(validations){
    var returnValue = true;
    for(var i = 0, len = validations.length; i < len; ++i ){
      var valid = validations[i].validate();
      if(returnValue) returnValue = valid;
    }
    return returnValue;
  }

});

/*** prototype ***/

LiveValidation.prototype = {
    
  validClass: 'LV_valid',
  invalidClass: 'LV_invalid',
  messageClass: 'LV_validation_message',
  validFieldClass: 'LV_valid_field',
  invalidFieldClass: 'LV_invalid_field',
    
  /**
   *	constructor for LiveValidation - validates a form field in real-time based on validations you assign to it
   *	
   *	@var element {mixed} - either a dom element reference or the string id of the element to validate
   *	@var optionsObj {Object} - general options, see below for details
   *
   *	optionsObj properties:
   *							validMessage {String} 	- the message to show when the field passes validation
   *													  (DEFAULT: "Thank you!")
   *							onValid {Function} 		- function to execute when field passes validation
   *													  (DEFAULT: function(){ this.insertMessage(this.createMessageSpan()s); this.addFieldClass(); } )	
   *							onInvalid {Function} 	- function to execute when field fails validation
   *													  (DEFAULT: function(){ this.insertMessage(this.createMessageSpan()); this.addFieldClass(); })
   *							insertAfterWhatNode {mixed} 	- reference or id of node to have the message inserted after 
   *													  (DEFAULT: the field that is being validated
   *              onlyOnBlur {Boolean} - whether you want it to validate as you type or only on blur
   *                            (DEFAULT: false)
   *              wait {Integer} - the time you want it to pause from the last keystroke before it validates (ms)
   *                            (DEFAULT: 0)
   *              onlyOnSubmit {Boolean} - whether should be validated only when the form it belongs to is submitted
   *                            (DEFAULT: false)
   */
  initialize: function(element, optionsObj){
    // set up special properties (ones that need some extra processing or can be overidden from optionsObj)
    if(!element) throw new Error("LiveValidation::initialize - No element reference or element id has been provided!");
    this.element = $(element);
    if(!this.element) throw new Error("LiveValidation::initialize - No element with reference or id of '" + element + "' exists!");
    // properties that could not be initialised above
    this.elementType = this.getElementType();
    this.validations = [];
    this.form = this.element.form;
    // overwrite the options defaults with passed in ones
    this.options = Object.extend({
      validMessage: '',
      onValid: function(){ this.insertMessage(this.createMessageSpan()); this.addFieldClass(); },
      onInvalid: function(){ this.insertMessage(this.createMessageSpan()); this.addFieldClass(); },
      insertAfterWhatNode: this.element,
      onlyOnBlur: true,
      wait: 50,
      onlyOnSubmit: false
    }, optionsObj || {});
	var node = this.options.insertAfterWhatNode || this.element;
    this.options.insertAfterWhatNode = $(node);
    Object.extend(this, this.options); // copy the options to the actual object
    // add to form if it has been provided
    if(this.form){
      this.formObj = LiveValidationForm.getInstance(this.form);
      this.formObj.addField(this);
    }
    // events
	// event callbacks are cached so they can be stopped being observed
	this.boundFocus = this.doOnFocus.bindAsEventListener(this);
    Event.observe(this.element, 'focus', this.boundFocus);
    if(!this.onlyOnSubmit){
      switch(this.elementType){
        case LiveValidation.CHECKBOX:
		  this.boundClick = this.validate.bindAsEventListener(this);
          Event.observe(this.element, 'click', this.boundClick);
          // let it run into the next to add a change event too
        case LiveValidation.SELECT:
        case LiveValidation.FILE:
		  this.boundChange = this.validate.bindAsEventListener(this);
          Event.observe(this.element, 'change', this.boundChange);
          break;
        default:
          if(!this.onlyOnBlur){
		  	this.boundKeyup = this.deferValidation.bindAsEventListener(this);
		  	Event.observe(this.element, 'keyup', this.boundKeyup);
		  }
          this.boundBlur = this.validate.bindAsEventListener(this);
		  Event.observe(this.element, 'blur', this.boundBlur);
      }
    }
  },
  
  /**
   *	destroys the instance's events and removes it from any LiveValidationForms
   */
  destroy: function(){
  	if(this.formObj){
		// remove the field from the LiveValidationForm
		this.formObj.removeField(this);
		// destroy the LiveValidationForm if no LiveValidation fields left in it
		this.formObj.destroy();
	}
    // remove events
    Event.stopObserving(this.element, 'focus', this.boundFocus);
    if(!this.onlyOnSubmit){
      switch(this.elementType){
        case LiveValidation.CHECKBOX:
          Event.stopObserving(this.element, 'click', this.boundClick);
          // let it run into the next to add a change event too
        case LiveValidation.SELECT:
        case LiveValidation.FILE:
          Event.stopObserving(this.element, 'change', this.boundChange);
          break;
        default:
          if(!this.onlyOnBlur) Event.stopObserving(this.element, 'keyup', this.boundKeyup);
          Event.stopObserving(this.element, 'blur', this.boundBlur);
      }
    }
    this.validations = [];
	this.removeMessageAndFieldClass();
  },
  
  /**
   *	adds a validation to perform to a LiveValidation object
   *
   *	@var validationFunction {Function} - validation function to be used (ie Validate.Presence )
   *	@var validationParamsObj {Object} - parameters for doing the validation, if wanted or necessary
   * @return {Object} - the LiveValidation object itself so that calls can be chained
   */
  add: function(validationFunction, validationParamsObj){
    this.validations.push( { type: validationFunction, params: validationParamsObj || {} } );
    return this;
  },
  
  /**
     *	removes a validation from a LiveValidation object - must have exactly the same arguments as used to add it 
     *
     *	@var validationFunction {Function} - validation function to be used (ie Validate.Presence )
     *	@var validationParamsObj {Object} - parameters for doing the validation, if wanted or necessary
     * @return {Object} - the LiveValidation object itself so that calls can be chained
     */
    remove: function(validationFunction, validationParamsObj){
	  this.validations = this.validations.reject(function(v){
	  	return (v.type == validationFunction && v.params == validationParamsObj);
	  });
	  return this;
    },
    
  /**
   * makes the validation wait the alotted time from the last keystroke 
   */
  deferValidation: function(e){
    if(this.wait >= 300) this.removeMessageAndFieldClass();
    if(this.timeout) clearTimeout(this.timeout);
    this.timeout = setTimeout(this.validate.bind(this), this.wait);
  },
    
  /**
   * sets the focused flag to false when field loses focus  and triggers TinyMCE to save content into field
   */
  doOnBlur: function(){
	tinyMCE.triggerSave();
	this.focused = false;
    this.validate();
  },
  
   
  /**
   * sets the focused flag to true when field gains focus and removes old message and field class 
   */
  doOnFocus: function(){
    this.focused = true;
    this.removeMessageAndFieldClass();
  },
		
  /**
   *	gets the type of element, to check whether it is compatible
   *
   *	@var validationFunction {Function} - validation function to be used (ie Validate.Presence )
   *	@var validationParamsObj {Object} - parameters for doing the validation, if wanted or necessary
   */
  getElementType: function(){
    switch(true){
      case (this.element.nodeName.toUpperCase() == 'TEXTAREA'):
        return LiveValidation.TEXTAREA;
      case (this.element.nodeName.toUpperCase() == 'INPUT' && this.element.type.toUpperCase() == 'TEXT'):
        return LiveValidation.TEXT;
      case (this.element.nodeName.toUpperCase() == 'INPUT' && this.element.type.toUpperCase() == 'PASSWORD'):
        return LiveValidation.PASSWORD;
      case (this.element.nodeName.toUpperCase() == 'INPUT' && this.element.type.toUpperCase() == 'CHECKBOX'):
        return LiveValidation.CHECKBOX;
      case (this.element.nodeName.toUpperCase() == 'INPUT' && this.element.type.toUpperCase() == 'FILE'):
        return LiveValidation.FILE;
      case (this.element.nodeName.toUpperCase() == 'SELECT'):
        return LiveValidation.SELECT;
      case (this.element.nodeName.toUpperCase() == 'INPUT'):
        throw new Error('LiveValidation::getElementType - Cannot use LiveValidation on an ' + this.element.type + ' input!');
      default:
        throw new Error('LiveValidation::getElementType - Element must be an input, select, or textarea!');
    }
  },
    
  /**
   *	loops through all the validations added to the LiveValidation object and checks them one by one
   *
   *	@var validationFunction {Function} - validation function to be used (ie Validate.Presence )
   *	@var validationParamsObj {Object} - parameters for doing the validation, if wanted or necessary
   * @return {Boolean} - whether the all the validations passed or if one failed
   */
  doValidations: function(){
    this.validationFailed = false;
    for(var i = 0, len = this.validations.length; i < len; ++i){
      var validation = this.validations[i];
      switch(validation.type){
        case Validate.Presence:
        case Validate.Confirmation:
        case Validate.Acceptance:
          this.displayMessageWhenEmpty = true;
          this.validationFailed = !this.validateElement(validation.type, validation.params); 
          break;
        default:
          this.validationFailed = !this.validateElement(validation.type, validation.params);
          break;
      }
      if(this.validationFailed) return false;	
    }
    this.message = this.validMessage;
    return true;
  },
    
  /**
   *	performs validation on the element and handles any error (validation or otherwise) it throws up
   *
   *	@var validationFunction {Function} - validation function to be used (ie Validate.Presence )
   *	@var validationParamsObj {Object} - parameters for doing the validation, if wanted or necessary
   * @return {Boolean} - whether the validation has passed or failed
   */
  validateElement: function(validationFunction, validationParamsObj){
    var value = (this.elementType == LiveValidation.SELECT) ? this.element.options[this.element.selectedIndex].value : this.element.value;     
    if(validationFunction == Validate.Acceptance){
      if(this.elementType != LiveValidation.CHECKBOX) throw new Error('LiveValidation::validateElement - Element to validate acceptance must be a checkbox!');
      value = this.element.checked;
    }
    var isValid = true;
    try{    
      validationFunction(value, validationParamsObj);
    } catch(error) {
      if(error instanceof Validate.Error){
        if( value !== '' || (value === '' && this.displayMessageWhenEmpty) ){
          this.validationFailed = true;
          this.message = error.message;
          isValid = false;
        }
      }else{
        throw error;
      }
    }finally{
      return isValid;
    }
  },
    
  /**
   *	makes it do the all the validations and fires off the onValid or onInvalid callbacks
   *
   * @return {Boolean} - whether the all the validations passed or if one failed
   */
  validate: function(){
  	if(!this.element.disabled){
		var isValid = this.doValidations();
		if(isValid){
			this.onValid();
			return true;
		}else {
			this.onInvalid();
			return false;
		}
	}else{
    return true;
  }
  },
  
  /**
   *  enables the field
   *
   *  @return {LiveValidation} - the LiveValidation object for chaining
   */
  enable: function(){
  	this.element.disabled = false;
	return this;
  },
  
  /**
   *  disables the field and removes any message and styles associated with the field
   *
   *  @return {LiveValidation} - the LiveValidation object for chaining
   */
  disable: function(){
  	this.element.disabled = true;
	this.removeMessageAndFieldClass();
	return this;
  },
    
  /** Message insertion methods ****************************
   * 
   * These are only used in the onValid and onInvalid callback functions and so if you overide the default callbacks,
   * you must either impliment your own functions to do whatever you want, or call some of these from them if you 
   * want to keep some of the functionality
   */
   
  /**
   *	makes a span containg the passed or failed message
   *
   * @return {HTMLSpanObject} - a span element with the message in it
   */
  createMessageSpan: function(){
    var span = document.createElement('span');
    var textNode = document.createTextNode(this.message);
    span.appendChild(textNode);
    return span;
  },
    
  /**
   *	inserts the element containing the message in place of the element that already exists (if it does)
   *
   * @var elementToIsert {HTMLElementObject} - an element node to insert
   */
  insertMessage: function(elementToInsert){
    this.removeMessage();
    var className = this.validationFailed ? this.invalidClass : this.validClass;
    if( (this.displayMessageWhenEmpty && (this.elementType == LiveValidation.CHECKBOX || this.element.value == '')) || this.element.value != '' ){
      $(elementToInsert).addClassName( this.messageClass + (' ' + className) );
      if( nxtSibling = this.insertAfterWhatNode.nextSibling){
        this.insertAfterWhatNode.parentNode.insertBefore(elementToInsert, nxtSibling);
      }else{
        this.insertAfterWhatNode.parentNode.appendChild(elementToInsert);
      }
    }
  },
    
  /**
   *	changes the class of the field based on whether it is valid or not
   */
  addFieldClass: function(){ 
    this.removeFieldClass();
    if(!this.validationFailed){
      if(this.displayMessageWhenEmpty || this.element.value != ''){
        if(!this.element.hasClassName(this.validFieldClass)) this.element.addClassName(this.validFieldClass);
      }
    }else{
      if(!this.element.hasClassName(this.invalidFieldClass)) this.element.addClassName(this.invalidFieldClass);
    }
  },
    
  /**
   *	removes the message element if it exists
   */
  removeMessage: function(){
    if( nxtEl = this.insertAfterWhatNode.next('.' + this.messageClass) ) nxtEl.remove();
  },
    
  /**
   *	removes the class that has been applied to the field to indicte if valid or not
   */
  removeFieldClass: function(){
    this.element.removeClassName(this.invalidFieldClass);
    this.element.removeClassName(this.validFieldClass);
  },
    
  /**
   *	removes the message and the field class
   */
  removeMessageAndFieldClass: function(){
    this.removeMessage();
    this.removeFieldClass();
  }
   
} // end of LiveValidation.prototype object

/*************************************** LiveValidationForm class ****************************************/

var LiveValidationForm = Class.create();

/*** static ***/

Object.extend(LiveValidationForm, {

	/**
	 * namespace to hold instances
	 */
	instances: {},
	
	/**
	   *	gets the instance of the LiveValidationForm if it has already been made or creates it if it doesnt exist
	   *	
	   *	@var element {HTMLFormElement} - a dom element reference to a form
	   */
	getInstance: function(element){
	  var rand = Math.random() * Math.random();
	  if(!element.id) element.id = 'formId_' + rand.toString().replace(/\./, '') + new Date().valueOf();
	  if(!LiveValidationForm.instances[element.id]) LiveValidationForm.instances[element.id] = new LiveValidationForm(element);
	  return LiveValidationForm.instances[element.id];
	}

});

/*** prototype ***/

LiveValidationForm.prototype = {
  
  /**
   *	constructor for LiveValidationForm - handles validation of LiveValidation fields belonging to this form on its submittal
   *	
   *	@var element {HTMLFormElement} - a dom element reference to the form to turn into a LiveValidationForm
   */
  initialize: function(element){
    this.element = $(element);
    this.fields = [];
    // need to capture onsubmit in this way rather than Event.observe because Rails helpers add events inline
	// and must ensure that the validation is run before any previous submit events 
	//(hence not using Event.observe, as inline events appear to be captured before prototype events)
	// tinyMCE save needs to be triggered here so live validation recognises content in the rich text editor
	this.oldOnSubmit = this.element.onsubmit || function(){};
	this.element.onsubmit = function(e){
		tinyMCE.triggerSave(this.fields);
	  var ret = (LiveValidation.massValidate(this.fields)) ? this.oldOnSubmit.call(this.element, e) !== false : false;
	  if (!ret) Event.stop(e)
    }.bindAsEventListener(this);
  },
  
  /**
   *	adds a LiveValidation field to the forms fields array
   *	
   *	@var lvObj {LiveValidation} - a LiveValidation object
   */
  addField: function(lvObj){
    this.fields.push(lvObj);
  },
  
  /**
   *	removes a LiveValidation field from the forms fields array
   *	
   *	@var victim {LiveValidation} - a LiveValidation object
   */
  removeField: function(victim){
	this.fields = this.fields.without(victim);
  },
  
  /**
   *	destroy this instance and its events
   *
   * @var force {Boolean} - whether to force the detruction even if there are fields still associated
   */
  destroy: function(force){
  	// only destroy if has no fields and not being forced
  	if (this.fields.length != 0 && !force) return false;
	// remove events
	this.element.onsubmit = this.oldOnSubmit;
	// remove from the instances namespace
	LiveValidationForm.instances[this.element.id] = null;
	return true;
  }
   
}// end of LiveValidationForm prototype

/*************************************** Validate class ****************************************/
/**
 * This class contains all the methods needed for doing the actual validation itself
 *
 * All methods are static so that they can be used outside the context of a form field
 * as they could be useful for validating stuff anywhere you want really
 *
 * All of them will return true if the validation is successful, but will raise a ValidationError if
 * they fail, so that this can be caught and the message explaining the error can be accessed ( as just 
 * returning false would leave you a bit in the dark as to why it failed )
 *
 * Can use validation methods alone and wrap in a try..catch statement yourself if you want to access the failure
 * message and handle the error, or use the Validate::now method if you just want true or false
 */

var Validate = {

  /**
   *	validates that the field has been filled in
   *
   *	@var value {mixed} - value to be checked
   *	@var paramsObj {Object} - parameters for this particular validation, see below for details
   *
   *	paramsObj properties:
   *							failureMessage {String} - the message to show when the field fails validation 
   *													  (DEFAULT: "Can't be empty!")
   */
  Presence: function(value, paramsObj){
    var params = Object.extend({
      failureMessage: "Can't be empty!"
    }, paramsObj || {});
    if(value === '' || value === null || value === undefined) Validate.fail(params.failureMessage);
    return true;
  },
    
  /**
   *	validates that the value is numeric, does not fall within a given range of numbers
   *	
   *	@var value {mixed} - value to be checked
   *	@var paramsObj {Object} - parameters for this particular validation, see below for details
   *
   *	paramsObj properties:
   *							notANumberMessage {String} - the message to show when the validation fails when value is not a number
   *													  	  (DEFAULT: "Must be a number!")
   *							notAnIntegerMessage {String} - the message to show when the validation fails when value is not an integer
   *													  	  (DEFAULT: "Must be a number!")
   *							wrongNumberMessage {String} - the message to show when the validation fails when is param is used
   *													  	  (DEFAULT: "Must be {is}!")
   *							tooLowMessage {String} 		- the message to show when the validation fails when minimum param is used
   *													  	  (DEFAULT: "Must not be less than {minimum}!")
   *							tooHighMessage {String} 	- the message to show when the validation fails when maximum param is used
   *													  	  (DEFAULT: "Must not be more than {maximum}!")
   *							is {Int} 					- the value must be equal to this numeric value
   *							minimum {Int} 				- the minimum numeric allowed
   *							maximum {Int} 				- the maximum numeric allowed
   *                          onlyInteger {Boolean} - if true will only allow integers to be valid
   *                                                             (DEFAULT: false)
   *
   *  NB. can be checked if it is within a range by specifying both a minimum and a maximum
   *  NB. will evaluate numbers represented in scientific form (ie 2e10) correctly as numbers				
   */
  Numericality: function(value, paramsObj){
    var suppliedValue = value;
    var value = Number(value);
    var paramsObj = paramsObj || {};
    var params = { 
      notANumberMessage:  paramsObj.notANumberMessage || "Must be a number!",
      notAnIntegerMessage: paramsObj.notAnIntegerMessage || "Must be an integer!",
      wrongNumberMessage: paramsObj.wrongNumberMessage || "Must be " + paramsObj.is + "!",
      tooLowMessage:         paramsObj.tooLowMessage || "Must not be less than " + paramsObj.minimum + "!",
      tooHighMessage:        paramsObj.tooHighMessage || "Must not be more than " + paramsObj.maximum + "!", 
      is:                            ((paramsObj.is) || (paramsObj.is == 0)) ? paramsObj.is : null,
      minimum:                   ((paramsObj.minimum) || (paramsObj.minimum == 0)) ? paramsObj.minimum : null,
      maximum:                  ((paramsObj.maximum) || (paramsObj.maximum == 0)) ? paramsObj.maximum : null,
      onlyInteger:               paramsObj.onlyInteger || false
    };
    if (!isFinite(value))  Validate.fail(params.notANumberMessage);
    if (params.onlyInteger && ( ( /\.0+$|\.$/.test(String(suppliedValue)) )  || ( value != parseInt(value) ) ) ) Validate.fail(params.notAnIntegerMessage);
    switch(true){
      case (params.is !== null):
        if( value != Number(params.is) ) Validate.fail(params.wrongNumberMessage);
        break;
      case (params.minimum !== null && params.maximum !== null):
        Validate.Numericality(value, {tooLowMessage: params.tooLowMessage, minimum: params.minimum});
        Validate.Numericality(value, {tooHighMessage: params.tooHighMessage, maximum: params.maximum});
        break;
      case (params.minimum !== null):
        if( value < Number(params.minimum) ) Validate.fail(params.tooLowMessage);
        break;
      case (params.maximum !== null):
        if( value > Number(params.maximum) ) Validate.fail(params.tooHighMessage);
        break;
    }
    return true;
  },
    
  /**
   *	validates against a RegExp pattern
   *	
   *	@var value {mixed} - value to be checked
   *	@var paramsObj {Object} - parameters for this particular validation, see below for details
   *
   *	paramsObj properties:
   *							failureMessage {String} - the message to show when the field fails validation
   *													  (DEFAULT: "Not valid!")
   *							pattern {RegExp} 		- the regular expression pattern
   *													  (DEFAULT: /./)
   *             negate {Boolean} - if set to true, will validate true if the pattern is not matched
   *                           (DEFAULT: false)
   *
   *  NB. will return true for an empty string, to allow for non-required, empty fields to validate.
   *		If you do not want this to be the case then you must either add a LiveValidation.PRESENCE validation
   *		or build it into the regular expression pattern
   */
  Format: function(value, paramsObj){
    var value = String(value);
    var params = Object.extend({ 
      failureMessage: "Not valid!",
      pattern:           /./ ,
      negate:            false
    }, paramsObj || {});
    if(!params.negate && !params.pattern.test(value)) Validate.fail(params.failureMessage); // normal
    if(params.negate && params.pattern.test(value)) Validate.fail(params.failureMessage); // negated
    return true;
  },
    
  /**
   *	validates that the field contains a valid email address
   *	
   *	@var value {mixed} - value to be checked
   *	@var paramsObj {Object} - parameters for this particular validation, see below for details
   *
   *	paramsObj properties:
   *							failureMessage {String} - the message to show when the field fails validation
   *													  (DEFAULT: "Must be a number!" or "Must be an integer!")
   */
  Email: function(value, paramsObj){
    var params = Object.extend({ 
      failureMessage: "Must be a valid email address!"
    }, paramsObj || {});
    Validate.Format(value, { failureMessage: params.failureMessage, pattern: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i } );
    return true;
  },
    
  /**
   *	validates the length of the value
   *	
   *	@var value {mixed} - value to be checked
   *	@var paramsObj {Object} - parameters for this particular validation, see below for details
   *
   *	paramsObj properties:
   *							wrongLengthMessage {String} - the message to show when the fails when is param is used
   *													  	  (DEFAULT: "Must be {is} characters long!")
   *							tooShortMessage {String} 	- the message to show when the fails when minimum param is used
   *													  	  (DEFAULT: "Must not be less than {minimum} characters long!")
   *							tooLongMessage {String} 	- the message to show when the fails when maximum param is used
   *													  	  (DEFAULT: "Must not be more than {maximum} characters long!")
   *							is {Int} 					- the length must be this long 
   *							minimum {Int} 				- the minimum length allowed
   *							maximum {Int} 				- the maximum length allowed
   *
   *  NB. can be checked if it is within a range by specifying both a minimum and a maximum				
   */
  Length: function(value, paramsObj){
    var value = String(value);
    var paramsObj = paramsObj || {};
    var params = { 
      wrongLengthMessage: paramsObj.wrongLengthMessage || "Must be " + paramsObj.is + " characters long!",
      tooShortMessage:      paramsObj.tooShortMessage || "Must not be less than " + paramsObj.minimum + " characters long!",
      tooLongMessage:       paramsObj.tooLongMessage || "Must not be more than " + paramsObj.maximum + " characters long!",
      is:                           ((paramsObj.is) || (paramsObj.is == 0)) ? paramsObj.is : null,
      minimum:                  ((paramsObj.minimum) || (paramsObj.minimum == 0)) ? paramsObj.minimum : null,
      maximum:                 ((paramsObj.maximum) || (paramsObj.maximum == 0)) ? paramsObj.maximum : null
    }
    switch(true){
      case (params.is !== null):
        if( value.length != Number(params.is) ) Validate.fail(params.wrongLengthMessage);
        break;
      case (params.minimum !== null && params.maximum !== null):
        Validate.Length(value, {tooShortMessage: params.tooShortMessage, minimum: params.minimum});
        Validate.Length(value, {tooLongMessage: params.tooLongMessage, maximum: params.maximum});
        break;
      case (params.minimum !== null):
        if( value.length < Number(params.minimum) ) Validate.fail(params.tooShortMessage);
        break;
      case (params.maximum !== null):
        if( value.length > Number(params.maximum) ) Validate.fail(params.tooLongMessage);
        break;
      default:
        throw new Error("Validate::Length - Length(s) to validate against must be provided!");
    }
    return true;
  },
    
  /**
   *	validates that the value falls within a given set of values
   *	
   *	@var value {mixed} - value to be checked
   *	@var paramsObj {Object} - parameters for this particular validation, see below for details
   *
   *	paramsObj properties:
   *							failureMessage {String} - the message to show when the field fails validation
   *													  (DEFAULT: "Must be included in the list!")
   *							within {Array} 			- an array of values that the value should fall in 
   *													  (DEFAULT: [])	
   *							allowNull {Bool} 		- if true, and a null value is passed in, validates as true
   *													  (DEFAULT: false)
   *             partialMatch {Bool} 	- if true, will not only validate against the whole value to check but also if it is a substring of the value 
   *													  (DEFAULT: false)
   *             caseSensitive {Bool} - if false will compare strings case insensitively
   *                          (DEFAULT: true)
   *             negate {Bool} - if true, will validate that the value is not within the given set of values
   *													  (DEFAULT: false)			
   */
  Inclusion: function(value, paramsObj){
    var params = Object.extend({
    failureMessage: "Must be included in the list!",
      within:           [],
      allowNull:        false,
      partialMatch:   false,
      caseSensitive: true,
      negate:          false
    }, paramsObj || {});
    if(params.allowNull && value == null) return true;
    if(!params.allowNull && value == null) Validate.fail(params.failureMessage);
    //if case insensitive, make all strings in the array lowercase, and the value too
    if(!params.caseSensitive){ 
      var lowerWithin = [];
      params.within.each( function(item){
        if(typeof item == 'string') item = item.toLowerCase();
        lowerWithin.push(item);
      });
      params.within = lowerWithin;
      if(typeof value == 'string') value = value.toLowerCase();
    }
    var found = (params.within.indexOf(value) == -1) ? false : true;
    if(params.partialMatch){
      found = false;
      params.within.each( function(arrayVal){
        if(value.indexOf(arrayVal) != -1 ) found = true;
      }); 
    }
    if( (!params.negate && !found) || (params.negate && found) ) Validate.fail(params.failureMessage);
    return true;
  },
    
  /**
   *	validates that the value does not fall within a given set of values (shortcut for using Validate.Inclusion with exclusion: true)
   *	
   *	@var value {mixed} - value to be checked
   *	@var paramsObj {Object} - parameters for this particular validation, see below for details
   *
   *	paramsObj properties:
   *							failureMessage {String} - the message to show when the field fails validation
   *													  (DEFAULT: "Must not be included in the list!")
   *							within {Array} 			- an array of values that the value should not fall in 
   *													  (DEFAULT: [])
   *							allowNull {Bool} 		- if true, and a null value is passed in, validates as true
   *													  (DEFAULT: false)
   *             partialMatch {Bool} 	- if true, will not only validate against the whole value to check but also if it is a substring of the value 
   *													  (DEFAULT: false)
   *             caseSensitive {Bool} - if false will compare strings case insensitively
   *                          (DEFAULT: true)					
   */
  Exclusion: function(value, paramsObj){
    var params = Object.extend({
      failureMessage: "Must not be included in the list!",
      within:             [],
      allowNull:          false,
      partialMatch:     false,
      caseSensitive:   true
    }, paramsObj || {});
    params.negate = true;// set outside of params so cannot be overridden
    Validate.Inclusion(value, params);
    return true;
  },
    
  /**
   *	validates that the value matches that in another field
   *	
   *	@var value {mixed} - value to be checked
   *	@var paramsObj {Object} - parameters for this particular validation, see below for details
   *
   *	paramsObj properties:
   *							failureMessage {String} - the message to show when the field fails validation
   *													  (DEFAULT: "Does not match!")
   *							match {String} 			- id of the field that this one should match						
   */
  Confirmation: function(value, paramsObj){
    if(!paramsObj.match) throw new Error("Validate::Confirmation - Error validating confirmation: Id of element to match must be provided!");
    var params = Object.extend({
      failureMessage: "Does not match!",
      match:            null
    }, paramsObj || {});
    params.match = $(paramsObj.match);
    if(!params.match) throw new Error("Validate::Confirmation - There is no reference with name of, or element with id of '" + params.match + "'!");
    if(value != params.match.value) Validate.fail(params.failureMessage);
    return true;
  },
    
  /**
   *	validates that the value is true (for use primarily in detemining if a checkbox has been checked)
   *	
   *	@var value {mixed} - value to be checked if true or not (usually a boolean from the checked value of a checkbox)
   *	@var paramsObj {Object} - parameters for this particular validation, see below for details
   *
   *	paramsObj properties:
   *							failureMessage {String} - the message to show when the field fails validation 
   *													  (DEFAULT: "Must be accepted!")
   */
  Acceptance: function(value, paramsObj){
    var params = Object.extend({
      failureMessage: "Must be accepted!"
    }, paramsObj || {});
    if(!value) Validate.fail(params.failureMessage);
    return true;
  },
  
   /**
     *	validates against a custom function that returns true or false (or throws a Validate.Error) when passed the value
     *	
     *	@var value {mixed} - value to be checked
     *	@var paramsObj {Object} - parameters for this particular validation, see below for details
     *
     *	paramsObj properties:
     *							failureMessage {String} - the message to show when the field fails validation
     *													  (DEFAULT: "Not valid!")
     *							against {Function} 			- a function that will take the value and object of arguments and return true or false 
     *													  (DEFAULT: function(){ return true; })
     *							args {Object} 		- an object of named arguments that will be passed to the custom function so are accessible through this object within it 
     *													  (DEFAULT: {})
     */
  Custom: function(value, paramsObj){
    var params = Object.extend({
	  against: function(){ return true; },
	  args: {},
      failureMessage: "Not valid!"
    }, paramsObj || {});
    if(!params.against(value, params.args)) Validate.fail(params.failureMessage);
    return true;
  },
    
  /**
   *	validates whatever it is you pass in, and handles the validation error for you so it gives a nice true or false reply
   *
   *	@var validationFunction {Function} - validation function to be used (ie Validate.Presence )
   *	@var value {mixed} - value to be checked 
   *	@var validationParamsObj {Object} - parameters for doing the validation, if wanted or necessary
   */
  now: function(validationFunction, value, validationParamsObj){
    if(!validationFunction) throw new Error("Validate::now - Validation function must be provided!");
    var isValid = true;
    try{    
      validationFunction(value, validationParamsObj || {});
    } catch(error) {
      if(error instanceof Validate.Error){
        isValid =  false;
      }else{
        throw error;
      }
    }finally{ 
      return isValid 
    }
  },
  
    
  Error: function(errorMessage){
    this.message = errorMessage;
    this.name = 'ValidationError';
  },
    
  fail: function(errorMessage){
    throw new Validate.Error(errorMessage);
  }

} // end of Validate object