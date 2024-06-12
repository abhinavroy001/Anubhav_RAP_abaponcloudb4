CLASS zats_cl_eml_aroy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zats_cl_eml_aroy IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*/--Create BO Instance
*    MODIFY ENTITIES OF zats_cv_aroy_travel
*    ENTITY Travel
*    CREATE
*    SET FIELDS WITH VALUE #( ( %cid = 'newInstanceTravel_01'
*                               AgencyId = '070007'
*                               BeginDate = cl_abap_context_info=>get_system_date( )
*                               EndDate = cl_abap_context_info=>get_system_date( ) + 18
*                               TravelId = '00005011')
*                               ( %cid = 'newInstanceTravel_02'
*                               AgencyId = '070042'
*                               BeginDate = cl_abap_context_info=>get_system_date(  )
*                               EndDate = cl_abap_context_info=>get_system_date(  ) + 10
*                               TravelId = '00005012')
*                               ( %cid = 'newInstanceTravel_03'
*                               AgencyId = '070042'
*                               BeginDate = cl_abap_context_info=>get_system_date(  )
*                               EndDate = cl_abap_context_info=>get_system_date( ) + 20
*                               TravelId = '00000009') )
*    MAPPED DATA(lt_mapped)
*    FAILED DATA(lt_failed)
*    REPORTED DATA(lt_reported).

*/--Create BO instance along with association
*    MODIFY ENTITIES OF zats_cv_aroy_travel
*    ENTITY Travel
*    CREATE
*    SET FIELDS WITH VALUE #( ( %cid = 'newInstanceTravel_04'
*                               AgencyId = '070007'
*                               BeginDate = cl_abap_context_info=>get_system_date( )
*                               EndDate = cl_abap_context_info=>get_system_date( ) + 18
*                               TravelId = '00005026' ) )
*    CREATE BY \_Booking
*    SET FIELDS WITH VALUE #(
*                             ( %cid_ref = 'newInstanceTravel_04'
*                               %target = VALUE #( ( %cid = 'newInstanceBooking_01'
*                                                    BookingId = '0001'
*                                                    CustomerId = '000706'
*                                                    FlightDate = cl_abap_context_info=>get_system_date( ) + 45 ) ) )
*                             ( %cid_ref = 'newInstanceTravel_04'
*                               %target = VALUE #( ( %cid = 'newInstanceBooking_02'
*                                                    BookingId = '0002'
*                                                    CustomerId = '000706'
*                                                    FlightDate = cl_abap_context_info=>get_system_date( ) + 57 ) ) )
*                           )
*
*    MAPPED DATA(lt_map_assoc)
*    FAILED DATA(lt_fail_assoc)
*    REPORTED DATA(lt_report_assoc).

    MODIFY ENTITIES OF zats_cv_aroy_travel
    ENTITY Booking
    CREATE BY \_BookingSupplement
    AUTO FILL CID
    SET FIELDS WITH VALUE #(
                             ( TravelId = '00005026'
                               BookingId = '0001'
                               %target = VALUE #( ( BookingSupplementId = '01'
                                                    SupplementId = 'ML-0021' ) ) )
                             ( TravelId = '00005026'
                               BookingId = '0001'
                               %target = VALUE #( ( BookingSupplementId = '02'
                                                    SupplementId = 'BV-0007' ) ) )
                             ( TravelId = '00005026'
                               BookingId = '0002'
                               %target = VALUE #( ( BookingSupplementId = '01'
                                                    SupplementId = 'ML-0021' ) ) )
                             ( TravelId = '00005026'
                               BookingId = '0002'
                               %target = VALUE #( ( BookingSupplementId = '02'
                                                    SupplementId = 'BV-0005' ) ) )
                             ( TravelId = '00005026'
                               BookingId = '0002'
                               %target = VALUE #( ( BookingSupplementId = '03'
                                                    SupplementId = 'ML-0002' ) ) )
                           )
    MAPPED DATA(lt_map_assoc)
    FAILED DATA(lt_fail_assoc)
    REPORTED DATA(lt_report_assoc).

*/--Create BO instances (new syntax)
*    MODIFY ENTITIES OF zats_cv_aroy_travel
*    ENTITY Travel
*    CREATE
*    AUTO FILL CID
*    SET FIELDS WITH VALUE #( ( AgencyId = '070007'
*                               BeginDate = cl_abap_context_info=>get_system_date( )
*                               EndDate = cl_abap_context_info=>get_system_date( ) + 18
*                               TravelId = '00005020' )
*                             ( AgencyId = '070037'
*                               BeginDate = cl_abap_context_info=>get_system_date( )
*                               EndDate = cl_abap_context_info=>get_system_date( ) + 19
*                               TravelId = '00005021' )
*                           )
*    MAPPED DATA(lt_map_assoc)
*    FAILED DATA(lt_fail_assoc)
*    REPORTED DATA(lt_report_assoc).

*/--Booking entries (via association)
*    MODIFY ENTITIES OF zats_cv_aroy_travel
*    ENTITY Travel
*    CREATE BY \_Booking
*    AUTO FILL CID
*    SET FIELDS WITH VALUE #(
*                            ( TravelId = '00005020'
*                              %target = VALUE #( ( BookingId = '0001'
*                                                   FlightDate = cl_abap_context_info=>get_system_date( )
*                                                   CustomerId = '000093' ) ) )
*                            ( TravelId = '00005020'
*                              %target = VALUE #( ( BookingId = '0002'
*                                                   FlightDate = cl_abap_context_info=>get_system_date( )
*                                                   CustomerId = '000706' ) ) )
*                            ( TravelId = '00005021'
*                              %target = VALUE #( ( BookingId = '0001'
*                                                   FlightDate = cl_abap_context_info=>get_system_date( ) + 10
*                                                   CustomerId = '000093' ) ) )
*                            ( TravelId = '00005021'
*                              %target = VALUE #( ( BookingId = '0002'
*                                                   FlightDate = cl_abap_context_info=>get_system_date( ) + 17
*                                                   CustomerId = '000706' ) ) )
*                            ( TravelId = '00005021'
*                              %target = VALUE #( ( BookingId = '0003'
*                                                   FlightDate = cl_abap_context_info=>get_system_date( ) + 21
*                                                   CustomerId = '000706' ) ) )
*                           )
*    MAPPED DATA(lt_map_assoc)
*    FAILED DATA(lt_fail_assoc)
*    REPORTED DATA(lt_report_assoc).

    out->write( '_____________________________________________________________________________________' ).

    out->write(
      EXPORTING
        data   = lt_map_assoc-travel
        name   = 'Mapped'
    ).

    out->write(
      EXPORTING
        data   = lt_report_assoc-travel
        name   = 'Reported'
    ).

    out->write(
      EXPORTING
        data   = lt_fail_assoc-travel
        name   = 'Failed'
    ).

    COMMIT ENTITIES
    RESPONSE OF zats_cv_aroy_travel
    FAILED DATA(lt_failed_commit)
    REPORTED DATA(lt_reported_commit).

    out->write( 'Creation done' ).

  ENDMETHOD.
ENDCLASS.
