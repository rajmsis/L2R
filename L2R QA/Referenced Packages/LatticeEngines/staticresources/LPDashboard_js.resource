var activePage = ''; //Save it here so I can retrieve without having to query the DOM to find out who's active

function activateTab(tabName) {
	$(".reports").hide();
	$(".filterSpan").hide();
	$(".reportlink").removeClass('active');

	$('#' + tabName + 'Panel').show();
	$('#' + tabName + 'Filters').show();
	$('#' + tabName + 'Link').addClass('active');

	activePage = tabName;

	toggleAllPanels();
}

function toggleAllPanels() {
	if (activePage == 'lead') {
		toggleCumulative('leadsScored');
		toggleCumulative('scoreSource');
		toggleCumulative('opportunities');
	} else {
		//Nothing for right now but...
	}
}

function toggleCumulative(tabName) {

	if ($('input[name=' + tabName + 'Toggle]:checked').val() == 'Cummulative') {
		$('#' + tabName + 'Weekly').hide();
		$('#' + tabName + 'Cummulative').show();
	} else {
		$('#' + tabName + 'Weekly').show();
		$('#' + tabName + 'Cummulative').hide();
	}
}

function attachControls() {
	$('[data-toggle="popover"]').popover();
	$('.selectpicker').selectpicker('refresh');

	$('#filterDate').datetimepicker({
		value: window.dashboardSettings.Variables.selectedDate,
		format:'Y-m-d',
		timepicker: false,
		closeOnDateSelect:true,
		weeks:true,
		disabledWeekDays:[1,2,3,4,5,6],
		onSelectDate:function(ct,$i){
  			callFilterCharts();
		}
	});

	$('#sourceFilter').SumoSelect({ okCancelInMulti:true,
									selectAll:true,
									locale: [window.dashboardSettings.Labels.ok, window.dashboardSettings.Labels.cancel, window.dashboardSettings.Labels.selectAllNone],
									search: true,
									searchText: window.dashboardSettings.Labels.search,
									captionFormatAllSelected: window.dashboardSettings.Labels.filterBySource,
									csvDispCount:2,
									triggerChangeCombined: true,
									captionFormat: window.dashboardSettings.Labels.xSourcesSelected
								});

	$('#statusFilter').SumoSelect({ okCancelInMulti:true,
									selectAll:true,
									locale: [window.dashboardSettings.Labels.ok, window.dashboardSettings.Labels.cancel, window.dashboardSettings.Labels.selectAllNone],
									search: true,
									captionFormatAllSelected: window.dashboardSettings.Labels.filterByStatus,
									csvDispCount:2,
									triggerChangeCombined: true,
									captionFormat: window.dashboardSettings.Labels.xStatusesSelected
								});

}

function callFilterCharts() {
	$('#el_loading1').show();

	var scoreField = $('#scoreField').val();
	var scoreFieldAccount = $('#scoreFieldAccount').val();
	var scoreFieldContact = $('#scoreFieldContact').val();
	var dateField = $('#filterDate').val();

	var sourceField = $('#sourceFilter').val();
	var statusField = $('#statusFilter').val();

	filterCharts(scoreField, scoreFieldAccount, scoreFieldContact, dateField, sourceField.toString(), statusField.toString());
}

function showDatePicker() {
	jQuery('#filterDate').datetimepicker('show'); //support hide,show and destroy command
}
