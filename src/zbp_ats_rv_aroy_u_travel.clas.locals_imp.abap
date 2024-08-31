CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Travel.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Travel.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Travel.

    METHODS read FOR READ
      IMPORTING keys FOR READ Travel RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Travel.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS statuschange FOR MODIFY
      IMPORTING keys FOR ACTION Travel~statuschange RESULT result.

    METHODS createNewEntity FOR MODIFY
      IMPORTING keys FOR ACTION Travel~createNewEntity.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    DATA: lt_entities   TYPE TABLE FOR CREATE zats_rv_aroy_u_travel\\travel,
          lt_messages   TYPE /dmo/t_message,
          ls_legacy_in  TYPE /dmo/travel,
          ls_legacy_out TYPE /dmo/travel.

    CLEAR: lt_entities[],
           lt_messages[],
           ls_legacy_in,
           ls_legacy_out.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entities>).
      CLEAR: ls_legacy_in.
      ls_legacy_in = CORRESPONDING #( <fs_entities> MAPPING FROM ENTITY USING CONTROL ).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( ls_legacy_in )
        IMPORTING
          es_travel   = ls_legacy_out
          et_messages = lt_messages.

      IF lt_messages IS INITIAL.
        mapped-travel = VALUE #( BASE mapped-travel ( %cid = <fs_entities>-%cid TravelId = ls_legacy_out-travel_id ) ).
      ELSE.
        failed-travel = VALUE #( BASE failed-travel ( %cid = <fs_entities>-%cid
                                                      TravelId = <fs_entities>-TravelId
                                                      %fail-cause = if_abap_behv=>cause-unspecific  ) ).
        LOOP AT lt_messages ASSIGNING FIELD-SYMBOL(<fs_msg>).
          reported-travel = VALUE #( BASE reported-travel ( %cid = <fs_entities>-%cid
                                                            TravelId = <fs_entities>-TravelId
                                                            %msg = new_message(
                                                                     id       = <fs_msg>-msgid
                                                                     number   = <fs_msg>-msgno
                                                                     severity = CONV #( <fs_msg>-msgty )
                                                                     v1       = <fs_msg>-msgv1
                                                                     v2       = <fs_msg>-msgv2
                                                                     v3       = <fs_msg>-msgv3
                                                                     v4       = <fs_msg>-msgv4
                                                                   ) ) ).
        ENDLOOP.
      ENDIF.
      CLEAR: ls_legacy_in,
             ls_legacy_out.
    ENDLOOP.

  ENDMETHOD.

  METHOD update.
    DATA: ls_legacy_entity_in TYPE /dmo/travel,
          ls_legacy_entity_x  TYPE /dmo/s_travel_inx,
          lt_messages         TYPE /dmo/t_message.
    CLEAR: lt_messages[],
           ls_legacy_entity_in,
           ls_legacy_entity_x.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entities>).
      ls_legacy_entity_in = CORRESPONDING #( <fs_entities> MAPPING FROM ENTITY ).
      ls_legacy_entity_x-_intx = CORRESPONDING zats_aroy_c_travel( <fs_entities> MAPPING FROM ENTITY ).
