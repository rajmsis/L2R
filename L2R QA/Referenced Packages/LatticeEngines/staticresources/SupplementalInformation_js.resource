var SupplementalInfoModule = (function ($) {
	"use strict";

	var playData = [];
	var suppInfoData = [];
	var getData = function(callback, errorCallback) {
		Visualforce.remoting.Manager.invokeAction(
			window.configSettings.RemoteActions.getPlaysWithSupplementalInfo,
			function(result, event) {
				if( event.status ) {
					callback(result);
				} else {
					//console.log(event);
					if( errorCallback ) {
						errorCallback();
					}
				}
			},
			{buffer: true, escape: true});
	};


	var initSupplementalInfoSelect = function(infos) {
		var suppInfoSelect = $('#suppInfoSelect');
		suppInfoSelect.next().find('li').remove().end();
		suppInfoSelect.find('option').remove().end();
		var tabNames = infos.map(function (i) {
			return i.tabName; //extract tabname from information object
		}).filter(function (tab, index, array) {
			return index == array.indexOf(tab); // reduce to have unique only
		});

		var suppInfoGroupedByTabNames = {};
		tabNames.forEach(function (tab) {
			suppInfoGroupedByTabNames[tab] = [];
		});

		//group by Tabname
		infos.forEach(function (info) {
			suppInfoGroupedByTabNames[info.tabName].push(info.supplementalId);
		});

		var options = [];
		for (var i = 0; i < tabNames.length; i++) {
			// retrieve the SI ids array and joining it so it can be stored in DOM
			var suppInfoIds = suppInfoGroupedByTabNames[tabNames[i]].join(',');
			var option = $('<option>')
				.attr({'value': JSON.stringify(suppInfoIds)})
				.text(tabNames[i]);
			//console.log(option);
			options.push(option);
		}
		$(suppInfoSelect).append(options);
		$(suppInfoSelect).selectpicker('refresh');
		$(suppInfoSelect).selectpicker('deselectAll');
	};

	var initPlaysSelect = function(plays) {
		var playSelect = $('#playSelect');
		if(plays && plays.length) {
			// clear the selectpicker
			playSelect.next().find('li').remove().end();
			playSelect.find('option').remove().end();

			for (var i = 0; i < plays.length; i++) {
				var option = $('<option>').text(plays[i].displayName)
					.attr({'value': plays[i].playId});
				$(playSelect).append(option);
			}
			playSelect.attr('disabled', false);
			$(playSelect).selectpicker('refresh');
		} else {
			playSelect.attr('disabled', true);
		}

	};

	var refreshSelectList = function() {
		getData(function(data) {
			playData = data.plays;
			suppInfoData = data.supplementalInfo;
			initSupplementalInfoSelect(data.supplementalInfo);
		});
	};

	var initUI = function() {
		refreshSelectList();
		$('#deleteSuppInfoBtn').click(function() {
			$('#selectsPanel').hide();
			$('#deletionConfirmationPanel').show();
		});
		$('#confirmDelete').click(function () {
			deleteSupInfoInternal();
			$('#deletionConfirmationPanel').hide();
			$('#selectsPanel').show();
		});
		$('#cancelGoBackButton').click(function() {
			$('#deletionConfirmationPanel').hide();
			$('#selectsPanel').show();
		});
		$('#suppInfoSelect').on('change', function(){
			var selected = $(this).find("option:selected").val();
			var suppInfoIds = JSON.parse(selected).split(',');
			var playIds = suppInfoData.filter(function (i) {
				return suppInfoIds.indexOf(i.supplementalId) != -1; // check the we're targeting right suppinfos
			}).map(function (i) {
				return i.playId;
			});
			var plays = playData.filter(function (p) {
				return playIds.indexOf(p.playId) != -1; // find play objects in array
			});
			initPlaysSelect(plays);
		});
	};

	var deleteSupInfoInternal = function() {
		var dialog = $('#clearDataDialog');
		var selectedPlays = $(dialog).find('#playSelect').find(':selected');

		var playsIds = [];
        $(selectedPlays).each(function(index, elem) {
            playsIds.push($(elem).val());
        });
		var selectedInfoIdsRaw =  $('#suppInfoSelect').find(':selected').val().split(',');
		var selectedInfoIds = selectedInfoIdsRaw.map(function(e) {
            return e.replace(/['"]+/g, '');
        });
		var suppInfoToDelete = suppInfoData.filter(function(i) {
			return selectedInfoIds.indexOf(i.supplementalId) != -1;
		}).map(function(i) {
            return i.supplementalId;
        });
        //console.log('Play ids to be deleted ' + playsIds);
        //console.log('Supplemental Info to be deleted ' +suppInfoToDelete);
		clearSupplementInfo({ plays: playsIds, supplementalInfo: suppInfoToDelete });
		$('#playSelect').selectpicker('refresh');
		$('#suppInfoSelect').selectpicker('refresh');
		deleteConfirm(); //apex:actionFunction see SupplementalInfoComponent
	};

	var clearSupplementInfo = function(plays) {
		Visualforce.remoting.Manager.invokeAction(
			window.configSettings.RemoteActions.deleteSupplementalInfoAndConnectedData,
			plays,
			function(result, event) {
				if( event.status ) {
					//console.log(event);
					refreshSelectList();
				} else {
					console.log(event);
				}
			},
			{buffer: true, escape: true});
	};



	return {
		initUI: initUI,
		clearSupplementInfoByPlay: clearSupplementInfo,
		getData: getData,
		refreshSelectList: refreshSelectList
	}

})(jQuery);

function loadExistingValues() {

	Visualforce.remoting.Manager.invokeAction(
    	window.configSettings.RemoteActions.getRelationshipObjects,
     	returnLoadValues,
        {buffer: true, escape: true}
	);
}

function handleReturnError(event) {
	if (event.type === 'exception') {
		alert('Error', + event.message + ' ' + event.where);
    }  else {
     	alert('Error', + event.message + ' ' + event.where);
	}
}

function getFieldsetsForObject(objectName) {
	var foundFieldsets = [];

	$.each(objectsAvailable, function(index, object) {
		if (object.objectName == objectName) {
			foundFieldsets = object.fieldsets;
		}
	});

	return foundFieldsets;
}

function returnLoadValues(result, event){
	if (event.status) {
		objectsAvailable = result;

		renderTable();
	} else {
		handleReturnError(event);
	}
}

function updateState() {
	var indexOfDeleted = null;

	$.each(suppInfoRecords, function(index, object) {
		if (object.markedForDeletion === true) {
			indexOfDeleted = index;
			return;
		}
		//This way I do not overwrite the newly created (and not yet rendered) row
		if ($("#object-" + index).length > 0) {
			object.objectName = $('#object-' + index).val();
			object.fieldsetName = $('#fieldset-' + index).val();
			object.tabName = $('#tabName-' + index).val();
			object.playIds = $("#value-" + index).val();
			object.playNames = $("#valueInfo-" + index).val();

			var tabOrder = $("#tab-order-" + index).val();
			tabOrder = parseInt(tabOrder);
			object.tabOrder = isNaN(tabOrder) ? undefined : tabOrder;

			if (console) {
				//console.log('pulling values from page');
				//console.log($("#showAtAccountLevel-" + index).prop("checked"));
			}

			//if ($("#showAtAccountLevel-" + index).prop("checked")) {
			if ($("#showAtAccountLevelYes-" + index).hasClass("active")) {
				object.showAtAccountLevel = 'true';
			} else {
				object.showAtAccountLevel = 'false';
			}

		}
	});

	if (typeof indexOfDeleted === 'number') {
		suppInfoRecords.splice(indexOfDeleted, 1);
	}

	var clauses = JSON.stringify(suppInfoRecords);
	$("[id$='fieldMappings']").val(clauses);
}

function renderTable() {
	suppInfoRecords = JSON.parse($("[id$='fieldMappings']").val());

	$('#rowsToRender').empty();

	$.each(suppInfoRecords, function(index, object) {
		var row = createRow(index, object);

		$('#rowsToRender').append(row);

		var row2 = createTypeAhead(index, object);

		$('#rowsToRender').append(row2);

        $('#rowsToRender').append('<hr />');

	});

	attachDropdowns();
}

function addNewRow() {
	var newRow = {
    		objectName: '',
    		fieldsetName: '',
    		tabName: '',
    		playIds: '',
    		playNames: '',
    		isError: false,
    		errorMessage: '',
    		showAtAccountLevel: 'false'
    	};

	suppInfoRecords.push(newRow);

	updateState();

	renderTable();

}

function removeRow(event) {
	suppInfoRecords[event.data.idx].markedForDeletion = true;

	updateState();

	renderTable();

}

function createRow(index, rowToRender) {
	var row = $('<div>').addClass('row').attr('id', 'row-' + index);

	var hiddenTabOrder = $('<input type="hidden"/>')
							.attr('id', 'tab-order-'+index)
							.val(rowToRender.tabOrder);
	$(row).append(hiddenTabOrder);

	var leftTitle = $('<div>').addClass('col-md-4');

	var leftSpan = $('<span>').addClass('help-text').text(window.configSettings.Label.objectTitle);

	var leftAnchor = $('<a>').addClass('helper')
							 .attr('data-content', window.configSettings.Label.objectHelper)
							 .attr('data-toggle', 'popover')
							 .attr('tabindex', index)
							 .attr('data-trigger', 'focus')
							 .attr('role', 'button')
							 .text('?')

	$(leftSpan).append(leftAnchor);

	$(leftTitle).append(leftSpan);

	$(row).append(leftTitle);

	var middleTitle = $('<div>').addClass('col-md-4');

	var middleSpan = $('<span>').addClass('help-text').text(window.configSettings.Label.fieldsetTitle);

	var middleAnchor = $('<a>').addClass('helper')
							 .attr('data-content', window.configSettings.Label.fieldsetHelper)
							 .attr('data-toggle', 'popover')
							 .attr('tabindex', index)
							 .attr('data-trigger', 'focus')
							 .attr('role', 'button')
							 .text('?')

	$(middleSpan).append(middleAnchor);

	$(middleTitle).append(middleSpan);

	$(row).append(middleTitle);

	var rightTitle = $('<div>').addClass('col-md-4');

	var rightSpan = $('<span>').addClass('help-text').text(window.configSettings.Label.tabNameTitle);

	var rightAnchor = $('<a>').addClass('helper')
							 .attr('data-content', window.configSettings.Label.tabNameHelper)
							 .attr('data-toggle', 'popover')
							 .attr('tabindex', index)
							 .attr('data-trigger', 'focus')
							 .attr('role', 'button')
							 .text('?')

	$(rightSpan).append(rightAnchor);

	$(rightTitle).append(rightSpan);
	$(row).append(rightTitle);

	var left = $('<div>').addClass('col-md-4');

	var objectSelect = $('<select>').attr('id', 'object-' + index).addClass('selectpicker');

	var option = $('<option>').attr('value', '').text(window.configSettings.Label.selectAnObject);
	$(objectSelect).append(option);

	$.each(objectsAvailable, function(index, object) {
		var option = $('<option>').attr('value', object.objectName).text(object.objectLabel);

		$(objectSelect).append(option);
	});
	$(objectSelect).on('change', {type: 'object', idx: index}, changeValue);

	$(left).append(objectSelect);

	$(objectSelect).val(rowToRender.objectName);

	$(row).append(left);

	var middle = $('<div>').addClass('col-md-4');

	var fsSelect = $('<select>').attr('id', 'fieldset-' + index).addClass('selectpicker');

	var fieldsets = getFieldsetsForObject(rowToRender.objectName);

	var option = $('<option>').attr('value', '').text(window.configSettings.Label.selectAFieldset);
	$(fsSelect).append(option);

	$.each(fieldsets, function(index, object) {
		var option = $('<option>').attr('value', object.objectName).text(object.objectLabel);

		$(fsSelect).append(option);
	});
	$(fsSelect).on('change', {type: 'fieldset', idx: index}, changeValue);

	$(middle).append(fsSelect);

	$(fsSelect).val(rowToRender.fieldsetName);

	$(row).append(middle);

	var right = $('<div>').addClass('col-md-4').addClass('form-group');

	var tabNameText = $('<input>').attr('id','tabName-' + index).attr('type','text').addClass('form-control').addClass('required-border');

	$(right).append(tabNameText);
	$(tabNameText).val(rowToRender.tabName);

	$(row).append(right);

	var titleRow = $('<div>').addClass('col-md-12');

	var text = $('<p>').text(window.configSettings.Label.selectPlays);

	// COD-1124
	var farRightTitle = $('<div>').addClass('col-md-4');

	var farRightSpan = $('<span>').addClass('help-text').text(window.configSettings.Label.acctLevelTitle);

	var farRightAnchor = $('<a>').addClass('helper')
							 .attr('data-content', window.configSettings.Label.acctLevelHelper)
							 .attr('data-toggle', 'popover')
							 .attr('tabindex', index)
							 .attr('data-trigger', 'focus')
							 .attr('role', 'button')
							 .text('?')

	$(farRightSpan).append(farRightAnchor);
	$(farRightTitle).append(farRightSpan);

	$(row).append(farRightTitle);

	var farRight = $('<div>').addClass('col-md-4').addClass('form-group styled-radios');

/*
	var acctLevelBool = $('<input>').attr('id','showAtAccountLevel-' + index).attr('type','checkbox').addClass('form-control');

	$(farRight).append(acctLevelBool);

	if (rowToRender.showAtAccountLevel == 'true') {
		$(acctLevelBool).prop('checked', 'checked');
	} else {
		$(acctLevelBool).removeProp('checked');
	}
*/
	var yesAnchor = $('<a>').attr('id','showAtAccountLevelYes-' + index)
							.attr('href', '#')
							.addClass('active-rule')
							.addClass('yes')

	if (rowToRender.showAtAccountLevel == 'true') {
		$(yesAnchor).addClass('active')
	}

	$(yesAnchor).on('click', {idx: index, newValue: true}, toggleActiveHidden);

	$(farRight).append(yesAnchor);

	var noAnchor = $('<a>').attr('id','showAtAccountLevelNo-' + index)
							.attr('href', '#')
							.addClass('active-rule')
							.addClass('no')

	if (rowToRender.showAtAccountLevel != 'true') {
		$(noAnchor).addClass('active')
	}

	$(noAnchor).on('click', {idx: index, newValue: false}, toggleActiveHidden);

	$(farRight).append(noAnchor);

	/*
	<inputHidden id="activeHidden" value="{!selectedRule.isActive__c}" />

    <a class="active-rule yes {!IF(selectedRule.isActive__c,'active','')}" href="#" onclick="toggleActiveHidden(true)" id="activeYes" />

    <a class="active-rule no {!IF(!selectedRule.isActive__c,'active','')}" href="#" onclick="toggleActiveHidden(false)" id="activeNo" />
    */

	$(row).append(farRight);

	$(titleRow).append(text);

	$(row).append(titleRow);

	return row;

}

function toggleActiveHidden(event) {
	event.preventDefault();

	index = event.data.idx;
	newValue = event.data.newValue;

	$('#showAtAccountLevelYes-' + index).removeClass('active');
	$('#showAtAccountLevelNo-' + index).removeClass('active');

	if (newValue) {
		$('#showAtAccountLevelYes-' + index).addClass('active');
	} else {
		$('#showAtAccountLevelNo-' + index).addClass('active');
	}
}

function createTypeAhead(index, rowToRender) {
	var row = $('<div>').addClass('row').attr('id', 'typeaheadRow-' + index);

	var typeaheadRow = $('<div>').addClass('col-md-12');

	var valueText = $('<input>').attr('id','value-' + index).attr('type','hidden').addClass('dirtyControl');

	$(valueText).val(rowToRender.playIds);

	$(typeaheadRow).append(valueText);

	var valueInfo = $('<input>').attr('id','valueInfo-' + index).attr('type','hidden').addClass('dirtyControl');

	$(valueInfo).val(rowToRender.playNames);

	$(typeaheadRow).append(valueInfo);

	var tokenDiv = $('<span>').attr('id','tokens-' + index);

	//get the value arrays
	var values = [];

	if (rowToRender.playIds != null && rowToRender.playIds != '') {
		var rawValues = rowToRender.playIds.split(',');
		var rawValueInfo = rowToRender.playNames.split(',');

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
	$(typeahead).attr('data-fieldName', window.configSettings.Label.displayName);
	$(typeahead).attr('data-objectName', window.configSettings.Label.playObjectName);
	$(typeahead).attr('data-valueArray',JSON.stringify(values));
	$(typeahead).addClass('typeahead');
	$(typeahead).addClass('form-control');
	$(typeahead).addClass('dirtyControl');

	$(tokenDiv).append(typeahead);


	$(typeaheadRow).append(tokenDiv);

	$(row).append(typeaheadRow);

	var spaceRow1 = $('<div>').addClass('col-md-8');

	if (rowToRender.isError) {
		var reqDiv = $('<div>').attr('id','error-' + index).addClass('required-text').html(rowToRender.errorMessage);

		$(spaceRow1).append(reqDiv);
	}

	$(row).append(spaceRow1);

	var spaceRow2 = $('<div>').addClass('col-md-4');

	var removeAnchor = $('<a>').addClass('remove-row').text(window.configSettings.Label.removeRow);
	$(spaceRow2).append(removeAnchor);

	$(removeAnchor).on('click', {idx: index}, removeRow);

	$(row).append(spaceRow2);

	return row;
}

function attachDropdowns() {

	$('.selectpicker').selectpicker('refresh');
	$('[data-toggle="popover"]').popover();

	$.each(suppInfoRecords, function(index, object) {
		initializeTypeAhead(index);
	});
}

function changeValue (event) {

	index = event.data.idx;
	type = event.data.type;

	if (type == 'object') {
		//suppInfoRecords[index].objectName = $('#object-' + index).val();
		$('#fieldset-' + index).val('');
	} else if (type == 'fieldset') {
		//suppInfoRecords[index].fieldsetName = $('#fieldset-' + index).val();

		var tabName = $('#object-' + index + ' option:selected').text() + ' / ' + $('#fieldset-' + index + ' option:selected').text();
		$('#tabName-' + index).val(tabName);

		//suppInfoRecords[index].tabName = tabName;
	}

	updateState();

	renderTable();
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
                    remotefn = window.configSettings.RemoteActions.defaultRecords;
                }else {
                    remotefn = window.configSettings.RemoteActions.searchRecords;
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
                    $('#value-' + index).val(),
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
	        if (token.id === event.attrs.id) {
	            event.preventDefault();
	        }
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

}