@EndUserText.label: 'Constant Parameter Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Semantics.valueRange.maximum: '1'
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'ConstantParameteAll'
  }
}
define root view entity ZI_ConstantParameter_S
  as select from I_Language
    left outer join ZTBC_PARAM on 0 = 0
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_ConstantParameter as _ConstantParameter
{
  @UI.facet: [ {
    id: 'ConstantParameter', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Constant Parameters', 
    position: 1 , 
    targetElement: '_ConstantParameter'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _ConstantParameter,
  @UI.hidden: true
  max( ZTBC_PARAM.LAST_CHANGED_AT ) as LastChangedAtMax,
  @ObjectModel.text.association: '_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 1 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  _ABAPTransportRequestText
}
where I_Language.Language = $session.system_language
