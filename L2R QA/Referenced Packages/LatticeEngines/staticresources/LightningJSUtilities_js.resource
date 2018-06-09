(function(w){
    "use strict"; //Optional because LC on LockerService active runs in strict mode

    var utilMethods = {
        "handleError": handleError,
        "showToastMessage": showToastMessage,
        "getParams": getParams
    };


    function handleError(error){
        if (error) {
            if (error && error.message) {
                console.log("Error message: " + error.message);
                console.log(error);

                var toastEvent = $A.get("e.force:showToast");
                //console.log(toastEvent);

                if (toastEvent) {
                    toastEvent.setParams({
                        "title": "An Error has Occurred",
                        "message": error.message,
                        "type": "error",
                        "mode": "sticky"
                    });
                    toastEvent.fire();
                } else {
                    alert(error.message);
                }
            }
        } else {
            console.log("Unknown error");
        }
    }

    //Only one link is supported. format is "text ~~label__url~~ text".
    //The text before and after the link is optional
    //The link MUST begin and end with a ~~
    function showToastMessage(type, title, message) {
        //Replace a link with '{0}'
        var finalMessage = '';
        var linkName = '';
        var linkUrl = '';

        if (message.includes("~~")) {
            var tokens = message.split("~~");

            //Because the link must begin and end with a ~~, then the middle part is the link
            var link = tokens[1];

            tokens[1] = "{0}";

            var linkParts = link.split("__");
            linkName = linkParts[0];
            linkUrl = linkParts[1];

            finalMessage = tokens.join(" ");
        } else {
            finalMessage = message;
        }



        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            mode: "pester",
            type: type,
            message: "has to be defined due to toast event validation, but isn't used.",
            messageTemplate: finalMessage,
            messageTemplateData: [{
                label: linkName,
                url: linkUrl
            }]
        });
        toastEvent.fire();
    }

    function getParams(component) {
        var action = component.get('c.getPageParameters');

        return new Promise(function (resolve, reject) {

            action.setCallback(this, function (response) {
               var state = response.getState();

                if (component.isValid() && state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (component.isValid() && state === "ERROR") {
                    reject(response.getError()[0]);
                }
            });

            $A.enqueueAction(action);
        });
    }


    w.lightningUtilities = utilMethods;


})(window);