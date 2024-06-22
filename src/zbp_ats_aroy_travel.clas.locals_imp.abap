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
    DATA(lv_flag) = abap_true.
  ENDMETHOD.

ENDCLASS.
