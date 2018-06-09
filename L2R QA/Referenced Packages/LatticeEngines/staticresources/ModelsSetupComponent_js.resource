'use strict';

var dataLead = [];
var dataContact = [];
var dataAccount = [];

function esc(myid) {
    return '#' + myid.replace(/(:|\.)/g,'\\\\$1');
}

function escapeHtml(unsafe) {
    return $('<div />').text(unsafe).html()
}

function unescapeHtml(safe) {
    return $('<div />').html(safe).text();
}

function scoreInternally() {
    return $('[id$="modelInternally"]').is(":checked");
}

function updateTabsState(object){

    switch(object){
        case 'Lead':
            if($('[id$="targetLead"]').is(":checked")){
                window.lpModelMappingSettings.activeTab = 'leadAnchor';
            } else {
                if ($('#rulesLead').val() != '0') {
                    $('#confirmUncheck').modal('show');
                }

                if(window.lpModelMappingSettings.activeTab === 'leadAnchor'){
                    window.lpModelMappingSettings.activeTab = '';
                }
            }
        break;
        case 'Contact':
            if($('[id$="targetContact"]').is(":checked")){
                window.lpModelMappingSettings.activeTab = 'contactAnchor';
            } else {
                if ($('#rulesAccount').val() != '0') {
                    $('#confirmUncheck').modal('show');
                }

                if(window.lpModelMappingSettings.activeTab === 'contactAnchor'){
                    window.lpModelMappingSettings.activeTab = '';
                }
            }
        break;
        case 'Account':
            if($('[id$="targetAccount"]').is(":checked")){
                window.lpModelMappingSettings.activeTab = 'accountAnchor';
            } else {
                if ($('#rulesAccount').val() != '0') {
                    $('#confirmUncheck').modal('show');
                }

                if(window.lpModelMappingSettings.activeTab === 'accountAnchor'){
                    window.lpModelMappingSettings.activeTab = '';
                }
            }
        break;
    }

    updateTableVisibility();
    makeTabActive();

}

function setActiveTabs(){
    if($('[id$="targetLead"]').is(":checked")) {
        window.lpModelMappingSettings.activeTab = 'leadAnchor';
    }

    if($('[id$="targetContact"]').is(":checked")) {
        window.lpModelMappingSettings.activeTab = 'contactAnchor';
    }

    if($('[id$="targetAccount"]').is(":checked")) {
        window.lpModelMappingSettings.activeTab = 'accountAnchor';
    }
}

function switchBetweenMods() {
    if($('[id$="selectedModelId"]').val() === '') {
        $('#modelEditSection').hide();
        $('#mappingSection').hide();
        $('#modelsList').show();

        turnDirtyOff();
        window.lpModelMappingSettings.LeadTableRendered = false;
        window.lpModelMappingSettings.AccountTableRendered = false;
        window.lpModelMappingSettings.ContactTableRendered = false;
        window.lpModelMappingSettings.activeTab = '';
    } else {
        getData();

        $('#modelEditSection').show();
        $('#modelsList').hide();
    }
}

function updateTableVisibility(){
    let account = $('[id$="targetAccount"]').is(":checked");
    let contact = $('[id$="targetContact"]').is(":checked");
    let lead = $('[id$="targetLead"]').is(":checked");

    if(lead || contact || account ){
        $('#mappingSection').show();
    }
    else{
        $('#mappingSection').hide();
    }

    var showAttributes = scoreInternally();

    if (lead) {
        $('#leadLi').show();
        $('#leadScoringFields').show();
        if (showAttributes) {
            $('#leadAttributesFields').show();
        } else {
            $('#leadAttributesFields').hide();
        }

        if(! window.lpModelMappingSettings.LeadTableRendered){
            renderTable('false', 'false', lead);
        }
    } else {
        $('#leadLi').hide();
        $('#leadScoringFields').hide();
        $('#leadAttributesFields').hide();
    }

    if (contact) {
        $('#contactLi').show();
        $('#contactScoringFields').show();
        if (showAttributes) {
            $('#contactAributesFields').show();
        } else {
            $('#contactAributesFields').hide();
        }

        if(!window.lpModelMappingSettings.ContactTableRendered){
            renderTable('false', contact, 'false');
        }
    } else {
        $('#contactLi').hide();
        $('#contactScoringFields').hide();
        $('#contactAributesFields').hide();
    }

    if (account) {
        $('#accountLi').show();
        $('#accountScoringFields').show();
        if (showAttributes) {
            $('#accountAttributesFields').show();
        } else {
            $('#accountAttributesFields').hide();
        }

        if(!window.lpModelMappingSettings.AccountTableRendered){
            renderTable(account, 'false', 'false');
        }
    } else {
        $('#accountLi').hide();
        $('#accountScoringFields').hide();
        $('#accountAttributesFields').hide();
    }
}

