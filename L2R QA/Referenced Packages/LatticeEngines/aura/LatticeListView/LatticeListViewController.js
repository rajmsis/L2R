({
	init : function(component, event, helper) {
		helper.initPage(component, event, helper);
	},
	changeListview: function(component, event, helper) {
		var dropdown = component.find("listview");

		component.set("v.selectedListViewId", dropdown.get("v.value"));

        helper.toggleSpinner(component);
		helper.initPage(component, event, helper);
	},
	viewRec: function(component, event, helper) {
		var globalId = event.srcElement.id;

		helper.showDetailRecord(globalId, component);
	}
})