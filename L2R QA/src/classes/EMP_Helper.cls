/**************************************************************************************

@author Jose Maldonado	(jose@empaua.com)
@date 09 May 2018
@group	Empaua
@description Class with methods that give support to funcionality in other classes


------------------------------------------------------------------------------
* Developer         Date            Description
Jose Maldoando		09/05/2018		Creation
-------------------------------------------------

*/

public with sharing class EMP_Helper {

	private Final Static String CONSTROLE = 'Sales Rep';
	/******************************************************************
	@name getMember
	@author Jose Maldonado (jose.maldonado@empaua.com)
	@date 09 May 2018
	@param id of the Account
	@param id of the user
	@param role in the account team
	@return AccountTeamMember
	@description create new AccountTeamMember

	*******************************************************************/
	public static AccountTeamMember getMember(Id idAccount, Id idUser, String role){
		AccountTeamMember ret = new AccountTeamMember(AccountId = idAccount, 
													  TeamMemberRole = (role!= null?role:CONSTROLE), 
													  UserId= idUser);

		return ret;
	}


}