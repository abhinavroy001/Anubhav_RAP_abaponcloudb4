CLASS lsc_zats_rv_aroy_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zats_rv_aroy_travel IMPLEMENTATION.

  METHOD save_modified.
*    IF create-travel IS NOT INITIAL.
*      TRY.
*          MODIFY /dmo/log_travel FROM TABLE @( VALUE #( ( change_id = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( )
*                                                          travel_id = create-travel[ 1 ]-TravelId
*                                                          changing_operation = 'CREATE'
*                                                          changed_field_name = 'ALL'
*                                                          changed_value = '*'
*                                                          created_at = cl_abap_tstmp=>utclong2tstmp( utclong = utclong_current( ) ) ) ) ).
*        CATCH cx_uuid_error INTO DATA(lo_cx).
*      ENDTRY.
*
*    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    TYPES: tt_failed     TYPE RESPONSE FOR FAILED EARLY zats_rv_aroy_travel,
           tt_reported   TYPE RESPONSE FOR REPORTED EARLY zats_rv_aroy_travel,
           tt_entities_u TYPE TABLE FOR UPDATE zats_rv_aroy_travel\\travel,
           tt_entities_c TYPE TABLE FOR CREATE zats_rv_aroy_travel\\travel.

  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~copytravel.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.
    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recalctotalprice.

    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~calculatetotalprice.
    METHODS validateheaderdata FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateheaderdata.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE travel.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE travel.
    METHODS acceptrequest FOR MODIFY
      IMPORTING keys FOR ACTION travel~acceptrequest RESULT result.

    METHODS rejectrequest FOR MODIFY
      IMPORTING keys FOR ACTION travel~rejectrequest RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE travel\_booking.

    METHODS precheck_reuse
      IMPORTING
        it_entities_c TYPE tt_entities_c OPTIONAL
        it_entities_u TYPE tt_entities_u OPTIONAL
      EXPORTING
        et_failed     TYPE tt_failed
        et_reported   TYPE tt_reported.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

    DATA: lt_keys     TYPE TABLE FOR AUTHORIZATION KEY zats_rv_aroy_travel\\travel,
          lt_req_auth TYPE STRUCTURE FOR AUTHORIZATION REQUEST zats_rv_aroy_travel\\travel,
          lt_res_auth TYPE TABLE FOR AUTHORIZATION RESULT zats_rv_aroy_travel\\travel.

    CLEAR: lt_keys[],
           lt_res_auth[],
           lt_req_auth.

