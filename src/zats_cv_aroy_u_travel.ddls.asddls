@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Project. View for ZATS_RV_AROY_U_TRAVEL'
@Metadata.allowExtensions: true
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZATS_CV_AROY_U_TRAVEL
  provider contract transactional_query
  as projection on zats_rv_aroy_u_travel
{
  key TravelId,
      AgencyId,
      AgencyName,
      CustomerId,
      CustomerName,
      BeginDate,
      EndDate,
      BookingFee,
      TotalPrice,
      CurrencyCode,
      Description,
      Status,
      StatusText,
      Criticality,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _agency,
      _currency,
      _customer,
      _TravelStatus
}
