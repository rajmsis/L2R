'use strict';

function esc(myid) {
	return '#' + myid.replace(/(:|\.)/g,'\\\\$1');
}

function confirmExit() {
	if (isDirty) {
		return window.campaignSettings.Labels.leaveScreen;
	}
}

function handleReturnError(event) {
	if (event.type === 'exception') {
		alert('Error: ' + event.message + ' ' + event.where);
    }  else {
		alert('Error: ' + event.message + ' ' + event.where);
	}
}

function closeModals(){
    $('#confirmDelete').modal('hide');

    $('.deleteToDisable').removeAttr('disabled');
	$('.btn-primary.deleteToDisable').attr('value', $('.btn-primary.deleteToDisable').attr('data-oldvalue'));
    $('.btn-primary.deleteToDisable').removeAttr('data-oldvalue');
}

function initScreen() {

	getAllObjects();
}


function getAllObjects() {
	if (window.campaignSettings.Objects.length >0) {
		return;
	}
	$('#loadingScreen').show();

	Visualforce.remoting.Manager.invokeAction(
    	window.campaignSettings.RemoteActions.getAllObjects,
    	function(result, event) {
			$('#loadingScreen').hide();

     		if (event.status) {
				window.campaignSettings.Objects = result.objects;

     			if (window.campaignSettings.Variables.reRenderTable) {
     				renderClausesTable();
     				showHideDelete();
     			}

			} else {
				handleReturnError(event);
			}

		},
        {buffer: true, escape: false}
	);

}

function renderClausesTable() {
	window.campaignSettings.Clauses = JSON.parse($("[id$='crClauses']").val());

	$('#clausesTable').empty();
	window.campaignSettings.ReferenceLines = [];

	if (window.campaignSettings.Clauses.length == 0) {
		$('#noCriteria').show();
		$('[id$="crLogic"]').val('');
	} else {
		$('#noCriteria').hide();
	}

	$.each(window.campaignSettings.Clauses, function(index, object) {
		var row = createRow(index, object);

		$('#clausesTable').append(row);

	});

	attachDropdowns();
}

function addNewRow() {

	var newRow = {
    		order: window.campaignSettings.Clauses.length+1,
			objectName: '',
			fieldName: '',
			operator: '',
			value: ''
    	};

	window.campaignSettings.Clauses.push(newRow);

	updateState();

	renderClausesTable();

}

function removeRow(event) {
	window.campaignSettings.Clauses.splice(event.data.idx,1);

	updateState();

	renderClausesTable();

}


