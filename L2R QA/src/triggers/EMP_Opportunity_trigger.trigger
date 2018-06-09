trigger EMP_Opportunity_trigger on Opportunity (after delete, after insert, after update) {
    
    if(trigger.isAfter) {
        
        if(trigger.isInsert) {
            
            EMP_Opportunity_Handler.createWaterfallHistory(trigger.new,trigger.old,trigger.isUpdate);
            
        }else if(trigger.isUpdate) {
            
            EMP_Opportunity_Handler.createWaterfallHistory(trigger.new,trigger.old,trigger.isUpdate);
            
        }
    }
}