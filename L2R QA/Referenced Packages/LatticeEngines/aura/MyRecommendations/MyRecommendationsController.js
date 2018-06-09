({
	init : function(component, event, helper) {
		lightningUtilities.getParams(component).then(function(results) {
			var pageParams = results;

          	component.set("v.labels", pageParams.labels);
            component.set("v.namespacePrefix", pageParams.namespace);
            component.set("v.dropdownObject", pageParams.details.dropdownObject);
            component.set("v.dropdownField", pageParams.details.dropdownField);
            component.set("v.dropdownDisplayField", pageParams.details.dropdownDisplayField);
            component.set("v.showDropdown", true);

			// Then select the first Id
			helper.getRecommendationsForPlay(component, event, 'All');

			//Do It after everything has been set
			helper.toggleSpinner(component);
        }).catch(function (err) {
			helper.toggleSpinner(component);
            lightningUtilities.handleError(err);
        });
	},
	viewAllRecommendations : function(component, event, helper) {
		helper.navigateToRecs(component, event);
	},
	handleLookupChange : function(component, event, helper) {
		helper.changePlay(component, event, event.getParam("sObjectId"));
	}
})