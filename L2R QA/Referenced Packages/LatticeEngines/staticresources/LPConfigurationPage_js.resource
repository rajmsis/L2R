'use strict';

function initLPConfigScreen() {
    updateApplicationState();
}

//Do it this way instead of via a poller because
//the poller will interfere with component's viewstate
function updateApplicationState() {
    console.log('updating app config state');
    try {
        setTimeout(function() {
            checkStatus();
            updateApplicationState();
        }, 10000);
    } catch(e) {
        console.log('Error while refreshing app state:' + e);
    }   
}

/*
//    $('#notificationCount').hide();
//    $('#notificationCount').text('0');
//    $('.mainLink').addClass('disabled');

//Do it this way instead of via a poller because
//the poller will interfere with component's viewstate
function checkNotifications() {
	//vfRemotingErrorHandler();
    Visualforce.remoting.Manager.invokeAction(
        checkInstallStatusCall,
        function(result, event) {
            if (event.status) {

               if (result.notificationCount != '0') {
                    $('#notificationCount').show();
                    $('#notificationCount').text(result.notificationCount);
               }

               if (result.isPrimaryUpgraded) {
                    $('.mainLink').removeClass('disabled');
               } else {
                    $('.mainLink').addClass('disabled');
               }
            } else {
                handleReturnError(event);
            }

            //Call itself in 10 seconds
            setTimeout(function() {
                checkNotifications();
            }, 10000);
        },
        {buffer: true, escape: false}
    );
}

function handleReturnError(event) {
    if (event.type === 'exception') {
        alert('Error: ' + event.message + ' ' + event.where);
    }  else {
        alert('Error: ' + event.message + ' ' + event.where);
    }
}
*/

