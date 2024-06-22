CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE Booking\_Bookingsupplement.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.
    DATA(lv_flag) = abap_true.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
