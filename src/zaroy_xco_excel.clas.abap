CLASS zaroy_xco_excel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_users,
        user_id   TYPE string,
        user_name TYPE string,
        user_mail TYPE string,
      END OF ty_users,

      tt_users TYPE STANDARD TABLE OF ty_users WITH EMPTY KEY,

      BEGIN OF ty_parts,
        dummy   TYPE string,
        country TYPE string,
        ranking TYPE string,
      END OF ty_parts,

      tt_parts TYPE STANDARD TABLE OF ty_parts WITH EMPTY KEY.

    CONSTANTS: BEGIN OF cs_sheets,
                 currency TYPE string VALUE `Currency`,
                 country  TYPE string VALUE `Country`,
                 users    TYPE string VALUE `Users`,
               END OF cs_sheets.

    CONSTANTS c_sender   TYPE cl_bcs_mail_message=>ty_address VALUE ''.
    CONSTANTS c_receiver TYPE cl_bcs_mail_message=>ty_address VALUE ''.


ENDCLASS.



CLASS ZAROY_XCO_EXCEL IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.
ENDCLASS.
