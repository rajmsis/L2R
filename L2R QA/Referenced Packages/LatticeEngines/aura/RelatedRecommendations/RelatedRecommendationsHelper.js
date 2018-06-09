({
	getRelatedRecommendations : function (component) {
    	var action = component.get('c.getRelatedRecommendations');
		var relatedType = component.get("v.relatedType");
		var recordId = component.get("v.recordId");

        return new Promise(function (resolve, reject) {
            action.setParams({
                recommendationId: recordId,
                relatedType: relatedType
            });

            action.setCallback(this, function (response) {
               var state = response.getState();

				if (component.isValid() && state === "SUCCESS") {
					resolve(response.getReturnValue());
				}
				else if (component.isValid() && state === "ERROR") {
					var errors = response.getError();
					reject(response.getError()[0]);
				}
            });

            $A.enqueueAction(action);
        });
    },
	toggleSpinner: function(component) {
		var spinner = component.find("loadingSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
	}
})