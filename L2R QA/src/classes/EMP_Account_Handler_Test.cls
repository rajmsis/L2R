/*
 * @Class : EMP_Account_Handler_Test
 *
 * @Author     : Jorge Valdés <jorge.valdes@empaua.com>
 * @Created    : Apr 18, 2018
 * @Description: This class contains unit tests for validating the behavior of Account_Handler
 *
 */
 
@isTest
private class EMP_Account_Handler_Test {
    
    static testMethod void accountHandlerTest() {
        
        //Creating 3 Industries for testing
        Industry_Standardization__c industry_1 = EMP_Test_Factory.getIndustry(1000);
        industry_1.SIC2_NAME__c = 'Ag Production-Crop';
        industry_1.SIC4_NAME__c = 'Soybeans';
        //industry_1.CRM_Industry__c = 'Real Estate';
        insert industry_1;
        Industry_Standardization__c industry_2 = EMP_Test_Factory.getIndustry(2000);
        industry_2.SIC2_NAME__c = 'Educational Services';
        industry_2.SIC4_NAME__c = 'Junior Colleges and Technical Institutes';
        //industry_2.CRM_Industry__c = 'Insurance';
        insert industry_2;
        Industry_Standardization__c industry_3 = EMP_Test_Factory.getIndustry(3000);
        industry_3.SIC2_NAME__c = 'Communication';
        industry_3.SIC4_NAME__c = 'Television Broadcasting Stations';
        //industry_3.CRM_Industry__c = 'Retail';
        insert industry_3;
        
        //Creating 3 Accounts for testing
        Account account_1 = EMP_Test_Factory.getAccount('Test 1');
        account_1.Sic = '1000';
        Account account_2 = EMP_Test_Factory.getAccount('Test 2');
        account_2.Sic = '3000';
        Account account_3 = EMP_Test_Factory.getAccount('Test 3');
        account_3.Sic = '';
        
        //Creating the Account list for Bulkify test
        List<Account> newAccountList = new List<Account>();
        newAccountList.add(account_1);
        newAccountList.add(account_2);
        newAccountList.add(account_3);
        //Inserting all created accounts
        insert newAccountList;
        
        /*
         * @Test			:	Account 1 Before Insert Trigger
	     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
	     * @Created         :   Apr 18, 2018
	     * @Description     :   The trigger should set into account_1.SIC_Level_2__c the value: 'Ag Production-Crop'
	     */
        account_1 = [SELECT MD_SIC_Level_2__c FROM Account WHERE Id = :account_1.Id ];
        System.assertEquals('Ag Production-Crop', account_1.MD_SIC_Level_2__c);
        
        /*
         * @Test			:	Account 2 Before Insert Trigger
	     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
	     * @Created         :   Apr 18, 2018
	     * @Description     :   The trigger should set into account_2.MD_SIC_Level_2__c the value: 'Communication'
	     */
        account_2 = [SELECT MD_SIC_Level_2__c FROM Account WHERE Id = :account_2.Id ];
        System.assertEquals('Communication', account_2.MD_SIC_Level_2__c);
        
        /*
         * @Test			:	Account 3 Before Insert Trigger
	     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
	     * @Created         :   Apr 18, 2018
	     * @Description     :   The trigger should not insert anything into account_3 because this account does not have a Sic code
	     */
        account_3 = [SELECT MD_SIC_Level_2__c FROM Account WHERE Id = :account_3.Id ];
        System.assertEquals(null, account_3.MD_SIC_Level_2__c);
        
        
        //Creating the Account list for Update Trigger test
        List<Account> updateAccountList = new List<Account>();
        account_1.Sic = '';
        updateAccountList.add(account_1);
        account_2.MD_Accounting_Email__c = 'testing@sitecore.com';
        updateAccountList.add(account_2);
        account_3.Sic = '2000';
        updateAccountList.add(account_3);
        //Updating all created accounts
        update updateAccountList; 
        
         /*
         * @Test			:	Account 1 Before Update Trigger
	     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
	     * @Created         :   Apr 18, 2018
	     * @Description     :   The trigger should left account_1.SIC_Level_2__c as blank because now the Account have not a Sic code
	     */
        account_1 = [SELECT MD_SIC_Level_2__c FROM Account WHERE Id = :account_1.Id ];
        System.assertEquals(null, account_1.MD_SIC_Level_2__c);
        
        /*
         * @Test			:	Account 2 Before Update Trigger
	     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
	     * @Created         :   Apr 18, 2018
	     * @Description     :   The trigger should not change anything from the Account's Industry fields as the Sic code did not change.
	     *						In the field account_2.MD_SIC_Level_2__c should be the value: 'Communication'
	     */
        account_2 = [SELECT MD_SIC_Level_2__c FROM Account WHERE Id = :account_2.Id ];
        System.assertEquals('Communication', account_2.MD_SIC_Level_2__c);
        
        /*
         * @Test			:	Account 3 Before Update Trigger
	     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
	     * @Created         :   Apr 18, 2018
	     * @Description     :   The trigger should set into account_1.MD_SIC_Level_2__c the value: 'Educational Services'
	     */
        account_3 = [SELECT MD_SIC_Level_2__c FROM Account WHERE Id = :account_3.Id ];
        System.assertEquals('Educational Services', account_3.MD_SIC_Level_2__c);
    }
    
    
}