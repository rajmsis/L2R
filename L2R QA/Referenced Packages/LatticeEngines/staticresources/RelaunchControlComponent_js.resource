var CommonModule = (function ($) {
	"use strict";

	var esc = function (myid) {
		return '#' + myid.replace(/(:|\.)/g,'\\\\$1');
	}

	var escapeHtml = function (unsafe) {
	    return $('<div />').text(unsafe).html()
	}

	var unescapeHtml = function (safe) {
	    return $('<div />').html(safe).text();
	}

	return {
		esc: esc,
		escapeHtml: esc,
		unescapeHtml: esc
	}

})(jQuery);

var RelaunchControlModule = (function ($) {
	"use strict";

	var isDirty = false;

	var initUI = function() {
		TypeaheadModule.initializeTypeAhead();
		$('[data-toggle="popover"]').popover();

		var isAllPlays = ($("[id$='expireAllHidden']").val() == 'true');
		toggleExpireAllHidden(isAllPlays);
		setDirtyCheck();
	};

	var toggleExpireAllHidden = function (newValue) {
		$('#expireAllYes').removeClass('active');
		$('#expireAllNo').removeClass('active');

		if (newValue) {
			$('#expireAllYes').addClass('active');
			$('#selectedPlays').hide();
		} else {
			$('#expireAllNo').addClass('active');
			$('#selectedPlays').show();
		}

		$("[id$='expireAllHidden']").val(newValue);
	}

	function setDirtyCheck() {
		$('.dirtyControl').on('change', null, turnDirtyOn);
	}

	var closeModals = function() {
	    $('#confirmCancel').modal('hide');
	    $('#confirmSave').modal('hide');

	    $('.deleteToDisable').removeAttr('disabled');
		$('.btn-primary.deleteToDisable').attr('value', $('.btn-primary.deleteToDisable').attr('data-oldvalue'));
	    $('.btn-primary.deleteToDisable').removeAttr('data-oldvalue');
	}

	var confirmExit = function() {
		if (isDirty) {
			return window.accountExtensionMappingSettings.Labels.leaveScreen;
		}

	}

	var turnDirtyOn = function() {
		isDirty = true;
	}

	var turnDirtyOff = function() {
		isDirty = false;
	}


	return {
		initUI: initUI,
		closeModals: closeModals,
		confirmExit: confirmExit,
		turnDirtyOn: turnDirtyOn,
		turnDirtyOff: turnDirtyOff,
		toggleExpireAllHidden: toggleExpireAllHidden
	}

})(jQuery);

//This module needs further help before it's ready to be reused. I only laid the foundation
//SK 4/19/16
var TypeaheadModule = (function ($) {

	var boxData;
	if (!boxData) boxData = {};

	function initializeTypeAhead() {
		var objectName = $('#typeahead').attr('data-objectName');
		var fieldName = $('#typeahead').attr('data-fieldName');
		var keyField = $('#typeahead').attr('data-keyName');

		boxData['boxData'] = {
	        setSelectedValue :
	            function( ctrl, id, value ,sfdcId) {
	                //console.log( id + ' => ' + value );

	                // put the id on the input tag
	                $(ctrl).attr('data-id', sfdcId);

	                // if destinations are defined, set them too
	                $(window.relaunchSettings.FieldNames.valueField).val( id );

	            },

	        boxQuery:
	            function(inputstring,typeaheadCallback ) {
	            	var remotefn ;
	                //console.log('inputstring = ' + inputstring);

	                if(inputstring === ''){
	                    remotefn = window.relaunchSettings.RemoteActions.defaultRecords;
	                }else {
	                    remotefn = window.relaunchSettings.RemoteActions.searchRecords;
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
	                    $(window.relaunchSettings.FieldNames.valueField).val(),
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

		$('#typeahead').tokenfield({
			typeahead: [{
	                minLength: 0,
	                hint: true,
	                autoselect: true,
	                highlight: true
	            },{
	                source: boxData['boxData'].boxQuery,
	        }]
		});

		var values = JSON.parse($('#typeahead').attr('data-valueArray'));

		$('#typeahead').tokenfield('setTokens', values);

		$('#typeahead').on('tokenfield:createtoken', function (event) {
		    var existingTokens = $(this).tokenfield('getTokens');

			$.each(existingTokens, function(index, token) {
		        if (token.id === event.attrs.id) {
		            event.preventDefault();
		        }
		    });
		});

		$('#typeahead').on('tokenfield:createdtoken', function (event) {
		    updateTokenValues();
		});

		$('#typeahead').on('tokenfield:editedtoken', function (event) {
		    updateTokenValues();
		});

		$('#typeahead').on('tokenfield:removedtoken', function (event) {
		    updateTokenValues();
		});

	    $('#typeahead').data('bs.tokenfield').$input.on("click", function (event) {

	        ev = $.Event("keydown");
	        ev.keyCode = ev.which = 40;

	        $(this).trigger(ev);

	        return true;

	    });

		function updateTokenValues() {
			var existingTokens = $('#typeahead').tokenfield('getTokens');

			var arrIDs = [];
			var arrValues = [];

		    $.each(existingTokens, function(index, token) {
		    	arrIDs.push(token.id);
		    	arrValues.push(token.value);
		    });

		    $(window.relaunchSettings.FieldNames.valueField).val(arrIDs.join(','));
		    $(window.relaunchSettings.FieldNames.valueInfoField).val(arrValues.join(','));

		}

	}

	return {
		initializeTypeAhead: initializeTypeAhead
	}

})(jQuery);