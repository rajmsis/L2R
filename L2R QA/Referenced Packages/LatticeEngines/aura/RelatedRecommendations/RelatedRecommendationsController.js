({
	init : function(component, event, helper) {
		Promise.all([lightningUtilities.getParams(component), helper.getRelatedRecommendations(component)]).then(function(results) {
			var pageParams = results[0];
			var recommendations = results[1];

          	component.set("v.labels", pageParams.labels);
            component.set("v.namespacePrefix", pageParams.namespace);

            component.set("v.recommendations", recommendations);

			//Do It after everything has been set
			helper.toggleSpinner(component);
        }).catch(function (err) {
			helper.toggleSpinner(component);
            lightningUtilities.handleError(err);
        });
	}
})