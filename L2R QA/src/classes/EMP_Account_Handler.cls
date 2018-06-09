/*
 * @Class : EMP_Account_Handler
 *
 * @Author     : Jorge Valdés <jorge.valdes@empaua.com>
 * @Created    : Apr 18, 2018
 * @Description: Handle all events on Account
 *
 */

public with sharing class EMP_Account_Handler {
	
	private static boolean runtrigger = true;
	
	
	/*
     * @Method          :   beforeInsert
     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
     * @Created         :   Apr 18, 2018
     * @Description     :   Handles the methods before insert the Account records
     * @Returns         :   Void
     * @param listNew 	:	New versions of the Account records
     */
	public static void beforeInsert(list<Account> listNew){
		//Update the list of Accounts with Industry Standard Object values
		updateAccountIndustryValue(listNew);	
	}
	
	
	/*
     * @Method          :   beforeUpdate
     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
     * @Created         :   Apr 18, 2018
     * @Description     :   Handles the methods before update the Account records
     * @Returns         :   Void
     * @param listNew 	:	New versions of the Account records
	 * @param mapOld 	:	A map of IDs to the old versions of the Account records
     */
     								
	public static void beforeUpdate(List<Account> listNew, Map<Id, Account> mapNew, List<Account> listOld, Map<Id, Account> mapOld){
		List<Account> toBeUpdated = new List<Account>();	//Account list to be update because their SIC code has changed
		
		for(Account iAccount : listNew){
			//Check if SIC code has changed
			if(String.isNotEmpty(iAccount.Sic) && !iAccount.Sic.equalsIgnoreCase(mapOld.get(iAccount.Id).Sic)){
				toBeUpdated.add(iAccount);
			//Check if Sic code is null or blank to delete de Account's Industry fields
			}else if(String.isBlank(iAccount.Sic)){
				iAccount.MD_SIC_Level_2__c = '';
				iAccount.SIC_Level_4__c = '';
				iAccount.Industry = null;
			}
		}
		//Update the list of Accounts with Industry Standard Object values
		updateAccountIndustryValue(toBeUpdated);	
	}
	
	/*
     * @Method          :   updateAccountIndustryValue
     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
     * @Created         :   Apr 18, 2018
     * @Description     :   Update a list of Accounts with Industry Standard Object values
     * @Returns         :   Void
     * @param news 		:	trigger.new
	 * @param olds 		:	trigger.new
	 * @param isupdate 	:	trigger.isupdate
     */
	public static void updateAccountIndustryValue(List<Account> accountList){
		Set<Decimal> sicList = new Set <Decimal>();	//Store all Sic codes
		List<Industry_Standardization__c> industryList = new List<Industry_Standardization__c>();	//Store all Industry Standard objects
		Map<Decimal, Industry_Standardization__c> industryMap = new Map<Decimal, Industry_Standardization__c>();
		Industry_Standardization__c industry = new Industry_Standardization__c();
		
		//Fill the Sic Code list
		for(Account iAccount : accountList){
			if(String.isNotEmpty(iAccount.Sic))
				sicList.add(Decimal.valueOf(iAccount.Sic));
		}
		
		//Fill the Industry Standard Object list
		industryList = [SELECT SIC4__c, SIC2_NAME__c, SIC4_NAME__c, CRM_Industry__c FROM Industry_Standardization__c WHERE SIC4__c IN :sicList];
		//Check if the Industry Standard Object list is not empty
		if(!industryList.isEmpty()){
			
			//Create a map with Sic code as Id and the Object as value
			for(Industry_Standardization__c iIndustry : industryList){
				industryMap.put(iIndustry.SIC4__c, iIndustry);
			}
			
			//Update each Account with the info from Industry Standard Object
			for(Account iAccount : accountList){
				if(String.isNotEmpty(iAccount.Sic) && (industryMap.get(Decimal.valueOf(iAccount.Sic)) != null)){
					industry = industryMap.get(Decimal.valueOf(iAccount.Sic));
					iAccount.MD_SIC_Level_2__c = industry.SIC2_NAME__c;
					iAccount.SIC_Level_4__c = industry.SIC4_NAME__c;
					iAccount.Industry = industry.CRM_Industry__c;
				}
			}
		}
	}
	
/******************************************************************
@name assignToAccountTeams
@author Jose Maldonado (jose.maldonado@empaua.com)
@date 09 May 2018
@param news trigger.new
@param olds trigger.oldmap
@param isupdate trigger.isupdate
@return Void
@description Assign Queue when the Region__c or ZipCode is changed based on the Lead_Assignment__c object

*******************************************************************/
    public static void assignToAccountTeams (list<Account> news, Map<Id,Account> olds, boolean isUpdate) {
		List<AccountTeamMember> membersToInsert = new List<AccountTeamMember>();        
		List<AccountTeamMember> membersToRemove = new List<AccountTeamMember>();

		Set<String> countries = new Set<String>();
		Set<String> idAccountsToClean = new Set<String>();
		Map<String, Set<Id>> accountsInCountry = new Map<String, Set<Id>>();

		//Prepare the data to search accounts
		for(Account iAccount:news){
			if(String.isNotBlank(iAccount.BillingCountry)){
				Boolean addUpdate = false;
				//check conditions for update
				if(isUpdate && (iAccount.BillingCountry != olds.get(iAccount.Id).BillingCountry)){
					addUpdate = true;
					idAccountsToClean.add(iAccount.Id);
				}
				//prepare data to creation
				if(!isUpdate || addUpdate){
System.debug('JRM -------    ' + iAccount);
System.debug('JRM -------    ' + iAccount.BillingCountry);
					countries.add(iAccount.BillingCountry);
					if(accountsInCountry.isEmpty() && !accountsInCountry.containsKey(iAccount.BillingCountry)){
						accountsInCountry.put(iAccount.BillingCountry, new Set<Id>());
					}
					accountsInCountry.get(iAccount.BillingCountry).add(iAccount.Id);
				}
			

			}
		}

		//get members to remove
		if(!idAccountsToClean.isEmpty()){
			membersToRemove = [Select Id From AccountTeamMember Where AccountId in :idAccountsToClean];
		}

		//generate new account team members
		if(!countries.isEmpty()){
			for(User iUser:[Select Id,Country
									From User
									Where Country in:countries]){
				if(accountsInCountry.containsKey(iUser.Country)){
					for(Id idAccount:accountsInCountry.get(iUser.Country)){
						membersToInsert.add(
								EMP_Helper.getMember(idAccount, iUser.Id, null)
							);
					}
				}
			}
		}

		if(!membersToRemove.isEmpty()){
			delete membersToRemove;
		}
		if(!membersToInsert.isEmpty()){
			insert membersToInsert;
		}


    }

    public EMP_Account_Handler() {
	}
	
    /*
     * @Method          :   shouldRunTrigger
     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
     * @Created         :   Apr 18, 2018
     * @Description     :   To get the flag that indicate if the trigger should run or not
     * @Returns         :   runtrigger attribute
     */     
    public  static  boolean shouldRunTrigger() {
        return runtrigger;
    }
    
    
    /*
     * @Method          :   dontRunTrigger
     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
     * @Created         :   Apr 18, 2018
     * @Description     :   To indicate that the trigger should not run
     */     
    public  static  void    dontRunTrigger() {
        runtrigger = false;
    }
    
    
    
}