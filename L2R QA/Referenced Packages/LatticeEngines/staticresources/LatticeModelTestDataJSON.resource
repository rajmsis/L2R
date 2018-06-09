{
	"modelStages": [{
		"~~NS~~Type__c":"Account",
		"~~NS~~LatticeModelID__c":"1-TEST",
        "~~NS~~Status__c":"Active",
		"~~NS~~ModelName__c":"Account Model #1",
        "~~NS~~ValidationExpression__c":"",
		"~~NS~~LatticeModelFieldMappingStages__r": {
			"totalSize" : 4,
    		"done" : true,
    		"records" : [ {
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_CompanyName",
                "~~NS~~APIDisplayName__c": "CompanyName",
                "~~NS~~APIIsPrimary__c": true
    		},
    		{
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_Website",
                "~~NS~~APIDisplayName__c": "Website",
                "~~NS~~APIIsPrimary__c": true
    		},
            {
                "~~NS~~APIDataType__c": "FLOAT",
                "~~NS~~APIName__c": "TEST_NrOfEmployees",
                "~~NS~~APIDisplayName__c": "NrOfEmployees",
                "~~NS~~APIIsPrimary__c": false
            },
            {
                "~~NS~~APIDataType__c": "STRING",
                "~~NS~~APIName__c": "TEST_Id",
                "~~NS~~APIDisplayName__c": "Id",
                "~~NS~~APIIsPrimary__c": true
            }]
    	}
	},
	{
		"~~NS~~Type__c":"Account",
		"~~NS~~LatticeModelID__c":"2-TEST",
		"~~NS~~ModelName__c":"Account Model #2",
        "~~NS~~ValidationExpression__c":"",
        "~~NS~~Status__c":"Active",
		"~~NS~~LatticeModelFieldMappingStages__r": {
			"totalSize" : 4,
    		"done" : true,
    		"records" : [ {
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_CompanyName",
                "~~NS~~APIDisplayName__c": "CompanyName",
                "~~NS~~APIIsPrimary__c": true
    		},
    		{
    			"~~NS~~APIDataType__c": "STRING",
                "~~NS~~APIName__c": "TEST_Website",
                "~~NS~~APIDisplayName__c": "Website",
                "~~NS~~APIIsPrimary__c": true
    		},
            {
                "~~NS~~APIDataType__c": "FLOAT",
                "~~NS~~APIName__c": "TEST_NrOfEmployees",
                "~~NS~~APIDisplayName__c": "NrOfEmployees",
                "~~NS~~APIIsPrimary__c": false
            },
            {
                "~~NS~~APIDataType__c": "STRING",
                "~~NS~~APIName__c": "TEST_Id",
                "~~NS~~APIDisplayName__c": "Id",
                "~~NS~~APIIsPrimary__c": true
            }]
    	}
	},
	{
		"~~NS~~Type__c":"Contact",
		"~~NS~~LatticeModelID__c":"3-TEST",
        "~~NS~~Status__c":"Active",
		"~~NS~~ModelName__c":"Contact/Lead Model #1",
        "~~NS~~ValidationExpression__c":"",
		"~~NS~~LatticeModelFieldMappingStages__r": {
			"totalSize" : 5,
    		"done" : true,
    		"records" : [ {
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_FirstName",
                "~~NS~~APIDisplayName__c": "FirstName",
                "~~NS~~APIIsPrimary__c": false
    		},
    		{
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_LastName",
                "~~NS~~APIDisplayName__c": "LastName",
                "~~NS~~APIIsPrimary__c": false
    		},
    		{
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_PhoneNumber",
                "~~NS~~APIDisplayName__c": "Phone",
                "~~NS~~APIIsPrimary__c": true
    		},
    		{
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_Email",
                "~~NS~~APIDisplayName__c": "Email",
                "~~NS~~APIIsPrimary__c": true
    		},
            {
                "~~NS~~APIDataType__c": "STRING",
                "~~NS~~APIName__c": "TEST_Id",
                "~~NS~~APIDisplayName__c": "Id",
                "~~NS~~APIIsPrimary__c": true
            }]
    	}
	},
	{
		"~~NS~~Type__c":"Contact",
		"~~NS~~LatticeModelID__c":"4-TEST",
        "~~NS~~Status__c":"Active",
		"~~NS~~ModelName__c":"Contact/Lead Model #2",
        "~~NS~~ValidationExpression__c":"",
		"~~NS~~LatticeModelFieldMappingStages__r": {
			"totalSize" : 5,
    		"done" : true,
    		"records" : [ {
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_FirstName",
                "~~NS~~APIDisplayName__c": "FirstName",
                "~~NS~~APIIsPrimary__c": false
    		},
    		{
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_LastName",
                "~~NS~~APIDisplayName__c": "LastName",
                "~~NS~~APIIsPrimary__c": false
    		},
    		{
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_PhoneNumber",
                "~~NS~~APIDisplayName__c": "PhoneNumber",
                "~~NS~~APIIsPrimary__c": true
    		},
    		{
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_Email",
                "~~NS~~APIDisplayName__c": "Email",
                "~~NS~~APIIsPrimary__c": true
    		},
            {
                "~~NS~~APIDataType__c": "STRING",
                "~~NS~~APIName__c": "TEST_Id",
                "~~NS~~APIDisplayName__c": "Id",
                "~~NS~~APIIsPrimary__c": true
            }]
    	}
	},
	{
		"~~NS~~Type__c":"Contact",
        "~~NS~~Status__c":"Active",
		"~~NS~~LatticeModelID__c":"5-TEST",
		"~~NS~~ModelName__c":"Contact/Lead Model #3",
        "~~NS~~ValidationExpression__c":"",
		"~~NS~~LatticeModelFieldMappingStages__r": {
			"totalSize" : 5,
    		"done" : true,
    		"records" : [ {
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_FirstName",
                "~~NS~~APIDisplayName__c": "FirstName",
                "~~NS~~APIIsPrimary__c": false
    		},
    		{
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_LastName",
                "~~NS~~APIDisplayName__c": "LastName",
                "~~NS~~APIIsPrimary__c": false
    		},
    		{
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_PhoneNumber",
                "~~NS~~APIDisplayName__c": "PhoneNumber",
                "~~NS~~APIIsPrimary__c": true
    		},
    		{
    			"~~NS~~APIDataType__c": "STRING",
				"~~NS~~APIName__c": "TEST_Email",
                "~~NS~~APIDisplayName__c": "Email",
                "~~NS~~APIIsPrimary__c": true
    		},
            {
                "~~NS~~APIDataType__c": "STRING",
                "~~NS~~APIName__c": "TEST_Id",
                "~~NS~~APIDisplayName__c": "Id",
                "~~NS~~APIIsPrimary__c": true
            }]
    	}
	}]
}