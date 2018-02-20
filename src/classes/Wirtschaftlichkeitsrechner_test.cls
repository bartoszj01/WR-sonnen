@isTest
private class Wirtschaftlichkeitsrechner_test {
	
	@testSetup static void createData() {

		
		List<Account> accounts = new List<Account>();
		List<Contact> contacts = new List<Contact>();
/*
		Account customer = new Account();
		customer.Name = 'Customer account';
		customer.RecordTypeId = [SELECT Id FROM RecordType WHERE Name LIKE 'Business Customer' AND sObjectType = 'Account' LIMIT 1].Id;
		//customer.PrimaryContact__c = null;
		//customer.IsPersonAccount = false;
		accounts.add(customer);

		Account partner = new Account();
		partner.Name = 'Partner account';
		partner.RecordTypeId = [SELECT Id FROM RecordType WHERE Name LIKE 'Partner' AND sObjectType = 'Account' LIMIT 1].Id;
		//partner.PrimaryContact__c = null;
		//partner.IsPersonAccount = false; 
		accounts.add(partner);
		insert accounts;

		Contact c1 = new Contact();
		c1.LastName = 'Customer';
		c1.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Standard' AND sObjectType = 'Contact' LIMIT 1].Id;
		c1.AccountId = customer.Id;
		contacts.add(c1);

		Contact c2 = new Contact();
		c2.LastName = 'Partner';
		c2.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Technician' AND sObjectType = 'Contact' LIMIT 1].Id;
		c2.AccountId = partner.Id;
		contacts.add(c2);
		insert contacts;

		customer.PrimaryContact__c = c1.Id;
		partner.PrimaryContact__c = c2.Id;
		update accounts;

		System.debug(accounts);
		System.debug(contacts);
		System.debug([SELECT Id, (SELECT Id FROM Contacts ORDER BY CreatedDate LIMIT 1) FROM Account]);
*/

		Account customer = new Account();
		customer.RecordTypeId = [SELECT Id FROM RecordType WHERE Name LIKE 'Private Customer' AND sObjectType = 'Account' LIMIT 1].Id;
		customer.LastName = 'Customer account';
		//customer.PrimaryContact__c = null;
		//customer.IsPersonAccount = false;
		accounts.add(customer);

		Account partner = new Account();
		partner.Name = 'Partner account';
		partner.RecordTypeId = [SELECT Id FROM RecordType WHERE Name LIKE 'Partner' AND sObjectType = 'Account' LIMIT 1].Id;
		//partner.PrimaryContact__c = null;
		//partner.IsPersonAccount = false; 
		accounts.add(partner);
		insert accounts;		

	}

