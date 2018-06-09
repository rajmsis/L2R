var AppChangeModule = (function ($) {
	"use strict";

	var originalRegion;

	var initUI = function() {
		originalRegion = $("[id$='hidSelectedRegion']").val();

		selectRegion($("[id$='hidSelectedRegion']").val(), '');
	};

	var closePopup = function(){
	    $('#changeApplication').modal('hide');
	}

	var selectRegion = function(theRegion, theName, theType) {
		$('.regionButton').addClass('btn-default')
							.removeClass('btn-primary')
							.removeClass('active');

		$('#btn-' + theRegion).removeClass('btn-default')
							.addClass('btn-primary')
							.addClass('active');

		$("[id$='hidSelectedRegion']").val(theRegion);
		$("[id$='hidSelectedRegionName']").val(theName);
		$("[id$='hidSelectedRegionType']").val(theType);

		$("[id$='changeAppButton']").focus();

		if (theRegion == originalRegion) {
	    	$("[id$='changeAppButton']").attr("disabled", "disabled");
		} else {
			$("[id$='changeAppButton']").removeAttr("disabled");
		}

	}

	return {
		initUI: initUI,
		closePopup: closePopup,
		selectRegion: selectRegion
	}

})(jQuery);