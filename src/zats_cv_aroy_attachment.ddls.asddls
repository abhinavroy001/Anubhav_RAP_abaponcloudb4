@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View Entity for Attachments'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZATS_CV_AROY_ATTACHMENT
  as projection on zats_iv_aroy_attachment
{
  key TravelId,
  key Id,
      Memo,
      @Semantics.largeObject: {
          mimeType: 'Filetype',
          fileName: 'Filename',
          contentDispositionPreference: #ATTACHMENT,
          acceptableMimeTypes: [ 'application/pdf' ]
          }
      Attachment,
      @Semantics.mimeType: true
      Filetype,
      Filename,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      /* Associations */
      _Travel : redirected to parent ZATS_CV_AROY_TRAVEL
}
