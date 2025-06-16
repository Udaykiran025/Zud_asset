@EndUserText.label: 'Table for Asset Creation'
@AccessControl.authorizationCheck: #NOT_ALLOWED
@Metadata.allowExtensions: true
define view entity ZI_Asset
  as select from zasset
  association to parent ZI_Asset_S as _AssetAll on $projection.SingletonID = _AssetAll.SingletonID
{
  key zz_pbukr              as ZzPbukr,
      external_id           as ExternalId,
      zz_proj_manager       as ZzProjManager,
      assetclass            as Assetclass,
      assetclassdes         as Assetclassdes,
      aktiv                 as Aktiv,
      zz_kostl_resp         as ZzKostlResp,
      anlhtxt               as Anlhtxt,
      changed_by            as ChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      @Consumption.hidden: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at            as ChangedAt,
      @Consumption.hidden: true
      1                     as SingletonID,
      _AssetAll

}
