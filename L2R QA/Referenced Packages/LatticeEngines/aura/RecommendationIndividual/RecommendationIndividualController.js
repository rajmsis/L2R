({
	init : function(component, event, helper) {
		helper.initPage(component, event, helper);
		// Promise.all([lightningUtilities.getParams(component), helper.getRecord(component)]).then(function(results) {
  //           var pageParams = results[0]; //Page Stuff
  //           var rec = results[1]; //rec Stuff

  //           component.set("v.showScore", pageParams.showScore);
  //           component.set("v.showRevenue", pageParams.showRevenue);
  //           component.set("v.labels", pageParams.labels);
  //           component.set("v.namespacePrefix", pageParams.namespace);

  //           component.set("v.recommendation", rec);

  //           var recId = [];
  //           recId.push(rec.id);
		// 	component.set("v.selectedRecommendations", recId);

		// 	helper.calculateScoreToShow(component);

		// 	//Do It after everything has been set
		// 	helper.toggleSpinner(component);
  //       }).catch(function (err) {
  //           lightningUtilities.handleError(err);
  //       });
	},
	goBack : function(component, event, helper) {
		helper.fireBackEvent(component);
	},
	handleRefreshPage : function(component, event, helper) {
		var isStandalone = component.get("v.isStandalone");

		if (isStandalone) {
			//Start Spinner
			helper.toggleSpinner(component);
			//Refresh Record
			helper.initPage(component, event, helper);
		} else {
			helper.fireBackEvent(component);
		}
	},
})