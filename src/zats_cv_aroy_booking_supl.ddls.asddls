@EndUserText.label: 'Projection View for Booking Supplments'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZATS_CV_AROY_BOOKING_SUPL
  as projection on zats_iv_aroy_booking_supl
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @Consumption.valueHelpDefinition: [{ entity.name: '/DMO/I_Supplement', entity.element: 'SupplementID' }]
      SupplementId,
      Price,
      CurrencyCode,
      LastChangedAt,
      Description,
      /* Associations */
      _Booking : redirected to parent ZATS_CV_AROY_BOOKING,
      _Product,
      _SupplementText,
      _Travel  : redirected to ZATS_CV_AROY_TRAVEL
}
