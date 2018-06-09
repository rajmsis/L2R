var lejQuery = jQuery.noConflict();

var isLoadingAccount = false;
var hasIFrameLoaded = false;

lejQuery(document).ready(function() {

	// This code is what listens to the iframe postmessage to resize itself
	window.addEventListener('message', function(evt) {
		if (console) {
			console.log('RLJ: Received A Message!.');
			console.log('RLJ: ' + evt);
			console.log(evt);
			console.log(evt.data);
		}

		if (!evt || typeof evt.data !== 'string') {
			if (console) {
				console.log('Evt.data not of type string.');
			}
			return;
		}

		if (evt.data.indexOf("IFrameResizeEvent") !== -1) {
			var height = evt.data.split('=')[1];
			if (console) {
				console.log(height);
			}
			
			var IFrame = document.getElementById('theIFrame');
			var iFrameOnAccount = document.getElementById('theIFrameOnAccount');

			//alert('RLJ: ' + height);
			if (window.parent && window.parent != window) {
				console.log('RLJ: Sending Resize event to Parent window.');
				window.parent.postMessage(evt.data, "*"); // Send the message back to parent window
			}
			//var isSafari = !!navigator.userAgent.match(/Version\/[\d\.]+.*Safari/);
			
			try {
				if (document.getElementById('padTheIframe').value == 'true') {
					if (console) {
						//console.log('Padding iFrame height response with 100px.');
					}
					//height = height+100;
				}
			} catch (err) {
				if (console) {
					//console.log('Could not find element with padding instructions, swallowing exception.');
				}
			}

			if (height && IFrame) {
				IFrame.style.height = (height == "auto" ? '' : height + 'px');
			}
			if (height && iFrameOnAccount) {
				iFrameOnAccount.style.height = (height == "auto" ? '' : height + 'px');
			}

			// iFrame resized itself, so we know it loaded.
			if (console) {
				console.log('Received iFrame Resize Event from postmessage listener.');
			}
			hasIFrameLoaded = true;

			setTimeout( function(){ lejQuery('.tabLi > a').css('pointer-events',''); }, 1000 );
		}
	});

	SF1configure();
});

function showProfileNavigation(linkName) {
	lejQuery('.toggle-content').hide();
	lejQuery('#category' + linkName).show();
	lejQuery('#category' + linkName).find('.hidden-xs').removeClass('hidden-xs');
	lejQuery('#companyProfileTOC').addClass('hidden-xs');

	lejQuery('.profile-link').removeClass('active');
	lejQuery('#link' + linkName).addClass('active');

}

function applyEvenOdd () {
    if (console) {
    	console.log('Applying Even Odd Classes');
    }
    
    lejQuery('#outputTable').addClass('test');
    lejQuery('.data:nth-of-type(4n-1) + div').addClass('bkg-colored first');
    lejQuery('.first').next().addClass('bkg-colored');
}

function doBackFromProfileNavigation() {
	lejQuery('#companyProfileTOC').removeClass('hidden-xs');
	lejQuery('div[id^="category"]').find('.toBeHidden').addClass('hidden-xs');
}

function showTalkingPoints() {
	if (console) {
		console.log('hasIFrameLoaded:  '+hasIFrameLoaded);
	}
	if (!hasIFrameLoaded) {
		return;
	}

	lejQuery('.suppInfoTab').removeClass('active');

	var iFrame;
	var iFrameOnAccount;
	if (document.getElementById('theIFrame')) {
		iFrame = document.getElementById('theIFrame').contentWindow;
	}
	if (document.getElementById('theIFrameOnAccount')) {
		iFrameOnAccount = document.getElementById('theIFrameOnAccount').contentWindow
	}

	if (iFrame) {
		iFrame.postMessage("CrmTabSelectedEvent=TalkingPoints", "*"); // switch to Buying Signals
	} else if (iFrameOnAccount) {
		iFrameOnAccount.postMessage("CrmTabSelectedEvent=TalkingPoints", "*"); // switch to Buying Signals
	}

	lejQuery('.talkingPointsLink').addClass('active');
	lejQuery('.buyingSignalsLink').removeClass('active');

	lejQuery('.iFrameHolder').show();
	lejQuery('.suppInfoHolder').hide();
	lejQuery('.company-profile-holder').hide();
	SF1configure();
}

