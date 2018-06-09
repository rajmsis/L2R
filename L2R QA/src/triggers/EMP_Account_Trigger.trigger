trigger EMP_Account_Trigger on Account (before insert, before update, after insert, after update) {
    
	if(EMP_Account_Handler.shouldRunTrigger()){
	    /*
	        TRIGGER IS AFTER
	    */
	    if(trigger.isAfter) {
	        
	        if(trigger.isInsert) {
	            EMP_Account_Handler.assignToAccountTeams(trigger.new, trigger.oldMap, trigger.isUpdate);
	        }else if(trigger.isUpdate) {
	            EMP_Account_Handler.assignToAccountTeams(trigger.new, trigger.oldMap, trigger.isUpdate);
	        }
	    /*
	        TRIGGER IS BEFORE
	    */
	    } else {
	    	if(trigger.isInsert) {
	    		EMP_Account_Handler.beforeInsert(trigger.new);
	    	}else if(trigger.isUpdate) {
	    		EMP_Account_Handler.beforeUpdate(trigger.new,trigger.newMap, trigger.old, trigger.oldMap);
	    	}
	    } 
    }
}