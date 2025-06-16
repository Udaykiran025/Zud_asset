@EndUserText.label: 'Table for Asset Creation Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'AssetAll'
  }
}
define root view entity ZI_Asset_S
  as select from I_Language
    left outer join ZASSET on 0 = 0
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_Asset as _Asset
{
  @UI.facet: [ {
    id: 'ZI_Asset', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Table for Asset Creation', 
    position: 1 , 
    targetElement: '_Asset'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _Asset,
  @UI.hidden: true
  max( ZASSET.CHANGED_AT ) as LastChangedAtMax,
  @ObjectModel.text.association: '_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 2 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  _ABAPTransportRequestText
  
}
where I_Language.Language = $session.system_language