*/--Get the requisite data from the instance
    READ ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
      IF <fs_result>-OverallStatus EQ 'X'.
        lt_res_auth = VALUE #( BASE lt_res_auth ( TravelId = <fs_result>-TravelId
                                                  %is_draft = <fs_result>-%is_draft
                                                  %update = if_abap_behv=>auth-unauthorized
                                                  %action-copyTravel = if_abap_behv=>auth-unauthorized ) ).
      ELSE.
        lt_res_auth = VALUE #( BASE lt_res_auth ( TravelId = <fs_result>-TravelId
                                                  %is_draft = <fs_result>-%is_draft
                                                  %update = if_abap_behv=>auth-allowed
                                                  %action-copyTravel = if_abap_behv=>auth-allowed ) ).
      ENDIF.
    ENDLOOP.

    result = lt_res_auth.
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

    IF lt_entities IS NOT INITIAL.
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
                                                              %is_draft = <fs_ent>-%is_draft
                                                              %msg = lo_cx ) ).
            failed-travel = VALUE #( BASE failed-travel ( %cid = <fs_ent>-%cid
                                                          %is_draft = <fs_ent>-%is_draft
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
                                                        %is_draft = <fs_ent>-%is_draft
                                                        TravelId = lv_travel_id ) ).
        ENDLOOP.
      ENDIF.
    ELSE.
      mapped-travel = CORRESPONDING #( entities ).
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
        VALUE #( FOR <fs_entity> IN lt_entities ( TravelId = <fs_entity>-TravelId
                                                  %is_draft = <fs_entity>-%is_draft ) )
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
                                                            %is_draft = <fs_book>-%is_draft
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

  METHOD get_instance_features.

    DATA: lt_output TYPE TABLE FOR INSTANCE FEATURES RESULT zats_rv_aroy_travel\\travel.

    READ ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelId OverallStatus )
    WITH
    CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

    IF lt_result IS NOT INITIAL.
      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
        DATA(lv_allow) = COND #( WHEN <fs_result>-OverallStatus EQ 'X'
                                 THEN if_abap_behv=>fc-o-disabled
                                 ELSE if_abap_behv=>fc-o-enabled ).
        result = VALUE #( BASE result ( %tky = <fs_result>-%tky
                                        %is_draft = <fs_result>-%is_draft
                                        %features-%assoc-_Booking = lv_allow ) ).
        CLEAR: lv_allow.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD reCalcTotalPrice.

    DATA: lt_keys TYPE TABLE FOR ACTION IMPORT zats_rv_aroy_travel\\travel~recalctotalprice.

    CLEAR: lt_keys[].

    READ ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel)
    REPORTED DATA(lt_repo_travel)
    FAILED DATA(lt_failed_travel).

    READ ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Travel
    BY \_Booking
    FIELDS ( FlightPrice CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_booking)
    REPORTED DATA(lt_repo_book)
    FAILED DATA(lt_failed_book).

    READ ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Booking
    BY \_BookingSupplement
    FIELDS ( Price CurrencyCode )
    WITH CORRESPONDING #( lt_booking )
    RESULT DATA(lt_bookspl)
    REPORTED DATA(lt_repo_bookspl)
    FAILED DATA(lt_failed_bookspl).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
      CLEAR: <fs_travel>-TotalPrice.
      <fs_travel>-TotalPrice += <fs_travel>-BookingFee.

      LOOP AT lt_booking ASSIGNING FIELD-SYMBOL(<fs_booking>) WHERE TravelId = <fs_travel>-TravelId AND
                                                                    %is_draft = <fs_travel>-%is_draft.

        IF <fs_booking>-CurrencyCode NE <fs_travel>-CurrencyCode.
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = <fs_booking>-FlightPrice
              iv_currency_code_source = <fs_booking>-CurrencyCode
              iv_currency_code_target = <fs_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = DATA(lv_amount)
          ).
          <fs_travel>-TotalPrice += lv_amount.
          CLEAR: lv_amount.
        ELSE.
          <fs_travel>-TotalPrice += <fs_booking>-FlightPrice.
        ENDIF.

        LOOP AT lt_bookspl ASSIGNING FIELD-SYMBOL(<fs_bookspl>) WHERE TravelId = <fs_booking>-TravelId
                                                                  AND BookingId = <fs_booking>-BookingId
                                                                  AND %is_draft = <fs_booking>-%is_draft.

          IF <fs_bookspl>-CurrencyCode NE <fs_travel>-CurrencyCode.
            CLEAR: lv_amount.
            /dmo/cl_flight_amdp=>convert_currency(
              EXPORTING
                iv_amount               = <fs_bookspl>-Price
                iv_currency_code_source = <fs_bookspl>-CurrencyCode
                iv_currency_code_target = <fs_travel>-CurrencyCode
                iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
              IMPORTING
                ev_amount               = lv_amount
            ).
            <fs_travel>-TotalPrice += lv_amount.
          ELSE.
            <fs_travel>-TotalPrice += <fs_bookspl>-Price.
          ENDIF.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( TotalPrice )
    WITH CORRESPONDING #( lt_travel )
    MAPPED DATA(lt_mapped).

  ENDMETHOD.

  METHOD calculateTotalPrice.

    DATA: lt_calc TYPE TABLE FOR DETERMINATION zats_rv_aroy_travel\\travel~calculatetotalprice.
    CLEAR: lt_calc[].

    MODIFY ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Travel
    EXECUTE reCalcTotalPrice
    FROM CORRESPONDING #( keys )
    MAPPED DATA(lt_mapped)
    REPORTED DATA(lt_repo)
    FAILED DATA(lt_failed).

  ENDMETHOD.

  METHOD validateHeaderData.

    TYPES: BEGIN OF ty_customerId,
             customer_id TYPE /dmo/customer_id,
           END OF ty_customerid.
    DATA: lt_keys      TYPE TABLE FOR VALIDATION zats_rv_aroy_travel\\travel~validateheaderdata,
          lt_customers TYPE STANDARD TABLE OF ty_customerId WITH DEFAULT KEY.

    CLEAR: lt_keys[],
           lt_customers[].

    READ ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CustomerId BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    IF lt_travel IS NOT INITIAL.

      lt_customers = CORRESPONDING #( lt_travel MAPPING customer_id = CustomerId ).
      DELETE lt_customers WHERE customer_id IS INITIAL.
      SORT lt_customers BY customer_id.
      DELETE ADJACENT DUPLICATES FROM lt_customers COMPARING customer_id.

      IF lt_customers IS NOT INITIAL.
        SELECT
        FROM /dmo/customer AS _cust
        INNER JOIN @lt_customers AS _customer
        ON _cust~customer_id = _customer~customer_id
        FIELDS
        _cust~customer_id
        INTO TABLE @DATA(lt_cust_db).
        IF sy-subrc IS INITIAL.
        ENDIF.
      ENDIF.

      LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).
        IF <fs_travel>-CustomerId IS INITIAL OR
               NOT line_exists( lt_cust_db[ customer_id = <fs_travel>-CustomerId ] ).

          reported-travel = VALUE #( BASE reported-travel (  TravelId = <fs_travel>-TravelId
                                                             %element-customerid = if_abap_behv=>mk-on
                                                             %is_draft = <fs_travel>-%is_draft
                                                             %msg = new_message_with_text(
                                                                     severity = if_abap_behv_message=>severity-error
                                                                     text     = 'Enter a valid Customer ID'
                                                                   ) ) ).
          failed-travel = VALUE #( BASE failed-travel ( TravelId = <fs_travel>-TravelId
                                                        %is_draft = <fs_travel>-%is_draft
                                                        %fail =  VALUE #( cause = if_abap_behv=>cause-not_found )  ) ).
        ELSEIF <fs_travel>-EndDate LT <fs_travel>-BeginDate.
          reported-travel = VALUE #( BASE reported-travel (  TravelId = <fs_travel>-TravelId
                                                             %element-enddate = if_abap_behv=>mk-on
                                                             %is_draft = <fs_travel>-%is_draft
                                                             %msg = new_message_with_text(
                                                                     severity = if_abap_behv_message=>severity-error
                                                                     text     = 'The End Date cannot be less than the Begin Date'
                                                                   ) ) ).
          failed-travel = VALUE #( BASE failed-travel ( TravelId = <fs_travel>-TravelId
                                                        %is_draft = <fs_travel>-%is_draft
                                                        %fail =  VALUE #( cause = if_abap_behv=>cause-conflict )  ) ).
        ELSEIF <fs_travel>-BeginDate LT cl_abap_context_info=>get_system_date( ).
          reported-travel = VALUE #( BASE reported-travel (  TravelId = <fs_travel>-TravelId
                                                             %element-begindate = if_abap_behv=>mk-on
                                                             %is_draft = <fs_travel>-%is_draft
                                                             %msg = new_message_with_text(
                                                                       severity = if_abap_behv_message=>severity-error
                                                                       text     = |The Begin Date can't be in the past|
                                                                     ) ) ).
          failed-travel = VALUE #( BASE failed-travel ( TravelId = <fs_travel>-TravelId
                                                        %is_draft = <fs_travel>-%is_draft
                                                        %fail =  VALUE #( cause = if_abap_behv=>cause-conflict )  ) ).
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD precheck_create.

