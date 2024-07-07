CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~copytravel.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE travel\_booking.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA: lt_entities  TYPE TABLE FOR CREATE zats_rv_aroy_travel\\travel,
          lv_travel_id TYPE /dmo/travel_id.
    CLEAR: lt_entities[],
           lv_travel_id.
    lt_entities = VALUE #( BASE lt_entities
                           FOR <fs_entity> IN entities
                           WHERE ( TravelId IS INITIAL )
                           ( <fs_entity> ) ).

    TRY.
        cl_numberrange_runtime=>number_get(
      EXPORTING
        nr_range_nr       = '01'
        object            = '/DMO/TRAVL'
        quantity          = CONV #( lines( lt_entities ) )
      IMPORTING
        number            = DATA(lv_number)
        returncode        = DATA(lv_returncode)
        returned_quantity = DATA(lv_ret_quan)
    ).
      CATCH cx_number_ranges INTO DATA(lo_cx).
        LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<fs_ent>).
          reported-travel = VALUE #( BASE reported-travel ( %cid = <fs_ent>-%cid
                                                            %key = <fs_ent>-%key
                                                            %msg = lo_cx ) ).
          failed-travel = VALUE #( BASE failed-travel ( %cid = <fs_ent>-%cid
                                                        %key = <fs_ent>-%key ) ).
        ENDLOOP.
        EXIT.
    ENDTRY.

    IF lv_returncode NE '3'.
      lv_travel_id = lv_number - lv_ret_quan.
      LOOP AT lt_entities ASSIGNING <fs_ent>.
        lv_travel_id += 1.
        mapped-travel = VALUE #( BASE mapped-travel ( %cid = <fs_ent>-%cid
                                                      %key = <fs_ent>-%key
                                                      TravelId = lv_travel_id ) ).
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.
    DATA: lt_entities   TYPE TABLE FOR CREATE zats_rv_aroy_travel\\travel\_booking,
          lv_booking_id TYPE /dmo/booking_id.
    CLEAR: lt_entities[],
           lv_booking_id.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_ent>) GROUP BY ( travelid = <fs_ent>-TravelId
                                                                 size = GROUP SIZE
                                                                 index = GROUP INDEX
                                                               ) ASSIGNING FIELD-SYMBOL(<fs_group>).
      LOOP AT GROUP <fs_group> ASSIGNING FIELD-SYMBOL(<fsg>).
        lt_entities = VALUE #( BASE lt_entities ( <fsg> ) ).
        READ ENTITIES OF zats_rv_aroy_travel
        IN LOCAL MODE
        ENTITY Travel
        BY \_Booking
        ALL FIELDS WITH
        VALUE #( FOR <fs_entity> IN lt_entities ( TravelId = <fs_entity>-TravelId ) )
        RESULT DATA(lt_result)
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).

        IF lt_result IS NOT INITIAL.
          lv_booking_id = lt_result[ 1 ]-BookingId.
          LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
            IF lv_booking_id < <fs_result>-BookingId.
              lv_booking_id = <fs_result>-BookingId.
            ENDIF.
          ENDLOOP.
        ELSE.
        ENDIF.

        LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<fs_travel>).
          LOOP AT <fs_travel>-%target ASSIGNING FIELD-SYMBOL(<fs_book>).
            lv_booking_id += 1.
            mapped-booking = VALUE #( BASE mapped-booking ( %cid = <fs_book>-%cid
                                                            TravelId = <fs_book>-TravelId
                                                            BookingId = lv_booking_id ) ).
          ENDLOOP.
        ENDLOOP.

      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD copyTravel.

    DATA: lt_keys             TYPE TABLE FOR ACTION IMPORT zats_rv_aroy_travel\\travel~copytravel,
          lt_travel_create    TYPE TABLE FOR CREATE zats_rv_aroy_travel\\Travel,
          lt_book_create      TYPE TABLE FOR CREATE zats_rv_aroy_travel\\Travel\_Booking,
          lt_booksuppl_create TYPE TABLE FOR CREATE zats_rv_aroy_travel\\Booking\_BookingSupplement.

    CLEAR: lt_travel_create[],
           lt_book_create[],
           lt_booksuppl_create[].

    READ ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH
    VALUE #( FOR <fs_key> IN keys ( TravelId = <fs_key>-TravelId ) )
    RESULT DATA(lt_result)
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

    IF  lt_result IS NOT INITIAL.
      READ ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
      ENTITY Travel
      BY \_Booking
      ALL FIELDS WITH
      VALUE #( FOR <fs_result> IN lt_result ( TravelId = <fs_result>-TravelId ) )
      RESULT DATA(lt_result_booking)
      REPORTED DATA(lt_reported_booking)
      FAILED DATA(lt_failed_booking).

      IF lt_result_booking IS NOT INITIAL.
        READ ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
        ENTITY Booking
        BY \_BookingSupplement
        ALL FIELDS WITH
        VALUE #( FOR <fs_booking> IN lt_result_booking ( TravelId = <fs_booking>-TravelId
                                                         BookingId = <fs_booking>-BookingId ) )
        RESULT DATA(lt_result_bookingsupl)
        REPORTED DATA(lt_reported_bookingsupl)
        FAILED DATA(lt_failed_bookingsupl).
      ENDIF.
    ENDIF.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_res>).
      lt_travel_create = VALUE #( BASE lt_travel_create ( %cid = keys[ TravelId = <fs_res>-TravelId ]-%cid
                                                          %data = CORRESPONDING #( <fs_res> EXCEPT TravelId ) ) ).
      LOOP AT lt_result_booking ASSIGNING FIELD-SYMBOL(<fs_res_book>) WHERE TravelId = <fs_res>-TravelId.
        lt_book_create = VALUE #( BASE lt_book_create ( %cid_ref = keys[ TravelId = <fs_res>-TravelId ]-%cid
                                                        %target = VALUE #( ( %cid = |{ keys[ TravelId = <fs_res>-TravelId ]-%cid }{ <fs_res_book>-BookingId }|
                                                                             %data = CORRESPONDING #( <fs_res_book> EXCEPT TravelId
                                                                                                                           BookingId ) ) ) ) ).
        LOOP AT lt_result_bookingsupl ASSIGNING FIELD-SYMBOL(<fs_res_booksupl>) WHERE TravelId = <fs_res_book>-TravelId
                                                                                  AND BookingId = <fs_res_book>-BookingId .
          lt_booksuppl_create = VALUE #( BASE lt_booksuppl_create ( %cid_ref = |{ keys[ TravelId = <fs_res>-TravelId ]-%cid }{ <fs_res_book>-BookingId }|
                                                                    %target = VALUE #( ( %cid = |{ keys[ TravelId = <fs_res>-TravelId ]-%cid }{ <fs_res_book>-BookingId }{ <fs_res_booksupl>-BookingSupplementId }|
                                                                                         %data = CORRESPONDING #( <fs_res_booksupl> EXCEPT TravelId
                                                                                                                                           BookingId
                                                                                                                                           BookingSupplementId ) ) ) ) ).
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Travel
    CREATE
    SET FIELDS WITH
    CORRESPONDING #( lt_travel_create )
    CREATE BY \_Booking
    SET FIELDS WITH
    CORRESPONDING #( lt_book_create )
    ENTITY Booking
    CREATE BY \_BookingSupplement
    SET FIELDS WITH
    CORRESPONDING #( lt_booksuppl_create )
    MAPPED DATA(lt_mapped)
    REPORTED DATA(lt_rep_create)
    FAILED DATA(lt_failed_create).

    mapped-travel = lt_mapped-travel.

  ENDMETHOD.

ENDCLASS.
