CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE Booking\_Bookingsupplement.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.
    DATA: lt_entities   TYPE TABLE FOR CREATE zats_rv_aroy_travel\\booking\_bookingsupplement,
          lv_book_suppl TYPE /dmo/booking_supplement_id.

    CLEAR: lt_entities[],
           lv_book_suppl.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entities>).
      READ ENTITIES OF zats_cv_aroy_travel
      ENTITY Booking BY \_BookingSupplement
      ALL FIELDS WITH
      VALUE #( ( TravelId = <fs_entities>-TravelId
                 BookingId = <fs_entities>-BookingId
                 %is_draft = <fs_entities>-%is_draft ) )
      RESULT DATA(lt_result)
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

      IF lt_result IS NOT INITIAL.
        LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
          IF lv_book_suppl < <fs_result>-BookingSupplementId.
            lv_book_suppl = <fs_result>-BookingSupplementId.
          ENDIF.
        ENDLOOP.
      ENDIF.

      LOOP AT <fs_entities>-%target ASSIGNING FIELD-SYMBOL(<fs_target>).
        lv_book_suppl += 1.
        mapped-bookingsuppl = VALUE #( BASE mapped-bookingsuppl
                                       ( %cid = <fs_target>-%cid
                                         %is_draft = <fs_target>-%is_draft
                                         TravelId = <fs_target>-TravelId
                                         BookingId = <fs_target>-BookingId
                                         BookingSupplementId = lv_book_suppl ) ).
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD calculateTotalPrice.
    TYPES: BEGIN OF ty_travelid,
             travelid TYPE /dmo/travel_id,
           END OF ty_travelid,
           tt_travelid TYPE STANDARD TABLE OF ty_travelid  WITH DEFAULT KEY.
    DATA: lt_keys     TYPE TABLE FOR DETERMINATION zats_rv_aroy_travel\\booking~calculatetotalprice,
          lt_travelid TYPE tt_travelid.

    CLEAR: lt_keys[],
           lt_travelid[].

    lt_travelid = CORRESPONDING #( keys MAPPING travelid = travelid ).
    IF lt_travelid IS NOT INITIAL.
      SORT lt_travelid BY travelid.
      DELETE ADJACENT DUPLICATES FROM lt_travelid COMPARING travelid.
    ENDIF.

    MODIFY ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Travel
    EXECUTE reCalcTotalPrice
    FROM CORRESPONDING #( lt_travelid )
    MAPPED DATA(lt_mapped).

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
