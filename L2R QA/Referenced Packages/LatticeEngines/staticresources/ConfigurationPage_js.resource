
function processErrorsSave() {
	processErrors();

	if (! errorsInSave) {
		reloadPage();
	}
}

function processErrorsSaveConditional() {
	processErrors();

	if (refreshAfterSave && ! errorsInSave) {
		reloadPage();
	}
}


function processErrors() {
	setDirtyCheck();

    $('.error').hide();
    errorsInSave = false;
	var errorsJSON = $(esc(hidErrorInfo)).val();

	if (errorsJSON != '' && errorsJSON != '[]') {
		var errors = JSON.parse(errorsJSON);

		$.each(errors, function(index, section) {
			errorsInSave = true;

			var sectionName = section.sectionName;

			$('#' + sectionName + 'Error').show();
		});
	} else {
		//Only reset the dirty flag if no errors;
		isDirty = false;
	}

}

function onScroll(event){
	//Give a few pixels break before starting to adjust the height
	var scrollPosition = $(document).scrollTop();

	//For the first last pixels, hardcode it to use the last element (it is so small, nothing won't scroll to it anyway)
	if (scrollPosition > ($(document).height() - ($(window).height() + 50)) ) {
		scrollPosition = $("#recommendationsP").position().top + 1;
	}

	$('.admin a').each(function () {
		var currentLink = $(this);
		var refElement = $("#" + currentLink.attr("data-scroll"));

		if (refElement.length>0) {

			if (refElement.position().top <= scrollPosition && refElement.position().top + refElement.height() > scrollPosition) {
				$('.admin ul li a').removeClass("active");
				currentLink.addClass("active");
			} else {
				currentLink.removeClass("active");
			}
		}

	});
}

function closeModals(){
    $('#populateTestData').modal('hide');
    $('#deleteTestData').modal('hide');
    $('#authenticate').modal('hide');
    $('#disconnect').modal('hide');
    $('#syncNewData').modal('hide');
    $('#syncMetadataOnly').modal('hide');
    $('#dirtyScreen').modal('hide');

    $('.modal-backdrop').remove();

    $('.deleteToDisable').removeAttr('disabled');
	$('.btn-primary.deleteToDisable').attr('value', $('.btn-primary.deleteToDisable').attr('data-oldvalue'));
    $('.btn-primary.deleteToDisable').removeAttr('data-oldvalue');
}

function openDeleteModal(){
     $('#deleteTestData').modal('show');
}

function openSyncModal(refreshAfter){
	processErrors();

	if ($(esc(hidHasSavedWorkedId)).val() == 'false' || errorsInSave) {
		return;
	}

	refreshAfterSave = refreshAfter;

    $('#syncNewData').modal('show');
}

function openSyncMetadataModal(refreshAfter){
	processErrors();

	if ($(esc(hidHasSavedWorkedId)).val() == 'false' || errorsInSave) {
		return;
	}

	refreshAfterSave = refreshAfter;

    $('#syncMetadataOnly').modal('show');
}

function openAuthenticateModal(){
     $('#authenticate').modal('show');
}

function disableDeleteButtons() {
    $('.deleteToDisable').attr('disabled','disabled');
    $('.btn-primary.deleteToDisable').attr('data-oldvalue', $('.btn-primary.deleteToDisable').attr('value'));
    $('.btn-primary.deleteToDisable').attr('value', pleaseWaitLabel);
}

function reAttachPicklists() {
    //$('.selectpicker').selectpicker();
    $('.selectpicker').select2();
    
    if (console) {
    	console.log('Attaching Picklist select2.');
    }
}

function redrawPicklists() {
	reAttachPicklists();

    getRuleValues();
    createLeadMappingTable();
}

function validateLogin() {
	var isValidated = true;

	$('#validation-loginClientId').hide();
	$('#validation-loginOTK').hide();

	if ($(esc(hidLoginClientID)).val() == '') {
		$('#validation-loginClientId').show();
		isValidated = false;
	}

	if ($(esc(hidLoginOTK)).val() == '') {
		$('#validation-loginOTK').show();
		isValidated = false;
	}

	if (! isValidated) {
		return false;
	} else {
		return true;
	}
}

function hideAuthValidation(prefix) {
	$('#validation-' + prefix + 'authClientId').hide();
	$('#validation-' + prefix + 'authOTK').hide();
}

