'use strict';

var isTabReady = {Account:false, Contact:false, Lead:false};

function esc(myid) {
	return '#' + myid.replace(/(:|\.)/g,'\\\\$1');
}

function escapeHtml(unsafe) {
    return $('<div />').text(unsafe).html()
}

function unescapeHtml(safe) {
    return $('<div />').html(safe).text();
}

function attachDropdowns(tabName) {
	//if (! isTabReady[tabName]) {
		$('.selectpicker-' + tabName).select2();
		isTabReady[tabName] = true;
	//}

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

function assignListenerToTabs(){
	$("#tabSection a").click(function(event) {

		$('#loadingScreen').show();
		var tabClicked = $(this);

		setTimeout(function() {
			window.mappingSettings.activeTab = $(tabClicked).attr('data-panelType');//$(tabClicked).attr('id');
			event.preventDefault();

			var panelName = $(tabClicked).attr('data-panelType');
			attachDropdowns(panelName);

			$('#loadingScreen').hide();
			$(tabClicked).tab('show');
		}, 100);

	});
}

function clearNotifications() {
	Visualforce.remoting.Manager.invokeAction(
    	window.mappingSettings.RemoteActions.clearNotifications,
    	function(result, event) {
     		if (event.status) {
				//Nothing to do on return
			} else {
				handleReturnError(event);
			}

		},
        {buffer: true, escape: false}
	);
}

function getData() {
	$('#loadingScreen').show();
	Visualforce.remoting.Manager.invokeAction(
    	window.mappingSettings.RemoteActions.getData,
    	function(result, event) {
     		if (event.status) {
				window.mappingSettings.ObjectFields = result.objectFields;
     			window.mappingSettings.ObjectNames = result.objectNames;

     			renderTable();
     			//updateTableVisibility();
     			makeTabActive();

				$('#loadingScreen').hide();
			} else {
				handleReturnError(event);
			}

		},
        {buffer: true, escape: false}
	);
}

function updateState() {
	$.each(window.mappingSettings.EnrichmentAttributesMappedFields, function(index1, object) {
		$.each(object, function(index2, field) {


			if ($("#target-attr-" + field.objectName + "-c" + index2).length > 0) {
				field.field = $("#target-attr-" + field.objectName + "-c" + index2).val();
				field.errorMessage = $("#errorMessage-attr-" + field.objectName + "-c" + index2).val();

				//since these fields contains a string, I have to "booleanize" them
				field.isError = ( $("#error-attr-" + field.objectName + "-c" + index2).val() == 'true');
				addOrRemoveValidationMessage(index2, 'attr', field.objectName, field);
			}
		});
	});

	var clauses = JSON.stringify(window.mappingSettings.EnrichmentAttributesMappedFields);

	$("[id$='scoringAttributesMapping']").val(clauses);
}

function displayValidation(){
	if ($("[id$='scoringAttributesMapping']").val()) {
		window.mappingSettings.EnrichmentAttributesMappedFields = JSON.parse($("[id$='scoringAttributesMapping']").val());
	}

	if(window.mappingSettings.LeadTableRendered){
		let attributesFields = window.mappingSettings.EnrichmentAttributesMappedFields['Lead'];
		updateValidationForEachObject(scoringFields, attributesFields, 'Lead');
	}

	if(window.mappingSettings.AccountTableRendered){
		let attributesFields = window.mappingSettings.EnrichmentAttributesMappedFields['Account'];
		updateValidationForEachObject(scoringFields, attributesFields, 'Account');
	}

	if(window.mappingSettings.ContactTableRendered){
		let attributesFields = window.mappingSettings.EnrichmentAttributesMappedFields['Contact'];
		updateValidationForEachObject(scoringFields, attributesFields, 'Contact');
	}
}

function updateValidationForEachObject(scoring, attributes, type) {
	for(let i=0; i<attributes.length; i++){
		let object = attributes[i];
		addOrRemoveValidationMessage(i, 'attributes', type, object);
	}
}

function addOrRemoveValidationMessage(index, fieldType, type, record) {
	var selector = '#validation-attr-' + type + '-c' + index;
	var	errorSelector = "#error-attr-" + type + "-c" + index;
	var	errorMessageSelector = "#errorMessage-attr-" + type + "-c" + index;

	var validationText = $(selector);
	var error = $(errorSelector);
	var errorMessage = $(errorMessageSelector);

	if (record.isError) {
		$(validationText).text(record.errorMessage);
		$(validationText).show();
		$(errorSelector).show();
		$(errorMessageSelector).text(record.errorMessage);
		$(errorMessageSelector).show();
	}
	else {
		$(validationText).text('');
		$(validationText).hide();
		$(errorSelector).hide();
		$(errorMessageSelector).text('');
		$(errorMessageSelector).hide();
	}
}

function renderTable() {
	window.mappingSettings.EnrichmentAttributesMappedFields = JSON.parse($("[id$='scoringAttributesMapping']").val());

	renderAttributeTables();
	//attachDropdowns();
	assignListenerToTabs();
}

function renderAttributeTables() {
	renderLeadAttributesTable();
	renderAccountAttributesTable();
	renderContactAttributesTable();
}

function makeTabActive() {
	$('[id$="leadAnchor"]').tab('show');
	attachDropdowns('Lead');
	window.mappingSettings.activeTab = 'Lead';
}

function renderAttributesTable(selector, objectType) {
	var fieldsList = window.mappingSettings.EnrichmentAttributesMappedFields[objectType];
	if (fieldsList.length > 0) {
		$(selector).empty();
		$(selector).append(createTableHeader(objectType, '', window.mappingSettings.Labels.enrichmentAttrFieldIntro));
		$(selector).append(createAttrTable(window.mappingSettings.ObjectNames[objectType].value,
												fieldsList
												)
								);
	}


}



function renderLeadAttributesTable() {
	renderAttributesTable('#leadAttributesFields', 'Lead');
}

function renderContactAttributesTable() {
	renderAttributesTable('#contactAributesFields', 'Contact');
}

function renderAccountAttributesTable() {
	renderAttributesTable('#accountAttributesFields', 'Account');
}

function createTableHeader(objectType, header, intro) {
	var div = $('<div>').attr('id', 'area-attributes-' + objectType);

	var title = $('<h3>').text(header);
	$(div).append(title);

	var para = $('<p>').text(intro);
	$(div).append(para);

	var table = $('<div>').attr('id', 'table-attributes-' + objectType);

	var row = $('<div>').addClass('row');
	var leftCol = $('<div>').addClass('col-md-3');
	var leftSpan = $('<span>')
							.addClass('static-title')
							.css('text-decoration', 'underline');

	$(leftSpan).text(window.mappingSettings.Labels.enrichmentAttr);

	$(leftCol).append(leftSpan);
	$(row).append(leftCol);
	var midCol = $('<div>').addClass('col-md-2').addClass('text-center');
	$(row).append(midCol);
	var rightCol = $('<div>').addClass('col-md-3 marginBottom');
	var title = $('<span>').text('')
						   .addClass('static-title')
						   .css('text-decoration', 'underline');

	$(title).text(window.mappingSettings.Labels.sfField);

	$(rightCol).append(title);

	$(row).append(rightCol);
	$(table).append(row);


	$(div).append(table);

	return div;
}

function createAttrTable (type, enrichmentAttributes) {
	 $.each(enrichmentAttributes, function(index, object) {
		var row = createAttributeRow(type, index, object);
		$('#table-attributes-'+type).append(row);
    });
}

function createAttributeRow (type, index, record) {
	var row = $('<div>').addClass('row');

	var leftCol = $('<div>').addClass('col-md-3');
	var title = $('<span>').text(record.label + ' (' + record.fieldType + ')')
						   .addClass('static-title');
	$(leftCol).append(title);

	$(row).append(leftCol);

	var midCol = $('<div>').addClass('col-md-2').addClass('text-center');

	$(midCol).append('<span class="glyphicon glyphicon-arrow-right" aria-hidden="true"></span>');

	var errorValue = $('<input>').attr('id','error-attr-' + type + '-c' + index)
							    .attr('type','hidden')
							    .val(record.isError);

	$(midCol).append(errorValue);

	var messageValue = $('<input>').attr('id','errorMessage-attr-' + type + '-c' + index)
							    .attr('type','hidden')
							    .val(record.errorMessage);

	$(midCol).append(messageValue);

	$(row).append(midCol);

	var rightCol = $('<div>').addClass('col-md-3 marginBottom');

	var targetSelect = $('<select>').attr('id','target-attr-' + type + '-c' + index)
							  .attr('data-live-search', 'true')
							  .addClass('selectpicker-' + type)
							  .addClass('dirtyControl');

	if(record.isRequired){
		targetSelect.addClass('required-border');
	}

	switch(type){
		case 'Lead':
			targetSelect.addClass('leadFields');
		break;
		case 'Contact':
			targetSelect.addClass('contactFields');
		break;
		case 'Account':
			targetSelect.addClass('accountFields');
		break;
	}

	var value = $('<option>').attr('value', '').text(window.mappingSettings.Labels.targetField);
	$(targetSelect).append(value);

	$.each(window.mappingSettings.ObjectFields[type], function(index, fieldRow) {
		var value = $('<option>').attr('value', fieldRow.value).text(fieldRow.label);
		$(targetSelect).append(value);
	});

	$(rightCol).append(targetSelect);

	$(targetSelect).val(record.field);
	$(targetSelect).on('change', {type: type, idx: index, tableName: 'attr'}, changeAttributesDropdown);

	var validationText = $('<div>').attr('id','validation-attr-' + type + '-c' + index).addClass('required-text');
	$(rightCol).append(validationText);

	$(row).append(rightCol);

	if (record.isError) {
		$(validationText).text(record.errorMessage);
	} else {
		$(validationText).hide();
	}

	return row;
}

function changeAttributesDropdown(event){
	updateState();
	var prefix = event.data.tableName;


	Visualforce.remoting.Manager.invokeAction(
    	window.mappingSettings.RemoteActions.matchAttributeType,
    	event.data.type,
    	event.data.idx,
    	''+ window.mappingSettings.EnrichmentAttributesMappedFields[event.data.type][event.data.idx].objectName,
    	''+ window.mappingSettings.EnrichmentAttributesMappedFields[event.data.type][event.data.idx].field,
    	''+ window.mappingSettings.EnrichmentAttributesMappedFields[event.data.type][event.data.idx].fieldType,
    	function(result, event) {
     		if (event.status) {
     			if (result.message != '') {
     				$("#error-" + prefix + "-" + result.type + "-c" + result.index).val(true);
     				$("#errorMessage-" + prefix + "-" + result.type + "-c" + result.index).val(result.message);
     			} else {
     				$("#error-" + prefix + "-" + result.type + "-c" + result.index).val(false);
     				$("#errorMessage-" + prefix + "-" + result.type + "-c" + result.index).val('');
     			}
     			updateState();
			} else {
				handleReturnError(event);
			}

		},
        {buffer: true, escape: true}
	);
}

function showModal(){
	var allAttributesPopulated = true;

	if(window.mappingSettings.LeadTableRendered){
		let attributesFields = window.mappingSettings.EnrichmentAttributesMappedFields['Lead'];
		for(let i=0; i< attributesFields.length; i++){
			if($("#target-attr-Lead-c" + i).val() == ''){
				allAttributesPopulated = false;
				break;
			}
		}
	}

	if(window.mappingSettings.AccountTableRendered && allAttributesPopulated){
		let attributesFields = window.mappingSettings.EnrichmentAttributesMappedFields['Account'];
		for(let i=0; i< attributesFields.length; i++){
			if($("#target-attr-Account-c" + i).val() == ''){
				allAttributesPopulated = false;
				break;
			}
		}
	}

	if(window.mappingSettings.ContactTableRendered && allAttributesPopulated){
		let attributesFields = window.mappingSettings.EnrichmentAttributesMappedFields['Contact'];
		for(let i=0; i< attributesFields.length; i++){
			if($("#target-attr-Contact-c" + i).val() == ''){
				allAttributesPopulated = false;
				break;
			}
		}
	}

	if(allAttributesPopulated){
		$('[id$="saveMessage"]').html(window.mappingSettings.Labels.confirmChanges);
	}
	else{
		$('[id$="saveMessage"]').html(window.mappingSettings.Labels.confirmChangesForEmptyAttributes);
	}

	$('#confirmSave').modal('show');
}

function closeModals(){
    $('#confirmCancel').modal('hide');
    $('#confirmSave').modal('hide');
    $('.deleteToDisable').removeAttr('disabled');
	$('.btn-primary.deleteToDisable').attr('value', $('.btn-primary.deleteToDisable').attr('data-oldvalue'));
    $('.btn-primary.deleteToDisable').removeAttr('data-oldvalue');
}

function openCancelScreenModal() {
     $('#confirmCancel').modal('show');
}

function confirmExit() {
	if (isDirty) {
		return window.mappingSettings.Labels.leaveScreen;
	}
}


function saveOnComplete() {
	//reset the "TabReady" flag
	isTabReady[window.mappingSettings.activeTab] = false;

	closeModals();
	renderTable();

	attachDropdowns(window.mappingSettings.activeTab);

	if($('[id$="selectedModelId"]').val() !== ''){
		displayValidation();
		turnDirtyOff();
	} else {
		switchBetweenMods();
	}
}

function cancelOnComplete() {
	switchBetweenMods();
}