function attachDropdowns() {
    $.fn.select2.defaults.set( "theme", "bootstrap" );

    switch(window.lpModelMappingSettings.activeTab){
        case 'leadAnchor':
            $('.leadFields').select2();
        break;
        case 'contactAnchor':
            $('.contactFields').select2();
        break;
        case 'accountAnchor':
            $('.accountFields').select2();
        break;
        default:
            $('.selectpicker').select2();
        break;
    }

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

function getData() {
    $('#loadingScreen').show();

    Visualforce.remoting.Manager.invokeAction(
        window.lpModelMappingSettings.RemoteActions.getData,
        function(result, event) {
            if (event.status) {
                let account = $('[id$="targetAccount"]').is(":checked");
                let contact = $('[id$="targetContact"]').is(":checked");
                let lead = $('[id$="targetLead"]').is(":checked");

                window.lpModelMappingSettings.ObjectFields = result.objectFields;
                window.lpModelMappingSettings.ObjectNames = result.objectNames;
                window.lpModelMappingSettings.CampaignRollupFields = result.campaignRollupFields;

                var d = new Date();
                var start = d.getTime();

                console.log('Begin Render');

                //populateFieldArrays();

                renderTableFirstTime(account, contact, lead);

                d = new Date();
                var end = d.getTime();

                console.log('End Render. Render Time (ms) = ' + (end - start));

                updateTableVisibility();
                makeTabActive();

                $('#loadingScreen').hide();
            } else {
                handleReturnError(event);
            }

        },
        {buffer: true, escape: false}
    );
}

function populateFieldArrays() {
    dataLead = [];

    dataLead.push({id: '', text: window.lpModelMappingSettings.Labels.targetField});

    $.each(window.lpModelMappingSettings.ObjectFields['Lead'], function(index, fieldRow) {
        dataLead.push({id: fieldRow.value, text: fieldRow.label});
    });

    dataContact = [];

    dataContact.push({id: '', text: window.lpModelMappingSettings.Labels.targetField});

    $.each(window.lpModelMappingSettings.ObjectFields['Contact'], function(index, fieldRow) {
        dataContact.push({id: fieldRow.value, text: fieldRow.label});
    });

    dataAccount = [];

    dataAccount.push({id: '', text: window.lpModelMappingSettings.Labels.targetField});

    $.each(window.lpModelMappingSettings.ObjectFields['Account'], function(index, fieldRow) {
        dataAccount.push({id: fieldRow.value, text: fieldRow.label});
    });
}

function updateState() {
    $.each(window.lpModelMappingSettings.ScoringAttributesMappedFields, function(index1, object) {
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

    $.each(window.lpModelMappingSettings.ScoringResultsMappedFields, function(index1, object) {
        $.each(object, function(index2, field) {

            //This way I do not overwrite the newly created (and not yet rendered) row
            if ($("#target-results-" + field.objectName + "-c" + index2).length > 0) {
                field.field = $("#target-results-" + field.objectName + "-c" + index2).val();
                field.errorMessage = $("#errorMessage-results-" + field.objectName + "-c" + index2).val();

                //since these fields contains a string, I have to "booleanize" them
                field.isError = ( $("#error-results-" + field.objectName + "-c" + index2).val() == 'true');
                addOrRemoveValidationMessage(index2, 'calculate', field.objectName, field);
            }
        });
    })

    var clauses = JSON.stringify(window.lpModelMappingSettings.ScoringAttributesMappedFields);

    $("[id$='scoringAttributesMapping']").val(clauses);

    var calcClauses = JSON.stringify(window.lpModelMappingSettings.ScoringResultsMappedFields);

    $("[id$='scoringResultsMapping']").val(calcClauses);
}

function renderTableFirstTime (account, contact, lead) {
    renderTable(account, contact, lead);

    setActiveTabs();
}

function displayValidation(){
    if ($("[id$='scoringResultsMapping']").val()) {
        window.lpModelMappingSettings.ScoringResultsMappedFields = JSON.parse($("[id$='scoringResultsMapping']").val());
    }
    if ($("[id$='scoringAttributesMapping']").val()) {
        window.lpModelMappingSettings.ScoringAttributesMappedFields = JSON.parse($("[id$='scoringAttributesMapping']").val());
    }

    if(window.lpModelMappingSettings.LeadTableRendered){
        let scoringFields = window.lpModelMappingSettings.ScoringResultsMappedFields['Lead'];
        let attributesFields = window.lpModelMappingSettings.ScoringAttributesMappedFields['Lead'];
        updateValidationForEachObject(scoringFields, attributesFields, 'Lead');
    }

    if(window.lpModelMappingSettings.AccountTableRendered){
        let scoringFields = window.lpModelMappingSettings.ScoringResultsMappedFields['Account'];
        let attributesFields = window.lpModelMappingSettings.ScoringAttributesMappedFields['Account'];
        updateValidationForEachObject(scoringFields, attributesFields, 'Account');
    }

    if(window.lpModelMappingSettings.ContactTableRendered){
        let scoringFields = window.lpModelMappingSettings.ScoringResultsMappedFields['Contact'];
        let attributesFields = window.lpModelMappingSettings.ScoringAttributesMappedFields['Contact'];
        updateValidationForEachObject(scoringFields, attributesFields, 'Contact');
    }
}

function updateValidationForEachObject(scoring, attributes, type) {
    for(let i=0; i<scoring.length; i++){
        let object = scoring[i];
        addOrRemoveValidationMessage(i, 'calculate', type, object);
    }

    for(let i=0; i<attributes.length; i++){
        let object = attributes[i];
        addOrRemoveValidationMessage(i, 'attributes', type, object);
    }
}

function addOrRemoveValidationMessage(index, fieldType, type, record) {
    var selector;
    var errorSelector;
    var errorMessageSelector;
    if(fieldType === 'calculate'){
        selector = '#validation-results-' + type + '-c' + index;
        errorSelector = "#error-results-" + type + "-c" + index;
        errorMessageSelector = "#errorMessage-results-" + type + "-c" + index;
    }
    else {
        selector = '#validation-attr-' + type + '-c' + index;
        errorSelector = "#error-attr-" + type + "-c" + index;
        errorMessageSelector = "#errorMessage-attr-" + type + "-c" + index;
    }

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

function renderTable(account, contact, lead) {
    window.lpModelMappingSettings.ScoringResultsMappedFields = JSON.parse($("[id$='scoringResultsMapping']").val());
    window.lpModelMappingSettings.ScoringAttributesMappedFields = JSON.parse($("[id$='scoringAttributesMapping']").val());

    switch(window.lpModelMappingSettings.activeTab){
        case 'leadAnchor':
            renderLeadTables();
            window.lpModelMappingSettings.LeadTableRendered = true;
        break;
        case 'contactAnchor':
            renderContactTables();
            window.lpModelMappingSettings.ContactTableRendered = true;
        break;
        case 'accountAnchor':
            renderAccountTables();
            window.lpModelMappingSettings.AccountTableRendered = true;
        break;
        default:
            if (lead){
                renderLeadTables();
                window.lpModelMappingSettings.LeadTableRendered = true;
            }
            if (contact){
                renderContactTables();
                window.lpModelMappingSettings.ContactTableRendered = true;
            }
            if (account){
                renderAccountTables();
                window.lpModelMappingSettings.AccountTableRendered = true;
            }
        break;
    }

    attachDropdowns();

    assingListenerToTabs();
}

function renderLeadTables() {
    renderLeadResultTable();
    renderLeadAttributesTable();
}

function renderAccountTables() {
    renderAccountResultTable();
    renderAccountAttributesTable();
}

function renderContactTables() {
    renderContactResultTable();
    renderContactAttributesTable();
}

function renderAttributesTables() {
    renderLeadAttributesTable();
    renderAccountAttributesTable();
    renderContactAttributesTable();
    attachDropdowns();
}

function assingListenerToTabs(){
    $("#tabSection a").click(function(event) {
        window.lpModelMappingSettings.activeTab = $(this).attr('id');
        event.preventDefault();
        $(this).tab('show');
    });
}

function makeTabActive() {
    var activeAnchor = $('[id$="'+window.lpModelMappingSettings.activeTab+'"]')
    if (window.lpModelMappingSettings.activeTab === activeAnchor.attr('id') && activeAnchor.length > 0){
        $(activeAnchor).tab('show');
    } else {
        if($('[id$="targetLead"]').is(":checked")) {
            $('[id$="leadAnchor"]').tab('show');
        }
        else if($('[id$="targetContact"]').is(":checked")) {
            $('[id$="contactAnchor"]').tab('show');
        }
        else if($('[id$="targetAccount"]').is(":checked")) {
            $('[id$="accountAnchor"]').tab('show');
        }
    }
}

function addSpaceToRadioButton () {
    $($('[id$="scoringSource"]').find('label')[0]).css('margin-right', '15px');
}

function renderResultTable (selector, objectType) {
    $(selector).empty();
    $(selector).append(createTableHeader('results', objectType, window.lpModelMappingSettings.Labels.scoringResults, window.lpModelMappingSettings.Labels.scoringResultsIntro));
    $(selector).append(createResultsTable(window.lpModelMappingSettings.ObjectNames[objectType].value,
                                            window.lpModelMappingSettings.ScoringResultsMappedFields[objectType]
                                            )
                            );
}

function renderAttributesTable(selector, objectType) {
    var fieldsList = window.lpModelMappingSettings.ScoringAttributesMappedFields[objectType];
    if (fieldsList.length > 0) {
        $(selector).empty();
        $(selector).append(createTableHeader('attributes', objectType, window.lpModelMappingSettings.Labels.scoringAttr, window.lpModelMappingSettings.Labels.scoringAttrIntro));
        $(selector).append(createAttrTable(window.lpModelMappingSettings.ObjectNames[objectType].value,
                                                fieldsList
                                                )
                                );
    }


}

function renderLeadResultTable() {
    renderResultTable ('#leadScoringFields', 'Lead');
}

function renderLeadAttributesTable() {
    renderAttributesTable('#leadAttributesFields', 'Lead');
}

function renderContactResultTable() {
    renderResultTable ('#contactScoringFields', 'Contact');
}

function renderContactAttributesTable() {
    renderAttributesTable('#contactAributesFields', 'Contact');
}

function renderAccountResultTable() {
    renderResultTable ('#accountScoringFields', 'Account');
}

function renderAccountAttributesTable() {
    renderAttributesTable('#accountAttributesFields', 'Account');
}

function createTableHeader(sectionName, objectType,  header, intro) {
    var div = $('<div>').attr('id', 'area-' + sectionName + '-' + objectType);

    var title = $('<h3>').text(header);
    $(div).append(title);

    var para = $('<p>').text(intro);
    $(div).append(para);

    var table = $('<div>').attr('id', 'table-' + sectionName + '-' + objectType);

    var row = $('<div>').addClass('row');
    var leftCol = $('<div>').addClass('col-md-3');
    var leftSpan = $('<span>')
                            .addClass('static-title')
                            .css('text-decoration', 'underline');

    if (sectionName == 'results') {
        $(leftSpan).text(window.lpModelMappingSettings.Labels.sfField);
    } else {
        $(leftSpan).text(window.lpModelMappingSettings.Labels.scoringAttr);
    }

    $(leftCol).append(leftSpan);
    $(row).append(leftCol);
    var midCol = $('<div>').addClass('col-md-2').addClass('text-center');
    $(row).append(midCol);
    var rightCol = $('<div>').addClass('col-md-3 marginBottom');
    var title = $('<span>').text(window.lpModelMappingSettings.Labels.scoringValues)
                           .addClass('static-title')
                           .css('text-decoration', 'underline');

    if (sectionName == 'results') {
        $(title).text(window.lpModelMappingSettings.Labels.scoringValues);
    } else {
        $(title).text(window.lpModelMappingSettings.Labels.sfField);
    }

    $(rightCol).append(title);

    $(row).append(rightCol);
    $(table).append(row);


    $(div).append(table);

    return div;
}

function createResultsTable(type, scoringResults) {
    $.each(scoringResults, function(index, object) {
        var row = createCalculatedRow(type, index, object);
        $('#table-results-'+type).append(row);
    });
}

function createAttrTable (type, scoringAttributes) {
     $.each(scoringAttributes, function(index, object) {
        var row = createAttributeRow(type, index, object);
        $('#table-attributes-'+type).append(row);
    });
}

function createCalculatedRow(type, index, record) {

    var row = $('<div>').addClass('row');

    var leftCol = $('<div>').addClass('col-md-3');

    var targetSelect = $('<select>').attr('id','target-results-' + type + '-c' + index)
                              .attr('data-live-search', 'true')
                              .addClass('selectpicker')
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

//*****
    var value = $('<option>').attr('value', '').text(window.lpModelMappingSettings.Labels.targetField);
    $(targetSelect).append(value);

    $.each(window.lpModelMappingSettings.ObjectFields[type], function(index, fieldRow) {
        if(fieldRow.isCustom && ! fieldRow.isCalculated){
            var value = $('<option>').attr('value', fieldRow.value).text(fieldRow.label);
            $(targetSelect).append(value);
        }
    });

    $(leftCol).append(targetSelect);

    $(targetSelect).val(record.field);
    $(targetSelect).on('change', {type: type, idx: index, tableName: 'results'}, changeCalculatedDropdown);

    $(row).append(leftCol);

    var validationText = $('<div>').attr('id','validation-results-' + type + '-c' + index).addClass('required-text');
    $(leftCol).append(validationText);

    if (record.isError) {
        $(validationText).text(record.errorMessage);
    } else {
        $(validationText).hide();
    }

    var midCol = $('<div>').addClass('col-md-2').addClass('text-center');

    $(midCol).append('<span class="glyphicon glyphicon-arrow-left" aria-hidden="true"></span>');

    var errorValue = $('<input>').attr('id','error-results-' + type + '-c' + index)
                                .attr('type','hidden')
                                .val(record.isError);

    $(midCol).append(errorValue);

    var messageValue = $('<input>').attr('id','errorMessage-results-' + type + '-c' + index)
                                .attr('type','hidden')
                                .val(record.errorMessage);

    $(midCol).append(messageValue);

    $(row).append(midCol);

    var rightCol = $('<div>').addClass('col-md-3 marginBottom');

    var title = $('<span>').text(record.label+ ' (' + record.name + ')')
                           .addClass('static-title');

    $(rightCol).append(title);

    $(row).append(rightCol);

    return row;

}

function createAttributeRow (type, index, record) {
    var row = $('<div>').addClass('row');

    var leftCol = $('<div>').addClass('col-md-3');
    var title = $('<span>').text(record.label + ' (' + record.name + ')')
                           .addClass('static-title');
    $(leftCol).append(title);

    $(row).append(leftCol);

    var midCol = $('<div>').addClass('col-md-2').addClass('text-center');

    $(midCol).append('<span class="glyphicon glyphicon-arrow-left" aria-hidden="true"></span>');

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
                              .addClass('selectpicker')
                              .addClass('dirtyControl');

    if(record.isRequired){
        targetSelect.addClass('required-border');
    }

    var doCampaignRollup = false;

    switch(type){
        case 'Lead':
            targetSelect.addClass('leadFields');
            doCampaignRollup = true;
        break;
        case 'Contact':
            targetSelect.addClass('contactFields');
            doCampaignRollup = true;
        break;
        case 'Account':
            targetSelect.addClass('accountFields');
        break;
    }

//*****
    var value = $('<option>').attr('value', '').text(window.lpModelMappingSettings.Labels.targetField);
    $(targetSelect).append(value);

    if (doCampaignRollup) {
        var optGroupCampaignRollup = $('<optgroup>').attr('label',window.lpModelMappingSettings.Labels.crFields);

        $.each(window.lpModelMappingSettings.CampaignRollupFields, function(index, fieldRow) {
            var value = $('<option>').attr('value', fieldRow.value).text(fieldRow.label);
            $(optGroupCampaignRollup).append(value);
        });

        $(targetSelect).append(optGroupCampaignRollup);
    }

    var optGroupStandard = $('<optgroup>').attr('label',window.lpModelMappingSettings.Labels.standardFields);

    $.each(window.lpModelMappingSettings.ObjectFields[type], function(index, fieldRow) {
        var value = $('<option>').attr('value', fieldRow.value).text(fieldRow.label);
        $(optGroupStandard).append(value);
    });

    $(targetSelect).append(optGroupStandard);

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

function changeCalculatedDropdown(event) {
    updateState();
    var prefix = event.data.tableName;

    Visualforce.remoting.Manager.invokeAction(
        window.lpModelMappingSettings.RemoteActions.matchFieldType,
        event.data.type,
        event.data.idx,
        ''+ window.lpModelMappingSettings.ScoringResultsMappedFields[event.data.type][event.data.idx].objectName,
        ''+ window.lpModelMappingSettings.ScoringResultsMappedFields[event.data.type][event.data.idx].field,
        ''+ window.lpModelMappingSettings.ScoringResultsMappedFields[event.data.type][event.data.idx].name,
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

function changeAttributesDropdown(event){
    updateState();
    var prefix = event.data.tableName;

    Visualforce.remoting.Manager.invokeAction(
        window.lpModelMappingSettings.RemoteActions.matchAttributeType,
        event.data.type,
        event.data.idx,
        ''+ window.lpModelMappingSettings.ScoringAttributesMappedFields[event.data.type][event.data.idx].objectName,
        ''+ window.lpModelMappingSettings.ScoringAttributesMappedFields[event.data.type][event.data.idx].field,
        ''+ window.lpModelMappingSettings.ScoringAttributesMappedFields[event.data.type][event.data.idx].name,
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

    if(window.lpModelMappingSettings.LeadTableRendered){
        let attributesFields = window.lpModelMappingSettings.ScoringAttributesMappedFields['Lead'];
        for(let i=0; i< attributesFields.length; i++){
            if($("#target-attr-Lead-c" + i).val() == ''){
                allAttributesPopulated = false;
                break;
            }
        }
    }

    if(window.lpModelMappingSettings.AccountTableRendered && allAttributesPopulated){
        let attributesFields = window.lpModelMappingSettings.ScoringAttributesMappedFields['Account'];
        for(let i=0; i< attributesFields.length; i++){
            if($("#target-attr-Account-c" + i).val() == ''){
                allAttributesPopulated = false;
                break;
            }
        }
    }

    if(window.lpModelMappingSettings.ContactTableRendered && allAttributesPopulated){
        let attributesFields = window.lpModelMappingSettings.ScoringAttributesMappedFields['Contact'];
        for(let i=0; i< attributesFields.length; i++){
            if($("#target-attr-Contact-c" + i).val() == ''){
                allAttributesPopulated = false;
                break;
            }
        }
    }

    if(allAttributesPopulated){
        $('[id$="saveMessage"]').html(window.lpModelMappingSettings.Labels.confirmChanges);
    }
    else{
        $('[id$="saveMessage"]').html(window.lpModelMappingSettings.Labels.confirmChangesForEmptyAttributes);
    }

    $('#confirmSave').modal('show');
}

function closeModals(){
    $('#confirmCancel').modal('hide');
    $('#confirmSave').modal('hide');
    $('#confirmUncheck').modal('hide');
    $('.deleteToDisable').removeAttr('disabled');
    $('.btn-primary.deleteToDisable').attr('value', $('.btn-primary.deleteToDisable').attr('data-oldvalue'));
    $('.btn-primary.deleteToDisable').removeAttr('data-oldvalue');
}

function openCancelScreenModal(){
     $('#confirmCancel').modal('show');
}

function confirmExit() {
    if (isDirty) {
        return window.lpModelMappingSettings.Labels.leaveScreen;
    }
}

function assignPagination() {
    $('#modelsTable').DataTable({
        "dom": '<<"pull-left"i><"pull-right"f>>t<"pull-left"p><"clear">',
        "iDisplayLength": 25
    });

    if($(".dataTables_empty").length === 1) {
        $(".dataTables_empty").hide();
        $(".dataTables_paginate").hide();
        $(".dataTables_filter").hide();
        $(".dataTables_info").hide();
    }

    if($("#modelsTable tbody tr").length <= 20){
        $(".dataTables_filter").hide();
    }

    // if($("#modelsTable tbody tr").length <= 25){
    //  $(".dataTables_paginate").hide();
    //  $(".dataTables_info").hide();
    // }

    $('#modelsTable_filter').addClass('pull-right');
    $('#modelsTable_paginate').addClass('pull-right');
}

function saveOnComplete() {
    closeModals();
    if($('[id$="selectedModelId"]').val() !== ''){
        displayValidation();
        turnDirtyOn();
    } else {
        switchBetweenMods();
    }
}

function cancelOnComplete() {
    switchBetweenMods();
}
