/**************************************************************************************

@author Javier Sanz	(javier.sanz@empaua.com)
@date 11 Apr 2018
@group	Empaua
@description Contaisn all the methods used on  the Lead trigger: Lead_Trigger


------------------------------------------------------------------------------
* Developer         Date            Description
Javier Sanz			11/04/2018		Creation
Javier Sanz			11/04/2018		added createWaterfallHistory method
Javier Sanz			11/04/2018	    added Stop boolean to avoid call the methods twice due to Workflow rules
-------------------------------------------------

*/
public with sharing class EMP_Lead_Handler {
    
    public static Boolean stop = false;
/******************************************************************
@name createWaterfallHistory
@author Javier Sanz	(javier.sanz@empaua.com)
@date 11 Apr 2018
@param news trigger.new
@param olds trigger.new
@param isupdate trigger.isupdate
@return Void
@description Creates a Waterfall_History__c if the lead status is changed

*******************************************************************/
    public static void createWaterfallHistory (list<Lead> news, list<Lead> olds, boolean isUpdate) {
    	
    	list<Waterfall_History__c> List_WatterfallHistorytoInsert = New list<Waterfall_History__c>();
    	
    	for (integer i = 0; i<news.size(); i++) {
    					
			
    		if (!isUpdate) {
    			List_WatterfallHistorytoInsert.add(new Waterfall_History__c(Lead__c = news[i].id,
    															New_lead_status__c = news[i].status,
    															MQL_Duration__c = news[i].MQL_Duration__c,
    															MQL_Date__c = news[i].MQL_Lead_Date__c,
    															SAL_Duration__c = news[i].SAL_Duration__c,
    															SAL_Date__c = news[i].SAL_Lead_Date__c,
    															SQL_Duration__c = news[i].SQL_Duration__c,
    															SQL_Date__c = news[i].SQL_Date__c,
    															New_Owner__c = news[i].ownerid
    															));
    		
    		} else if(news[i].Status != olds[i].Status) { 
    			 system.debug(news[i].Status);   	 
				system.debug(olds[i].Status); 
				 
    			List_WatterfallHistorytoInsert.add(new Waterfall_History__c(Lead__c = news[i].id,
    															New_lead_status__c = news[i].status, 
    															MQL_Duration__c = news[i].MQL_Duration__c,
    															MQL_Date__c = news[i].MQL_Lead_Date__c,
    															SAL_Duration__c = news[i].SAL_Duration__c,
    															SAL_Date__c = news[i].SAL_Lead_Date__c,
    															SQL_Duration__c = news[i].SQL_Duration__c,
    															SQL_Date__c = news[i].SQL_Date__c,
    															New_Owner__c = news[i].ownerid,
    															previous_owner__c = olds[i].ownerid,
    															Previous_Lead_Status__c = olds[i].status
    															));
    									
    		} 
    	}
    	
    	if (!stop && !List_WatterfallHistorytoInsert.isEmpty()) {
    		system.debug(List_WatterfallHistorytoInsert); 
    		insert List_WatterfallHistorytoInsert;
    		stop = true;
    	}
    	 
    }

/******************************************************************
@name setAssignment
@author Jose Maldonado (jose.maldonado@empaua.com)
@date 27 Apr 2018
@param news trigger.new
@param olds trigger.oldmap
@param isupdate trigger.isupdate
@return Void
@description Assign Queue when the Region__c or ZipCode is changed based on the Lead_Assignment__c object

*******************************************************************/
    public static void setAssignment (list<Lead> news, Map<Id,Lead> olds, boolean isUpdate) {
        
        for(Lead iLead: news) {
            if(String.isNotBlank(iLead.Region__c) && String.isNotBlank(iLead.postalcode)){
                if((isUpdate && (iLead.Region__c != olds.get(iLead.Id).Region__c || iLead.postalcode != olds.get(iLead.Id).postalcode))
                    || !isUpdate){
                    if(queuesMap.containsKey(iLead.postalcode + iLead.Region__c) &&
                        groupsMap.containsKey( queuesMap.get(iLead.postalcode + iLead.Region__c) )){
                        iLead.OwnerId = groupsMap.get( queuesMap.get(iLead.postalcode + iLead.Region__c) );
                    }

                }
            }
            
        }
         
    }


/******************************************************************
@name queuesMap
@author Jose Maldonado (jose.maldonado@empaua.com)
@date 27 Apr 2018
@param 
@return Map<String, String> queues based On ExternalId, Name
@description returns in static way the queues with the externalId and the queued setted to it in Lead_Assignment__c

*******************************************************************/
    public static Map<String, String> queuesMap {
        get{
            if(queuesMap == null){
                queuesMap = new Map<String, String>();
                for(Lead_Assignment__c assignment:[Select External_Id__c, Queue__c
                                                    From Lead_Assignment__c]){
                    queuesMap.put(assignment.External_Id__c, assignment.Queue__c);
                }
            }
            return queuesMap;
        }
        set;

    } 

//SELECT DeveloperName,Email,Id,Name,Type FROM Group

/******************************************************************
@name groupsMap
@author Jose Maldonado (jose.maldonado@empaua.com)
@date 27 Apr 2018
@param 
@return Map<String, String> queues based on DeveloperName, Id
@description returns in static way the groups of the leads queues

*******************************************************************/
    public static Map<String, String> groupsMap {
        get{
            if(groupsMap == null){
                groupsMap = new Map<String, String>();
                for(Group iGroup:[SELECT DeveloperName,Email,Id,Name,Type 
                                                    FROM Group
                                                    WHERE type = 'Queue']){
                    groupsMap.put(iGroup.DeveloperName, iGroup.Id);
                }
            }
            return groupsMap;
        }
        set;

    } 














}