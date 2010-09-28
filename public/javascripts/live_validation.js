// LiveValidation 1.4 (prototype.js version)
// Copyright (c) 2007-2008 Alec Hill (www.livevalidation.com)
// LiveValidation is licensed under the terms of the MIT License

var LiveValidation = Class.create();

/*********************************************** LiveValidation class ***********************************/

/*** static ***/

Object.extend(LiveValidation, {
  
  VERSION: '1.4 prototype',
  
  /*** element types constants ***/
  TEXTAREA:  1,
  TEXT:      2,
  PASSWORD:  3,
  CHECKBOX:  4,
  SELECT:    5,
  FILE:      6,

  /**
   *	pass an array of LiveValidation objects and it will validate all of them
   *	
   *	@param validations {Array} - an array of LiveValidation objects
   *	@return {Bool} - true if all passed validation, false if any fail						
   */
  massValidate: function(validations){
    var ret = true;
    for(var i = 0, len = validations.length; i < len; ++i ){
      var valid = validations[i].validate();
      if(ret) ret = valid;
    }
    return ret;
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
   *	@param element {mixed} - either a dom element reference or the string id of the element to validate
   *	@param optionsObj {Object} - general options, see below for details
   *
   *	optionsObj properties:
   *							validMessage {String} 	- the message to show when the field passes validation (set to '' or false to not insert any message)
   *													  (DEFAULT: "Thankyou!")
   *                            beforeValidation {Function} - function to execute directly before validation is performed
   *													  (DEFAULT: function(){})
   *                            beforeValid {Function}  - function to execute directly before the onValid function is executed
   *													  (DEFAULT: function(){})
   *							onValid {Function} 		- function to execute when field passes validation
   *													  (DEFAULT: function(){ this.insertMessage(this.createMessageSpan()s); this.addFieldClass(); } )
   *                            afterValid {Function}   - function to execute directly after the onValid function is executed
   *													  (DEFAULT: function(){})
   *                            beforeInvalid {Function} - function to execute directly before the onInvalid function is executed
   *													  (DEFAULT: function(){})	
   *							onInvalid {Function} 	- function to execute when field fails validation
   *													  (DEFAULT: function(){ this.insertMessage(this.createMessageSpan()); this.addFieldClass(); })
   *                            aterInvalid {Function}  - function to execute directly after the onInvalid function is executed
   *													  (DEFAULT: function(){})
   *                            afterValidation {Function} - function to execute directly after validation is performed
   *													  (DEFAULT: function(){})
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
      validMessage: 'Thankyou!',
      insertAfterWhatNode: this.element,
      onlyOnBlur: false,
      wait: 0,
      onlyOnSubmit: false,
	  // hooks
	  beforeValidation: function(){},
	  beforeValid: function(){},
	  onValid: function(){ this.insertMessage(this.createMessageSpan()); this.addFieldClass(); },
	  afterValid: function(){},
	  beforeInvalid: function(){},
	  onInvalid: function(){ this.insertMessage(this.createMessageSpan()); this.addFieldClass(); },
	  afterInvalid: function(){},
	  afterValidation: function(){},
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
	this.cFocus = this.doOnFocus.bindAsEventListener(this);
    Event.observe(this.element, 'focus', this.cFocus);
    this.cBlur = this.doOnBlur.bindAsEventListener(this);
	Event.observe(this.element, 'blur', this.cBlur);
    if(!this.onlyOnSubmit){
      switch(this.elementType){
        case LiveValidation.CHECKBOX:
		  this.cClick = this.validate.bindAsEventListener(this);
          Event.observe(this.element, 'click', this.cClick);
          // let it run into the next to add a change event too
        case LiveValidation.SELECT:
        case LiveValidation.FILE:
		  this.cChange = this.validate.bindAsEventListener(this);
          Event.observe(this.element, 'change', this.cChange);
          break;
        default:
          if(!this.onlyOnBlur){
		  	this.cKeyup = this.deferValidation.bindAsEventListener(this);
		  	Event.observe(this.element, 'keyup', this.cKeyup);
		  }
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
	var el = this.element;
    Event.stopObserving(el, 'focus', this.cFocus);
    Event.stopObserving(el, 'blur', this.cBlur);
    if(!this.onlyOnSubmit){
      switch(this.elementType){
        case LiveValidation.CHECKBOX:
          Event.stopObserving(el, 'click', this.cClick);
          // let it run into the next to add a change event too
        case LiveValidation.SELECT:
        case LiveValidation.FILE:
          Event.stopObserving(el, 'change', this.cChange);
          break;
        default:
          if(!this.onlyOnBlur) Event.stopObserving(el, 'keyup', this.cKeyup);
      }
    }
    this.validations = [];
	this.removeMessageAndFieldClass();
  },
  
  /**
   *	adds a validation to perform to a LiveValidation object
   *
   *	@param validationFunction {Function} - validation function to be used (ie Validate.Presence )
   *	@param validationParamsObj {Object} - parameters for doing the validation, if wanted or necessary
   *    @return {Object} - the LiveValidation object itself so that calls can be chained
   */
  add: function(validationFunction, validationParamsObj){
	// if Validate.Remote must make it run the LiveValidation hooks when AJAX responds
	if(validationFunction == Validate.Remote){
		validationParamsObj.onResponse = function(valid, paramsUsed){
			this.validationFailed = !valid;
			if(valid){
				this.message = this.validMessage;
				this.beforeValid();
				this.onValid();
				this.afterValid();
			}else{
				this.message = paramsUsed.failureMessage;
				this.beforeInvalid();
	        	this.onInvalid();
				this.afterInvalid();
			}
		}.bind(this);
	}
    this.validations.push( { type: validationFunction, params: validationParamsObj || {} } );
	// @todo - do not want to send AJAX request with value we already know is invalid, so move all Remote validations to the back of the stack
    return this;
  },
  
  /**
     *	removes a validation from a LiveValidation object - must have exactly the same arguments as used to add it 
     *
     *	@param validationFunction {Function} - validation function to be used (ie Validate.Presence )
     *	@param validationParamsObj {Object} - parameters for doing the validation, if wanted or necessary
     *  @return {Object} - the LiveValidation object itself so that calls can be chained
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
   * sets the focused flag to false when field loses focus 
   */
  doOnBlur: function(){
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
   *	@param validationFunction {Function} - validation function to be used (ie Validate.Presence )
   *	@param validationParamsObj {Object} - parameters for doing the validation, if wanted or necessary
   */
  getElementType: function(){
	var nn = this.element.nodeName.toUpperCase();
	var nt = this.element.type.toUpperCase();
    switch(true){
      case (nn == 'TEXTAREA'):
        return LiveValidation.TEXTAREA;
      case (nn == 'INPUT' && nt == 'TEXT'):
        return LiveValidation.TEXT;
      case (nn == 'INPUT' && nt == 'PASSWORD'):
        return LiveValidation.PASSWORD;
      case (nn == 'INPUT' && nt == 'CHECKBOX'):
        return LiveValidation.CHECKBOX;
      case (nn == 'INPUT' && nt == 'FILE'):
        return LiveValidation.FILE;
      case (nn == 'SELECT'):
        return LiveValidation.SELECT;
      case (nn == 'INPUT'):
        throw new Error('LiveValidation::getElementType - Cannot use LiveValidation on an ' + nt.toLowerCase() + ' input!');
      default:
        throw new Error('LiveValidation::getElementType - Element must be an input, select, or textarea - ' + nn.toLowerCase() + ' was given!');
    }
  },
    
  /**
   *	loops through all the validations added to the LiveValidation object and checks them one by one
   *
   *	@param validationFunction {Function} - validation function to be used (ie Validate.Presence )
   *	@param validationParamsObj {Object} - parameters for doing the validation, if wanted or necessary
   *    @return {Boolean} - whether the all the validations passed or if one failed
   */
  doValidations: function(){
    this.validationFailed = false;
    for(var i = 0, len = this.validations.length; i < len; ++i){
		this.validationFailed = !this.validateElement(this.validations[i].type, this.validations[i].params);
	  	if(this.validationFailed) return false;	
    }
    this.message = this.validMessage;
    return true;
  },
    
  /**
   *	performs validation on the element and handles any error (validation or otherwise) it throws up
   *
   *	@param validationFunction {Function} - validation function to be used (ie Validate.Presence )
   *	@param validationParamsObj {Object} - parameters for doing the validation, if wanted or necessary
   *    @return {Boolean} - whether the validation has passed or failed
   */
  validateElement: function(validationFunction, validationParamsObj){
  	// check whether we should display the message when empty
	switch(validationFunction){
    	case Validate.Presence:
        case Validate.Confirmation:
        case Validate.Acceptance:
    		this.displayMessageWhenEmpty = true;
    		break;
		case Validate.Custom:
			if(validationParamsObj.displayMessageWhenEmpty) this.displayMessageWhenEmpty = true;
			break;
    }
	// select and checkbox elements values are handled differently
    var value = (this.elementType == LiveValidation.SELECT) ? this.element.options[this.element.selectedIndex].value : this.element.value;     
    if(validationFunction == Validate.Acceptance){
      if(this.elementType != LiveValidation.CHECKBOX) throw new Error('LiveValidation::validateElement - Element to validate acceptance must be a checkbox!');
      value = this.element.checked;
    }
	// if empty and a Remote validation, we dont even bother sending the request...should apply a Presence as well if required
	// if focused then validation is running on a keyup, so dont send otherwise will fire multiple AJAX requests -  let it happen once on blur
	if( validationFunction == Validate.Remote){
		if(value === '' || this.focused ) return true;
	}
	// now validate
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
   *	makes it do the all the validations and fires off the various callbacks
   *
   *    @return {Boolean} - whether the all the validations passed or if one failed
   */
  validate: function(){
  	if(!this.element.disabled){
		this.beforeValidation();
		var isValid = this.doValidations();
		if(isValid){
			this.beforeValid();
			this.onValid();
			this.afterValid();
			return true;
		}else {
			this.beforeInvalid();
			this.onInvalid();
			this.afterInvalid();
			return false;
		}
		this.afterValidation();
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
   *    @return {HTMLSpanObject} - a span element with the message in it
   */
  createMessageSpan: function(){
    var span = document.createElement('span');
    var textNode = document.createTextNode(this.message);
    span.appendChild(textNode);
    return span;
  },
    
  /**
   *  inserts the element containing the message in place of the element that already exists (if it does)
   *
   *  @param elementToInsert {HTMLElementObject} - an element node to insert
   */
  insertMessage: function(elementToInsert){
    this.removeMessage();
    if(!this.validationFailed && !this.validMessage) return; // dont insert anything if validMesssage has been set to false or empty string
    if( (this.displayMessageWhenEmpty && (this.elementType == LiveValidation.CHECKBOX || this.element.value == '')) || this.element.value != '' ){
      var className = this.validationFailed ? this.invalidClass : this.validClass;
	  $(elementToInsert).addClassName( this.messageClass + ' ' + className );
	  var parent = this.insertAfterWhatNode.up();
      if( nxtSibling = this.insertAfterWhatNode.next()){
        parent.insertBefore(elementToInsert, nxtSibling);
      }else{
        parent.appendChild(elementToInsert);
      }
    }
  },
    
  /**
   *  changes the class of the field based on whether it is valid or not
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
	var nxtEl = this.insertAfterWhatNode.next('.' + this.messageClass);
    if(nxtEl) nxtEl.remove();
  },
    
  /**
   *  removes the class that has been applied to the field to indicte if valid or not
   */
  removeFieldClass: function(){
    this.element.removeClassName(this.invalidFieldClass);
    this.element.removeClassName(this.validFieldClass);
  },
    
  /**
   *  removes the message and the field class
   */
  removeMessageAndFieldClass: function(){
    this.removeMessage();
    this.removeFieldClass();
  }
   
}

/*************************************** LiveValidationForm class ****************************************/
/**
 * This class is used internally by LiveValidation class to associate a LiveValidation field with a form it is icontained in one
 * 
 * It will therefore not really ever be needed to be used directly by the developer, unless they want to associate a LiveValidation 
 * field with a form that it is not a child of, or add some extra functionality via the hooks (access through a LiveValidation object's formObj property)
 */

var LiveValidationForm = Class.create();

/*** static ***/

Object.extend(LiveValidationForm, {

	/**
	 *  namespace to hold instances
	 */
	instances: {},
	
	/**
	   *	gets the instance of the LiveValidationForm if it has already been made or creates it if it doesnt exist
	   *	
	   *	@param element {mixed} - a dom element reference to or id of a form
	   */
	getInstance: function(element){
	  if(!element) throw new Error("LiveValidationForm::getInstance - No element reference or element id has been provided!");
	  var el = $(element);
	  var rand = Math.random() * Math.random();
	  if(!el.id) el.id = 'formId_' + rand.toString().replace(/\./, '') + new Date().valueOf();
	  if(!LiveValidationForm.instances[el.id]) LiveValidationForm.instances[el.id] = new LiveValidationForm(el);
	  return LiveValidationForm.instances[el.id];
	}

});

/*** prototype ***/

LiveValidationForm.prototype = {
  
  // hooks
  beforeValidation: function(){},
  onValid: function(){},
  onInvalid: function(){},
  afterValidation: function(){},

  /**
   *	constructor for LiveValidationForm - handles validation of LiveValidation fields belonging to this form on its submittal
   *	
   *	@param element {HTMLFormElement} - a dom element reference to the form to turn into a LiveValidationForm
   */
  initialize: function(element){
    this.element = $(element);
    this.fields = [];
    // need to capture onsubmit in this way rather than Event.observe because Rails helpers add events inline
	// and must ensure that the validation is run before any previous submit events 
	//(hence not using Event.observe, as inline events appear to be captured before prototype events)
	this.oldOnSubmit = this.element.onsubmit || function(){};
	this.element.onsubmit = function(e){
	  var ret = false;
	  this.beforeValidation(),
      this.valid = LiveValidation.massValidate(this.fields);
      this.valid ? this.onValid() : this.onInvalid();
      this.afterValidation();
	  if(this.valid) ret = this.oldOnSubmit.call(this.element, e) !== false;
	  if(!ret) Event.stop(e);
    }.bindAsEventListener(this);
  },
  
  /**
   *	adds a LiveValidation field to the forms fields array
   *	
   *	@param lvObj {LiveValidation} - a LiveValidation object
   */
  addField: function(lvObj){
    this.fields.push(lvObj);
  },
  
  /**
   *	removes a LiveValidation field from the forms fields array
   *	
   *	@param victim {LiveValidation} - a LiveValidation object
   */
  removeField: function(victim){
	this.fields = this.fields.without(victim);
  },
  
  /**
   *    destroy this instance and its events
   *
   *    @param force {Boolean} - whether to force the detruction even if there are fields still associated
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
   
}

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
   *	@param value {mixed} - value to be checked
   *	@param paramsObj {Object} - parameters for this particular validation, see below for details
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
   *	@param value {mixed} - value to be checked
   *	@param paramsObj {Object} - parameters for this particular validation, see below for details
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
   *	@param value {mixed} - value to be checked
   *	@param paramsObj {Object} - parameters for this particular validation, see below for details
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
      pattern:        /./,
      negate:   	  false
    }, paramsObj || {});
    if(!params.negate && !params.pattern.test(value)) Validate.fail(params.failureMessage); // normal
    if(params.negate && params.pattern.test(value)) Validate.fail(params.failureMessage); // negated
    return true;
  },
    
  /**
   *	validates that the field contains a valid email address
   *	
   *	@param value {mixed} - value to be checked
   *	@param paramsObj {Object} - parameters for this particular validation, see below for details
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
   *	@param value {mixed} - value to be checked
   *	@param paramsObj {Object} - parameters for this particular validation, see below for details
   *
   *	paramsObj properties:
   *							 wrongLengthMessage {String} - the message to show when the fails when is param is used
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
   *	@param value {mixed} - value to be checked
   *	@param paramsObj {Object} - parameters for this particular validation, see below for details
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
   *	@param value {mixed} - value to be checked
   *	@param paramsObj {Object} - parameters for this particular validation, see below for details
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
   *	@param value {mixed} - value to be checked
   *	@param paramsObj {Object} - parameters for this particular validation, see below for details
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
   *	@param value {mixed} - value to be checked if true or not (usually a boolean from the checked value of a checkbox)
   *	@param paramsObj {Object} - parameters for this particular validation, see below for details
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
     *	@param value {mixed} - value to be checked
     *	@param paramsObj {Object} - parameters for this particular validation, see below for details
     *
     *	paramsObj properties:
     *							failureMessage {String} - the message to show when the field fails validation
     *													  (DEFAULT: "Not valid!")
     *							against {Function} 			- a function that will take the value and object of arguments and return true or false 
     *													  (DEFAULT: function(value, argsObj){ return true; })
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
   *	validates a value against a remote function, passing 'value' parameter, response should be true for a valid value
   *
   *	@var value {mixed} - value to be checked
   *	@var paramsObj {Object} - parameters for this particular validation, see below for details
   *
   *	paramsObj properties:
   *							failureMessage {String} - the message to show when the field fails validation 
   *													  (DEFAULT: "Already been taken!")
   *              				loadingMessage {String} - the message to show when the call is being made
   *													  (DEFAULT: "Checking, please wait...")
   *              				requestParamsObj {Object} - parameters for the ajax request (see Prototype.js api for options)
   *							url {String} 			- the url to send the request to
   *													  (DEFAULT: "")
   *							onResponse {Function} 	- a function to perform on response (passes whether valid, and params used)
   *													  (DEFAULT: function(valid, paramsUsed){})
   */
  Remote: function(value, paramsObj){
    var params = Object.extend({
		url: '',
  		failureMessage: "Already been taken!",
		loadingMessage: "Checking, please wait...",
		onResponse: function(valid){}
  	}, paramsObj || {});
	var request = new Ajax.Request( 
	  	params.url, 
		Object.extend({ 
			method: 'get',
			parameters: { value: value },
			onSuccess: function(transport){
			  	var valid = Validate.now( Validate.Inclusion, transport.responseText, { within: [true, 'true', 1, '1'] } );
				params.onResponse(valid, params);
			},
			onFailed: function(){ throw new Error("Validate::Remote - Error: request failed") }
		}, params.requestParamsObj || {} )
	);
	// fail to show loading message until ajax returns response and does something else
	Validate.fail(params.loadingMessage);
  },

  /**
   *	validates whatever it is you pass in, and handles the validation error for you so it gives a nice true or false reply
   *
   *	@param validationFunction {Function} - validation function to be used (ie Validate.Presence )
   *	@param value {mixed} - value to be checked 
   *	@param validationParamsObj {Object} - parameters for doing the validation, if wanted or necessary
   */
  now: function(validationFunction, value, validationParamsObj){
    if(!validationFunction) throw new Error("Validate::now - Validation function must be provided!");
    var isValid = true;
    try{    
      validationFunction(value, validationParamsObj || {});
    }catch(error){
      if(error instanceof Validate.Error){
        isValid = false;
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

}