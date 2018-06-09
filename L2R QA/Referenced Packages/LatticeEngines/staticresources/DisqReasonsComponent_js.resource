function esc(myid) {
	return '#' + myid.replace(/(:|\.)/g,'\\\\$1');
}

function handleReturnError(event) {
	if (event.type === 'exception') {
		alert('Error: ' + event.message + ' ' + event.where);
    }  else {
		alert('Error: ' + event.message + ' ' + event.where);
	}
}

function resetScreen() {
	$('[data-toggle="popover"]').popover();
}

function initScreen() {
	resetSorters();

}

function resetSorters() {
	$( ".sortable" ).sortable({
		cursor: "move",
		placeholder: "ui-state-highlight"
	});
	$( ".sortable" ).disableSelection();

	$( ".sortable" ).on( "sortstop", stopSorting );
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

function toggleActiveHidden(newValue) {
	$('#activeYes').removeClass('active');
	$('#activeNo').removeClass('active');

	if (newValue) {
		$('#activeYes').addClass('active');
	} else {
		$('#activeNo').addClass('active');
	}

	$("[id$='activeHidden']").val(newValue);
}

function toggleOptionalHidden(newValue) {
	$('#optionalYes').removeClass('active');
	$('#optionalNo').removeClass('active');

	if (newValue) {
		$('#optionalYes').addClass('active');
	} else {
		$('#optionalNo').addClass('active');
	}

	$("[id$='optionalHidden']").val(newValue);
}

function closeModals(){
    $('#confirmDelete').modal('hide');

    $('.deleteToDisable').removeAttr('disabled');
	$('.btn-primary.deleteToDisable').attr('value', $('.btn-primary.deleteToDisable').attr('data-oldvalue'));
    $('.btn-primary.deleteToDisable').removeAttr('data-oldvalue');
}