function createRow(index, rowToRender) {
	//MAIN ROW
	var mainRow = $('<div>').addClass('suppresion-criteria').attr('id', 'mainRow-' + index);

	if ((index+1) % 2 == 0) {
		$(mainRow).addClass('even');
	}

	//TOP ROW (OBJECT)
	var row = $('<div>').addClass('row').attr('id', 'row1-' + index);

	var numberDiv = $('<div>').addClass('col-md-12').addClass('criteria-number');

	var numberSpan = $('<span>').addClass('number').html(index+1);

	$(numberDiv).append(numberSpan);

	var objectSelect = $('<select>').attr('id', 'object-' + index).addClass('selectpicker').addClass('dirtyControl');

	var option = $('<option>').attr('value', '').text(window.campaignSettings.Labels.selectAnObject);
	$(objectSelect).append(option);

	$.each(window.campaignSettings.Objects, function(index, object) {
		var indentCount = 0;

		var displayTitle = object.title;

		var option = $('<option>').attr('data-content','<span>' + displayTitle + '</span>')
							      .attr('value', 'c-' + object.value).attr('title', object.title).text(displayTitle);

		$(objectSelect).append(option);

	});

	$(objectSelect).on('change', {idx: index}, changeObject);

	$(numberDiv).append(objectSelect);

	var prefix = 'c';
	var modifier = 'Regular';

	var objectName = (rowToRender.objectName == '') ? '' : prefix + '-' + rowToRender.objectName + '-' + modifier;

	$(objectSelect).val(objectName);

	$(row).append(numberDiv);

	$(mainRow).append(row);

	//BOTTOM ROW (FIELD, OPERATOR, VALUE)
	var row = $('<div>').addClass('row').attr('id', 'row3-' + index);

	var fieldColumn = $('<div>').addClass('col-md-5');

	var fieldSelect = $('<select>').attr('id', 'field-' + index).attr('data-live-search', 'true').addClass('selectpicker').addClass('dirtyControl');

	var option = $('<option>').attr('value', '').text(window.campaignSettings.Labels.selectAField);
	$(fieldSelect).append(option);

	var fields = getFieldsForObject(rowToRender.objectName + '-' +  modifier);

	$.each(fields, function(index, field) {
		var option = $('<option>').attr('value', field.value).text(field.label);

		$(fieldSelect).append(option);
	});

	$(fieldSelect).on('change', {idx: index}, changeField);

	$(fieldColumn).append(fieldSelect);

	$(fieldSelect).val(rowToRender.fieldName);

	$(row).append(fieldColumn);

	var operatorColumn = $('<div>').addClass('col-md-2');

	var operatorSelect = $('<select>').attr('id', 'operator-' + index).addClass('nosearch-picker').addClass('dirtyControl');

	var selectedField = null;
	$.each(fields, function(index, field) {
		if (field.value == rowToRender.fieldName) {
			selectedField = field;
		}
	});

	var operators = getOperatorsForType(selectedField);

	$.each(operators, function(index, operator) {
		var option = $('<option>').attr('value', operator.value).text(operator.label);
		$(operatorSelect).append(option);
	});

	if (operators.length == 0) {
		var option = $('<option>').attr('value', '').text(window.campaignSettings.Labels.selectAnOperator);
		$(operatorSelect).append(option);
	} else {
		//If the operator value is null, but I have options, default it to the first option
		if (rowToRender.operator == null || rowToRender.operator == '') {
			rowToRender.operator = 'equals';
		}
	}

	$(operatorColumn).append(operatorSelect);

	$(operatorSelect).val(rowToRender.operator);

	$(operatorSelect).on('change', {idx: index}, changeOperator);

	$(row).append(operatorColumn);

	var valueColumn = $('<div>').addClass('col-md-5');

	var defaultContainer = $('<span>').attr('id','defaultContainer-' + index);

	if (selectedField != null && selectedField.type == 'PICKLIST') {
		var valueText = $('<input>').attr('id','value-' + index).attr('type','hidden').addClass('dirtyControl');

		$(valueText).val(rowToRender.value);

		$(defaultContainer).append(valueText);

		var values = [];
		if (rowToRender.value != '') {
			values = rowToRender.value.split(',');
		}

		var defaultPicklist = $('<select>').attr('id','dropdown-' + index).addClass('selectpicker').addClass('dirtyControl').attr('multiple','').attr('data-selected-text-format','count>2');

		$.each(selectedField.options, function(index, option) {
			var theOption = $('<option>').attr('value',option.value).text(option.label);

			$(defaultPicklist).append(theOption);
		});

		$(defaultPicklist).val(values);

		$(defaultPicklist).on('change', {idx: index}, changePicklist);

		$(defaultContainer).append(defaultPicklist);
	} else if (selectedField != null && selectedField.type == 'DATETIME' && rowToRender.operator != 'within' && rowToRender.operator != 'notWithin') {
		var valueText = $('<input>').attr('id','value-' + index).attr('type','text').addClass('form-control').addClass('dateTimeControl').addClass('dirtyControl');

		$(valueText).val(rowToRender.value);

		$(defaultContainer).append(valueText);
	} else if (selectedField != null && selectedField.type == 'DATE' && rowToRender.operator != 'within' && rowToRender.operator != 'notWithin') {
		var valueText = $('<input>').attr('id','value-' + index).attr('type','text').addClass('form-control').addClass('dateControl').addClass('dirtyControl');

		$(valueText).val(rowToRender.value);

		$(defaultContainer).append(valueText);
	} else {
		var valueText = $('<input>').attr('id','value-' + index).attr('type','text').addClass('form-control').addClass('dirtyControl');

		$(valueText).val(rowToRender.value);
		$(defaultContainer).append(valueText);

		if (rowToRender.operator == 'within' || rowToRender.operator == 'notWithin') {

			var labelSpan = $('<span>').addClass('days-container').text('Days');

			$(defaultContainer).append(labelSpan);
		}

	}

	$(valueColumn).append(defaultContainer);

	$(row).append(valueColumn);

	var errorDiv = $('<div>').addClass('col-md-9');

	if (rowToRender.isError) {
		$(errorDiv).attr('id','error-' + index).addClass('required-text').html(rowToRender.errorMessage);
	}

	$(row).append(errorDiv);

	var buttonDiv = $('<div>').addClass('col-md-3');

	var removeRowButton = $('<a>').addClass('remove-row').text(window.campaignSettings.Labels.remove);

	$(removeRowButton).on('click', {idx: index}, removeRow);

	$(buttonDiv).append(removeRowButton);

	$(row).append(buttonDiv);

	$(mainRow).append(row);

	return mainRow;
}