*    TYPES: BEGIN OF ty_customerid,
*             customerid TYPE /dmo/customer_id,
*           END OF ty_customerid,
*
*           BEGIN OF ty_agencyid,
*             agencyid TYPE /dmo/agency_id,
*           END OF ty_agencyid.
*
*    DATA: lt_entities   TYPE TABLE FOR CREATE zats_rv_aroy_travel\\travel,
*          lt_customerid TYPE STANDARD TABLE OF ty_customerid WITH DEFAULT KEY,
*          lt_agencyid   TYPE STANDARD TABLE OF ty_agencyid WITH DEFAULT KEY.

    precheck_reuse(
      EXPORTING
        it_entities_c = entities
      IMPORTING
        et_failed     = failed
        et_reported   = reported
    ).


  ENDMETHOD.

  METHOD precheck_update.

*    DATA: lt_entities   TYPE TABLE FOR UPDATE zats_rv_aroy_travel\\travel,
*          lt_customerid TYPE STANDARD TABLE OF ty_customerid WITH DEFAULT KEY,
*          lt_agencyid   TYPE STANDARD TABLE OF ty_agencyid WITH DEFAULT KEY.
*
*    CLEAR: lt_entities[],
*           lt_customerid[],
*           lt_agencyid[].

*    READ ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
*    ENTITY Travel
*    ALL FIELDS
*    WITH CORRESPONDING #( entities )
*    RESULT DATA(lt_result)
*    FAILED DATA(lt_failed)
*    REPORTED DATA(lt_reported).

