/**
*   @Class : EMP_Test_Factory
*
*   @Author				:   Jorge Valdés <jorge.valdes@empaua.com>
*   @Created			:   Apr 18, 2018
*   @Description		:   Objects Factory for Tests purpose.
*
*/

@isTest
public class EMP_Test_Factory
{

    //Call constructor to create general records
    public static EMP_Test_Factory iTEST_Factory{
        get{
            if(iTEST_Factory == null){
            	iTEST_Factory = new EMP_Test_Factory();
            }
            return iTEST_Factory;
        }
        set;
    }

    //Create general records
	public EMP_Test_Factory() {
	}
	
    /*
     * @Author          :   JOsé Ramón Maldonado <jose.maldonado@empaua.com>
     * @Created         :   21 Oct 2016
     * @Description     :   External Id for GEO_Invoiced_Consumption__c: Integer format
     */
    public static Integer autonumber {
        get{
            if (autonumber == null){
                autonumber = 0;
            }

            autonumber++;
            return autonumber;
        }
        set;
    }


    /*
     * @Author          :   JOsé Ramón Maldonado <jose.maldonado@empaua.com>
     * @Created         :   21 Oct 2016
     * @Description     :   External Id for GEO_Invoiced_Consumption__c: String format
     */
    public static String autonumber_String {
        get{
            return String.valueOf(autonumber);
        }
    }

    /*
     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
     * @Created			:   Apr 18, 2018
     * @Description     :	Instance for Generic Account sObject
     */
    public static Account iAccount{
        get{
            if(iAccount == null){
                iAccount = getAccount('Test Account');
                insert iAccount;
                System.assert(iAccount.Id != null);
            }
            return iAccount;
        }
        set;
    }
    
    /*
     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
     * @Created         :   Apr 18, 2018
     * @Description     :   Create Account
     */
    public static Account getAccount(String name){
        System.assertNotEquals(null, iTEST_Factory);

        Account objStructure = new Account();
        objStructure.Name = name;
        return objStructure;
    } 
    
    
    /*
     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
     * @Created			:   Apr 18, 2018
     * @Description     :	Instance for Generic Industry Standardization sObject
     */
    public static Industry_Standardization__c iIndustry{
        get{
            if(iIndustry == null){
                iIndustry = getIndustry(8263);
                insert iIndustry;
                System.assert(iIndustry.DB_SIC__c != null);
            }
            return iIndustry;
        }
        set;
    }
    
    /*
     * @Author          :   Jorge Valdés <jorge.valdes@empaua.com>
     * @Created         :   Apr 18, 2018
     * @Description     :   Create Industry
     */
    public static Industry_Standardization__c getIndustry(Decimal sic){
        System.assertNotEquals(null, iTEST_Factory);

        Industry_Standardization__c objStructure = new Industry_Standardization__c();
        objStructure.SIC4__c = sic;
        return objStructure;
    }

    /*
     * @Author          :   JOse Maldonado <jose.maldonado@empaua.com>
     * @Created         :   Apr 27, 2018
     * @Description     :   Create Group
     */
    public static Group getGroup(){
        System.assertNotEquals(null, iTEST_Factory);
        // Create group       
        Group objStructure = new Group ();
        objStructure.Name = 'TestQueue' + autonumber_String;
        objStructure.DeveloperName = 'TestQueue' + autonumber_String;
        objStructure.Type = 'Queue';

        return objStructure;
    } 

    /*
     * @Author          :   JOse Maldonado <jose.maldonado@empaua.com>
     * @Created         :   Apr 27, 2018
     * @Description     :   Instance a Group
     */
    public static Group iGroup{
        get{
            if(iGroup == null){
                iGroup = getGroup();
                insert iGroup;
                System.assert(iGroup.Id != null);

            }
            return iGroup;
        }
        set;
    }

    /*
     * @Author          :   JOse Maldonado <jose.maldonado@empaua.com>
     * @Created         :   Apr 27, 2018
     * @Description     :   Create Group
     */
    public static QueueSObject getLeadQueue(String idGroup){
        System.assertNotEquals(null, iTEST_Factory);

        // Create queue       
        QueueSObject objStructure = new QueueSObject();
        objStructure.QueueId = idGroup;
        objStructure.SObjectType = 'Lead';

        return objStructure;
    } 


    /*
     * @Author          :   JOse Maldonado <jose.maldonado@empaua.com>
     * @Created         :   Apr 27, 2018
     * @Description     :   Create Group
     */
    public static Lead_Assignment__c getLead_Assignment(){
        System.assertNotEquals(null, iTEST_Factory);

        // Create queue       
        Lead_Assignment__c objStructure = new Lead_Assignment__c();
        objStructure.Queue__c = iGroup.DeveloperName;
        objStructure.Region__c = 'Region' + autonumber_String;
        objStructure.ZipCode__c = 'ZipCode' + autonumber_String;

        return objStructure;
    } 

    /*
     * @Author          :   JOse Maldonado <jose.maldonado@empaua.com>
     * @Created         :   Apr 27, 2018
     * @Description     :   Instance a Group
     */
    public static Lead_Assignment__c iLead_Assignment{
        get{
            if(iLead_Assignment == null){
                iLead_Assignment = getLead_Assignment();
                insert iLead_Assignment;
                System.assert(iLead_Assignment.Id != null);
            }
            return iLead_Assignment;
        }
        set;
    }

    /*
     * @Author          :   JOse Maldonado <jose.maldonado@empaua.com>
     * @Created         :   Apr 27, 2018
     * @Description     :   Create Group
     */
    public static Lead getLead(){
        System.assertNotEquals(null, iTEST_Factory);

        // Create queue       
        Lead objStructure = new Lead();
        objStructure.FirstName = 'Name';
        objStructure.LastName = 'LastName';
        objStructure.Company = 'Company';

        return objStructure;
    } 

    /*
     * @Author          :   JOse Maldonado <jose.maldonado@empaua.com>
     * @Created         :   Apr 27, 2018
     * @Description     :   Instance a Group
     */
    public static Lead iLead{
        get{
            if(iLead == null){
                iLead = getLead();
                insert iLead;
                System.assert(iLead.Id != null);
            }
            return iLead;
        }
        set;
    }
}