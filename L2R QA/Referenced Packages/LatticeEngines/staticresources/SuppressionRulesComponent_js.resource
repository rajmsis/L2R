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
	$('[data-toggle="popover"]').popover();
	// $('.selectpicker').selectpicker('refresh');
	// $('.nosearch-picker').selectpicker('refresh');
	// $('.selectpickerTitle').selectpicker('refresh');

	$('.selectpicker').select2();
	$('.nosearch-picker').select2({
	  minimumResultsForSearch: Infinity
	});
    $('.selectpickerTitle').select2({
	  	minimumResultsForSearch: Infinity,
  		escapeMarkup: function(m) {
        	// Do not escape HTML in the select options text
        	return m;
     	},
     	templateSelection: function(data, container)  {
     		if (data.title == '') {
     			return data.text;
     		} else {
     			return data.title;
     		}
     	}
    });

	$('.dateControl').datetimepicker({
		format:'Y-m-d',
		timepicker: false
	});
	$('.dateTimeControl').datetimepicker({
		format:'Y-m-d H:i:00',
		defaultTime:'00:00'
	});

	$.each(window.suppressionRulesSettings.ReferenceLines, function(index, object) {
		initializeTypeAhead(object);
	});
}

function handleReturnError(event) {
	if (event.type === 'exception') {
		alert('Error: ' + event.message + ' ' + event.where);
    }  else {
		alert('Error: ' + event.message + ' ' + event.where);
	}
}

function initScreen() {
	$( ".sortable" ).sortable({
		cursor: "move",
		placeholder: "ui-state-highlight"
	});
	$( ".sortable" ).disableSelection();


	$( ".sortable" ).on( "sortstop", stopSorting );

	getAllObjects();
}

function getMatcherFieldsForObject(objectName) {

	var returnValue = [];
	var foundFields = false;
	$.each(window.suppressionRulesSettings.Objects, function(index, object) {

		// TAL - Added foundFields here so the second instance of 'Recommendation__c-Active' doesn't overwrite the first one.  As long as order is maintained we should be okay.
		if (object.value == objectName && !foundFields) {
			foundFields = true;
			returnValue = object.matcherFields;
		}

	});

	return returnValue;
}

