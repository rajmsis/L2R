/**************************************************************************************

@author Javier Sanz	(javier.sanz@empaua.com)
@date 11 Apr 2018
@group	Empaua
@description Contaisn all the methods used on  the Opportinuty trigger: Opportunity_Trigger
 

------------------------------------------------------------------------------
* Developer         Date            Description
Javier Sanz			11/04/2018		Creation
Javier Sanz			11/04/2018		added createWaterfallHistory method
-------------------------------------------------

*/
public with sharing class EMP_Opportunity_Handler {
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
    public static void createWaterfallHistory (list<Opportunity> news, list<Opportunity> olds, boolean isUpdate) {
    	
    	list<Waterfall_History__c> List_WatterfallHistorytoInsert = New list<Waterfall_History__c>();
    	
    	for (integer i = 0; i < news.size(); i++) {
    		
    		if (!isUpdate) {
    			
    			List_WatterfallHistorytoInsert.add(new Waterfall_History__c(
    													Opportunity__c = news[i].id,
    													New_Opportunity_stage__c = news[i].StageName, 
    													Lead__c = news[i].Lead_Id__c,
    													New_lead_status__c = label.Lead_Qualified,
    													Previous_Lead_Status__c =label.Lead_Qualified ,
    													Opportunity_Circle_of_Influence_duration__c = news[i].Circle_of_Influence_Duration__c,
														Opportunity_Circle_of_Influence_date__c = news[i].Circle_of_Influence_Date__c,
														Opportunity_Closed_Lost_date__c = news[i].Closed_Lost_Date__c,
														Opportunity_Closed_Lost_duration__c = news[i].Closed_Lost_Duration__c,
														Opportunity_Closed_Won_date__c = news[i].Closed_Won_Date__c,
														Opportunity_Closed_Won_duration__c = news[i].Closed_Won_Duration__c,
														Opportunity_Close_Execution_date__c = news[i].Close_Execution_Date__c,
														Opportunity_Close_Execution_duration__c = news[i].Close_Execution_Duration__c,
														Opportunity_Contract_Negotiation_date__c = news[i].Contract_Negotiation_Date__c,
														Opportunity_Contract_Negotiatio_duration__c = news[i].Contract_Negotiation_Duration__c,
														Opportunity_Customer_Commitment_date__c = news[i].Customer_Commitment_Date__c,
														Opportunity_Customer_Commitment_duration__c = news[i].Customer_Commitment_Duration__c,
														Opportunity_Planning_date__c = news[i].Planning_Date__c,
														Opportunity_Planning_duration__c = news[i].Planning_Duration__c,
														Opportunity_Prospecting_date__c = news[i].Prospecting_Date__c,
														Opportunity_Prospecting_duration__c = news[i].Prospecting_Duration__c,
														Opportunity_Qualification_date__c = news[i].Qualification_Date__c,
														Opportunity_Qualification_duration__c = news[i].Qualification_Duration__c,
														Opportunity_Solution_Decision_date__c = news[i].Solution_Decision_Date__c,
														Opportunity_Solution_Decision_duration__c = news[i].Solution_Decision_Duration__c,
														new_Opportunity_Owner__c = news[i].ownerid
    															));
    		} else if(olds[i].StageName != news[i].StageName) {
    			
				List_WatterfallHistorytoInsert.add(new Waterfall_History__c(
														Opportunity__c = news[i].id,
														New_Opportunity_stage__c = news[i].StageName, 
														Previous_Opportunity_Stage__c = olds[i].stagename, 
														Lead__c = news[i].Lead_Id__c,
														New_lead_status__c = label.Lead_Qualified,
														Previous_Lead_Status__c = label.Lead_Qualified,
														Opportunity_Circle_of_Influence_duration__c = news[i].Circle_of_Influence_Duration__c,
														Opportunity_Circle_of_Influence_date__c = news[i].Circle_of_Influence_Date__c,
														Opportunity_Closed_Lost_date__c = news[i].Closed_Lost_Date__c,
														Opportunity_Closed_Lost_duration__c = news[i].Closed_Lost_Duration__c,
														Opportunity_Closed_Won_date__c = news[i].Closed_Won_Date__c,
														Opportunity_Closed_Won_duration__c = news[i].Closed_Won_Duration__c,
														Opportunity_Close_Execution_date__c = news[i].Close_Execution_Date__c,
														Opportunity_Close_Execution_duration__c = news[i].Close_Execution_Duration__c,
														Opportunity_Contract_Negotiation_date__c = news[i].Contract_Negotiation_Date__c,
														Opportunity_Contract_Negotiatio_duration__c = news[i].Contract_Negotiation_Duration__c,
														Opportunity_Customer_Commitment_date__c = news[i].Customer_Commitment_Date__c,
														Opportunity_Customer_Commitment_duration__c = news[i].Customer_Commitment_Duration__c,
														Opportunity_Planning_date__c = news[i].Planning_Date__c,
														Opportunity_Planning_duration__c = news[i].Planning_Duration__c,
														Opportunity_Prospecting_date__c = news[i].Prospecting_Date__c,
														Opportunity_Prospecting_duration__c = news[i].Prospecting_Duration__c,
														Opportunity_Qualification_date__c = news[i].Qualification_Date__c,
														Opportunity_Qualification_duration__c = news[i].Qualification_Duration__c,
														Opportunity_Solution_Decision_date__c = news[i].Solution_Decision_Date__c,
														Opportunity_Solution_Decision_duration__c = news[i].Solution_Decision_Duration__c,
														Previous_Opportunity_Owner__c = olds[i].ownerid,
														new_Opportunity_Owner__c = news[i].ownerid
																
														));
    														 	
    		}
    	}
    	
    	if (!List_WatterfallHistorytoInsert.isEmpty()) {
    		insert List_WatterfallHistorytoInsert;
    	}
    	
    }
    
}