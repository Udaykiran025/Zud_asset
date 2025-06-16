@EndUserText.label: 'Copy Table for Asset Creation'
define abstract entity ZD_CopyAssetP
{
  @EndUserText.label: 'New ZzPbukr'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: ZzPbukr' )
  ZzPbukr : ZBUKRS;
  
}