function showBuyingSignals() {
	if (console) {
		console.log('hasIFrameLoaded:  '+hasIFrameLoaded);
	}
	if (!hasIFrameLoaded) {
		return;
	}

	lejQuery('.suppInfoTab').removeClass('active');

	var iFrame;
	var iFrameOnAccount;
	if (document.getElementById('theIFrame')) {
		iFrame = document.getElementById('theIFrame').contentWindow;
	}
	if (document.getElementById('theIFrameOnAccount')) {
		iFrameOnAccount = document.getElementById('theIFrameOnAccount').contentWindow
	}

	if (iFrame) {
		iFrame.postMessage("CrmTabSelectedEvent=BuyingSignals", "*"); // switch to Buying Signals
	} else if (iFrameOnAccount) {
		iFrameOnAccount.postMessage("CrmTabSelectedEvent=BuyingSignals", "*"); // switch to Buying Signals
	}

	lejQuery('.talkingPointsLink').removeClass('active');
	lejQuery('.buyingSignalsLink').addClass('active');

	lejQuery('.iFrameHolder').show();
	lejQuery('.suppInfoHolder').hide();
	lejQuery('.company-profile-holder').hide();
	SF1configure();
}

function showProductPurchaseHistory() {
	if (console) {
		console.log('hasIFrameLoaded:  '+hasIFrameLoaded);
	}
	if (!hasIFrameLoaded) {
		return;
	}

	lejQuery('.suppInfoTab').removeClass('active');

	var iFrame;
	var iFrameOnAccount;
	if (document.getElementById('theIFrame')) {
		iFrame = document.getElementById('theIFrame').contentWindow;
	}
	if (document.getElementById('theIFrameOnAccount')) {
		iFrameOnAccount = document.getElementById('theIFrameOnAccount').contentWindow
	}

	if (iFrame) {
		iFrame.postMessage("CrmTabSelectedEvent=spendAnalytics", "*"); // switch to Spend Analytics, previously Purchase History
	} else if (iFrameOnAccount) {
		iFrameOnAccount.postMessage("CrmTabSelectedEvent=spendAnalytics", "*"); // switch to Spend Analytics, previously Purchase History
	}

	lejQuery('.iFrameHolder').show();
	lejQuery('.suppInfoHolder').hide();
	lejQuery('.company-profile-holder').hide();
	SF1configure();
}

function selectThisSuppInfo(suppInfoId, recLevel) {
	if (console) {
		console.log('hasIFrameLoaded:  '+hasIFrameLoaded);
	}
	if (!hasIFrameLoaded) {
		return;
	}

	lejQuery('.suppInfoHolder').show();
	lejQuery('.talkingPointsLink').removeClass('active');
	lejQuery('.buyingSignalsLink').removeClass('active');
	lejQuery('.company-profile-holder').hide();
	lejQuery('.iFrameHolder').hide();
	lejQuery('#recommendationCardsContainer').hide();
	lejQuery('#companyProfileTabContentsOnAccount').hide();
	lejQuery('#companyProfileHolder').hide();
	lejQuery('#iFrameHolderOnAccount').hide();
	lejQuery('input[id$="searchTerm"]').val('');
	SF1configure();
	if (recLevel) {
		selectSuppInfoApexRec(suppInfoId);
	} else {
		selectSuppInfoApex(suppInfoId);
	}
}

