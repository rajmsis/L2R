function esc(myid) {
	return '#' + myid.replace(/(:|\.)/g,'\\\\$1');
}

var boxData;
if (!boxData) boxData = {};

function initializeTypeAhead() {
	var objectName = $('#userTypeahead').attr('data-objectName');
	var fieldName = $('#userTypeahead').attr('data-fieldName');
	var keyField = $('#userTypeahead').attr('data-keyName');

	boxData['userBoxData'] = {
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
                    remotefn = window.notificationSettings.RemoteActions.defaultRecords;
                }else {
                    remotefn = window.notificationSettings.RemoteActions.searchRecords;
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
                    $('[id$="hidSelectedUsers"]').val(),
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

	$('#userTypeahead').tokenfield({
		typeahead: [{
                minLength: 0,
                hint: true,
                autoselect: true,
                highlight: true
            },{
                source: boxData['userBoxData'].boxQuery,
        }]
	});

	var values = JSON.parse($('#userTypeahead').attr('data-valueArray'));

	$('#userTypeahead').tokenfield('setTokens', values);

	$('#userTypeahead').on('tokenfield:createtoken', function (event) {
	    var existingTokens = $(this).tokenfield('getTokens');

        if (event.attrs.id == null) {
            event.preventDefault();
        }

		$.each(existingTokens, function(index, token) {
	        if (token.value === event.attrs.value)
	            event.preventDefault();
	    });
	});

	$('#userTypeahead').on('tokenfield:createdtoken', function (event) {
	    updateTokenValues();
	    addUser(event.attrs.id);
	});

	$('#userTypeahead').on('tokenfield:editedtoken', function (event) {
	    updateTokenValues();
	});

	$('#userTypeahead').on('tokenfield:removedtoken', function (event) {
	    updateTokenValues();
	    deleteUser(event.attrs.id);
	});

    $('#userTypeahead').data('bs.tokenfield').$input.on("click", function (event) {

        ev = $.Event("keydown");
        ev.keyCode = ev.which = 40;

        $(this).trigger(ev);

        return true;

    });

	function updateTokenValues() {
		var existingTokens = $('#userTypeahead').tokenfield('getTokens');

		var arrIDs = [];
		var arrValues = [];

	    $.each(existingTokens, function(index, token) {
	    	arrIDs.push(token.id);
	    	arrValues.push(token.value);
	    });

	    $('[id$="hidSelectedUsers"]').val(arrIDs.join(','));
	}
}


function handleReturnError(event) {
	if (event.type === 'exception') {
		alert('Error: ' + event.message + ' ' + event.where);
    }  else {
		alert('Error: ' + event.message + ' ' + event.where);
	}
}

function addUser(userId) {
	Visualforce.remoting.Manager.invokeAction(
    	window.notificationSettings.RemoteActions.addUser,
    	userId,
    	function(result, event) {
     		if (event.status) {
     			//Nothing to do
			} else {
				handleReturnError(event);
			}

		},
        {buffer: true, escape: true}
	);

}
function deleteUser(userId) {

	Visualforce.remoting.Manager.invokeAction(
    	window.notificationSettings.RemoteActions.deleteUser,
    	userId,
    	function(result, event) {
     		if (event.status) {
     			//Nothing to do
			} else {
				handleReturnError(event);
			}

		},
        {buffer: true, escape: true}
	);

}