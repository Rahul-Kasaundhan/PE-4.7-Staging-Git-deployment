/*
 Controller Class for ViewRelatedAssociations comp. 
 Get's all the realetd assocation details for task in Phase3 CR by Akash(28-11-2019).
*/
public class ViewRelatedAssociationsCtrl{
    @AuraEnabled
    public static List<RelAssociationWrapper> getRelatedAssociations( String[] taskId){
         // get list of RelatedId for bug fixing (00028217)
         List<RelAssociationWrapper> nodeList = new List<RelAssociationWrapper>();
         taskId.remove(0);
         Set<String> setRelatedAssociations = new Set<String>(taskId);
        
        //Call dynamic method to get object id to sobject map
        Map<Id, Sobject> mapIdToSobject = sdgNamespaceUtility2.populateObjectToSobjectMap(setRelatedAssociations);
        
        Map<String,String> mapObjectToIcon = new map<String,String>();
        List<String> objectNameList = new List<String>();
        for(sobject sobj : mapIdToSobject.values()){
            String sobjectname = sobj.getSObjectType().getDescribe().getName()+'';
            objectNameList.add(sobjectname);
        }
        mapObjectToIcon = getIconName(objectNameList);
        //Iterate valuest to get sobject details
        for(sobject sobj : mapIdToSobject.values()){
            String sobjectname = sobj.getSObjectType().getDescribe().getName()+'';
            nodeList.add(new RelAssociationWrapper(String.valueOf(sobj.get('id')), String.valueOf(sobj.get('name')), mapObjectToIcon.get(sobjectname)));
        }
        return nodeList;
    }
    
    @AuraEnabled
    public static Map<String,String> getIconName(List<String> sObjectName){
        Set<String> setSobjectName = new Set<String>(sObjectName);
        Map<String,String> mapSobjectToIconName = new Map<String,String>();
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        Map<String,List<Schema.DescribeIconResult>> iconDesc = new Map<string,List<Schema.DescribeIconResult>>();
        
        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { 
            tabDesc.addAll(tsr.getTabs()); 
        }
        
        for(Schema.DescribeTabResult tr : tabDesc) {
            if( setSobjectName.contains(tr.getSobjectName())) {
                if( tr.isCustom() == true ) {
                    iconDesc.put(tr.getSobjectName(),tr.getIcons());
                } else {
                    mapSobjectToIconName.put(tr.getSobjectName(),'standard:' + tr.getSobjectName().toLowerCase());
                }
            }
        }
        for(String objectName : iconDesc.keySet()){
            for (Schema.DescribeIconResult ir : iconDesc.get(objectName)) {
                if (ir.getContentType() == 'image/svg+xml'){
                    mapSobjectToIconName.put(objectName,'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_'));
                    break;
                }
            }
        }
        return mapSobjectToIconName;
    }
    
    public class RelAssociationWrapper{
        @AuraEnabled public String recId;
        @AuraEnabled public String recName;
        @AuraEnabled public String objIcon;
     
        
        public RelAssociationWrapper(String recId, String recName, String objIcon ){
            this.recId = recId;
            this.recName = recName;
            this.objIcon = objIcon;
         
        }
    }
    
}