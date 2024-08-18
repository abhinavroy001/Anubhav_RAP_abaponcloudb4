@EndUserText.label: 'Projection View for Booking'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZATS_CV_AROY_BOOKING_Processor
  as projection on zats_iv_aroy_booking
{
  key TravelId,
  key BookingId,
      BookingDate,
      @Consumption.valueHelpDefinition: [{ entity.name: '/DMO/I_Customer', entity.element: 'CustomerID' }]
      CustomerId,
      @Consumption.valueHelpDefinition: [{ entity.name: '/DMO/I_Carrier', entity.element: 'AirlineID'  }]
      CarrierId,
      @Consumption.valueHelpDefinition: [{ entity.name: '/DMO/I_Connection', entity.element: 'ConnectionID',
                                           additionalBinding: [{ localElement: 'CarrierId', element: 'AirlineID' }] }]
      ConnectionId,
      FlightDate,
      FlightPrice,
      CurrencyCode,
      @Consumption.valueHelpDefinition: [{ entity.name: '/DMO/I_Booking_Status_VH', entity.element: 'BookingStatus' }]
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _BookingStatus,
      _Carrier,
      _Connection,
      _Customer,
      _Travel : redirected to parent ZATS_CV_AROY_TRAVEL_Processor
}