function validateAuthenticate(prefix) {
	var isValidated = true;

	hideAuthValidation(prefix);

	if ($(esc(hidAuthClientID)).val() == '') {
		$('#validation-' + prefix + 'authClientId').show();
		isValidated = false;
	}

	if ($(esc(hidAuthOTK)).val() == '') {
		$('#validation-' + prefix + 'authOTK').show();
		isValidated = false;
	}

	if (! isValidated) {
		return false;
	} else {
		disableDeleteButtons();

		return true;
	}
}

function setRuleValues() {
	var rule1Radio = $('#leadRule1').is(':checked');
	var rule2Check = $('#leadRule2Check').is(':checked');
	var rule2Radio = $('#leadRule2').is(':checked');

	var hidLeadRule1 = $(esc(hidLeadRule1Id));
	var hidLeadRule2 = $(esc(hidLeadRule2Id));

	if (rule1Radio && rule2Check) {
		$(hidLeadRule1).val(true);
		$(hidLeadRule2).val(true);
	} else if (rule1Radio) {
		$('#leadRule2Check').prop('disabled', false);
		$('input[id^="'  +optionsRadioId + '"]').prop('disabled', false);

		$(hidLeadRule1).val(true);
		$(hidLeadRule2).val(false);
	} else if (rule2Radio) {
		$('#leadRule2Check').attr('checked', false); // Unchecks it
		$('#leadRule2Check').prop('disabled', true);
		$('input[id^="'  +optionsRadioId + '"]').prop('disabled', true);

		$(hidLeadRule1).val(false);
		$(hidLeadRule2).val(true);
	}

}

function getRuleValues() {
	var rule1Radio = $('#leadRule1');
	var rule2Check = $('#leadRule2Check');
	var rule2Radio = $('#leadRule2');

	var hidLeadRule1 = $(esc(hidLeadRule1Id)).val(); //Come as strings, not booleans
	var hidLeadRule2 = $(esc(hidLeadRule2Id)).val(); //Come as strings, not booleans

	if (hidLeadRule1 == 'true' && hidLeadRule2 == 'true') {
		$('#leadRule2Check').prop('disabled', false);
		$('input[id^="'  +optionsRadioId + '"]').prop('disabled', false);

		$(rule1Radio).attr('checked', true);
		$(rule2Check).attr('checked', true);
		$(rule2Radio).attr('checked', false);
	} else if (hidLeadRule1 == 'true') {
		$('#leadRule2Check').prop('disabled', false);
		$('input[id^="'  +optionsRadioId + '"]').prop('disabled', false);

		$(rule1Radio).attr('checked', true);
		$(rule2Check).attr('checked', false);
		$(rule2Radio).attr('checked', false);
	} else if (hidLeadRule2 == 'true') {
		$('#leadRule2Check').prop('disabled', true);
		$('input[id^="'  +optionsRadioId + '"]').prop('disabled', true);

		$(rule1Radio).attr('checked', false);
		$(rule2Check).attr('checked', false);
		$(rule2Radio).attr('checked', true);
	}

}

function rebuildLeadFromHidden() {
	if ($(esc(hidLeadMappingsId)).val() != '') {
		leadMappings = JSON.parse($(esc(hidLeadMappingsId)).val());
	}
}

function rebuildRecommendationFromHidden() {
	if ($(esc(hidRecommendationMappingsId)).val() != '') {
		recommendationMappings = JSON.parse($(esc(hidRecommendationMappingsId)).val());
	}
}

function refreshLeadHidden() {
	$(esc(hidLeadMappingsId)).val(JSON.stringify(leadMappings));
}

function refreshRecommendationHidden() {
	$(esc(hidRecommendationMappingsId)).val(JSON.stringify(recommendationMappings));
}

function handleReturnError(event) {
	if (event.type === 'exception') {
		alert('Error: ' + event.message + ' ' + event.where);
    }  else {
		alert('Error: ' + event.message + ' ' + event.where);
	}
}

function populateFieldsArray(result, event) {

	if (event.status) {
		recommendationFields = result.recommendation;
    	leadObjectFields = result.lead;
    	opportunityObjectFields = result.opportunity;

		if ($(esc(hidLeadMappingsId)).val() != '' || $(esc(hidRecommendationMappingsId)).val() != '') {
    		rebuildLeadFromHidden();
      		rebuildRecommendationFromHidden();

      		createTables();
      		$(esc(mainSaveButton)).prop( "disabled", false );
      	} else {
      		getFieldMappings();
      	}
	} else {
		handleReturnError(event);
	}
}

