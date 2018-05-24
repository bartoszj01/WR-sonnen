@RestResource(urlMapping='/createOpp')
global without sharing class createOpportunityEndpoint {

	@HttpPost
	global static Opportunity createOpportunityEndpoint() {

		RestRequest req =  RestContext.request;
		RestResponse res = RestContext.response;

		String jsonInput = req.requestBody.toString();
		System.debug(jsonInput);
		//deserialize body to the wrapper object
		OppWrapper opp = (OppWrapper) JSON.deserialize(jsonInput, OppWrapper.class);

		//query custom metadata WRSetting to find info for opportunity
		WrSettings__mdt wr = [SELECT OpportunityName__c, OpportunityRecordSource__c, OpportunityStage__c, CloseDateFormula__c FROM WrSettings__mdt WHERE MasterLabel = 'WRApi' LIMIT 1];

		Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Direct Sales'].Id;

		Opportunity opt = new Opportunity();
		if(opp.opportunityId != null && opp.opportunityId != '') {
			opt = [SELECT Id, AccountId, ProposedSBC__c, Name, StageName, CloseDate, RecordSource__c, PowerPvPlant__c, EnergyConsumption__c, RoofOrientation__c, 
								GeneratorsOutput__c FROM Opportunity WHERE Id = :opp.opportunityId];
		}
		
		opt.AccountId = (Id) opp.accountId;
		opt.ProposedSBC__c = (Id) opp.partnerId;
		opt.Name = wr.OpportunityName__c;
		opt.RecordTypeId = recordTypeId;
		opt.StageName = wr.OpportunityStage__c;
		opt.CloseDate = Date.today().addMonths(2);
		opt.RecordSource__c = wr.OpportunityRecordSource__c;
		opt.PowerPvPlant__c = (String) opp.powerPvPlant;
		opt.EnergyConsumption__c = (Decimal) opp.energyConsumption;
		opt.RoofOrientation__c = (String) opp.roofOrientation;
		opt.GeneratorsOutput__c = (Decimal) opp.generatorsOutput;

		try{
			upsert opt;
		}
		catch(Exception e) {
			System.debug(e);
		}

		System.debug(opt);

		List<OpportunityLineItem> listItems = new List<OpportunityLineItem>();
		List<PriceBookEntry> pbeList = (List<PriceBookEntry>) opp.pbeIds;
		System.debug('pbeList: '+pbeList);
		// if opporutnity is an update and product entries are passed, delete existing opportunity products and create new ones
		if(pbeList != null && opp.opportunityId != null && opp.opportunityId != ''){
			List<OpportunityLineItem> oppProds = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:opp.opportunityId];
			delete oppProds;
		}

		if(pbeList != null) {
			for(PriceBookEntry i : pbeList) {
				OpportunityLineItem oil = new OpportunityLineItem();
				oil.OpportunityId = opt.Id;
				oil.PricebookEntryId = i.Id;
				oil.Quantity = 1;
				oil.UnitPrice = i.UnitPrice;
				listItems.add(oil);
			}			
		}

		insert listItems;
		return opt;
	}	

	global class OppWrapper {
		String opportunityId;
		String accountId;
		String partnerId;
		Decimal energyConsumption;
		String powerPvPlant;
		String roofOrientation;
		Decimal generatorsOutput;
		List<PriceBookEntry> pbeIds;	
	}
}