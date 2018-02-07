@RestResource(urlMapping='/calculator')
global with sharing class wirtschaftlichkeitsRechner  {

    @HttpPost
    global static String method1() {

        Integer consumption;
        Decimal maxLeistung;
        Integer pvErzeugung;
        Integer stromertrag;

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String jsonInput = req.requestBody.toString();
        System.debug(jsonInput);

        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        System.debug(m);

        ID accountId = (Id) m.get('accountId');
        if(m.get('electricityConsumption') != null) {
            consumption = (Integer) m.get('electricityConsumption');
        }
        if(m.get('maxLeistung') != null) {
            maxLeistung = (Decimal) m.get('maxLeistung');
        }
        if(m.get('PVErzeugung') != null) {
            pvErzeugung = (Integer) m.get('PVErzeugung');
        }
        if(m.get('Stromertrag') != null) {
            stromertrag = (Integer) m.get('Stromertrag');
        }

        System.debug('consumption: '+consumption);
        System.debug('max Leistung: '+maxLeistung);
        System.debug('pvErzeugung: '+pvErzeugung);
        System.debug('Stromertrag: '+stromertrag);
    
        //call suggestion class and get suggested product
        suggestProduct3 sp = new suggestProduct3();
        List<PricebookEntry> pbeList = sp.suggestProduct3(consumption, maxLeistung, stromertrag);
        System.debug(pbeList);

/*
        //call createOpportunity class, passing list of product IDs and the accountId
        List<Id> prodIds = new List<Id>();
        for(PriceBookEntry pbe : pbeList) {
            prodIds.add(pbe.Product2Id);
        }
        createOpportunity.createOpportunity(prodIds, accountId);
*/
        //construct JSON response with array of returned products (price book entries)
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('Recommended products');
        gen.writeStartArray();
        for(PricebookEntry pbe : pbeList) {
            gen.writeStartObject();
            gen.writeStringField('Product name', pbe.Name);
            //gen.writeNumberField('Unit price', pbe.UnitPrice);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();

        String jsonResponse = gen.getAsString();
        System.debug(jsonResponse);

        return jsonResponse;

    }
}