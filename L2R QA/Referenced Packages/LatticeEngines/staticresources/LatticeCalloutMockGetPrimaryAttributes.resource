{
  "primaryFields": [
    {
      "fieldName": "Id",
      "fieldType": "STRING",
      "displayName": "Id"
    },
    {
      "fieldName": "Email",
      "fieldType": "STRING",
      "displayName": "Email"
    },
    {
      "fieldName": "City",
      "fieldType": "STRING",
      "displayName": "City"
    },
    {
      "fieldName": "State",
      "fieldType": "STRING",
      "displayName": "State"
    },
    {
      "fieldName": "PostalCode",
      "fieldType": "STRING",
      "displayName": "PostalCode"
    },
    {
      "fieldName": "Country",
      "fieldType": "STRING",
      "displayName": "Country"
    },
    {
      "fieldName": "PhoneNumber",
      "fieldType": "STRING",
      "displayName": "PhoneNumber"
    },
    {
      "fieldName": "Website",
      "fieldType": "STRING",
      "displayName": "Website"
    },
    {
      "fieldName": "CompanyName",
      "fieldType": "STRING",
      "displayName": "CompanyName"
    },
    {
      "fieldName": "DUNS",
      "fieldType": "STRING",
      "displayName": null
    }
  ],
  "validationExpression": {
    "expression": "( Email || Website ) && Id "
  }
}