function createTables() {
	createLeadMappingTable();
	createRecommendationMappingTable();

}

function populateMappingArrays(result, event) {

	if (event.status) {
		leadMappings = result.leadMappings;
    	recommendationMappings = result.recommendationMappings;

		createTables();

		$(esc(mainSaveButton)).prop( "disabled", false );
	} else {
		handleReturnError(event);
	}
}

function createFieldMappingEmptyRow() {
	var newRow = {
		sourceField : '',
    	targetField : '',
    	defaultValue : '',
    	isDefault : false,
    	isRequired : false,
	}


	return newRow;
}

function removeRow (event) {
	//Remove the row
	$('#' + event.data.type + '-' + event.data.idx).remove();

	//Keep the array in sync
	if (event.data.type == 'lead') {
		leadMappings.splice(event.data.idx,1);

		refreshLeadHidden();
	} else if (event.data.type == 'recommendation') {
		recommendationMappings.splice(event.data.idx,1);

		refreshRecommendationHidden();
	}
}

function addRow(type) {
	if (type == 'lead') {
		var fieldRow = createFieldMappingEmptyRow();
		leadMappings.push(fieldRow);
		refreshLeadHidden();

		var row = createRow(type, leadMappings.length-1, fieldRow, leadObjectFields);

		$('#leadMappingFields').append(row);
	} else if (type == 'recommendation') {
		var fieldRow = createFieldMappingEmptyRow();
		recommendationMappings.push(fieldRow);
		refreshRecommendationHidden();

		var row = createRow(type, recommendationMappings.length-1,fieldRow, opportunityObjectFields);

		$('#recommendationMappingFields').append(row);
	}

	//$('.selectpicker').selectpicker();
    $('.selectpicker').select2();
	setDirtyCheck();
}

function createLeadMappingTable() {
	refreshLeadHidden();

	//Only do this if the lead functionality is enabled
	if ($('#leadMappingFields').length > 0) {
		$.each(leadMappings, function(index, mappingRow) {
			//Create the row
			var row = createRow('lead', index, mappingRow, leadObjectFields);

			$('#leadMappingFields').append(row);

			evaluateRow('lead', index);
		});
	}

	//$('.selectpicker').selectpicker();
    $('.selectpicker').select2();
	setDirtyCheck();
}

function createRecommendationMappingTable() {
	refreshRecommendationHidden();

	$.each(recommendationMappings, function(index, mappingRow) {
		//Create the row
		var row = createRow('recommendation', index, mappingRow, opportunityObjectFields);

		$('#recommendationMappingFields').append(row);
		evaluateRow('recommendation', index);
	});

	// $('.selectpicker').selectpicker();
    $('.selectpicker').select2();
	setDirtyCheck();

}

