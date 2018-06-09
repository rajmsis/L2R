trigger EMP_Lead_Trigger on Lead (after delete, after insert, after update, before insert, before update) {
    /*
        TRIGGER IS AFTER
    */
    if(trigger.isAfter) {
        
        if(trigger.isInsert) {
            
            EMP_Lead_Handler.createWaterfallHistory(trigger.new,trigger.old,trigger.isUpdate);
            
        }else if(trigger.isUpdate) {
            
            EMP_Lead_Handler.createWaterfallHistory(trigger.new,trigger.old,trigger.isUpdate);
            
        }
    /*
        TRIGGER IS BEFORE
    */
    } else {

        if(trigger.isInsert) {
            
            EMP_Lead_Handler.setAssignment(trigger.new,trigger.oldMap,trigger.isUpdate);
            
        }else if(trigger.isUpdate) {
            
            EMP_Lead_Handler.setAssignment(trigger.new,trigger.oldMap,trigger.isUpdate);
            
        }

    }
}