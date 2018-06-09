({
    /**
     * Get the details for the component
     */
    init : function(component, event, helper) {


        helper.getComponentDetails(component).then(function(results) {
            var resultInfo = results; //Page Stuff

            component.set("v.objectLabel", resultInfo.details.label);
            component.set("v.objectPluralLabel", resultInfo.details.pluralLabel);

            if (resultInfo.details.valueName != '') {
                var value = component.get("v.value");

                helper.handleSelection(component, value, resultInfo.details.valueName, false);
            }

            var placeholder = component.get("v.placeholder");
            if (placeholder == '') {
                placeholder = 'Search ' + resultInfo.details.pluralLabel;
            }
            component.set("v.placeholder", placeholder);

        }).catch(function (err) {

            lightningUtilities.handleError(err);
        });
    },
    /**
     * Search an SObject for a match
     */
    search : function(component, event, helper) {
        helper.doSearch(component);
    },

    /**
     * Select an SObject from a list
     */
    select: function(component, event, helper) {
        // Resolve the Object Id
        var objectId = event.currentTarget.id;

        // The Object label is the 2nd child (index 1)
        //var objectLabel = event.currentTarget.children[0].children[1].children[0].innerText;
        var objectLabel = event.currentTarget.dataset.recordname;
        //console.log(event.currentTarget.dataset.recordname);
        
        //objectLabel = 'test';

        helper.handleSelection(component, objectId, objectLabel, true);
    },

    /**
     * Clear the currently selected SObject
     */
    clear: function(component, event, helper) {
        helper.clearSelection(component);
    }
})