function createRow(rowType, rowIndex, rowInfo, targetFields) {
	//Create the row
	var row = $('<div>').addClass('row').attr('id', rowType + '-' + rowIndex);

	//Create left column
	var left = $('<div>').addClass('col-md-5');

	if (rowInfo.isRequired) {

		var rowTitle = rowInfo.targetField;

		$.each(targetFields, function(index, fieldRow) {
			if (fieldRow.value == rowInfo.targetField) {
				rowTitle = fieldRow.label;
			}
		});

		$(left).append(rowTitle + ' (' + requiredLabel + ')');
		var hiddenTarget = $('<input>').attr('type','hidden').attr('id','target-' + rowType + '-' + rowIndex).val(rowInfo.targetField);

		$(left).append(hiddenTarget);
	} else {
		var selectTarget = $('<select>').attr('id','target-' + rowType + '-' + rowIndex).attr('data-live-search', 'true').addClass('selectpicker').addClass('dirtyControl');

		$.each(targetFields, function(index, fieldRow) {
			if (! fieldRow.isRequired) { //You can't pick a required field in the dropdown
				var value = $('<option>').attr('value', fieldRow.value).text(fieldRow.label);
				$(selectTarget).append(value);
			}
		});
		$(selectTarget).on('change', {type: rowType, idx: rowIndex}, toggleDefaultValue);

		$(left).append(selectTarget);

		$(selectTarget).val(rowInfo.targetField);
	}

	$(row).append(left);

	//Create middle column
	var middle = $('<div>').addClass('col-md-2').addClass('text-center');

	$(middle).append('<span class="glyphicon glyphicon-arrow-left" aria-hidden="true"></span>');
	$(row).append(middle);

	//Create right column
	var right = $('<div>').addClass('col-md-5').addClass('form-group');
	var select = $('<select>').attr('id','source-' + rowType + '-' + rowIndex).attr('data-live-search', 'true').addClass('selectpicker').addClass('dirtyControl');

	if (rowInfo.isRequired) {
		$(select).addClass('required-border');
	}

	var emptyValue = $('<option>').attr('value', '').text(selectFieldLabel);
	$(select).append(emptyValue);

	//First set the "Opt Group" for the default value
	var ogDefault = $('<optgroup>').attr('label', chooseActionLabel);
	var value = $('<option>').attr('value', 'DEFVAL').text(specifyValueLabel);
	$(ogDefault).append(value);

	if (rowType == 'recommendation') {
		var value = $('<option>').attr('value', 'CONVERSION').text(specifyConversionLabel);
		$(ogDefault).append(value);
	}

	$(select).append(ogDefault);

	//Now Set up all the fields
	var ogOption = $('<optgroup>').attr('label', chooseOptionLabel);

	$.each(recommendationFields, function(index, fieldRow) {
		var showField = true;

		if (rowType == 'lead' && fieldRow.isFormula) {
			showField = false;
		}

		if (showField) {
			var value = $('<option>').attr('value', fieldRow.value).text(fieldRow.label);
			$(ogOption).append(value);
		}
	});

	$(select).append(ogOption);
	$(select).val(rowInfo.sourceField);
	$(select).on('change', {type: rowType, idx: rowIndex}, toggleDefaultValue);

	$(right).append(select);

	var defaultContainer = $('<span>').attr('id','defaultContainer-' + rowType + '-' + rowIndex).attr('data-required', rowInfo.isRequired);

	if (rowInfo.isDefault) {
		var options = getPicklistOptions(rowType, rowInfo.targetField);
		if (options != undefined && options != '') {
			addDefaultPicklist(rowType, rowIndex, rowInfo.defaultValue, defaultContainer, options);
		} else {
			addDefaultTextbox(rowType, rowIndex, rowInfo.defaultValue, defaultContainer);
		}
	}

	$(right).append(defaultContainer);

	var validationText = $('<div>').attr('id','validation-' + rowType + '-' + rowIndex).addClass('required-text');
	$(right).append(validationText);
	$(validationText).hide();

	if (! rowInfo.isRequired) {
		var removeRowButton = $('<a>').addClass('remove-row').text(removeRowLabel);

		$(removeRowButton).on('click', {type: rowType, idx: rowIndex}, removeRow);

		$(right).append(removeRowButton);
	}

	$(row).append(right);

	return row;
}

function addDefaultTextbox(type, index, value, defaultContainer) {
	if (defaultContainer == '') {
		defaultContainer = $('#defaultContainer-' + type + '-' + index);
	}

	//Remove the old one, if exists
	if ($('#default-' + type + '-' + index).length > 0) {
		//$('#default-' + type + '-' + index).selectpicker('destroy');
		//TODO
		$('#default-' + type + '-' + index).remove();
	}

	var isRequired = $(defaultContainer).attr('data-required');

	var defaultText = $('<input>').attr('type','text').attr('id','default-' + type + '-' + index).addClass('form-control').addClass('dirtyControl');
	if (isRequired) {
		$(defaultText).addClass('required-border');
	}

	$(defaultText).on('change', {type: type, idx: index}, rowChanged);

	$(defaultText).val(value);

	$(defaultContainer).append(defaultText);
}

function addDefaultPicklist(type, index, value, defaultContainer, options) {
	if (defaultContainer == '') {
		defaultContainer = $('#defaultContainer-' + type + '-' + index);
	}

	//Remove the old one, if exists
	if ($('#default-' + type + '-' + index).length > 0) {
		//$('#default-' + type + '-' + index).selectpicker('destroy');
		//TODO
		$('#default-' + type + '-' + index).remove();
	}

	var isRequired = $(defaultContainer).attr('data-required');

	var defaultPicklist = $('<select>').attr('id','default-' + type + '-' + index).addClass('selectpicker').addClass('dirtyControl');

	if (isRequired) {
		$(defaultPicklist).addClass('required-border');
	}

	$.each(options, function(index, option) {
		var theOption = $('<option>').attr('value',option.value).text(option.label);

		$(defaultPicklist).append(theOption);
	});

	$(defaultPicklist).on('change', {type: type, idx: index}, rowChanged);

	$(defaultPicklist).val(value);

	$(defaultContainer).append(defaultPicklist);
}

