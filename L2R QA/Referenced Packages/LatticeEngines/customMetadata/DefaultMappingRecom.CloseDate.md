<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Close Date Field</label>
    <protected>false</protected>
    <values>
        <field>DefaultValue__c</field>
        <value xsi:type="xsd:string">Today+30</value>
    </values>
    <values>
        <field>IsRequired__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>SourceFieldName__c</field>
        <value xsi:type="xsd:string">DEFVAL</value>
    </values>
    <values>
        <field>SourceObject__c</field>
        <value xsi:type="xsd:string">Recommendation__c</value>
    </values>
    <values>
        <field>TargetFieldName__c</field>
        <value xsi:type="xsd:string">CloseDate</value>
    </values>
    <values>
        <field>TargetObject__c</field>
        <value xsi:type="xsd:string">Opportunity</value>
    </values>
</CustomMetadata>
