function resetTableColumns() {

	$('.sortableCol').on('click', null, clickedColumn);
}

function clickedColumn() {
	var columnSort = $(this).attr('data-sortColumn');
	
	if (columnSort == sortField) {
		//Reverse the sort
		if (sortOrder == 'DESC') {
			sortOrder = 'ASC';
		} else {
			sortOrder = 'DESC';
		}
	} else {
		sortOrder = 'ASC';
	}

	resortTable(columnSort, sortOrder);
}

function clickedStageFilter(button) {		
	var arrName = button.id.split(':');

	arrName[arrName.length-1] = 'hid';

	var hiddenId = esc(arrName.join(':'));

	newVal = ($(hiddenId).val() == 'true' ? 'false' : 'true');

	$(hiddenId).val(newVal);
}

function activateTab(tabName) {
	$("div[id$='Panel']").hide();
	$("li[id$='Nav']").removeClass('active');

	$('#' + tabName + 'Panel').show();
	$('#' + tabName + 'Nav').addClass('active');
}

function resetDropdown() {
	$('#statusFilter').SumoSelect({ okCancelInMulti:true, 
									selectAll:true, 
									selectAlltext: selectAllNone,
									csvDispCount:1,
									triggerChangeCombined: true,
									captionFormat: xSelected
								});
	
	$('#statusFilter').on('change', null, optionsSelected);
}

function resetPlayDropdown() {
	$('#playFilter').val(selectedPlay);
	
	$('#playFilter').selectpicker();
	
	$('#playFilter').on('change', null, filterByPlay);
}

function filterByPlay (event) {
	filterCharts($('#playFilter').val());
}

function optionsSelected() {
	var selectedValues = $('#statusFilter').val();

	filterOpportunityCharts(selectedValues.toString());	
}


function returnRefreshStats(result, event) {
	//Nothing here, really, just to catch the return
}