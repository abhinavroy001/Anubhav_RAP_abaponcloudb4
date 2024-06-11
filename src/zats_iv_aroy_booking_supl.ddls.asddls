@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for Booking Supplement'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zats_iv_aroy_booking_supl
  as select from /dmo/booksuppl_m
  association        to parent zats_iv_aroy_booking as _Booking        on  $projection.TravelId  = _Booking.TravelId
                                                                       and $projection.BookingId = _Booking.BookingId
  association [1..1] to zats_rv_aroy_travel         as _Travel         on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement           as _Product        on  $projection.SupplementId = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText       as _SupplementText on  $projection.SupplementId = _SupplementText.SupplementID
{
  key travel_id                                         as TravelId,
  key booking_id                                        as BookingId,
  key booking_supplement_id                             as BookingSupplementId,
      supplement_id                                     as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                                             as Price,
      currency_code                                     as CurrencyCode,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                                   as LastChangedAt,
      _SupplementText[1:LanguageCode = 'E'].Description as Description,
      _Booking,
      _Travel,
      _Product,
      _SupplementText
}
