function esc(myid) {
	return '#' + myid.replace(/(:|\.)/g,'\\\\$1');
}

function escapeHtml(unsafe) {
    return $('<div />').text(unsafe).html()
}

function unescapeHtml(safe) {
    return $('<div />').html(safe).text();
}

function attachDropdowns() {
    $('[data-toggle="popover"]').popover();
	//$('.selectpicker').selectpicker('refresh');
	$('.selectpicker').select2();

	setDirtyCheck();
}

function setDirtyCheck() {
	$('.dirtyControl').on('change', null, turnDirtyOn);
}

function turnDirtyOn() {
	isDirty = true;
}

function turnDirtyOff() {
	isDirty = false;
}

function handleReturnError(event) {
	if (event.type === 'exception') {
		alert('Error: ' + event.message + ' ' + event.where);
    }  else {
		alert('Error: ' + event.message + ' ' + event.where);
	}
}

function initScreen() {

	getData();
}

function getData() {

	$('#loadingScreen').show();
	Visualforce.remoting.Manager.invokeAction(
    	window.accountExtensionMappingSettings.RemoteActions.getData,
    	function(result, event) {
     		if (event.status) {
     			window.accountExtensionMappingSettings.AccountExtensionFields = result.accountExtensionFields;
				window.accountExtensionMappingSettings.ObjectFields = result.objectFields;
     			window.accountExtensionMappingSettings.ObjectNames = result.objectNames;

     			renderTable();
			} else {
				handleReturnError(event);
			}

			$('#loadingScreen').hide();

		},
        {buffer: true, escape: false}
	);

}

function updateState() {
	$.each(window.accountExtensionMappingSettings.MappedFields, function(index1, object) {
		$.each(object, function(index2, field) {

			//This way I do not overwrite the newly created (and not yet rendered) row
			if ($("#source-" + field.targetObject + "-" + index2).length > 0) {
				field.sourceField = $("#source-" + field.targetObject + "-" + index2).val();
				field.targetField = $("#target-" + field.targetObject + "-" + index2).val();
				field.sourceFieldType = $("#source-" + field.targetObject + "-" + index2 + " option:selected").attr('data-datatype');
				field.errorMessage = $("#errorMessage-" + field.targetObject + "-" + index2).val();

				//since these fields contains a string, I have to "booleanize" them
				field.isDeleted = ( $("#deleted-" + field.targetObject + "-" + index2).val() == 'true');
				field.isError = ( $("#error-" + field.targetObject + "-" + index2).val() == 'true');
			}

		});
	});

	$.each(window.accountExtensionMappingSettings.CalculatedMappedFields, function(index1, object) {
		$.each(object, function(index2, field) {

			//This way I do not overwrite the newly created (and not yet rendered) row
			if ($("#target-" + field.objectName + "-c" + index2).length > 0) {
				field.field = $("#target-" + field.objectName + "-c" + index2).val();
				field.errorMessage = $("#errorMessage-" + field.objectName + "-c" + index2).val();

				//since these fields contains a string, I have to "booleanize" them
				field.isError = ( $("#error-" + field.objectName + "-c" + index2).val() == 'true');
			}

		});
	})

	var clauses = JSON.stringify(window.accountExtensionMappingSettings.MappedFields);

	$("[id$='fieldMappings']").val(clauses);

	var calcClauses = JSON.stringify(window.accountExtensionMappingSettings.CalculatedMappedFields);

	$("[id$='calculatedFieldMappings']").val(calcClauses);
}