function selectCompanyProfile(suppInfoId) {
	console.log("delay");
	setTimeout(function(){
		if (console) {
			console.log('hasIFrameLoaded:  '+hasIFrameLoaded);
		}
		if (!hasIFrameLoaded) {
			return;
		}

		applyEvenOdd();

		lejQuery('#recommendationCardsContainer').hide();
		lejQuery('.company-profile-holder').show();
		lejQuery('.suppInfoHolder').hide();
		lejQuery('.talkingPointsLink').removeClass('active');
		lejQuery('.buyingSignalsLink').removeClass('active');
		lejQuery('.iFrameHolder').hide();
		SF1configure();
	}, 100);
}

// TODO: dhom - combine with selectCompanyProfile
function showCompanyProfile () {
	if (console) {
		console.log('hasIFrameLoaded:  '+hasIFrameLoaded);
	}
	if (!hasIFrameLoaded) {
		return;
	}

	applyEvenOdd();

	lejQuery('#recommendationCardsContainer').hide();
	lejQuery('#companyProfileTabContentsOnAccount').show();
	lejQuery('#companyProfileHolder').show();
	lejQuery('#iFrameHolderOnAccount').hide();
	lejQuery('.suppInfoHolder').hide();
	SF1configure();
}

function showRecommendationCards () {
	lejQuery('#recommendationCardsContainer').show();
	lejQuery('#companyProfileTabContentsOnAccount').hide();
	lejQuery('#companyProfileHolder').hide();
	lejQuery('#iFrameHolderOnAccount').hide();
	lejQuery('.suppInfoHolder').hide();
	SF1configure();
}

function showProductPurchaseHistoryCard () {
	if (console) {
		console.log('hasIFrameLoaded:  '+hasIFrameLoaded);
	}
	if (!hasIFrameLoaded) {
		return;
	}

	lejQuery('#recommendationCardsContainer').hide();
	lejQuery('#companyProfileTabContentsOnAccount').hide();
	lejQuery('#companyProfileHolder').hide();
	lejQuery('#iFrameHolderOnAccount').show();
	lejQuery('.suppInfoHolder').hide();

	//SF1configure();  // This is also called in the next function

	showProductPurchaseHistory();
}

function reEnableAccount() {
	isLoadingAccount = false;
}

function suppInfoTabClick(el, suppInfoId, recLevel) {
	if (isLoadingAccount) {
		return;
	}

	lejQuery('.suppInfoTab').removeClass('active');
	toggleClass(el,'active');
	selectThisSuppInfo(suppInfoId, recLevel);
}


function detectSubmit(event) {

	if (event.keyCode == 13) {
		submitSearchInApex();
	}
}

function showModal() {
	lejQuery('#spinnerModal').modal({
		show: true
	});
}

function hideModal() {
	lejQuery('#spinnerModal').modal('hide');
}

function makeOpportunityClickable(isForceRedirectRequired) {
	var foundAnOpp = false;
	var oppId = '';
	var oppName = '';

	lejQuery('span[id$="PageMessages"]').find('div.messageText, li').each(function(messageNumber) {
		var theInnerText = '' + lejQuery(this).text();
		var index = theInnerText.indexOf('__:');

		var theUrlEncoded = '';

		if (index != -1) {
			foundAnOpp = true;

			theUrlEncoded = theInnerText.substring(theInnerText.lastIndexOf('_') + 1, theInnerText.length);
			var theUrlDecoded = decodeURIComponent(theUrlEncoded);


			oppId = theUrlDecoded.substring(theUrlDecoded.lastIndexOf('/') + 1, theUrlDecoded.length);
			var oppName = theInnerText.substring(theInnerText.indexOf('__:') + 3, theInnerText.lastIndexOf('_'));

			// Got that, now let's build the anchor around it, and stuff it back into the page.

			var anchorTag = '<a href="#" onClick="openOpportunityPage(\'' +
				theUrlDecoded + '\', \'' + oppId + '\', ' + isForceRedirectRequired + ');">"' + oppName + '"</a>';


			// Let's also scrub off the old find/rep target
			lejQuery(this).text(theInnerText.substring(0, index));

			lejQuery(this).append(anchorTag);
		}
	});

	if (foundAnOpp) {
		// pop an opp?

		try {
			popOpportunityEdit(oppId, isForceRedirectRequired);
		} catch (ex) {
			console.log("Failed to open opportunity page: " + ex);
		}
	}
}