function toggleDefaultValue(event) {
	var sourceField = $('#source-' + event.data.type + '-' + event.data.idx);

	if ($(sourceField).val() == 'DEFVAL') {

		var targetField = $('#target-' + event.data.type + '-' + event.data.idx);

		if ($(targetField).val() != '') {
			var options = getPicklistOptions(event.data.type, $(targetField).val());

			if (options != undefined && options != '') {
				addDefaultPicklist(event.data.type, event.data.idx, '', '', options);
			} else {
				addDefaultTextbox(event.data.type, event.data.idx, '', '');
			}

			//$('.selectpicker').selectpicker();
    		$('.selectpicker').select2();
			setDirtyCheck();

			var defaultControl = $('#default-' + event.data.type + '-' + event.data.idx);

			$(defaultControl).show();
			$(defaultControl).focus();
		} else {
			$(sourceField).val('');
		}
	} else {
		//$('#default-' + event.data.type + '-' + event.data.idx).selectpicker('destroy');
		//TODO

		var defaultControl = $('#default-' + event.data.type + '-' + event.data.idx);

		$(defaultControl).remove();
	}

	evaluateRow(event.data.type, event.data.idx);
}

function rowChanged(event) {
	evaluateRow(event.data.type, event.data.idx);
}

function evaluateRow(type, index) {
	//Get the three objects involved
	var defaultControl = $('#default-' + type + '-' + index);
	var sourceField = $('#source-' + type + '-' + index);
	var targetField = $('#target-' + type + '-' + index);

	var defaultText;
	if ($(defaultControl).length > 0) {
		defaultText = $(defaultControl).val();
	} else {
		defaultText = '';
	}

	if (type == 'lead') {
		//Update the array with the new values
		leadMappings[index].sourceField = $(sourceField).val();
		leadMappings[index].targetField = $(targetField).val();
		leadMappings[index].defaultValue = defaultText;
		leadMappings[index].isDefault = ($(sourceField).val() == 'DEFVAL');
		validateRow(type, index, leadMappings[index]);

		//Refresh the hidden
		refreshLeadHidden();
	} else if (type == 'recommendation') {
		//Update the array with the new values
		recommendationMappings[index].sourceField = $(sourceField).val();
		recommendationMappings[index].targetField = $(targetField).val();
		recommendationMappings[index].defaultValue = defaultText;
		recommendationMappings[index].isDefault = ($(sourceField).val() == 'DEFVAL');
		validateRow(type, index, recommendationMappings[index]);

		//Refresh the hidden
		refreshRecommendationHidden();
	}
}

function returnValidateRow(result, event) {

	if (event.status) {
		var validationText = $('#validation-' + result.originType + '-' + result.originIndex);

		if (result.originType == 'lead') {
			leadMappings[result.originIndex].isValidMapping = result.isValid;
		} else if (result.originType == 'recommendation') {
			recommendationMappings[result.originIndex].isValidMapping = result.isValid;
		}

		if (! result.isValid) {
			$(validationText).text(result.message);
			$(validationText).show();
		} else {
			$(validationText).text('');
			$(validationText).hide();
		}
	} else {
		handleReturnError(event);
	}
}

function getPicklistOptions(type, targetFieldValue) {

	var theList;
	if (type =='lead') {
		theList = leadObjectFields;
	} else if (type == 'recommendation') {
		theList = opportunityObjectFields;
	}

	var options;
	$.each(theList, function(index, field) {
		if (field.value == targetFieldValue) {
			options = field.options;
		}
	});

	return options;
}

function verifyDirty() {
	if (! isDirty) {
		return true;
	}

    $('#dirtyScreen').modal('show');

	return false;
}

function setDirtyCheck() {
	$('.dirtyControl').on('change', null, turnDirtyOn);
}

function turnDirtyOn() {
	isDirty = true;
}