function getFieldsForObject(objectName) {
	var returnValue = [];

	$.each(window.suppressionRulesSettings.Objects, function(index, object) {

		if (object.value == objectName) {
			returnValue = object.fields;
		}

	});

	return returnValue;
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


function getAllObjects() {

	if (window.suppressionRulesSettings.Objects.length >0) {
		return;
	}
	$('#loadingScreen').show();

	Visualforce.remoting.Manager.invokeAction(
    	window.suppressionRulesSettings.RemoteActions.getAllObjects,
    	function(result, event) {

			$('#loadingScreen').hide();

     		if (event.status) {
     			window.suppressionRulesSettings.Objects = result.objects;
     			window.suppressionRulesSettings.ObjectDisplays = result.objectDisplays;

     			if (window.suppressionRulesSettings.Variables.reRenderTable) {
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

function updateState() {
	$.each(window.suppressionRulesSettings.Clauses, function(index, object) {
		object.order = index;

		if ($("#object-" + index).length > 0) {
			var objectName = $("#object-" + index).val();

			var res = objectName.split("-");
			object.objectName = res[1];
			object.isPrevious = (res[0] == 'p');
			object.isAllRecs = (res[0] == 'a');
			object.objectModifier = res[2];
		} else {
			object.objectName = '';
			object.isPrevious = false;
			object.isPrevious = false;
			object.objectModifier = window.suppressionRulesSettings.Labels.regular;
		}

		if ($("#objectMatcher-" + index).length > 0) {
			object.objectMatcher =  $("#objectMatcher-" + index).val();
		} else {
			object.objectMatcher =  '';
		}

		if (object.isAllRecs && $("#field-" + index).val() == '') {
			object.fieldName = 'EXISTS';
			object.onlyCheckExistence = true;
		} else {
			object.fieldName = $("#field-" + index).val();
			object.onlyCheckExistence = ($("#field-" + index).val() == 'EXISTS');
		}

		object.operator = $("#operator-" + index).val();

		if ($("#value-" + index).length > 0) {
			object.value = $("#value-" + index).val();
		} else {
			object.value = '';
		}

		if ($("#valueInfo-" + index).length > 0) {
			object.valueInfo = $("#valueInfo-" + index).val();
		} else {
			object.valueInfo = '';
		}

	});

	var clauses = JSON.stringify(window.suppressionRulesSettings.Clauses);

	$("[id$='ruleClauses']").val(clauses);
}

function renderClausesTable() {
	window.suppressionRulesSettings.Clauses = JSON.parse($("[id$='ruleClauses']").val());

	$('#clausesTable').empty();
	window.suppressionRulesSettings.ReferenceLines = [];

	if (window.suppressionRulesSettings.Clauses.length == 0) {
		$('#noCriteria').show();
		$('#ruleClausesLogic').hide();
		$('[id$="ruleLogic"]').val('');
	} else {
		$('#noCriteria').hide();
		$('#ruleClausesLogic').show();
	}

	$.each(window.suppressionRulesSettings.Clauses, function(index, object) {
		var row = createRow(index, object);

		$('#clausesTable').append(row);

	});


	attachDropdowns();
}

function addNewRow() {

	var newRow = {
    		order: window.suppressionRulesSettings.Clauses.length+1,
			isPrevious: false,
			objectName: '',
			fieldName: '',
			operator: '',
			value: '',
			valueInfo: ''
    	};

	window.suppressionRulesSettings.Clauses.push(newRow);

	updateState();

	renderClausesTable();

}

function removeRow(event) {
	window.suppressionRulesSettings.Clauses.splice(event.data.idx,1);

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

	var objectSelect = $('<select>').attr('id', 'object-' + index).addClass('selectpickerTitle').addClass('dirtyControl');

	var option = $('<option>').attr('value', '')
								.text(window.suppressionRulesSettings.Labels.selectAnObject);

	$(objectSelect).append(option);

	var basicGroup = $('<optGroup>').attr('label', window.suppressionRulesSettings.Labels.currentRecommendations);

	$(objectSelect).append(basicGroup);

	if (window.suppressionRulesSettings.Variables.advancedEnabled) {
		var advancedGroup = $('<optGroup>').attr('label', window.suppressionRulesSettings.Labels.previousRecommendations);

		$(objectSelect).append(advancedGroup);
	}

	if (window.suppressionRulesSettings.Variables.allRecsEnabled) {
		var allRecsGroup = $('<optGroup>').attr('label', window.suppressionRulesSettings.Labels.widerSearch);

		$(objectSelect).append(allRecsGroup);
	}

	$.each(window.suppressionRulesSettings.Objects, function(index, object) {
		var indentCount = 0;

		if (object.comparerString != null && object.comparerString != '') {
			indentCount = object.comparerString.split("~").length - 1;
		}

		//The indending does not display as tabs or spaces if I use the "text" property.
		//Because of it, I add hardcoded spaces and use the "data-content" property to render them as html
		var displayTitle = "&nbsp;".repeat(indentCount*4) + ' ' + object.title;

		if (object.isCurrent) {

			var option = $('<option>').attr('data-content','<span>' + displayTitle + '</span>')
								      .attr('value', 'c-' + object.value).attr('title', object.title).text(displayTitle);

			$(basicGroup).append(option);
		}

		if (window.suppressionRulesSettings.Variables.advancedEnabled && object.isPrevious) {
			var title = window.suppressionRulesSettings.Labels.previousRecommendations + ' > ' + object.title;

			var option = $('<option>').attr('data-content','<span>' + displayTitle + '</span>')
								      .attr('value', 'p-' + object.value).attr('title', title).text(displayTitle);

			$(advancedGroup).append(option);
		}

		if (window.suppressionRulesSettings.Variables.allRecsEnabled && object.isAllRecs) {
			var title = window.suppressionRulesSettings.Labels.widerSearch + ' > ' + object.title;

			var option = $('<option>').attr('data-content','<span>' + displayTitle + '</span>')
								      .attr('value', 'a-' + object.value).attr('title', title).text(displayTitle);

			$(allRecsGroup).append(option);
		}


	});

	$(objectSelect).on('change', {idx: index}, changeObject);

	$(numberDiv).append(objectSelect);

	var prefix = '';

	if (rowToRender.isPrevious) {
		prefix = 'p';
	} else if (rowToRender.isAllRecs) {
		prefix = 'a';
	} else {
		prefix = 'c';
	}

	var modifier = (rowToRender.objectModifier == '' || rowToRender.objectModifier == null) ? window.suppressionRulesSettings.Labels.regular : rowToRender.objectModifier;

	var objectName = prefix + '-' + rowToRender.objectName + '-' + modifier;

	if (rowToRender.objectName == '') {
		objectName = '';
	}

	$(objectSelect).val(objectName);

	$(row).append(numberDiv);

	$(mainRow).append(row);

	if (rowToRender.isAllRecs) {
		var row = $('<div>').addClass('row').attr('id', 'row2-' + index);

		var labelDiv = $('<div>').addClass('col-md-7').addClass('text-right').addClass('vert-align').text(window.suppressionRulesSettings.Labels.withTheSame);

		$(row).append(labelDiv);

		var fieldDiv = $('<div>').addClass('col-md-5');

		var objectMatcherSelect = $('<select>').attr('id', 'objectMatcher-' + index).addClass('selectpicker').addClass('dirtyControl');

		var matcherFields = getMatcherFieldsForObject(rowToRender.objectName + '-' +  modifier);

		var option = $('<option>').attr('value', '').text(window.suppressionRulesSettings.Labels.selectAField);
		$(objectMatcherSelect).append(option);

		$.each(matcherFields, function(index, field) {
			var option = $('<option>').attr('value', field.value).text(field.label);

			$(objectMatcherSelect).append(option);
		});

		$(fieldDiv).append(objectMatcherSelect);

		$(objectMatcherSelect).val(rowToRender.objectMatcher);

		$(row).append(fieldDiv);


		$(mainRow).append(row);
	}

	//BOTTOM ROW (FIELD, OPERATOR, VALUE)
	var row = $('<div>').addClass('row').attr('id', 'row3-' + index);

	var fieldColumn = $('<div>').addClass('col-md-5');
	if (rowToRender.isAllRecs) {
		$(fieldColumn).addClass('and-style').addClass('vert-align').text(window.suppressionRulesSettings.Labels.and);
	}

	var fieldSelect = $('<select>').attr('id', 'field-' + index).attr('data-live-search', 'true').addClass('selectpicker').addClass('dirtyControl');

	var option = $('<option>').attr('value', '').text(window.suppressionRulesSettings.Labels.selectAField);
	$(fieldSelect).append(option);

	var fields = getFieldsForObject(rowToRender.objectName + '-' +  modifier);

	if (rowToRender.isAllRecs) {
		var option = $('<option>').attr('value', 'EXISTS').text(window.suppressionRulesSettings.Labels.isFound);

		$(fieldSelect).append(option);
	}

	$.each(fields, function(index, field) {
		var option = $('<option>').attr('value', field.value).text(field.label);

		$(fieldSelect).append(option);
	});

	$(fieldSelect).on('change', {idx: index}, changeField);

	$(fieldColumn).append(fieldSelect);

	if (rowToRender.onlyCheckExistence) {
		$(fieldSelect).val('EXISTS');
	} else {
		$(fieldSelect).val(rowToRender.fieldName);
	}

	$(row).append(fieldColumn);

	var operatorColumn = $('<div>').addClass('col-md-3 operator-select');

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

	if (! rowToRender.onlyCheckExistence) {
		$(operatorColumn).append(operatorSelect);
	}

	//Set it for the first time
	if (rowToRender.operator == null || rowToRender.operator == '') {
		rowToRender.operator = 'equals';
	}

	$(operatorSelect).val(rowToRender.operator);

	$(operatorSelect).on('change', {idx: index}, changeOperator);

	$(row).append(operatorColumn);

	var valueColumn = $('<div>').addClass('col-md-4');

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
	} else if (selectedField != null && selectedField.type == 'REFERENCE') {
		var valueText = $('<input>').attr('id','value-' + index).attr('type','hidden').addClass('dirtyControl');

		$(valueText).val(rowToRender.value);

		$(defaultContainer).append(valueText);

		var valueInfo = $('<input>').attr('id','valueInfo-' + index).attr('type','hidden').addClass('dirtyControl');

		$(valueInfo).val(rowToRender.valueInfo);

		$(defaultContainer).append(valueInfo);

		var tokenDiv = $('<span>').attr('id','tokens-' + index);

		//get the value arrays
		var values = [];
		if (rowToRender.value != '') {
			var rawValues = rowToRender.value.split(',');
			var rawValueInfo = rowToRender.valueInfo.split(',');

			$.each(rawValues, function(index, rawVal) {
				var newObject = {
					id: rawVal,
					value: rawValueInfo[index],
					sfdcId: rawVal,
					label: rawValueInfo[index]
				}

				values.push(newObject);

			});
		}

 		//For Clarity, I will put each attribute separately
		var typeahead = $('<input>');
		$(typeahead).attr('id','typeahead-' + index);
		$(typeahead).attr('type','text');
		$(typeahead).attr('placeholder', 'Type to Search...');
		$(typeahead).attr('data-required','false');
		$(typeahead).attr('data-keyName','Id');
		$(typeahead).attr('data-fieldName', getDisplayFieldForObject(selectedField.referenceObjectName));
		$(typeahead).attr('data-objectName',selectedField.referenceObjectName);
		$(typeahead).attr('data-valueArray',JSON.stringify(values));
		$(typeahead).addClass('typeahead');
		$(typeahead).addClass('form-control');
		$(typeahead).addClass('dirtyControl');

		$(tokenDiv).append(typeahead);


		$(defaultContainer).append(tokenDiv);


		window.suppressionRulesSettings.ReferenceLines.push(index);
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

	if (! rowToRender.onlyCheckExistence) {
		$(row).append(valueColumn);
	}

	var errorDiv = $('<div>').addClass('col-md-9');

	if (rowToRender.isError) {
		$(errorDiv).attr('id','error-' + index).addClass('required-text').html(rowToRender.errorMessage);
	}

	$(row).append(errorDiv);

	var buttonDiv = $('<div>').addClass('col-md-3');

	var removeRowButton = $('<a>').addClass('remove-row').text(window.suppressionRulesSettings.Labels.remove);

	$(removeRowButton).on('click', {idx: index}, removeRow);

	$(buttonDiv).append(removeRowButton);

	$(row).append(buttonDiv);

	$(mainRow).append(row);

	return mainRow;
}

function changePicklist (event) {
	index = event.data.idx;

	var picklistValues = $('#dropdown-' + index).val();

	$('#value-' + index).val(picklistValues.join(','));

	updateState()
	renderClausesTable();
}

function changeOperator (event) {
	index = event.data.idx;

	updateState()
	renderClausesTable();
}

function changeField (event) {
	index = event.data.idx;

	if ($("#field-" + index).val() == 'EXISTS') {
		$('#operator-' + index).val('');
		$("#value-" + index).val('');
		$("#valueInfo-" + index).val('');
	} else {
		$('#operator-' + index).val('equals'); //.trigger('change');
	}

	updateState()
	renderClausesTable();
}

function changeObject (event) {
	index = event.data.idx;

	$('#field-' + index).val('');
	$("#value-" + index).val('');
	$("#valueInfo-" + index).val('');

	updateState()
	renderClausesTable();
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

	$.each(window.suppressionRulesSettings.Operators, function(index, operator) {

		if ($.inArray(standardType, operator.availableFor) != -1) {
			operators.push(operator);
		}

	});

	return operators;

}

function getDisplayFieldForObject(theObject) {
	var fieldName = '';

	if (theObject == null || theObject == '') {
		return '';
	}

	$.each(window.suppressionRulesSettings.ObjectDisplays, function(index, object) {

		if (object.objectName == theObject ) {
			fieldName = object.displayField;
		}

	});

	if (fieldName == '') {
		fieldName = 'Name';
	}

	return fieldName;

}


////***** typeahead functions
var boxData;
if (!boxData) boxData = {};

function initializeTypeAhead(index) {
	var objectName = $('#typeahead-' + index).attr('data-objectName');
	var fieldName = $('#typeahead-' + index).attr('data-fieldName');
	var keyField = $('#typeahead-' + index).attr('data-keyName');

	boxData['boxData-' + index] = {
        setSelectedValue :
            function( ctrl, id, value ,sfdcId) {
                //console.log( id + ' => ' + value );

                // put the id on the input tag
                $(ctrl).attr('data-id', sfdcId);

                // if destinations are defined, set them too
                $('#value-' + index).val( id );

            },

        boxQuery:
            function(inputstring,typeaheadCallback ) {
            	var remotefn ;
                //console.log('inputstring = ' + inputstring);

                if(inputstring === ''){
                    remotefn = window.suppressionRulesSettings.RemoteActions.defaultRecords;
                }else {
                    remotefn = window.suppressionRulesSettings.RemoteActions.searchRecords;
                }

                Visualforce.remoting.Manager.invokeAction(
                    remotefn,
                    fieldName,
                    '',
                    '',
                    objectName,
                    '',
                    inputstring,
                    'none',
                    function(result, event){
                        if (event.status) {
                            var dataList = [];
                            $.each(result, function(i, r) {
                                dataList.push({
                                    id: r[keyField],
                                    value: r[fieldName],
                                    sfdcId: r.Id
                                });
                            });
                            typeaheadCallback( dataList );
                        } else {
                            // TODO: deal with error
                            alert('Callout error: ' + event.message);
                            typeaheadCallback( [] );
                        }
                    },
                    {escape: false}
                );
            }
    };

	$('#typeahead-' + index).tokenfield({
		typeahead: [{
                minLength: 0,
                hint: true,
                autoselect: true,
                highlight: true
            },{
                source: boxData['boxData-' + index].boxQuery,
        }]
	});

	var values = JSON.parse($('#typeahead-' + index).attr('data-valueArray'));

	$('#typeahead-' + index).tokenfield('setTokens', values);

	$('#typeahead-' + index).on('tokenfield:createtoken', function (event) {
	    var existingTokens = $(this).tokenfield('getTokens');

		$.each(existingTokens, function(index, token) {
	        if (token.value === event.attrs.value)
	            event.preventDefault();
	    });
	});

	$('#typeahead-' + index).on('tokenfield:createdtoken', function (event) {
	    updateTokenValues(index);
	});

	$('#typeahead-' + index).on('tokenfield:editedtoken', function (event) {
	    updateTokenValues(index);
	});

	$('#typeahead-' + index).on('tokenfield:removedtoken', function (event) {
	    updateTokenValues(index);
	});

    $('#typeahead-' + index).data('bs.tokenfield').$input.on("click", function (event) {

        ev = $.Event("keydown");
        ev.keyCode = ev.which = 40;

        $(this).trigger(ev);

        return true;

    });

	function updateTokenValues(index) {
		var existingTokens = $('#typeahead-' + index).tokenfield('getTokens');

		var arrIDs = [];
		var arrValues = [];

	    $.each(existingTokens, function(index, token) {
	    	arrIDs.push(token.id);
	    	arrValues.push(token.value);
	    });

	    $('#value-' + index).val(arrIDs.join(','));
	    $('#valueInfo-' + index).val(arrValues.join(','));

	}

	/*
    var typeaheadcall = $('#typeahead-' + index).typeahead({
        minLength: 0,
        hint: true,
        autoselect: true,
        highlight: true
    },
    {
        source: boxData['boxData-' + index].boxQuery,    // calls our remoting function
        name:  'boxData-' + index +'-Typeahead'
    }).on('typeahead:selected', function (object, datum) {
        boxData['boxData-' + index].setSelectedValue( this, datum.id, datum.value , datum.sfdcId);
        $('#typeahead-' + index).prev('input').focus();//Focus previous to fix the bug in SF1
    }).on('typeahead:autocompleted', function (object, datum) {
        boxData['boxData-' + index].setSelectedValue( this, datum.id, datum.value , datum.sfdcId);
    }).on('typeahead:cursorchanged', function (object, datum) {
        boxData['boxData-' + index].setSelectedValue( this, datum.id, datum.value , datum.sfdcId);
    }).keyup( function(ev) {
        // if they press backspace or escape, we want to clear the selection
        if ( ev.which == 8 || ev.which == 27 ) {
            boxData['boxData-' + index].setSelectedValue( this, null, null , null);
        }
    });

    $('#typeahead-' + index).on("click", function () {
        ev = $.Event("keydown")
        ev.keyCode = ev.which = 40
        $(this).trigger(ev)
        return true
    });
*/
}

function closeModals(){
    $('#confirmDelete').modal('hide');

    $('.deleteToDisable').removeAttr('disabled');
	$('.btn-primary.deleteToDisable').attr('value', $('.btn-primary.deleteToDisable').attr('data-oldvalue'));
    $('.btn-primary.deleteToDisable').removeAttr('data-oldvalue');
}
