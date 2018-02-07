public with sharing class createOpportunity {
	public static void createOpportunity(List<Id> prodIds, Id accountId) {
		
		Opportunity opp = new Opportunity();
		opp.Name =  'New opportunity from Wirtschaftsrechner';
		opp.AccountId = accountId;
		opp.StageName = 'New';
		opp.CloseDate = Date.today().addMonths(1);
		opp.PriceBook2Id = '01s24000003w2Gi';
		opp.CurrencyISOCode = 'EUR';

		insert opp;

		//price book entries must be created for each opportunity line item
		List<PricebookEntry> pbeList = new List<PricebookEntry>();
		Map<Id, Id> p2pbe = new Map<Id, Id>(); // the map will hold pairs of productId and respective pricebookentry ID, needed for creation of opportunity line items

		//identify pricebook entry based on product name
		List<PricebookEntry> pbeList2 = [SELECT Id, isActive, PriceBook2Id, Name, Product2Id FROM PriceBookEntry WHERE Pricebook2Id = '01s24000003w2Gi' AND Product2Id IN :prodIds ];

		for(PricebookEntry pbe : pbeList2) {
			p2pbe.put(pbe.product2Id, pbe.Id);
		}

		List<OpportunityLineItem> listProducts = new List<OpportunityLineItem>(); 
		//create opportunity line items from product IDs sent in the list parameter
		for(Id pId : prodIds) {
			OpportunityLineItem op = new OpportunityLineItem();
			op.OpportunityId = opp.Id;
			op.Quantity =  1;
			op.UnitPrice = 0;
			op.PriceBookEntryId = p2pbe.get(pId);

			listProducts.add(op);
		}
		System.debug(opp);
		System.debug(listProducts);
		insert listProducts;
	}
}