function openOpportunityPage(oppURL, oppId, isForceRedirectRequired) {

	if (isInSalesConsole){
		if(!isForceRedirectRequired) {
			openOrActivateInPrimaryConsoleTab(oppURL, oppId);
		} else {
			window.top.location.href = '/' + oppId + '/e?retURL=%2Fconsole';
		}

	}
	else{
			window.top.location.href = oppURL;
	}
}

function openOrActivateInPrimaryConsoleTab(tabURL, itemId, tabName, tabIconUrl) {
	console.log("openOrActivateInPrimaryConsoleTab");
	var pattern = itemId.length > 15 ? itemId.substring(0, 14) : itemId;

	sforce.console.openPrimaryTab(null, tabURL, true, tabName, function callBack(result) {
	    if (result.success) {
	    	if (null != tabIconUrl) {
	    		sforce.console.setTabIcon(tabIconUrl, result.id);
	    	}

	    	return;
	    }

        avctivateConsoleTabByPattern(pattern);
	});
}

function popOpportunityEdit (convertedOppId, isForceRedirectRequired) {
	
	
	// Only pop with no errors present....
	if (lejQuery('div[class$="messageText"]').find('h4:contains("Errors")').length == 0) {
		// We are using isdtp=vw to hide the header in some instances, which trips out sforce.console.isInConsole into thinking it's in the console even if it's not (tho it /could/ be) 
		// Let's instead look for our override param in the url and not try to do anything special like opening a new tab or changing the window location
		if (window.location.search.includes('usingAlternativeLeadAccount=true')) {
			return;
		}
		
		if (isInSalesConsole){
			if(!isForceRedirectRequired) {
				sforce.console.openPrimaryTab(null, '/' + convertedOppId, true);
			} else {
				window.top.location.href = '/' + convertedOppId + '/e?retURL=%2Fconsole';
			}
		}
		else{
				openNewTab('/' + convertedOppId + '/e?retURL='+convertedOppId, '_' + convertedOppId);
		}
	} else {
		attachClickOverridesOnCheckboxes();
	}
}

function openNewTab(link) {
	var open_link = window.open('','_blank');
	open_link.location=link;
}

function SF1configure() {
	try {
		var a = navigator.userAgent;
		if ((a.indexOf('Salesforce') != -1) && (a.indexOf('iPhone') != -1 || a.indexOf('iPad') != -1) && (a.indexOf('OS/8') != -1 || a.indexOf('OS 8') != -1 || a.indexOf('OS/9') != -1 || a.indexOf('OS 9') != -1 || a.indexOf('OS/10') != -1 || a.indexOf('OS 10') != -1) && (a.indexOf('Safari') == -1)) {
			var s = document.createElement('style');
			if (a.indexOf('OS/8') != -1 || a.indexOf('OS 8') != -1) {
				s.innerHTML = "html,html body{overflow: auto;-webkit-overflow-scrolling:touch;}body{position:absolute;left:0;right:0;top:0;bottom:0;}";
			} else if (a.indexOf('OS/9') != -1 || a.indexOf('OS 9') != -1) {
				s.innerHTML = "html,html body{overflow: auto;-webkit-overflow-scrolling:touch;}body{position:absolute;left:0;right:0;top:0;bottom:0;}";
			} else if (a.indexOf('OS/10') != -1 || a.indexOf('OS 10') != -1) {
				s.innerHTML = "html,html body{overflow: auto;-webkit-overflow-scrolling:auto;}body{position:absolute;left:0;right:0;top:0;bottom:0;}";
			}
			document.getElementsByTagName('head')[0].appendChild(s);
		} else { // add scrolling to webkit for phones/devices having no scroller for iframe
			var iOS = !!a.match(/iPad/i) || !!a.match(/iPhone/i);
			var webkit = !!a.match(/WebKit/i);
			var iOSSafari = iOS && webkit && !a.match(/CriOS/i);
			if (iOSSafari) {
				var s = document.createElement('style');
				s.innerHTML = "html,html body{overflow: auto;-webkit-overflow-scrolling:touch;}body{position:absolute;left:0;right:0;top:0;bottom:0;}";
				document.getElementsByTagName('head')[0].appendChild(s);
			}
		}
	} catch (e) {}
}


