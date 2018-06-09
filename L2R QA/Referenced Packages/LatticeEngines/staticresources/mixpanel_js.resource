(function(e,b){if(!b.__SV){var a,f,i,g;window.mixpanel=b;b._i=[];b.init=function(a,e,d){function f(b,h){var a=h.split(".");2==a.length&&(b=b[a[0]],h=a[1]);b[h]=function(){b.push([h].concat(Array.prototype.slice.call(arguments,0)))}}var c=b;"undefined"!==typeof d?c=b[d]=[]:d="mixpanel";c.people=c.people||[];c.toString=function(b){var a="mixpanel";"mixpanel"!==d&&(a+="."+d);b||(a+=" (stub)");return a};c.people.toString=function(){return c.toString(1)+".people (stub)"};i="disable time_event track track_pageview track_links track_forms register register_once alias unregister identify name_tag set_config people.set people.set_once people.increment people.append people.union people.track_charge people.clear_charges people.delete_user".split(" ");
for(g=0;g<i.length;g++)f(c,i[g]);b._i.push([a,e,d])};b.__SV=1.2;a=e.createElement("script");a.type="text/javascript";a.async=!0;a.src="undefined"!==typeof MIXPANEL_CUSTOM_LIB_URL?MIXPANEL_CUSTOM_LIB_URL:"file:"===e.location.protocol&&"//cdn.mxpnl.com/libs/mixpanel-2-latest.min.js".match(/^\/\//)?"https://cdn.mxpnl.com/libs/mixpanel-2-latest.min.js":"//cdn.mxpnl.com/libs/mixpanel-2-latest.min.js";f=e.getElementsByTagName("script")[0];f.parentNode.insertBefore(a,f)}})(document,window.mixpanel||[]);
mixpanel.init("6812846496bc7ad1b6d79e78e1898da9");

var MixPanelModule = (function ($, mpBasicReturnObject, mpOldTabName, isFeatureOn, mpOldTopTabName, actionVerificationCallback) {

"use strict";

var mpPageLoadTime = new Date();
var mpTabOpenTime;
var mpTopTabOpenTime;

function assingMPEvents() {
	if(!isFeatureOn){
		return;
	}

	$("li[id$='converToOppButton']").on("click", function() {
		if (!shouldTrackActionForItem("converToOppButton")) {
			return;
		}

		sendMpMessage("Convert to Opportunity");
	});

	$("li[id$='converToOppButtonEmbedded']").on("click", function() {
		if (!shouldTrackActionForItem("converToOppButtonEmbedded")) {
			return;
		}

		sendMpMessage("Convert to Opportunity");
	});

	$("li[id$='linkToOppButton']").on("click", function() {
		if (!shouldTrackActionForItem("linkToOppButton")) {
			return;
		}

		sendMpMessage("Link to Opportunity");
	});

	$("li[id$='disqualifyButtton']").on("click", function() {
		if (!shouldTrackActionForItem("disqualifyButtton")) {
			return;
		}

		sendMpMessage("Disqualify");
	});

	$("li[id$='emailButton']").on("click", function() {
		if (!shouldTrackActionForItem("emailButton")) {
			return;
		}

		sendMpMessage("Send an Email");
	});

	$("li[id$='logButton']").on("click", function() {
		if (!shouldTrackActionForItem("logButton")) {
			return;
		}

		sendMpMessage("Log a Call");
	});

	$("li[id$='taskButton']").on("click", function() {
		if (!shouldTrackActionForItem("taskButton")) {
			return;
		}

		sendMpMessage("Create a Task");
	});

	$("li[id$='meetingButton']").on("click", function() {
		if (!shouldTrackActionForItem("meetingButton")) {
			return;
		}

		sendMpMessage("Create a Meeting");
	});

	$("li[id$='eventButton']").on("click", function() {
		if (!shouldTrackActionForItem("eventButton")) {
			return;
		}

		sendMpMessage("Create an Event");
	});

	$("li[id$='bsBullet']").on("click", function(event) {
		sendMpTabDurationMessage("Change Tab", event);
		startTabStopwatch();
	});

	$("li[id$='tpBullet']").on("click", function(event) {
		sendMpTabDurationMessage("Change Tab", event);
		startTabStopwatch();
	});

	$("li[id$='companyProfileBullet']").on("click", function(event) {
		sendMpTabDurationMessage("Change Tab", event);
		startTabStopwatch();
	});

	$("li[id$='CompanyProfileBulletTopLevel']").on("click", function(event) {
		sendMpTopLevelTabDurationMessage("Change Tab", event);
		startTopTabStopwatch();
	});

	$("li[id$='PurchaseHistoryBullet']").on("click", function(event) {
		sendMpTabDurationMessage("Change Tab", event);
		startTabStopwatch();
	});

	$("li[id$='PurchaseHistoryBulletTopLevel']").on("click", function(event) {
		sendMpTopLevelTabDurationMessage("Change Tab", event);
		startTopTabStopwatch();
	});

	$("li[id$='recommendationsBulletTopLevel']").on("click", function(event) {
		sendMpTopLevelTabDurationMessage("Change Tab", event);
		startTopTabStopwatch();
	});

	$("li[id^='suppInfoBulletTopLevel_']").on("click", function(event) {
		sendMpTopLevelTabDurationMessage("Change Tab", event);
		startTopTabStopwatch();
	});

	$("li[id^='suppInfoBullet_']").on("click", function(event) {
		sendMpTabDurationMessage("Change Tab", event);
		startTabStopwatch();
	});

	$("a[id$='disqualificationCancelButton']").on("click", function(event) {
		sendCancelMpMessage("Disqualification");
	});

	$("a[id$='linkToOpportunityCancelButton']").on("click", function(event) {
		sendCancelMpMessage("Link To Opportunity");
	});

	$("a[id$='newOppCancelButton']").on("click", function(event) {
		sendCancelMpMessage("New Opportunity");
	});

	$("div[id$='recommendationName']").on("click", function(event) {
		sendMpMessage("Reccomendation Selected");
		startTabStopwatch();
	});

	$("a[id$='backToRecommendationsListButton']").on("click", function(event) {
		sendCancelMpMessage("Recommendation Card");
	});
}

function sendMpMessage(event, rawParameters) {
	if(!isFeatureOn){
		return;
	}

	var parameters = mpBasicReturnObject;
	parameters = $.extend(rawParameters, mpBasicReturnObject);

	mixpanel.track(event, parameters);
}

function sendMpPageDurationMessage(event) {
	if(!isFeatureOn){
		return;
	}

	sendMpMessage(event, {
		"Duration": new Date() - mpPageLoadTime
	});
}

function sendMpTabDurationMessage(event, eventObject) {
	if(!isFeatureOn){
		return;
	}

	var newTabName = $($(eventObject.currentTarget).children().children()[0]).text()
	//console.log("Changed tab:" + mpOldTopTabName + " -> " + newTabName);

	sendMpMessage(event, {
		"Duration": new Date() - mpTabOpenTime,
		"Old Tab": mpOldTabName,
		"New Tab": newTabName
	});

	mpOldTabName = newTabName;
}

function sendMpTopLevelTabDurationMessage(event, eventObject) {
	if(!isFeatureOn){
		return;
	}

	var newTabName = $($(eventObject.currentTarget).children().children()[0]).text();

	//console.log("Changed top level tab:" + mpOldTopTabName + " -> " + newTabName);

	sendMpMessage(event, {
		"Duration": new Date() - mpTopTabOpenTime,
		"Old Tab": mpOldTopTabName,
		"New Tab": newTabName
	});

	mpOldTopTabName = newTabName;
}

function assingMPEventsForDashboard(){
	if(!isFeatureOn){
		return;
	}
	$("#totalNav").on("click", sendMpMessageFromDashboard);
	$("#availableNav").on("click", sendMpMessageFromDashboard);
	$("#pipelineNav").on("click", sendMpMessageFromDashboard);
}

function sendMpMessageFromDashboard (event) {

	var newTabName = $($(event.currentTarget).children().children()[1]).text();
	var parameters = $.extend({
		"Duration": new Date() - mpTabOpenTime,
		"Old Tab": mpOldTabName,
		"New Tab": newTabName
	}, mpBasicReturnObject);

	mpOldTabName = newTabName;
	startTabStopwatch();

	mixpanel.track("Change Tab", parameters);
}

function sendCancelMpMessage(source) {
	var parameters = $.extend({
		"Source": source
	}, mpBasicReturnObject);

	mixpanel.track("Back", parameters);
}

function mpCardClic (argument) {

}

function startTabStopwatch() {
	if(!isFeatureOn){
		return;
	}
	mpTabOpenTime = new Date();
}

function startTopTabStopwatch() {
	if(!isFeatureOn){
		return;
	}
	mpTopTabOpenTime = new Date();
}

function topLevelTabsDidUpdate(tabName) {
	mpOldTopTabName = tabName;
	startTopTabStopwatch();
}

function shouldTrackActionForItem(itemId) {
	return undefined == actionVerificationCallback || actionVerificationCallback(itemId);
}

return {
	"sendMpMessage" : sendMpMessage,
	"sendMpPageDurationMessage" : sendMpPageDurationMessage,
	"assingMPEvents" : assingMPEvents,
	"startTabStopwatch" : startTabStopwatch,
	"assingMPEventsForDashboard" : assingMPEventsForDashboard,
	"topLevelTabsDidUpdate" : topLevelTabsDidUpdate
}

});

var hashCode = function(str) {
	var hash = 0,
		i, chr, len;
	if (str.length === 0) return hash;
	for (i = 0, len = str.length; i < len; i++) {
		chr = str.charCodeAt(i);
		hash = ((hash << 5) - hash) + chr;
		hash |= 0; // Convert to 32bit integer
	}
	return hash;
}
