'use strict';

function attachDropdowns() {
    $('#loadingScreen').show();

    //Artificially delay one second
    setTimeout(function() {
        $.fn.select2.defaults.set( "theme", "bootstrap" );

        resetOptGroups();

        $('.dropdown').select2();
        setDirtyCheck();

        $('#loadingScreen').hide();
    }, 1000);


}

function setDirtyCheck() {
    $('.dirtyControl').on('change', null, turnDirtyOn);
}

function turnDirtyOn() {
    isDirty = true;
}

function turnDirtyOff() {
    isDirty = false;
}

function resetTab() {
	window.modelMappingSettings.Variables.activeTab = 'Lead';
    turnDirtyOff();

    attachDropdowns();
}

function setActiveTab(tabToLoad) {
    if (window.modelMappingSettings.Variables.activeTab != tabToLoad) {

        if (isDirty && ! confirm(window.modelMappingSettings.Labels.leaveScreen)) {
            return;
        }

        turnDirtyOff();

        //Clear the errors
        $('#message').hide();
        $('#errorList').empty();

        window.modelMappingSettings.Variables.activeTab = tabToLoad;

        $('.mainTab').removeClass('active');
        $('#' + tabToLoad + 'Tab').addClass('active');

        changeTab(tabToLoad);
    }
}

function confirmSave() {
    var ruleCount = $('#rulesCount').val();

    if (ruleCount == 0) {
        savePage();
    } else {
      $('#confirmUncheck').modal('show');
    }
}

function closeModals() {
    $('#confirmUncheck').modal('hide');
}

function loadForm() {
    attachDropdowns();

    goBack();
}


function confirmExit() {
    if (isDirty) {
        return window.modelMappingSettings.Labels.leaveScreen;
    }
}

function resetOptGroups(onlyPrimaryAttributes) {

    $.each($('.addGroups'), function(index, object) {
	 	resetOptGroupsInComponent(object);
	 });
}

//http://salesforce.stackexchange.com/questions/21120/is-there-a-way-to-group-options-in-a-selectlist
//Thanks Mark Pond!
function resetOptGroupsInComponent(selectList) {
	// a javascript object to collect the elements in each region
    var optGroups = {};

    // iterate all of the options and collect them by region
    jQuery('option', selectList).each(function (i) {
        if (i === 0) {
            return; // skip the first element in the list
        }
        var oElement = jQuery(this);
        var groupName = oElement.text().split('~~');

        // create an array entry for the region name if there is not one
        if (!optGroups[groupName[0]]) {
            optGroups[groupName[0]] = [];
        }

        // add the item to the array for this region
        optGroups[groupName[0]].push(oElement);
    });

    // iterate all of the names in the optGroups object
    for (var optGroup in optGroups) {

        // make sure the name did not come from the prototype
        if (optGroups.hasOwnProperty(optGroup)) {

            // turn the array of items into a single jQuery collection
            var groupElements = jQuery(optGroups[optGroup]).map(function () {
                return this.toArray();
            });

            // create the group and set the label
            var optgroup = jQuery('<optgroup/>');
            optgroup.attr('label', optGroup);

            // wrap the option elements in an optgroup
            groupElements.wrapAll(optgroup);

            // remove the optGroup text from the label
            groupElements.each(function () {
                jQuery(this).text(function () {
                    return jQuery(this).text().replace(optGroup + '~~', '');
                });
            });
        }
    }
}