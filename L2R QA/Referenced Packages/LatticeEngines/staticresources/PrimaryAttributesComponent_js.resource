'use strict';

function esc(myid) {
    return '#' + myid.replace(/(:|\.)/g,'\\\\$1');
}

function attachDropdowns() {
    $.fn.select2.defaults.set( "theme", "bootstrap" );

    $('.dropdown').select2();
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

function setActiveTab(tabToLoad) {
    if (window.primaryAttributesSettings.Variables.activeTab != tabToLoad) {

        if (isDirty && ! confirm(window.primaryAttributesSettings.Labels.leaveScreen)) {
            return;
        }

        turnDirtyOff();

        //Clear the errors
        $('#message').hide();
        $('#errorList').empty();

        window.primaryAttributesSettings.Variables.activeTab = tabToLoad;

        $('.mainTab').removeClass('active');
        $('#' + tabToLoad + 'Tab').addClass('active');

        getData();
    }
}

function getData() {
    $('#loadingScreen').show();

    Visualforce.remoting.Manager.invokeAction(
        window.primaryAttributesSettings.RemoteActions.getDataTab,
        window.primaryAttributesSettings.Variables.activeTab,
        function(result, event) {
            if (event.status) {

                window.primaryAttributesSettings.FieldsForDropdown = result.objectFields;
                window.primaryAttributesSettings.MappedFields = result.mappingsForTab;

                var d = new Date();
                var start = d.getTime();

                console.log('Begin Render');

                renderTable();
                attachDropdowns();

                d = new Date();
                var end = d.getTime();

                console.log('End Render. Render Time (ms) = ' + (end - start));

                $('#loadingScreen').hide();
            } else {
                handleReturnError(event);
            }

        },
        {buffer: true, escape: false}
    );
}

function renderTable() {
    $('#fields').empty();

    $('#nothingConfigured').hide();
    if (window.primaryAttributesSettings.MappedFields.length == 0) {
        $('#nothingConfigured').show();
    }

    $.each(window.primaryAttributesSettings.MappedFields, function(index, object) {
        var row = createRow(index, object);

        $('#fields').append(row);
    });
}

function createRow(index, record) {
    var row = $('<tr>');

    var leftCol = $('<td>').text(record.apiDisplayName);

    $(row).append(leftCol);

    var rightCol = $('<td>');
    if (record.isError) {
        $(rightCol).addClass('has-error');
    }

    var dropdown = $('<select>').attr('id',record.id).addClass('dropdown').addClass('dirtyControl');

    var defaultValue = $('<option>').attr('value', '').text(window.primaryAttributesSettings.Labels.selectField);
    $(dropdown).append(defaultValue);

    $.each(window.primaryAttributesSettings.FieldsForDropdown, function(index, fieldRow) {
        var value = $('<option>').attr('value', fieldRow.value).text(fieldRow.label);
        $(dropdown).append(value);
    });

    $(dropdown).val(record.fieldName);

    $(rightCol).append(dropdown);

    $(row).append(rightCol);

    return row;
}

function saveTab() {
    closeModals();
    $('#loadingScreen').show();

    //Clear the errors first
    $('#message').hide();
    $('#errorList').empty();

    //Refresh the array with the new/changed mappings
    $.each(window.primaryAttributesSettings.MappedFields, function(index, object) {
        object.fieldName = $('#' + object.id).val();
    });

    Visualforce.remoting.Manager.invokeAction(
        window.primaryAttributesSettings.RemoteActions.saveTab,
        window.primaryAttributesSettings.Variables.activeTab,
        window.primaryAttributesSettings.MappedFields,
        function(result, event) {
            if (event.status) {

                window.primaryAttributesSettings.MappedFields = result.mappingsForTab;
                var errors = [];

                if (result.message != '') {
                    if (! result.isMessageError) {
                        //This is the success message
                        $('#message').show();
                        $('#message').text(result.message);

                        //If it was successful remove the notification
                        $('#' + window.primaryAttributesSettings.Variables.activeTab + 'Tab').removeClass('has-notification');

                        //Turn the dirty if the save worked
                        turnDirtyOff();
                    } else {
                        //Add the error to the collection that goes at the end
                        errors.push(result.message);
                    }
                }

                //Record any global and/or line-item errors
                $.each(window.primaryAttributesSettings.MappedFields, function(index, object) {
                    if (object.isError && object.errorMessage != '') {
                        errors.push(object.errorMessage);
                    }
                });

                if (errors.length > 0) {
                    renderErrors(errors);
                }

                var d = new Date();
                var start = d.getTime();

                console.log('Begin Render');

                renderTable();
                attachDropdowns();

                d = new Date();
                var end = d.getTime();

                console.log('End Render. Render Time (ms) = ' + (end - start));

                $('#loadingScreen').hide();
            } else {
                handleReturnError(event);
            }

        },
        {buffer: true, escape: false}
    );
}

function renderErrors(errors) {
    $('#errorList').empty();

    $.each(errors, function(index, error) {
        var errorMessage = $('<li>').text(error);

        $('#errorList').append(errorMessage);
    });
}

function showModal(){
    $('#confirmSave').modal('show');
}

function closeModals(){
    $('#confirmSave').modal('hide');
}

function openCancelScreenModal(){
     $('#confirmCancel').modal('show');
}

function confirmExit() {
    if (isDirty) {
        return window.primaryAttributesSettings.Labels.leaveScreen;
    }
}