function renderTable() {
	window.accountExtensionMappingSettings.MappedFields = JSON.parse($("[id$='fieldMappings']").val());
	window.accountExtensionMappingSettings.CalculatedMappedFields = JSON.parse($("[id$='calculatedFieldMappings']").val());

	$('#objectFields').empty();

	//First create the four tables
	$('#objectFields').append(createTableHeader(window.accountExtensionMappingSettings.ObjectNames['Account']));
	$('#objectFields').append(createTableHeader(window.accountExtensionMappingSettings.ObjectNames[recObjectName]));
	$('#objectFields').append(createTableHeader(window.accountExtensionMappingSettings.ObjectNames['Opportunity']));
	$('#objectFields').append(createTableHeader(window.accountExtensionMappingSettings.ObjectNames['Lead']));

	$('#objectFields').append(createTable(window.accountExtensionMappingSettings.ObjectNames['Account'].value, window.accountExtensionMappingSettings.MappedFields['Account'], window.accountExtensionMappingSettings.CalculatedMappedFields['Account']));
	$('#objectFields').append(createTable(window.accountExtensionMappingSettings.ObjectNames[recObjectName].value, window.accountExtensionMappingSettings.MappedFields[recObjectName], window.accountExtensionMappingSettings.CalculatedMappedFields[recObjectName]));
	$('#objectFields').append(createTable(window.accountExtensionMappingSettings.ObjectNames['Opportunity'].value, window.accountExtensionMappingSettings.MappedFields['Opportunity'], window.accountExtensionMappingSettings.CalculatedMappedFields['Opportunity']));
	$('#objectFields').append(createTable(window.accountExtensionMappingSettings.ObjectNames['Lead'].value, window.accountExtensionMappingSettings.MappedFields['Lead'], window.accountExtensionMappingSettings.CalculatedMappedFields['Lead']));


	attachDropdowns();

}

function createTableHeader(tableWrap) {
	var div = $('<div>').attr('id', 'area-' + tableWrap.value);

	$(div).append('<hr>');

	var title = $('<p>').text(tableWrap.label + ' Mapping');
	$(div).append(title);

	var table = $('<div>').attr('id', 'table-' + tableWrap.value);
	$(div).append(table);


	return div;
}

function createTable(type, rows, calculatedRows) {

	$.each(calculatedRows, function(index, object) {

		var row = createCalculatedRow(type, index, object);

		$('#table-' + type).append(row);

    });

	$.each(rows, function(index, object) {

		var row = createRow(type, index, object);

		$('#table-' + type).append(row);

    });

	var row = $('<div>').addClass('row');
	var cell = $('<div>').addClass('col-md-12');

	var addButton = $('<input>').attr('type','button')
								.attr('value',window.accountExtensionMappingSettings.Labels.addRow)
								.addClass('btn')
								.addClass('btn-default')
								.addClass('pull-right')
								.addClass('add-row');


	$(addButton).on('click', {type: type}, addNewRow);

	$(cell).append(addButton);
	$(row).append(cell);

	$('#area-' + type).append(row);
}

function createCalculatedRow(type, index, record) {

	var row = $('<div>').addClass('row');

	var leftCol = $('<div>').addClass('col-md-5');

	var targetSelect = $('<select>').attr('id','target-' + type + '-c' + index)
							  .attr('data-live-search', 'true')
							  .addClass('selectpicker')
							  .addClass('dirtyControl');

	var value = $('<option>').attr('value', '').text(window.accountExtensionMappingSettings.Labels.targetField);
	$(targetSelect).append(value);

	$.each(window.accountExtensionMappingSettings.ObjectFields[type], function(index, fieldRow) {
		var value = $('<option>').attr('value', fieldRow.value).text(fieldRow.label);
		$(targetSelect).append(value);
	});

	$(leftCol).append(targetSelect);

	$(targetSelect).val(record.field);
	$(targetSelect).on('change', {type: type, idx: index}, changeCalculatedDropdown);

	$(row).append(leftCol);

	var validationText = $('<div>').attr('id','validation-' + type + '-c' + index).addClass('required-text');
	$(leftCol).append(validationText);

	if (record.isError) {
		$(validationText).text(record.errorMessage);
	} else {
		$(validationText).hide();
	}

	var midCol = $('<div>').addClass('col-md-2').addClass('text-center');

	$(midCol).append('<span class="glyphicon glyphicon-arrow-left" aria-hidden="true"></span>');

	var errorValue = $('<input>').attr('id','error-' + type + '-c' + index)
							    .attr('type','hidden')
							    .val(record.isError);

	$(midCol).append(errorValue);

	var messageValue = $('<input>').attr('id','errorMessage-' + type + '-c' + index)
							    .attr('type','hidden')
							    .val(record.errorMessage);

	$(midCol).append(messageValue);

	$(row).append(midCol);

	var rightCol = $('<div>').addClass('col-md-5 all-plays');

	var title = $('<span>').text(record.label)
						   .addClass('static-title');

	$(rightCol).append(title);

	var rightSpan = $('<span>').addClass('help-text');

	var rightAnchor = $('<a>').addClass('helper')
							  .attr('data-content', record.helpText)
							  .attr('data-toggle', 'popover')
							  .attr('data-trigger', 'focus')
							  .attr('role', 'button')
							  .attr('tabindex', '1')
							  .text('?');

	$(rightSpan).append(rightAnchor);
	$(rightCol).append(rightSpan);

	$(row).append(rightCol);

	return row;

}

