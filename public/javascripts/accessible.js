/**
 * @author Administrator
 */
// Alters default browser behaviours for drop-down menus: if navigating by keys the form will be submitted ONLY
// when 'Enter' is pressed (not when tabbing in and out or when using up/down keys). 

function initSelect()
{
	var theSelect = document.getElementById("accessible_menu");
	
	theSelect.changed = false;
	theSelect.onfocus = selectFocussed;
	theSelect.onchange = selectChanged;
	theSelect.onkeydown = selectKeyed;
	theSelect.onclick = selectClicked;
	
	return true;
}




function selectChanged(theElement)
{
	var theSelect;
	
	if (theElement && theElement.value)
	{
		theSelect = theElement;
	}
	else
	{
		theSelect = this;
	}
	
	if (!theSelect.changed)
	{
		return false;
	}

	this.form.submit(theSelect.value);
	
	return true;
}




function selectClicked()
{
	this.changed = true;
}




function selectFocussed()
{
	this.initValue = this.value;
	
	return true;
}




function selectKeyed(e)
{
	var theEvent;
	var keyCodeTab = "9";
	var keyCodeEnter = "13";
	var keyCodeEsc = "27";
	
	if (e)
	{
		theEvent = e;
	}
	else
	{
		theEvent = event;
	}

	if ((theEvent.keyCode == keyCodeEnter) && this.value != this.initValue)
	{
		this.changed = true;
		this.form.submit(this);
	}
	else if (theEvent.keyCode == keyCodeEsc || theEvent.keyCode == keyCodeTab)
	{
		this.value = this.initValue;
	}
	else
	{
		this.changed = false;
	}
	
	return true;
}
