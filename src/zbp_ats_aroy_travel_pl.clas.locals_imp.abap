CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS augment_create FOR MODIFY
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD augment_create.
    DATA: lt_entities TYPE TABLE FOR CREATE zats_cv_aroy_travel\\travel.
    CLEAR: lt_entities[].
    lt_entities = CORRESPONDING #( entities ).
    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<fs_entities>).
      <fs_entities>-BeginDate = cl_abap_context_info=>get_system_date( ) + 5.
      <fs_entities>-CurrencyCode = 'EUR'.
      <fs_entities>-OverallStatus = 'O'.
      <fs_entities>-%control-BeginDate = if_abap_behv=>mk-on.
      <fs_entities>-%control-OverallStatus = if_abap_behv=>mk-on.
      <fs_entities>-%control-CurrencyCode = if_abap_behv=>mk-on.
    ENDLOOP.

    MODIFY AUGMENTING ENTITIES OF zats_rv_aroy_travel
    ENTITY Travel
    CREATE
    SET FIELDS WITH CORRESPONDING #( lt_entities ).
  ENDMETHOD.

ENDCLASS.
