(function(myContext){
    myContext.ForceUI = myContext.ForceUI || {};

    myContext.ForceUI.isSalesforce1 = function() {
        return((typeof sforce != 'undefined') && sforce && (!!sforce.one));
    }
})(this);