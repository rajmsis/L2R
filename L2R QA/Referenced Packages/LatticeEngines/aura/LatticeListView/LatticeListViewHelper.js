({
	initPage: function(component, event, helper) {

        Promise.all([lightningUtilities.getParams(component), helper.getPage(component)]).then(function(results) {
            var pageParams = results[0]; //Page Stuff
            var pageInfo = results[1]; //page records Stuff

            component.set("v.labels", pageParams.labels);
            component.set("v.namespacePrefix", pageParams.namespace);

            component.set("v.listviews", pageInfo.listviewOptions);
			component.set("v.selectedListViewId", pageInfo.listviewId);
			component.set("v.pagedRecords", pageInfo.records);

            //Do It after everything has been set
            helper.toggleSpinner(component);
        }).catch(function (err) {
        	console.log('error');
        	console.log(err);
            helper.toggleSpinner(component);

            lightningUtilities.handleError(err);
        });
    },
	getPage : function (component) {
    	var action = component.get('c.getListviewPage');
		var objectType = component.get("v.objectType");
		var selectedListViewId = component.get("v.selectedListViewId");

        return new Promise(function (resolve, reject) {
            action.setParams({
            	objectType: objectType,
            	selectedListView: selectedListViewId
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
	},
	showDetailRecord: function(recordId, component) {
		var detailComponentDef = [["LBI:RecommendationIndividual", {recordId : recordId, sObjectName: '', isStandalone: false}]];

		$A.createComponents(detailComponentDef,
		                function(recDetailComponent, status, statusMessagesList){
		                    component.set("v.recDetail", recDetailComponent);
							component.set("v.isShowingDetail", true);
		                });
	}
})