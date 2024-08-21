@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View Entity for Travel (Unmanaged)'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zats_rv_aroy_u_travel
  as select from /dmo/travel
  association [1] to zats_iv_aroy_u_agency   as _agency       on $projection.AgencyId = _agency.AgencyId
  association [1] to zats_iv_aroy_u_customer as _customer     on $projection.CustomerId = _customer.CustomerId
  association [1] to I_Currency              as _currency     on $projection.CurrencyCode = _currency.Currency
  association [1] to /DMO/I_Travel_Status_VH as _TravelStatus on $projection.Status = _TravelStatus.TravelStatus
{
      @ObjectModel.text.element: [ 'Description' ]
  key travel_id                                                       as TravelId,
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{ entity: {
          name: 'zats_iv_aroy_u_agency',
          element: 'AgencyId'
      } }]
      agency_id                                                       as AgencyId,
      _agency.Name                                                    as AgencyName,
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity: {
          name: 'zats_iv_aroy_u_customer',
          element: 'CustomerId'
      } }]
      customer_id                                                     as CustomerId,
      concat_with_space( _customer.FirstName, _customer.LastName, 1 ) as CustomerName,
      begin_date                                                      as BeginDate,
      end_date                                                        as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee                                                     as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price                                                     as TotalPrice,
      currency_code                                                   as CurrencyCode,
      description                                                     as Description,
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: '/DMO/I_Travel_Status_VH',
              element: 'TravelStatus'
          }
      }]
      status                                                          as Status,
      createdby                                                       as Createdby,
      createdat                                                       as Createdat,
      lastchangedby                                                   as Lastchangedby,
      lastchangedat                                                   as Lastchangedat,
      _agency,
      _customer,
      _currency,
      _TravelStatus
}