function createRow(type, index, record) {

	var row = $('<div>').addClass('row');

	if (record.isDeleted) {
		$(row).addClass('delete-field');
	}

	var leftCol = $('<div>').addClass('col-md-5');

	var targetSelect = $('<select>').attr('id','target-' + type + '-' + index)
							  .attr('data-live-search', 'true')
							  .addClass('selectpicker')
							  .addClass('dirtyControl');

	if (record.isDeleted) {
		$(targetSelect).attr('disabled','disabled');
	}

	var value = $('<option>').attr('value', '').text(window.accountExtensionMappingSettings.Labels.targetField);
	$(targetSelect).append(value);

	$.each(window.accountExtensionMappingSettings.ObjectFields[type], function(index, fieldRow) {
		var value = $('<option>').attr('value', fieldRow.value).text(unescapeHtml(fieldRow.label));
		$(targetSelect).append(value);
	});

	$(leftCol).append(targetSelect);

	$(targetSelect).val(record.targetField);
	$(targetSelect).on('change', {type: type, idx: index}, changeDropdown);

	$(row).append(leftCol);

	var validationText = $('<div>').attr('id','validation-' + type + '-' + index).addClass('required-text');
	$(leftCol).append(validationText);

	if (record.isError) {
		$(validationText).text(record.errorMessage);
	} else {
		$(validationText).hide();
	}

	var midCol = $('<div>').addClass('col-md-2').addClass('text-center');

	$(midCol).append('<span class="glyphicon glyphicon-arrow-left" aria-hidden="true"></span>');

	var deletedValue = $('<input>').attr('id','deleted-' + type + '-' + index)
							    .attr('type','hidden')
							    .val(record.isDeleted);

	$(midCol).append(deletedValue);

	var errorValue = $('<input>').attr('id','error-' + type + '-' + index)
							    .attr('type','hidden')
							    .val(record.isError);

	$(midCol).append(errorValue);

	var messageValue = $('<input>').attr('id','errorMessage-' + type + '-' + index)
							    .attr('type','hidden')
							    .val(record.errorMessage);

	$(midCol).append(messageValue);

	$(row).append(midCol);

	var rightCol = $('<div>').addClass('col-md-5');
	var sourceSelect = $('<select>').attr('id','source-' + type + '-' + index)
							  .attr('data-live-search', 'true')
							  .addClass('selectpicker')
							  .addClass('dirtyControl');

	if (record.isDeleted) {
		$(sourceSelect).attr('disabled','disabled');
	}

	var value = $('<option>').attr('value', '').text(window.accountExtensionMappingSettings.Labels.acctExtField);
	$(sourceSelect).append(value);

	$.each(window.accountExtensionMappingSettings.AccountExtensionFields, function(index, fieldRow) {
		var value = $('<option>').attr('value', fieldRow.value).attr('data-datatype', fieldRow.type).text(unescapeHtml(fieldRow.label));
		$(sourceSelect).append(value);
	});

	$(rightCol).append(sourceSelect);

	$(sourceSelect).val(record.sourceField);
	$(sourceSelect).on('change', {type: type, idx: index}, changeDropdown);

	if (! record.isDeleted) {
		var removeRowButton = $('<a>').addClass('remove-row').text(window.accountExtensionMappingSettings.Labels.removeRow);

		$(removeRowButton).on('click', {type: type, idx: index, value: true}, removeRow);

		$(rightCol).append(removeRowButton);
	} else {
		var removeRowButton = $('<a>').addClass('remove-row').text(window.accountExtensionMappingSettings.Labels.undo);

		$(removeRowButton).on('click', {type: type, idx: index, value: false}, removeRow);

		$(rightCol).append(removeRowButton);

	}

	$(row).append(rightCol);

	return row;
}

