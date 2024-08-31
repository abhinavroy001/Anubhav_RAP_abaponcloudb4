@EndUserText.label: 'Projection View for Travel'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZATS_CV_AROY_TRAVEL
  provider contract transactional_query
  as projection on zats_rv_aroy_travel
{
  key TravelId,
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{ entity.name: '/DMO/I_Agency', entity.element: 'AgencyID' }]
      AgencyId,
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity.name: '/DMO/I_Customer', entity.element: 'CustomerID' }]
      CustomerId,
      BeginDate,
      EndDate,
      BookingFee,
      TotalPrice,
      CurrencyCode,
      @Semantics.text: true
      _Agency.Name       as AgencyName,
      @Semantics.text: true
      _Customer.LastName as CustomerName,
      @Semantics.text: true
      Description,
      @ObjectModel.text.element: [ 'StatusText' ]
      @Consumption.valueHelpDefinition: [{ entity.name: '/DMO/I_Overall_Status_VH', entity.element: 'OverallStatus' }]
      OverallStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Semantics.text: true
      StatusText,
      Criticality,
      /* Associations */
      _Agency,
      _Booking    : redirected to composition child ZATS_CV_AROY_BOOKING,
      _attachment : redirected to composition child ZATS_CV_AROY_ATTACHMENT,
      _Currency,
      _Customer,
      _OverallStatus
}
