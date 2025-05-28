CLASS zcx_conversion_ext_int DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check "cx_xco_runtime_exception
  FINAL
  CREATE PUBLIC .

*CX_STATIC_CHECK and implementing the interface IF_T100_DYN_MSG.

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg.

    CONSTANTS:
      gc_msgid TYPE symsgid VALUE 'ZCM_CONV_EXT_INT',

      BEGIN OF bapi_amount_incorrect,
        msgid TYPE symsgid VALUE 'CM_CONV_EXT_INT',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF bapi_amount_incorrect
      ,
      BEGIN OF value_not_found,
        msgid TYPE symsgid VALUE 'ZCM_CONV_EXT_INT',
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF value_not_found
      ,
      BEGIN OF no_iso_code_maintained,
        msgid TYPE symsgid VALUE 'ZCM_CONV_EXT_INT',
        msgno TYPE symsgno VALUE '020',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF  no_iso_code_maintained
      ,
      BEGIN OF other_error,
        msgid TYPE symsgid VALUE 'ZCM_CONV_EXT_INT',
        msgno TYPE symsgno VALUE '030',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF  other_error
      .


    DATA attr1 TYPE string.
    DATA attr2 TYPE string.

    CLASS-METHODS class_constructor .
    METHODS constructor
      IMPORTING
        !textid LIKE if_t100_message=>t100key OPTIONAL
*        !previous   LIKE previous OPTIONAL
        !attr1  TYPE string OPTIONAL
        !attr2  TYPE string OPTIONAL .


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_conversion_ext_int IMPLEMENTATION.

  METHOD class_constructor.
  ENDMETHOD.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor(
*      textid   = textid
*      previous =
    ).

    me->attr1 = attr1.
    me->attr2 = attr2.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
