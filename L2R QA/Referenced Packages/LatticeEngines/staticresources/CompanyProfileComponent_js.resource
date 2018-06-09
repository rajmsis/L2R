function esc(myid) {
	return '#' + myid.replace(/(:|\.)/g,'\\\\$1');
}

var substringMatcher = function(strs) {
  return function findMatches(q, cb) {
    var matches, substringRegex;

    // an array that will be populated with substring matches
    matches = [];

    // regex used to determine if a string contains the substring `q`
    substrRegex = new RegExp(q, 'i');

    // iterate through the pool of strings and for any string that
    // contains the substring `q`, add it to the `matches` array
    $.each(strs, function(i, str) {
      if (substrRegex.test(str)) {
        matches.push(str);
      }
    });

    cb(matches);
  };
};


function attachDropdowns() {
	// $('.selectpicker').selectpicker('refresh');
	$('.selectpicker').select2();
	$('[data-toggle="popover"]').popover();
}

function handleReturnError(event) {
	if (event.type === 'exception') {
		alert('Error: ' + event.message + ' ' + event.where);
    }  else {
		alert('Error: ' + event.message + ' ' + event.where);
	}
}

function initScreen() {
	resetSorters();

	getAllFields();
}

function resetSorters() {
	$( ".sortable" ).sortable({
		cursor: "move",
		placeholder: "ui-state-highlight"
	});
	$( ".sortable" ).disableSelection();

	$( ".sortableSave" ).on( "sortstop", stopSorting );
	$( ".sortableMemory" ).on( "sortstop", stopSortingMemory );
}

function stopSorting( event, ui ) {
	
	//Create the JSON
	var allObjects = [];
	$( ".hidId" ).each(function( index ) {
		var oneObject = {
			id: $(this).val(),
			order: index
		}

		$('#rowNum'+ $(this).val()).text(index+1);

		allObjects.push(oneObject);
	});

	saveReorder(JSON.stringify(allObjects));
}

function stopSortingMemory( event, ui ) {
	$.each($('.orderHolder'), function(index, object) {
		var formerIndex = $(object).val();

		window.companyProfileSettings.Fields[index].order = index;
		window.companyProfileSettings.Fields[index].id = $('#id-' + formerIndex).val();
		window.companyProfileSettings.Fields[index].describeId = $('#describeId-' + formerIndex).val();
		window.companyProfileSettings.Fields[index].describeName = $('#describeName-' + formerIndex).val();
	});


	updateState();
	renderFieldsTable();
}

function getAllFields() {
	if (window.companyProfileSettings.AvailableFields.length > 0) {
		return;
	}

	Visualforce.remoting.Manager.invokeAction(
    	window.companyProfileSettings.RemoteActions.getAllFields,
    	function(result, event) {
     		if (event.status) {
     			window.companyProfileSettings.AvailableFields = result;

     			if (window.companyProfileSettings.Variables.reRenderTable) {
     				renderFieldsTable();
     			}
			} else {
				handleReturnError(event);
			}

		},
        {buffer: true, escape: false}
	);

}

function renderFieldsTable() {

	window.companyProfileSettings.Fields = JSON.parse($("[id$='groupFields']").val());

	$('#fieldsArea').empty();

	$.each(window.companyProfileSettings.Fields, function(index, object) {
		var row = createRow(index, object);

		$('#fieldsArea').append(row);
	});

	renderDropdown();
	attachDropdowns();
	resetSorters();
}

function renderDropdown() {
	$('#newFieldDropdown').empty();

	var objectSelect = $('<select>').attr('id', 'newField').attr('data-live-search', 'true').addClass('selectpicker');

	var option = $('<option>').attr('value', '').text(window.companyProfileSettings.Labels.addField);
	$(objectSelect).append(option);

	$.each(window.companyProfileSettings.AvailableFields, function(index, object) {
		if (object.display) {
			var option = $('<option>').attr('value', object.value).text(object.label);

			$(objectSelect).append(option);
		}

	});

	$(objectSelect).on('change', addNewField);

	$('#newFieldDropdown').append(objectSelect);
}

function addNewField() {
	descId = $('#newField').val();
	descName = $("#newField option:selected").text();

	var newRow = {
		id: '',
		order: window.companyProfileSettings.Fields.length+1,
		describeId: descId,
		describeName: descName
	};

	window.companyProfileSettings.Fields.push(newRow);

	showHideFieldFromDropdown(descId, false);

	updateState();

	renderFieldsTable();
}

function removeRow(event) {
	var descId = window.companyProfileSettings.Fields[event.data.idx].describeId;

	window.companyProfileSettings.Fields.splice(event.data.idx,1);

	showHideFieldFromDropdown(descId, true);

	updateState();
	renderFieldsTable();

}

function updateState() {
	$.each(window.companyProfileSettings.Fields, function(index, object) {
		object.order = index;
	});

	var fields = JSON.stringify(window.companyProfileSettings.Fields);

	$("[id$='groupFields']").val(fields);
}

function createRow(index, rowToRender) {

	var row = $('<tr>').attr('id', 'row-' + index).attr('data-rulename', 'field-' + rowToRender.id);

	var leftColumn = $('<td>');

	var anchor = $('<a>').addClass('drag-and-drop').attr('href','#');

	var icon = $('<span>').addClass('glyphicon').addClass('glyphicon-move');

	$(anchor).append(icon);
	$(leftColumn).append(anchor);

	var title = $('<span>').attr('id','fieldNum-' + rowToRender.id).text(index);
	$(leftColumn).append(title);

	var hidValue = $('<input>').attr('type','hidden').addClass('orderHolder').attr('id','order-' + index).val(rowToRender.order);
	$(leftColumn).append(hidValue);
	var hidValue = $('<input>').attr('type','hidden').attr('id','id-' + index).val(rowToRender.id);
	$(leftColumn).append(hidValue);
	var hidValue = $('<input>').attr('type','hidden').attr('id','describeId-' + index).val(rowToRender.describeId);
	$(leftColumn).append(hidValue);
	var hidValue = $('<input>').attr('type','hidden').attr('id','describeName-' + index).val(rowToRender.describeName);
	$(leftColumn).append(hidValue);

	$(row).append(leftColumn);

	var middleColumn = $('<td>').text(rowToRender.describeName);

	$(row).append(middleColumn);

	var rightColumn = $('<td>');

	var img = $('<span>').addClass('glyphicon').addClass('glyphicon-remove');

	$(img).on('click', {idx: index}, removeRow);

	$(rightColumn).append(img);

	$(row).append(rightColumn);

	return row;
}

function resetAllDropdownFields() {

	$.each(window.companyProfileSettings.AvailableFields, function(index, object) {
		object.display = true;
	});

	window.companyProfileSettings.FieldsInDB = JSON.parse($("[id$='allFields']").val());

	$.each(window.companyProfileSettings.FieldsInDB, function(index, object) {
		showHideFieldFromDropdown(object, false);
	});
}

function showHideFieldFromDropdown(fieldId, showHide) {
	$.each(window.companyProfileSettings.AvailableFields, function(index, object) {

		if (object.value == fieldId) {
			object.display = showHide;
		}
	});
}

function closeModals(){
    $('#confirmDelete').modal('hide');

    $('.deleteToDisable').removeAttr('disabled');
	$('.btn-primary.deleteToDisable').attr('value', $('.btn-primary.deleteToDisable').attr('data-oldvalue'));
    $('.btn-primary.deleteToDisable').removeAttr('data-oldvalue');
}
