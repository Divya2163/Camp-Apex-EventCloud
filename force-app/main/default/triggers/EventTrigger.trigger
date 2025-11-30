trigger EventTrigger on CAMPX__Event__c (before insert, before update) {
	if (Trigger.isBefore && Trigger.isInsert) {
        for (CAMPX__Event__c newRecord : Trigger.new) {
            newRecord.CAMPX__Status__c = 'Planning';
            newRecord.CAMPX__StatusChangeDate__c = System.now();
            if(newRecord.CAMPX__GrossRevenue__c != null && newRecord.CAMPX__TotalExpenses__c !=null){
                newRecord.CAMPX__NetRevenue__c = newRecord.CAMPX__GrossRevenue__c - newRecord.CAMPX__TotalExpenses__c;
            }
        }  
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        for (CAMPX__Event__c newRecord : Trigger.new) {
            CAMPX__Event__c oldEvent = Trigger.oldMap.get(newRecord.Id);
            
            if(oldEvent.CAMPX__Status__c != newRecord.CAMPX__Status__c){
                newRecord.CAMPX__StatusChangeDate__c = System.now();
            }
            if(newRecord.CAMPX__GrossRevenue__c != null && newRecord.CAMPX__TotalExpenses__c !=null){
                newRecord.CAMPX__NetRevenue__c = newRecord.CAMPX__GrossRevenue__c - newRecord.CAMPX__TotalExpenses__c;
            }
        }
    }
}