*    IF lt_result IS NOT INITIAL.
*    lt_customerid = CORRESPONDING #( entities MAPPING customerid = CustomerId ).
*    IF lt_customerid IS NOT INITIAL.
*      SORT lt_customerid BY customerid.
*      DELETE ADJACENT DUPLICATES FROM lt_customerid COMPARING customerid.
*    ENDIF.
*    lt_agencyid = CORRESPONDING #( entities MAPPING agencyid = AgencyId ).
*    IF lt_agencyid IS NOT INITIAL.
*      SORT lt_agencyid BY agencyid.
*      DELETE ADJACENT DUPLICATES FROM lt_agencyid COMPARING agencyid.
*    ENDIF.
*
*    SELECT
*    FROM /dmo/customer AS _cust
*    INNER JOIN @lt_customerid AS _inp
*    ON _inp~customerid = _cust~customer_id
*    FIELDS
*    _inp~customerid
*    INTO TABLE @DATA(lt_cust_valid).
*
*    IF sy-subrc IS INITIAL.
**/--Do Nothing
*    ENDIF.

*    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).
*      IF NOT line_exists( lt_cust_valid[ customerid = <fs_entity>-CustomerId ] ).
*        failed-travel = VALUE #( BASE failed-travel ( %cid = <fs_entity>-%cid_ref
*                                                      %is_draft = <fs_entity>-%is_draft
*                                                      TravelId = <fs_entity>-TravelId
*                                                      %fail-cause = if_abap_behv=>cause-not_found ) ).
*        reported-travel = VALUE #( BASE reported-travel ( %cid = <fs_entity>-%cid_ref
*                                                          %msg = new_message_with_text(
*                                                                   severity = if_abap_behv_message=>severity-error
*                                                                   text     = 'Customer ID is invalid'
*                                                                 )
*                                                          %element-customerid = if_abap_behv=>mk-on ) ).
*      ENDIF.
*    ENDLOOP.