*      ls_legacy_entity_x-_intx = CORRESPONDING /dmo/s_travel_intx( <fs_entities> MAPPING FROM ENTITY ).
*      ls_legacy_entity_x-_intx = CORRESPONDING /dmo/s_travel_intx( <fs_entities> MAPPING agency_id = AgencyId ).
      ls_legacy_entity_x-travel_id = <fs_entities>-TravelId.
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( ls_legacy_entity_in )
          is_travelx  = CORRESPONDING /dmo/s_travel_inx( ls_legacy_entity_x )
        IMPORTING
          et_messages = lt_messages.
      IF lt_messages IS INITIAL.
        mapped-travel = VALUE #( BASE mapped-travel ( TravelId = <fs_entities>-TravelId ) ).
      ELSE.
        failed-travel = VALUE #( BASE failed-travel ( TravelId = <fs_entities>-TravelId
                                                      %fail-cause = if_abap_behv=>cause-unspecific  ) ).
        LOOP AT lt_messages ASSIGNING FIELD-SYMBOL(<fs_msg>).
          reported-travel = VALUE #( BASE reported-travel ( TravelId = <fs_entities>-TravelId
                                                            %msg = new_message(
                                                                     id       = <fs_msg>-msgid
                                                                     number   = <fs_msg>-msgno
                                                                     severity = CONV #( <fs_msg>-msgty )
                                                                     v1       = <fs_msg>-msgv1
                                                                     v2       = <fs_msg>-msgv2
                                                                     v3       = <fs_msg>-msgv3
                                                                     v4       = <fs_msg>-msgv4
                                                                   ) ) ).
        ENDLOOP.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD delete.
    DATA lt_messages TYPE /dmo/t_message.
    CLEAR: lt_messages[].
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_DELETE'
        EXPORTING
          iv_travel_id = <fs_key>-travelid
        IMPORTING
          et_messages  = lt_messages.

      IF lt_messages IS INITIAL.
        mapped-travel = VALUE #( BASE mapped-travel ( travelid = <fs_key>-TravelId ) ).
      ELSE.
        failed-travel = VALUE #( BASE failed-travel ( %cid = <fs_key>-%cid_ref
                                                       TravelId = <fs_key>-TravelId
                                                       %fail-cause = if_abap_behv=>cause-unspecific  ) ).
        LOOP AT lt_messages ASSIGNING FIELD-SYMBOL(<fs_msg>).
          reported-travel = VALUE #( BASE reported-travel ( %cid = <fs_key>-%cid_ref
                                                            TravelId = <fs_key>-TravelId
                                                            %msg = new_message(
                                                                     id       = <fs_msg>-msgid
                                                                     number   = <fs_msg>-msgno
                                                                     severity = CONV #( <fs_msg>-msgty )
                                                                     v1       = <fs_msg>-msgv1
                                                                     v2       = <fs_msg>-msgv2
                                                                     v3       = <fs_msg>-msgv3
                                                                     v4       = <fs_msg>-msgv4
                                                                   ) ) ).
        ENDLOOP.
      ENDIF.
      CLEAR: lt_messages[].
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    DATA: lt_messages   TYPE /dmo/t_message,
          ls_legacy_out TYPE /dmo/travel.
    CLEAR: lt_messages[],
           ls_legacy_out.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <fs_key>-travelid
        IMPORTING
          es_travel    = ls_legacy_out
          et_messages  = lt_messages.
      IF lt_messages IS INITIAL.
        result = VALUE #( BASE result ( CORRESPONDING #( ls_legacy_out MAPPING TO ENTITY ) ) ).
      ELSE.
        failed-travel = VALUE #( BASE failed-travel ( travelId = <fs_key>-TravelId
                                                      %fail-cause = if_abap_behv=>cause-unspecific  ) ).
        LOOP AT lt_messages ASSIGNING FIELD-SYMBOL(<fs_msg>).
          reported-travel = VALUE #( BASE reported-travel ( TravelId = <fs_key>-TravelId
                                                            %msg = new_message(
                                                                     id       = <fs_msg>-msgid
                                                                     number   = <fs_msg>-msgno
                                                                     severity = CONV #( <fs_msg>-msgty )
                                                                     v1       = <fs_msg>-msgv1
                                                                     v2       = <fs_msg>-msgv2
                                                                     v3       = <fs_msg>-msgv3
                                                                     v4       = <fs_msg>-msgv4
                                                                   ) ) ).
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD statuschange.
  ENDMETHOD.

  METHOD createNewEntity.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZATS_RV_AROY_U_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZATS_RV_AROY_U_TRAVEL IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_SAVE'.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
