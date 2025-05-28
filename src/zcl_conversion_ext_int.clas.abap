CLASS zcl_conversion_ext_int DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    INTERFACES zif_conversion_ext_int .

    CLASS-DATA mo_instance TYPE REF TO zcl_conversion_ext_int READ-ONLY.

    CLASS-METHODS:
      "! Factory method to create a new conversion for BAPI consumption instance
      "! @parameter ro_instance | Conversion for BAPI consumption instance
      "! @raising ZCX_conversion_ext_int | Conversion for BAPI consumption exception
      get_instance
        RETURNING
          VALUE(ro_instance) TYPE REF TO zif_conversion_ext_int "cl_conversion_ext_int
        RAISING
          zcx_conversion_ext_int.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_conversion_ext_int IMPLEMENTATION.

  METHOD zif_conversion_ext_int~currency_amount_ext_to_int.

    CALL FUNCTION 'CURRENCY_AMOUNT_BAPI_TO_SAP'
      EXPORTING
        currency              = currency
        bapi_amount           = bapi_amount
      IMPORTING
        sap_amount            = sap_amount
      EXCEPTIONS
        bapi_amount_incorrect = 1.
    CASE sy-subrc .
      WHEN 0.
      WHEN 1.
        RAISE EXCEPTION TYPE ZCX_conversion_ext_int
          EXPORTING
            textid = ZCX_conversion_ext_int=>bapi_amount_incorrect.
    ENDCASE.

  ENDMETHOD.


  METHOD zif_conversion_ext_int~currency_amount_int_to_ext.
    CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_BAPI'
      EXPORTING
        currency    = currency
        sap_amount  = sap_amount
      IMPORTING
        bapi_amount = bapi_amount.
  ENDMETHOD.


  METHOD zif_conversion_ext_int~currency_code_ext_to_int.
*  DATA unique TYPE calltrans2.
    CALL FUNCTION 'CURRENCY_CODE_ISO_TO_SAP'
      EXPORTING
        iso_code  = iso_code
      IMPORTING
        sap_code  = sap_code
        unique    = is_unique
      EXCEPTIONS
        not_found = 1.

    CASE sy-subrc.
      WHEN 0.
      WHEN 1.
        RAISE EXCEPTION TYPE ZCX_conversion_ext_int
          EXPORTING
            textid = ZCX_conversion_ext_int=>value_not_found
            attr1  = |{ iso_code }|.
    ENDCASE.
  ENDMETHOD.


  METHOD zif_conversion_ext_int~currency_code_int_to_ext.

    CALL FUNCTION 'CURRENCY_CODE_SAP_TO_ISO'
      EXPORTING
        sap_code  = sap_code
*       no_msg_repetition =
*       no_msg_output     =
      IMPORTING
        iso_code  = iso_code
*       not_allowed =
*       msg_out   =
      EXCEPTIONS
        not_found = 1.
    CASE sy-subrc.
      WHEN 0.
      WHEN 1.
        RAISE EXCEPTION TYPE ZCX_conversion_ext_int
          EXPORTING
            textid = ZCX_conversion_ext_int=>value_not_found
            attr1  = |{ sap_code }|.
    ENDCASE.


  ENDMETHOD.


  METHOD zif_conversion_ext_int~language_code_ext_to_int.

    CALL FUNCTION 'LANGUAGE_CODE_ISO_TO_SAP'
      EXPORTING
        iso_code  = iso_code
      IMPORTING
        sap_code  = sap_code
      EXCEPTIONS
        not_found = 1.

    CASE sy-subrc.
      WHEN 0.
      WHEN 1.
        RAISE EXCEPTION TYPE ZCX_conversion_ext_int
          EXPORTING
            textid = ZCX_conversion_ext_int=>value_not_found
            attr1  = |{ iso_code }|.
    ENDCASE.

  ENDMETHOD.


  METHOD zif_conversion_ext_int~language_code_int_to_ext.

    CALL FUNCTION 'LANGUAGE_CODE_SAP_TO_ISO'
      EXPORTING
        sap_code  = sap_code
      IMPORTING
        iso_code  = iso_code
      EXCEPTIONS
        not_found = 1.
    CASE sy-subrc.
      WHEN 0.
      WHEN 1.
        RAISE EXCEPTION TYPE ZCX_conversion_ext_int
          EXPORTING
            textid = ZCX_conversion_ext_int=>value_not_found
            attr1  = |{ sap_code }|.
    ENDCASE.


  ENDMETHOD.


  METHOD zif_conversion_ext_int~unit_of_measure_ext_to_int.

    CALL FUNCTION 'cl_abap_unit_assert=>fail( msg    = |sap_code { lv_sap_code } should not exist| ).UNIT_OF_MEASURE_ISO_TO_SAP'
      EXPORTING
        iso_code  = iso_code
      IMPORTING
        sap_code  = sap_code
        unique    = unique
      EXCEPTIONS
        not_found = 1.
    CASE sy-subrc.
      WHEN 0.
      WHEN 1.
        RAISE EXCEPTION TYPE ZCX_conversion_ext_int
          EXPORTING
            textid = ZCX_conversion_ext_int=>value_not_found
            attr1  = |{ sap_code }|.

    ENDCASE.

  ENDMETHOD.


  METHOD zif_conversion_ext_int~unit_of_measure_int_to_ext.

    CALL FUNCTION 'UNIT_OF_MEASURE_SAP_TO_ISO'
      EXPORTING
        sap_code    = sap_code
      IMPORTING
        iso_code    = iso_code
      EXCEPTIONS
        not_found   = 1
        no_iso_code = 2.
    CASE sy-subrc.
      WHEN 0.
      WHEN 1.
        RAISE EXCEPTION TYPE ZCX_conversion_ext_int
          EXPORTING
            textid = ZCX_conversion_ext_int=>value_not_found
            attr1  = |{ sap_code }|.
      WHEN 2.
        RAISE EXCEPTION TYPE ZCX_conversion_ext_int
          EXPORTING
            textid = ZCX_conversion_ext_int=>no_iso_code_maintained
            attr1  = |{ iso_code }|.
    ENDCASE.

  ENDMETHOD.



  METHOD get_instance.

    IF mo_instance IS INITIAL.
      mo_instance = NEW zcl_conversion_ext_int( ).
    ENDIF.

    ro_instance = mo_instance.

  ENDMETHOD.

ENDCLASS.