function addNewRow(event) {

	var newRow = {
    		id: '',
			isDeleted: false,
			sourceField: '',
			targetField: '',
			targetObject: event.data.type,
			isError: false,
			errorMessage: '',
			sourceFieldType: ''
    	};

	window.accountExtensionMappingSettings.MappedFields[event.data.type].push(newRow);

	updateState();

	renderTable();

}

function removeRow(event) {
	$("#deleted-" + event.data.type + "-" + event.data.idx).val(event.data.value);

	updateState();

	renderTable();

}

function changeCalculatedDropdown(event) {
	updateState();

	Visualforce.remoting.Manager.invokeAction(
    	window.accountExtensionMappingSettings.RemoteActions.matchCalculatedFieldType,
    	event.data.type,
    	event.data.idx,
    	''+ window.accountExtensionMappingSettings.CalculatedMappedFields[event.data.type][event.data.idx].objectName,
    	''+ window.accountExtensionMappingSettings.CalculatedMappedFields[event.data.type][event.data.idx].field,
    	''+ window.accountExtensionMappingSettings.CalculatedMappedFields[event.data.type][event.data.idx].name,
    	function(result, event) {
     		if (event.status) {

     			if (result.message != '') {
     				$("#error-" + result.type + "-c" + result.index).val(true);
     				$("#errorMessage-" + result.type + "-c" + result.index).val(result.message);
     			} else {
     				$("#error-" + result.type + "-c" + result.index).val(false);
     				$("#errorMessage-" + result.type + "-c" + result.index).val('');
     			}

     			updateState();

     			renderTable();
			} else {
				handleReturnError(event);
			}

		},
        {buffer: true, escape: true}
	);
}

function changeDropdown(event) {
	updateState();

	if (typeof window.accountExtensionMappingSettings.MappedFields[event.data.type][event.data.idx].sourceFieldType == 'undefined') {
		return;
	}

	Visualforce.remoting.Manager.invokeAction(
    	window.accountExtensionMappingSettings.RemoteActions.matchFieldType,
    	event.data.type,
    	event.data.idx,
    	''+ window.accountExtensionMappingSettings.MappedFields[event.data.type][event.data.idx].targetObject,
    	''+ window.accountExtensionMappingSettings.MappedFields[event.data.type][event.data.idx].targetField,
    	''+ window.accountExtensionMappingSettings.MappedFields[event.data.type][event.data.idx].sourceFieldType,
    	function(result, event) {
     		if (event.status) {

     			if (result.message != '') {
     				$("#error-" + result.type + "-" + result.index).val(true);
     				$("#errorMessage-" + result.type + "-" + result.index).val(result.message);
     			} else {
     				$("#error-" + result.type + "-" + result.index).val(false);
     				$("#errorMessage-" + result.type + "-" + result.index).val('');
     			}

     			updateState();

     			renderTable();
			} else {
				handleReturnError(event);
			}

		},
        {buffer: true, escape: true}
	);
}

function closeModals(){
    $('#confirmCancel').modal('hide');
    $('#confirmSave').modal('hide');

    $('.deleteToDisable').removeAttr('disabled');
	$('.btn-primary.deleteToDisable').attr('value', $('.btn-primary.deleteToDisable').attr('data-oldvalue'));
    $('.btn-primary.deleteToDisable').removeAttr('data-oldvalue');
}

function openCancelScreenModal(){
     $('#confirmCancel').modal('show');
}

function confirmExit() {
	if (isDirty) {
		return window.accountExtensionMappingSettings.Labels.leaveScreen;
	}

}