function navigateToTab(link, sfRecordId, isNewWindow, isEmbedded, newTabTitle) {
	if (!link) {
		return;
	}

	if (isInSalesConsole) {

		if(isEmbedded == 'true'){
			//var link = enchancePartialRedirectUrl(link, 'retURL=%2Fconsole', 'saveURL=%2Fconsole');
			//window.top.location.href = link;
		}

		// In cosonle you must not pass the save or ret urls, as this will cause an error displayed after action execution.
		if(link.indexOf('?') > -1){
			link = enchanceRedirectUrl(link);
		}
		else{
		 	link = enchancePartialRedirectUrl(link);
		}

		sforce.console.getEnclosingPrimaryTabId(function openSubtabForCurrentPrimaryTab(result) {
			if (result.id != "null") {
				sforce.console.openSubtab(result.id, link, true, newTabTitle);
			} else {
				sforce.console.openPrimaryTab(null, link, true, newTabTitle);
			}
		});
	} else {
		if (!isNewWindow) {

			window.top.location.href = link;

		} else {
			openNewTab(link);
		}
	}
}

function updateElementLinkToReturnInConsole(element, newLink){
	if(isInSalesConsole){
		var link = '';

		if(newLink !== undefined) {
			link = enchanceRedirectUrl(newLink, 'retURL=%2Fconsole', 'saveURL=%2Fconsole');
		}
		else {
			link = enchanceRedirectUrl(element.href, 'retURL=%2Fconsole', 'saveURL=%2Fconsole');
		}

		element.href = link;
	}
}

function enchancePartialRedirectUrl(link, retURL, saveURL){
	var parameters = link.split('&');

	var newParameters = [];

	for(var i =0; i<parameters.length; i++){
		var param = parameters[i];
		if(param.indexOf('retURL=') > -1){
			if(retURL !== undefined){
				newParameters.push(retURL);
			}
		}
		else if(param.indexOf('saveURL=') > -1){
			if(saveURL !== undefined){
				newParameters.push(saveURL);
			}
		}
		else{
			newParameters.push(param);
		}
	}

	return newParameters.join('&');
}

function enchanceRedirectUrl(link, retURL, saveURL){
	var urlParts = link.split('?');
	var enchanceResult = enchancePartialRedirectUrl(urlParts[1], retURL, saveURL);

	return urlParts[0] + '?' + enchanceResult;
}

function isInSalesConsole() {
	return sforce.console.isInConsole();
}

function openSalesPrismURL(urlToOpen) {
	window.open(urlToOpen, "_top");
	return false;
}

function avctivateConsoleTabByPattern(pattern) {
	sforce.console.getPrimaryTabIds(function callBack(result) {
        var tabIds = result.ids;
        var isSubTabFound = false;

        for (var i = 0; i < tabIds.length; i++) {
            (function(i) {
                sforce.console.getPageInfo(tabIds[i], function callBack(result) {
                    if (result.success && result.pageInfo.indexOf(pattern) != -1) {
						sforce.console.focusPrimaryTabById(tabIds[i]);

                    }

                });
            })(i)

            if (isSubTabFound) {
            	break;
            }
        }
    });
}
