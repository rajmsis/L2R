({
    afterRender : function( component, helper ) {

        this.superAfterRender();

        var iFrameType = component.get("v.iFrameType");

        console.log('Type: ' + iFrameType);

        if (iFrameType == 'Lattice Insights') {
            console.log('Attaching Listener');

    		// Listen for message
    		window.addEventListener("message", function(msgEvent) {

                console.log('parent received message!:  ',msgEvent.data);

    		    // Get Insights App message
    		    var latticeInsightsAppIsReady = msgEvent.data;

    		    // If Insights App is available, run this code
    		    if ( latticeInsightsAppIsReady == 'init' ) {

                    var postMessageData = component.get('v.jsonData');
                    //debugger;
                    console.log('Posting this to the iframe:  ', postMessageData);

    		        // Turn data string into JSON object and send via postMessage
    		        // This will work similar to how we're doing it for Dante
    		        var iFrame = component.find("iFrameContainer").getElement().contentWindow;
    		        iFrame.postMessage(postMessageData, "*");

    		    }
    		    return true;

    		}, false);
        }
    }
})