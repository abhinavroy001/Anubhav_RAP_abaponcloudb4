@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for attachments'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zats_iv_aroy_attachment
  as select from zats_aroy_attach
  association to parent zats_rv_aroy_travel as _Travel on $projection.TravelId = _Travel.TravelId
{
  key travel_id       as TravelId,
  key id              as Id,
      memo            as Memo,
      @Semantics.largeObject: {
          mimeType: 'Filetype',
          fileName: 'Filename',
          contentDispositionPreference: #ATTACHMENT,
          acceptableMimeTypes: [ 'application/pdf' ]
          }
      attachment      as Attachment,
      @Semantics.mimeType: true
      filetype        as Filetype,
      filename        as Filename,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      _Travel
}