function getStandardType(typeName) {
	if (typeName == 'PICKLIST' || typeName == 'MULTIPICKLIST' || typeName == 'TEXTAREA' || typeName == 'URL' || typeName == 'PHONE' || typeName == 'EMAIL') {
        return 'STRING'; //they compare as strings
    }

    if (typeName == 'DATE' || typeName == 'DATETIME') {
        return 'DATETIME'; //they compare as Date Times
    }

    if (typeName == 'CURRENCY' || typeName == 'DOUBLE' || typeName == 'PERCENT' || typeName == 'INTEGER') {
        return 'NUMBER'; //they compare as Numbers
    }

    if (typeName == 'REFERENCE') {
        return 'ID'; //they compare as IDS
    }

    return typeName; //STRING, NUMBER, DATE, DATETIME, BOOLEAN, ID
}


function getOperatorsForType(theField) {
	var operators = [];

	if (theField == null || theField.type == '') {
		return operators;
	}

	var standardType = getStandardType(theField.type);

	$.each(window.campaignSettings.Operators, function(index, operator) {

		if ($.inArray(standardType, operator.availableFor) != -1) {
			operators.push(operator);
		}

	});

	return operators;

}

function getFieldsForObject(objectName) {
	var returnValue = [];

	$.each(window.campaignSettings.Objects, function(index, object) {

		if (object.value == objectName) {
			returnValue = object.fields;
		}

	});

	return returnValue;
}

function attachDropdowns() {

	$('[data-toggle="popover"]').popover();
	//$('.selectpicker').selectpicker('refresh');
	//$('.nosearch-picker').selectpicker('refresh');
	$('.selectpicker').select2();
	$('.nosearch-picker').select2({
	  minimumResultsForSearch: Infinity
	});

	$('.dateControl').datetimepicker({
		format:'Y-m-d',
		timepicker: false
	});
	$('.dateTimeControl').datetimepicker({
		format:'Y-m-d H:i:00',
		defaultTime:'00:00'
	});

	// $.each(window.campaignSettings.ReferenceLines, function(index, object) {
	// 	initializeTypeAhead(object);
	// });
}

function changePicklist (event) {
	var index = event.data.idx;

	var picklistValues = $('#dropdown-' + index).val();

	$('#value-' + index).val(picklistValues.join(','));

	updateState();
	renderClausesTable();
}

function changeOperator (event) {
	var index = event.data.idx;

	updateState();
	renderClausesTable();
}

function changeField (event) {
	var index = event.data.idx;

	$('#operator-' + index).val('equals');

	updateState();
	renderClausesTable();
}

function changeObject (event) {
	var index = event.data.idx;

	$('#field-' + index).val('');
	$("#value-" + index).val('');

	updateState();
	renderClausesTable();
}

function updateState() {
	$.each(window.campaignSettings.Clauses, function(index, object) {
		object.order = index;

		if ($("#object-" + index).length > 0 &&  $("#object-" + index).val() != '') {
			var objectName = $("#object-" + index).val();

			var res = objectName.split("-");
			object.objectName = res[1];
		} else {
			object.objectName = '';
		}

		object.fieldName = $("#field-" + index).val();
		object.operator = $("#operator-" + index).val();

		if ($("#value-" + index).length > 0) {
			object.value = $("#value-" + index).val();
		} else {
			object.value = '';
		}

	});

	var clauses = JSON.stringify(window.campaignSettings.Clauses);

	$("[id$='crClauses']").val(clauses);

}

function toggleActiveHidden(newValue) {
	$('#activeYes').removeClass('active');
	$('#activeNo').removeClass('active');

	if (newValue) {
		$('#activeYes').addClass('active');
	} else {
		$('#activeNo').addClass('active');
	}

	$("[id$='activeHidden']").val(newValue);
	showHideDelete();
}

function showHideDelete() {
	if ($("[id$='activeHidden']").val() == 'true') {
		$("[id$='confirmButton']").hide();
	} else {
		$("[id$='confirmButton']").show();
	}
}
