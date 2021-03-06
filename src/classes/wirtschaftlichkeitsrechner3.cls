/*
- Rest endpoint for Wirtschaftlichkeitsrechner App. 
- Author: Bartosz Jarmolinski
- parameters: consumption, maxLeistung, pvErzeugung, stromvertrag - all to be included in JSON Payload and cannot be null - validation on the website
- the class invokes another class: suggestProduct, where product recommendation logic is included
- the return element of the suggestProduct class is then passed as response to the original external callout from the app.
*/



@RestResource(urlMapping='/calculator3')
global with sharing class wirtschaftlichkeitsrechner3  {

    @HttpPost
    global static String method1() {

        Integer consumption;
        Decimal maxLeistung;
        Decimal pvErzeugung;
        Decimal stromertrag;

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
            pvErzeugung = (Decimal) m.get('PVErzeugung');
        }
        if(m.get('Stromertrag') != null) {
            stromertrag = (Decimal) m.get('Stromertrag');
        }

        System.debug('consumption: '+consumption);
        System.debug('max Leistung: '+maxLeistung);
        System.debug('pvErzeugung: '+pvErzeugung);
        System.debug('Stromertrag: '+stromertrag);
    
        //call suggestion class and get suggested products in JSON string format
        suggestProduct9 sp = new suggestProduct9();
        String jsonResponse = sp.suggestProduct9(consumption, maxLeistung, stromertrag, pvErzeugung);
        System.debug(jsonResponse);
        
        return jsonResponse;

    }

}