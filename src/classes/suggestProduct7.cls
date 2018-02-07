/*
- Author: Bartosz Jarmolinski

- The class includes product recommendation logic - sonnenFlat contract and matching battery
- parameters: consumption (per year), maxLeistung (peak power of the PV which can be installed), stromertag (yearly electricity production), 
- the method returns JSON string which contains recommended electricity contract together with battery as well as other available products
*/

public with sharing class suggestProduct7 {
	public String suggestProduct7(Integer consumption, Decimal maxLeistung, Decimal stromertrag, Decimal pvErzeugung) {
		
		List<PricebookEntry> productList; // list of products with prices which will be returned as suggested products 
											//Pricebook entry and not products because the latter does not contain unit price
		
		List<PriceBookEntry> tarifs = new List<PriceBookEntry>(); // list of tariff products
		List<PriceBookEntry> batteries = new List<PriceBookEntry>(); // list of battery products
 		Map<String, PriceBookEntry> batteryRecommend = new Map<String, PriceBookEntry>(); // map of sonnenFlat name and recommened battery
		Map<String, PriceBookEntry> batterySize = new Map<String, PriceBookEntry>(); // map of battery size in kWh and corresponding price book record
 		Map<Integer, PriceBookEntry> batterySizeInt = new Map<Integer, PriceBookEntry>(); // map of battery size and corresponding price book, with key stripped to integer


		String sonnenFlatTarif;  // name of suggested sonnenFlat
		String batteryCapacity;  // capacity of the battery recommened for the sonnenFlat

		Decimal freeElectricityCalc; // calculated as per recommendation logic
		Map<String, Decimal> freeElectricityMap; // calculated free electricity for each tariff

		// query batteries and sonnenFlat contracts from the sonnen sales DE price book - price book logic to be reviewed in the future if
		// further countries or different groups of partners are to be included.
		productList = [SELECT id, Name, Product2.Name, UnitPrice, Product2.AmountFreeEnergy__c, Product2.MaxConsumption__c, Product2.MinConsumption__c,
						Product2.ContractRunningTime__c, Product2.ContractRenewalTime__c, ElectricityPrice__c, ElectricityPrice2000__c, Product2.Type__c, 
						Product2.ProductSize__c, Product2.DeductionForEachKWpInKWh__c, Product2.MinBatteryCapacity__c, Product2.MinProduction__c, Product2.MinPVSize__c, 
						RecommendedMaximalConsumption__c, RecommendedMinimalConsumption__c, MaximalConsumption__c, RecommendedBatteryCapacity2__c
						FROM PricebookEntry WHERE Pricebook2.Name = 'sonnen Sales DE' AND
						(Product2.Type__c != 'Electricity contract' OR MaximalConsumption__c >= :consumption) AND
						(Product2.Type__c = 'Electricity contract' OR Product2.Type__c = 'Battery') AND IsActive = true ORDER BY Product2.Type__c DESC];

		// construct list of tarifs (electricity contract products) only
		for(PriceBookEntry pbe : productList){
			if(pbe.Product2.Type__c == 'Electricity contract') {
				tarifs.add(pbe);
			}
			else if(pbe.Product2.Type__c == 'Battery') {
				batteries.add(pbe);
				batterySize.put(pbe.Product2.ProductSize__c, pbe);
				// pbe.Product2.ProductSize__c is a string - needs to be split. First element of the split is always a number of kWh, which then is converted into Integer
				List<String> ls = pbe.Product2.ProductSize__c.split(' ');
				Integer size = Integer.valueOf(ls[0]);
				batterySizeInt.put(size, pbe);
			} 
		}
		System.debug('batterySize: '+batterySize);

		// recommendation logic 2.0 - find recpmmended tarif based on parameters in the if conditions and assign to recommened-variables
		for(PriceBookEntry pbe : tarifs) {
			if(consumption <= pbe.MaximalConsumption__c && consumption >= pbe.RecommendedMinimalConsumption__c && consumption <= pbe.RecommendedMaximalConsumption__c) {
				sonnenFlatTarif = pbe.Name;
				batteryCapacity = pbe.RecommendedBatteryCapacity2__c;
			}
			batteryRecommend.put(pbe.Name, batterySize.get(pbe.RecommendedBatteryCapacity2__c));
		}
		System.debug('batteryRecommend: '+batteryRecommend);
		
		//contruct JSON string with the recommended products and other products which will be returned as response
		JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('RecommendedProducts');
        gen.writeStartArray();
        for(PricebookEntry pbe : tarifs){
        	gen.writeStartObject();
    		gen.writeStringField('Id', pbe.Id);
    		if(pbe.Name == sonnenFlatTarif) {
    			gen.writeBooleanField('Recommended', true);
    		}
    		else {
    			gen.writeBooleanField('Recommended', false);
    		}
        	gen.writeStringField('Name', pbe.Name);
        	gen.writeNumberField('ContractRunningTime', pbe.Product2.ContractRunningTime__c);
        	gen.writeNumberField('ContractRenewalTime', pbe.Product2.ContractRenewalTime__c);
        	gen.writeNumberField('CommunityChargePerMonth', pbe.UnitPrice);
        	gen.writeStringField('ProductType', pbe.Product2.Type__c);
        	gen.writeNumberField('FreeElectricitySupply', pbe.Product2.AmountFreeEnergy__c);
        	gen.writeNumberField('ElectricityPrice', pbe.ElectricityPrice__c);
        	gen.writeNumberField('ElectricityPrice2000', pbe.ElectricityPrice2000__c);
        	
        	gen.writeFieldName('Batteries');
        	gen.writeStartArray();

        	String recSizeS = pbe.RecommendedBatteryCapacity2__c.split(' ')[0];
        	Integer recSize = Integer.valueOf(recSizeS);

        	for(Integer i : batterySizeInt.keySet()) {
        		if(i >= recSize) {
        			gen.writeStartObject();
		        	gen.writeStringField('Id', batterySizeInt.get(i).Id);
		        	gen.writeStringField('Name', batterySizeInt.get(i).Name);
		        	if(i == recSize){
		        		gen.writeBooleanField('Recommended', true);
		        	}
		        	else {
		        		gen.writeBooleanField('Recommended', false);
		        	}
		        	gen.writeEndObject();
        		}
        	}   	
        	gen.writeEndArray();
        	gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();

        String jsonResponse = gen.getAsString();
        System.debug(jsonResponse);

		return jsonResponse;
	}
}