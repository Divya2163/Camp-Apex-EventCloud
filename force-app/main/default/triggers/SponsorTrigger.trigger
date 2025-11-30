trigger SponsorTrigger on CAMPX__Sponsor__c (before insert,before update) {
    
	if (Trigger.isBefore && Trigger.isInsert) {
        
        CAMPX_SponsorTriggerHandler.updateStatus(Trigger.new);
        
        for(CAMPX__Sponsor__c newRecord : Trigger.new){
            if(newRecord.CAMPX__ContributionAmount__c == null || newRecord.CAMPX__ContributionAmount__c <=0){
                newRecord.CAMPX__Tier__c = '';
            }
            else if(newRecord.CAMPX__ContributionAmount__c > 0 && newRecord.CAMPX__ContributionAmount__c < 1000){
                newRecord.CAMPX__Tier__c = 'Bronze';
            }
            else if(newRecord.CAMPX__ContributionAmount__c >= 1000 && newRecord.CAMPX__ContributionAmount__c < 5000){
                newRecord.CAMPX__Tier__c = 'Silver';
            }
            else if(newRecord.CAMPX__ContributionAmount__c >= 5000){
                newRecord.CAMPX__Tier__c = 'Gold';
            }
        }
    }
    if(Trigger.isAfter || Trigger.isBefore){
        CAMPX_SponsorTriggerHandler.updateEventRevenue(Trigger.new, Trigger.oldMap);
    }
}