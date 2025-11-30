public class CAMPX_SponsorTriggerHandler {
    
    public static void updateStatus(List<CAMPX__Sponsor__c> newList){
        for (CAMPX__Sponsor__c newRecord : newList) {
            if(newRecord.CAMPX__Status__c == null)
                newRecord.CAMPX__Status__c = 'Pending';
        }
    }
    
    public static void updateEventRevenue(List<CAMPX__Sponsor__c> newList, Map<Id, CAMPX__Sponsor__c> oldMap) {
        
        Set<Id> eventIdsToUpdate = new Set<Id>();
        Map<Id, Decimal> eventNetRevenueChangeMap = new Map<Id, Decimal>();

        for (CAMPX__Sponsor__c newSponsor : newList) {
            CAMPX__Sponsor__c oldSponsor = (Trigger.isUpdate) ? oldMap.get(newSponsor.Id) : null;

            Decimal contribution = (newSponsor.CAMPX__ContributionAmount__c != null) ? newSponsor.CAMPX__ContributionAmount__c : 0;

            if (Trigger.isUpdate && oldSponsor.CAMPX__Status__c == 'Accepted' && newSponsor.CAMPX__Status__c != 'Accepted') { 
                Id oldEventId = oldSponsor.CAMPX__Event__c;
                if (oldEventId != null) {
                    addRevenueChange(eventNetRevenueChangeMap, oldEventId, -contribution);
                    eventIdsToUpdate.add(oldEventId);
                }
            }
            if (Trigger.isUpdate && oldSponsor.CAMPX__Event__c != newSponsor.CAMPX__Event__c) {
                Id oldEventId = oldSponsor.CAMPX__Event__c;
                if (oldEventId != null && oldSponsor.CAMPX__Status__c == 'Accepted') {
                    addRevenueChange(eventNetRevenueChangeMap, oldEventId, -contribution);
                    eventIdsToUpdate.add(oldEventId);
                }
            }

            Boolean isNewlyAccepted = false;
            if (Trigger.isInsert) {
                if (newSponsor.CAMPX__Status__c == 'Accepted') {
                    isNewlyAccepted = true;
                }
            } else if (Trigger.isUpdate) {
                if (newSponsor.CAMPX__Status__c == 'Accepted' && oldSponsor.CAMPX__Status__c != 'Accepted') {
                    isNewlyAccepted = true;
                }
            }

            if (isNewlyAccepted && newSponsor.CAMPX__Event__c != null) {
                Id newEventId = newSponsor.CAMPX__Event__c;
                addRevenueChange(eventNetRevenueChangeMap, newEventId, contribution);
                eventIdsToUpdate.add(newEventId);
            }
        }
        if (eventIdsToUpdate.isEmpty()) {
            return;
        }
        List<CAMPX__Event__c> eventsToUpdate = [SELECT Id, CAMPX__GrossRevenue__c FROM CAMPX__Event__c WHERE Id IN :eventIdsToUpdate];
        
        for (CAMPX__Event__c event : eventsToUpdate) {
            Decimal netChange = eventNetRevenueChangeMap.get(event.Id);
            if (netChange != null) {
                Decimal currentRevenue = (event.CAMPX__GrossRevenue__c != null) ? event.CAMPX__GrossRevenue__c : 0;
                event.CAMPX__GrossRevenue__c = currentRevenue + netChange;
            }
        }
        update eventsToUpdate;
    }
    private static void addRevenueChange(Map<Id, Decimal> revenueMap, Id eventId, Decimal changeAmount) {
        Decimal currentTotal = revenueMap.get(eventId);
        if (currentTotal == null) {
            currentTotal = 0;
        }
        revenueMap.put(eventId, currentTotal + changeAmount);
    }
}