*    ENDIF.

    precheck_reuse(
      EXPORTING
        it_entities_u = entities
      IMPORTING
        et_failed     = failed
        et_reported   = reported
    ).

  ENDMETHOD.

  METHOD precheck_reuse.

    TYPES: BEGIN OF ty_customerid,
             customerid TYPE /dmo/customer_id,
           END OF ty_customerid,

           BEGIN OF ty_agencyid,
             agencyid TYPE /dmo/agency_id,
           END OF ty_agencyid.

    DATA: lr_customerid TYPE RANGE OF /dmo/customer_id,
          lr_agencyid   TYPE RANGE OF /dmo/agency_id.

    CLEAR: lr_agencyid[],
           lr_customerid[].


    IF it_entities_c IS NOT INITIAL.
      DATA(lt_entities_c) = CORRESPONDING lhc_travel=>tt_entities_c( it_entities_c ).
      DELETE lt_entities_c WHERE %control-AgencyId EQ if_abap_behv=>mk-off AND
                                 %control-CustomerId EQ if_abap_behv=>mk-off.
      IF lt_entities_c IS NOT INITIAL.
        lr_agencyid = CORRESPONDING #( lt_entities_c MAPPING low = AgencyId EXCEPT * ).
        LOOP AT lr_agencyid ASSIGNING FIELD-SYMBOL(<fs_agency>).
          <fs_agency>-sign = 'I'.
          <fs_agency>-option = 'EQ'.
        ENDLOOP.
        SORT lr_agencyid BY low.
        DELETE ADJACENT DUPLICATES FROM lr_agencyid COMPARING low.

        lr_customerid = CORRESPONDING #( lt_entities_c MAPPING low = CustomerId EXCEPT * ).
        LOOP AT lr_customerid ASSIGNING FIELD-SYMBOL(<fs_customer>).
          <fs_customer>-sign = 'I'.
          <fs_customer>-option = 'EQ'.
        ENDLOOP.
        SORT lr_customerid BY low.
        DELETE ADJACENT DUPLICATES FROM lr_customerid COMPARING low.


        SELECT
        FROM /dmo/agency AS _dbagency
        INNER JOIN @lr_agencyid AS _agencyid
        ON _agencyid~low = _dbagency~agency_id
        FIELDS
        _dbagency~agency_id,
        _dbagency~country_code
        INTO TABLE @DATA(lt_agency_validation).
        IF sy-subrc IS INITIAL.

        ENDIF.

        SELECT
        FROM /dmo/customer AS _dbcustomer
        INNER JOIN @lr_customerid AS _customerid
        ON _customerid~low = _dbcustomer~customer_id
        FIELDS
        _dbcustomer~customer_id,
        _dbcustomer~country_code
        INTO TABLE @DATA(lt_customer_validation).
        IF sy-subrc IS INITIAL.

        ENDIF.

        LOOP AT lt_entities_c ASSIGNING FIELD-SYMBOL(<fs_ent>).
          IF VALUE #( lt_agency_validation[ agency_id = <fs_ent>-AgencyId ]-country_code OPTIONAL ) NE
             VALUE #( lt_customer_validation[ customer_id = <fs_ent>-CustomerId ]-country_code OPTIONAL ).
            et_failed-travel = VALUE #( BASE et_failed-travel ( %cid = <fs_ent>-%cid
                                                                %is_draft = <fs_ent>-%is_draft
                                                                %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) ).
            et_reported-travel = VALUE #( BASE et_reported-travel ( %cid = <fs_ent>-%cid
                                                                    %is_draft = <fs_ent>-%is_draft
                                                                    %msg = new_message_with_text(
                                                                             severity = if_abap_behv_message=>severity-error
                                                                             text     = 'Country code is different for Agency ID & Customer ID'
                                                                           )
                                                                    %element-agencyid = if_abap_behv=>mk-on
                                                                    %element-customerid = if_abap_behv=>mk-on ) ).
          ENDIF.
        ENDLOOP.
      ENDIF.

    ELSEIF it_entities_u IS NOT INITIAL.
      DATA(lt_entities_u) = CORRESPONDING lhc_travel=>tt_entities_u( it_entities_u ).
      DELETE lt_entities_u WHERE %control-AgencyId EQ if_abap_behv=>mk-off AND
                                 %control-CustomerId EQ if_abap_behv=>mk-off.
      IF lt_entities_u IS NOT INITIAL.
        lr_agencyid = CORRESPONDING #( lt_entities_u MAPPING low = AgencyId EXCEPT * ).
        LOOP AT lr_agencyid ASSIGNING <fs_agency>.
          <fs_agency>-sign = 'I'.
          <fs_agency>-option = 'EQ'.
        ENDLOOP.
        SORT lr_agencyid BY low.
        DELETE ADJACENT DUPLICATES FROM lr_agencyid COMPARING low.
        lr_customerid = CORRESPONDING #( lt_entities_u MAPPING low = CustomerId EXCEPT * ).
        LOOP AT lr_customerid ASSIGNING <fs_customer>.
          <fs_customer>-sign = 'I'.
          <fs_customer>-option = 'EQ'.
        ENDLOOP.
        SORT lr_customerid BY low.
        DELETE ADJACENT DUPLICATES FROM lr_customerid COMPARING low.

*/--Select valid Agencies
        SELECT
        FROM /dmo/agency AS _dbagency
        INNER JOIN @lr_agencyid AS _agencyid
        ON _agencyid~low = _dbagency~agency_id
        FIELDS
        _dbagency~agency_id,
        _dbagency~country_code
        INTO TABLE @lt_agency_validation.
        IF sy-subrc IS INITIAL.

        ENDIF.

