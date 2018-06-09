({
	changePlay : function(cmp, ev, playId) {
		cmp.set("v.recommendations", []);

        if (playId == '') {
        	playId = 'ALL';
        }

		this.getRecommendationsForPlay(cmp, ev, playId);
	},
	getRecommendationsForPlay : function(component, ev, playName) {
		var action = component.get("c.getRecommendationsForComponent");
		action.setParams({playType:playName});

		this.toggleSpinner(component);

		action.setCallback(this, function(response) {
			var state = response.getState();
			this.toggleSpinner(component);

			if (component.isValid() && state === "SUCCESS") {

				component.set("v.recommendations", response.getReturnValue());
			}
			else if (state === "INCOMPLETE") {
				// do something
				console.log(state);
			}
			//else if (component.isValid() && state === "ERROR") {
			else if (state === "ERROR") {
				console.log(state);

				var errors = response.getError();

				lightningUtilities.handleError(errors[0]);
			}
		});

		$A.enqueueAction(action);
	},
	navigateToRecs : function (cmp, ev) {
		var namespacePrefix = cmp.get("v.namespacePrefix");

	    var homeEvent = $A.get("e.force:navigateToObjectHome");
	    homeEvent.setParams({
	        "scope": namespacePrefix + "Recommendation__c"
	    });
	    homeEvent.fire();

	},
	toggleSpinner: function(component) {
		var spinner = component.find("loadingSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
	}
})