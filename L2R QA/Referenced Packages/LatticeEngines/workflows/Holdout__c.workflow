<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_HoldoutGroupAccountID</fullName>
        <field>HoldoutGroupAccount__c</field>
        <formula>Account__c &amp; &quot;~&quot; &amp; IF( Account__c != null, Account__c,  LEAccount__c )</formula>
        <name>Populate HoldoutGroupAccountID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Populate HoldoutGroupAccountID%5F%5Fc</fullName>
        <actions>
            <name>Populate_HoldoutGroupAccountID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