	@isTest static void test_method_one() {


		//create test data - products, pricebook, pricebookentries
		PriceBook2 pb = new PriceBook2();
		pb.Name = 'sonnen Sales DE';
		pb.isActive = true;
		insert pb;

		//create products
		List<Product2> pList = new List<Product2>();
		Product2 p = new Product2();
		p.Name = 'sonnenFlat 4250';
		p.CurrencyISOCode = 'EUR';
		p.AmountFreeEnergy__c = 4250;
		p.IsActive = true;
		p.Type__c = 'Electricity contract';
		p.ContractRunningTime__c = 1;
		p.ContractRenewalTime__c = 1;
		p.DeductionForEachKWpInKWh__c =  625;
		p.MinPVSize__c = 5.5;
		pList.add(p);

		Product2 p1 = new Product2();
		p1.Name = 'sonnenFlat 8000';
		p1.CurrencyISOCode = 'EUR';
		p1.AmountFreeEnergy__c = 8000;
		p1.IsActive = true;
		p1.Type__c = 'Electricity contract';
		p1.ContractRunningTime__c = 1;
		p1.ContractRenewalTime__c = 1;
		p1.DeductionForEachKWpInKWh__c =  625;
		p1.MinPVSize__c = 9.5;
		pList.add(p1);

		Product2 p2 = new Product2();
		p2.Name = 'Battery eco 8 6kWh';
		p2.CurrencyISOCode = 'EUR';
		p2.ProductSize__c = '6 kWh';
		p2.IsActive = true;
		p2.Type__c = 'Battery';
		pList.add(p2);

		Product2 p3 = new Product2();
		p3.Name = 'Battery eco 8 12kWh';
		p3.CurrencyISOCode = 'EUR';
		p3.ProductSize__c = '12 kWh';
		p3.IsActive = true;
		p3.Type__c = 'Battery';
		pList.add(p3);

		insert pList;
		// obtain Id of standard pricebook
		Id standard = Test.getStandardPricebookId();

		//create pricebook entries for the standard Price book
		List<PriceBookEntry> pbsList = new List<PriceBookEntry>();

		PriceBookEntry pbs = new PriceBookEntry();
		pbs.Pricebook2Id = standard; 
		pbs.Product2Id = p.Id;
		pbs.CurrencyISOCode = 'EUR';
		pbs.UnitPrice = 10;
		pbs.IsActive = true;
		pbs.ElectricityPrice__c = 0.23;
		pbs.ElectricityPrice2000__c = 0.259;
		pbsList.add(pbs);

		PriceBookEntry pbs1 = new PriceBookEntry();
		pbs1.Pricebook2Id = standard; 
		pbs1.Product2Id = p1.Id;
		pbs1.CurrencyISOCode = 'EUR';
		pbs1.UnitPrice = 20;
		pbs1.IsActive = true;
		pbs1.ElectricityPrice__c = 0.23;
		pbs1.ElectricityPrice2000__c = 0.259;
		pbsList.add(pbs1);

		PriceBookEntry pbs2 = new PriceBookEntry();
		pbs2.Pricebook2Id = standard; 
		pbs2.Product2Id = p2.Id;
		pbs2.CurrencyISOCode = 'EUR';
		pbs2.UnitPrice = 9471.50;
		pbs2.IsActive = true;
		pbsList.add(pbs2);

		PriceBookEntry pbs3 = new PriceBookEntry();
		pbs3.Pricebook2Id = standard;
		pbs3.Product2Id = p3.Id;
		pbs3.CurrencyISOCode = 'EUR';
		pbs3.UnitPrice = 14848.50;
		pbs3.IsActive = true;
		pbsList.add(pbs3);

		insert pbsList;

		//create price book entries
		List<PriceBookEntry> pbeList = new List<PriceBookEntry>();

		// PB entries for the sonnen Sales DE pricebook
		PriceBookEntry pbe = new PriceBookEntry();
		pbe.Pricebook2Id = pb.Id; 
		pbe.Product2Id = p.Id;
		pbe.CurrencyISOCode = 'EUR';
		pbe.UnitPrice = 10;
		pbe.IsActive = true;
		pbe.MaximalConsumption__c = 4750;
		pbe.ElectricityPrice__c = 0.23;
		pbe.ElectricityPrice2000__c = 0.259;
		pbe.RecommendedMinimalConsumption__c = 0;
		pbe.RecommendedMaximalConsumption__c = 4250;
		pbe.RecommendedBatteryCapacity2__c = '6 kWh';
		pbeList.add(pbe);

		PriceBookEntry pbe1 = new PriceBookEntry();
		pbe1.Pricebook2Id = pb.Id; 
		pbe1.Product2Id = p1.Id;
		pbe1.CurrencyISOCode = 'EUR';
		pbe1.UnitPrice = 20;
		pbe1.IsActive = true;
		pbe1.MaximalConsumption__c = 100000;
		pbe1.ElectricityPrice__c = 0.23;
		pbe1.ElectricityPrice2000__c = 0.259;
		pbe1.RecommendedMinimalConsumption__c = 6751;
		pbe1.RecommendedMaximalConsumption__c = 100000;
		pbe1.RecommendedBatteryCapacity2__c = '12 kWh';
		pbeList.add(pbe1);

		PriceBookEntry pbe2 = new PriceBookEntry();
		pbe2.Pricebook2Id = pb.Id; 
		pbe2.Product2Id = p2.Id;
		pbe2.CurrencyISOCode = 'EUR';
		pbe2.UnitPrice = 9471.50;
		pbe2.IsActive = true;
		pbeList.add(pbe2);

		PriceBookEntry pbe3 = new PriceBookEntry();
		pbe3.Pricebook2Id = pb.Id;
		pbe3.Product2Id = p3.Id;
		pbe3.CurrencyISOCode = 'EUR';
		pbe3.UnitPrice = 14848.50;
		pbe3.IsActive = true;
		pbeList.add(pbe3);

		insert pbeList;

		// test @RestResource endpoint
		String jsonMsg = '{ "accountId": "0019E00000TSwJr", "electricityConsumption": 7900, "maxLeistung": 10.5, "PVErzeugung": 900.3, "Stromertrag": 8000.5 } ';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = 'https://sonnen--ims.cs88.my.salesforce.com/apexrest/calculator2';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(jsonMsg);

		RestContext.request = req;
		RestContext.response = res; 

		String jsonString = wirtschaftlichkeitsrechner2.method1();

		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
			
		Map<String, Object> mParsed; // the map will hold part of the JSON response which is related to recommended products only 
										//where key is field name e.g. Name, Battery etc.

		List<Object> mlist = (List<Object>)m.get('RecommendedProducts'); 

		for(Object result : mlist) {
			mParsed = (Map<String, Object>)result;
		}
		System.debug(mParsed);
		System.assertEquals('sonnenFlat 8000', (String)mParsed.get('Name'));

		
		//test createOpportunityEndpoint
		Id customerId = [SELECT Id, IsPersonAccount FROM Account WHERE Name = 'Customer account' LIMIT 1].Id;
		Id partnerId = [SELECT Id, IsPersonAccount FROM Account WHERE Name = 'Partner account' LIMIT 1].Id;

		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeIdField('accountId', customerId);
		gen.writeIdField('partnerId', partnerId);
		gen.writeNumberField('energyConsumption', 1200.5);
		gen.writeStringField('powerPvPlant', '6.4');
		gen.writeNumberField('generatorsOutput', 7.5);
		gen.writeStringField('roofOrientation', 'East');
		gen.writeFieldName('pbeIds');
		gen.writeStartArray();
		gen.writeStartObject();
		gen.writeStringField('Id', p1.Id);
		gen.writeNumberField('UnitPrice', pbe1.UnitPrice);
		gen.writeEndObject();
		gen.writeStartObject();
		gen.writeStringField('Id', p3.Id);
		gen.writeNumberField('UnitPrice', pbe3.UnitPrice);
		gen.writeEndObject();
		gen.writeEndArray();

		//String jsonOpp = '{ "accountId":"0019E00000VNfbg", "partnerId":"0019E00000Xs39N", "energyConsumption":1200.5, "powerPvPlant":"6.4", "generatorsOutput": 7.5, "roofOrientation":"East", "pbeIds":[{"Id": "01u9E00000A17kE", "UnitPrice" : 10755.46 },{"Id": "01u9E000008Q1gw", "UnitPrice":"19.99"}] }';
		//String jsonOpp = '{ "attributes": { "type": "Opportunity", "url": "/services/data/v36.0/sobjects/Opportunity/0069E0000071bamQAA" }, "AccountId": "0019E00000VNfbgQAD", "ProposedSBC__c": "0019E00000Xs39NQAR", "Name": "New opportunity from Wirtschaflichkeitsrechner", "StageName": "New", "CloseDate": "2018-04-19", "RecordSource__c": "Wirtschaflichkeitsrechner", "PowerPvPlant__c": "6.4", "EnergyConsumption__c": 1200.5, "RoofOrientation__c": "East", "GeneratorsOutput__c": 7.5, "Id": "0069E0000071bamQAA" }';
		String jsonOpp = gen.getAsString();

		RestRequest req2 = new RestRequest();
		RestResponse res2 = new RestResponse();

		req2.requestURI = Url.getSalesforceBaseUrl().toExternalForm() + '/apexrest/createOpp';
		req2.httpMethod = 'POST';
		req2.requestBody = Blob.valueOf(jsonOpp);

		RestContext.request = req;
		RestContext.response = res;


		Opportunity o = createOpportunityEndpoint.createOpportunityEndpoint();


		System.assertEquals(2, [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:o.Id].size());

	}
}