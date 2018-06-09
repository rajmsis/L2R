   function typeaheadFn(j$,searchId,destinationForSelectedId,accountId,remoteFunction){
        var contactData;
        if (!contactData) contactData = {};
        contactData[searchId] = { 
            setSelectedValue : 
                function( ctrl, id, value ) {
                    //console.log( id + ' => ' + value );
                    // put the id on the input tag
                    j$(ctrl).attr('data-id', id);

                    // if destinations are defined, set them too
                    j$("[id$="+destinationForSelectedId+"]").val( id );
                    //j$('[id$=oppName]').val( value );
                },

            contactQuery: 
                function(inputstring, typeaheadCallback ) {
                    var accId = document.getElementById(accountId).value;
                    Visualforce.remoting.Manager.invokeAction(
                        remoteFunction, 
                        accId,
                        inputstring,
                        function(result, event){
                            if (event.status) {
                                var dataList = [];
                                j$.each(result, function(i, r) {
                                    dataList.push({
                                        id: r.Id,
                                        value: r.Name
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

            return contactData;
        }


