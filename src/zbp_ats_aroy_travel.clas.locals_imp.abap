CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.
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

ENDCLASS.