*/--Select valid Customers
        SELECT
        FROM /dmo/customer AS _dbcustomer
        INNER JOIN @lr_customerid AS _customerid
        ON _customerid~low = _dbcustomer~customer_id
        FIELDS
        _dbcustomer~customer_id,
        _dbcustomer~country_code
        INTO TABLE @lt_customer_validation.
        IF sy-subrc IS INITIAL.

        ENDIF.

        LOOP AT lt_entities_u ASSIGNING FIELD-SYMBOL(<fs_ent_u>).
          IF VALUE #( lt_agency_validation[ agency_id = <fs_ent_u>-AgencyId ]-country_code OPTIONAL ) NE
             VALUE #( lt_customer_validation[ customer_id = <fs_ent_u>-CustomerId ]-country_code OPTIONAL ).
            et_failed-travel = VALUE #( BASE et_failed-travel ( %cid = <fs_ent_u>-%cid_ref
                                                                TravelId = <fs_ent_u>-TravelId
                                                                %is_draft = <fs_ent_u>-%is_draft
                                                                %fail = VALUE #( cause = if_abap_behv=>cause-conflict ) ) ).
            et_reported-travel = VALUE #( BASE et_reported-travel ( %cid = <fs_ent_u>-%cid_ref
                                                                    %is_draft = <fs_ent_u>-%is_draft
                                                                    TravelId = <fs_ent_u>-TravelId
                                                                    %msg = new_message_with_text(
                                                                             severity = if_abap_behv_message=>severity-error
                                                                             text     = 'Country code is different for Agency ID & Customer ID'
                                                                           )
                                                                    %element-agencyid = if_abap_behv=>mk-on
                                                                    %element-customerid = if_abap_behv=>mk-on ) ).
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.


  ENDMETHOD.

  METHOD AcceptRequest.
    DATA: lt_result_m   TYPE TABLE FOR ACTION RESULT zats_rv_aroy_travel\\travel~acceptrequest,
          lt_mapped_m   TYPE RESPONSE FOR MAPPED EARLY zats_rv_aroy_travel,
          lt_failed_m   TYPE RESPONSE FOR FAILED EARLY zats_rv_aroy_travel,
          lt_reported_m TYPE RESPONSE FOR REPORTED EARLY zats_rv_aroy_travel.

    CLEAR: lt_result_m[],
           lt_mapped_m,
           lt_failed_m,
           lt_reported_m.

    MODIFY ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY travel
    UPDATE
    SET FIELDS WITH
    VALUE #( FOR <fs_key> IN keys ( %cid_ref = <fs_key>-%cid_ref
                                    %is_draft = <fs_key>-%is_draft
                                    travelid = <fs_key>-TravelId
                                    OverallStatus = 'A' ) )
    MAPPED DATA(lt_mapped)
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

*    IF lt_mapped-travel IS NOT INITIAL.
    READ ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    REPORTED lt_reported
    FAILED lt_failed.

    IF lt_result IS NOT INITIAL.
      result = VALUE #( FOR <fs_result> IN lt_result ( %is_draft = <fs_result>-%is_draft
                                                        travelid = <fs_result>-TravelId
                                                        %param = CORRESPONDING #( <fs_result> )
                                                  ) ).
      reported = lt_reported.
      failed = lt_failed.
    ENDIF.

*    ENDIF.

  ENDMETHOD.

  METHOD RejectRequest.
    MODIFY ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
      ENTITY travel
      UPDATE
      SET FIELDS WITH
      VALUE #( FOR <fs_key> IN keys ( %cid_ref = <fs_key>-%cid_ref
                                      %is_draft = <fs_key>-%is_draft
                                      travelid = <fs_key>-TravelId
                                      OverallStatus = 'R' ) )
      MAPPED DATA(lt_mapped)
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

*    IF lt_mapped-travel IS NOT INITIAL.
    READ ENTITIES OF zats_rv_aroy_travel IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    REPORTED lt_reported
    FAILED lt_failed.

    IF lt_result IS NOT INITIAL.
      result = VALUE #( FOR <fs_result> IN lt_result ( %is_draft = <fs_result>-%is_draft
                                                        travelid = <fs_result>-TravelId
                                                        %param = CORRESPONDING #( <fs_result> )
                                                  ) ).
      reported = lt_reported.
      failed = lt_failed.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
