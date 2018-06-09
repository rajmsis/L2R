'use strict';
$(document).ready(function() {
	beautifyTable();
});

function beautifyTable(){

	$('#scoringRulesTable_filter').find( "input" ).css( "margin-left", "15px" );
	$('#scoringRulesTable_filter').find( "label" ).css( "padding-top", "5px" );

	if($(".dataTables_empty").length === 1) {
		$(".dataTables_empty").hide();
		$(".dataTables_paginate").hide();
		$(".dataTables_filter").hide();
		$(".dataTables_info").hide();
	}

	if($("#scoringRulesTable tbody tr").length <= 20){
		$(".dataTables_filter").hide();
	}

}

function rerenderTable(){
	beautifyTable();
}

function toggleActiveHidden(newValue) {
	$('#activeYes').removeClass('active');
	$('#activeNo').removeClass('active');

	if (newValue) {
		$('#activeYes').addClass('active');
	} else {
		$('#activeNo').addClass('active');
	}

	$("[id$='activeHidden']").val(newValue);
}

function initSelectPickers() {
	 $('#loadingScreen').show();

    //Artificially delay one second
    setTimeout(function() {
        attachDropdowns();

        $('#loadingScreen').hide();
    }, 1000);

	reloadPage();
}

function attachDropdowns() {

	$('.selectpicker').select2();
	$('.nosearch-picker').select2({
	  minimumResultsForSearch: Infinity
	});
	$('[data-toggle="popover"]').popover();

	$('.dateControl').datetimepicker({
		format:'Y-m-d',
		timepicker: false
	});
	$('.dateTimeControl').datetimepicker({
		format:'Y-m-d H:i:00',
		defaultTime:'00:00'
	});
}

function closeModals(){
    $('#confirmDelete').modal('hide');

    $('.deleteToDisable').removeAttr('disabled');
	$('.btn-primary.deleteToDisable').attr('value', $('.btn-primary.deleteToDisable').attr('data-oldvalue'));
    $('.btn-primary.deleteToDisable').removeAttr('data-oldvalue');
}
function closeStartScoringModal(){
    $('#confirmStartScoring').modal('hide');
    $("input[id$='selectedRuleIdForScoring']").val('');
}

function showModalForRuleScoring(ruleId, ruleName){
	$('#confirmStartScoring').modal('show');
	$('#ruleNameInModal').text(ruleName);
	$("input[id$='selectedRuleIdForScoring']").val(ruleId);
}

function showSubmittedSuccessfully () {
	  closeStartScoringModal();
	  $('#submittedSuccessfully').modal('show');
}

function closeSubmittedSuccessfully () {
	 $('#submittedSuccessfully').modal('hide');
	 $('[id$=startscoring]').removeAttr('disabled');
}

$(function () {
      $('[id$=startscoring]').on('click', function (e) {
      	$(this).attr('disabled', 'disabled');
    });
});
