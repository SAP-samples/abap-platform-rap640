"! <p class="shorttext synchronized" lang="en">
"!  ABAP Cloud API for conversions: Methods
"! </p>
"!
"! Conversion routines for central data entities for BAPI consumption.
INTERFACE zif_conversion_ext_int
  PUBLIC .

  METHODS:
    "! Translates ISO currency key into the SAP internal currency key.
    "!
    "! @parameter iso_code | ISO code for the currency
    "! @parameter sap_code | SAP internal code for the currency
    "! @parameter is_unique | Is there only one SAP code for the ISO code provided?
    currency_code_ext_to_int
      IMPORTING
                VALUE(iso_code)  TYPE isocd
      EXPORTING
                VALUE(sap_code)  TYPE waers_curc
                VALUE(is_unique) TYPE abap_bool
      RAISING   ZCX_conversion_ext_int ,

    "! Translates a SAP internal country key into the ISO code
    "!
    "! @parameter sap_code | SAP internal code for the currency
    "! @parameter iso_code | ISO code for the currency
    currency_code_int_to_ext
      IMPORTING
                VALUE(sap_code) TYPE waers_curc
      EXPORTING
                VALUE(iso_code) TYPE isocd
      RAISING   ZCX_conversion_ext_int ,

    "! Translates the external amount into the SAP internal amount.
    "!
    "! @parameter currency | ISO code for the currency
    "! @parameter bapi_amount | External format of the amount
    "! @parameter sap_amount | SAP internal format of the amount
    currency_amount_ext_to_int
      IMPORTING
                VALUE(currency)    TYPE waers_curc
                VALUE(bapi_amount) TYPE bapicurr_d
      EXPORTING
                VALUE(sap_amount)  TYPE bapicurr_d
      RAISING   ZCX_conversion_ext_int ,

    "! Translates the SAP internal amount into the amount in the external format.
    "!
    "! @parameter currency | ISO code for the currency
    "! @parameter sap_amount | SAP internal format of the amount
    "! @parameter bapi_amount | External format of the amount
    currency_amount_int_to_ext
      IMPORTING
                VALUE(currency)    TYPE waers_curc
                VALUE(sap_amount)  TYPE bapicurr_d
      EXPORTING
                VALUE(bapi_amount) TYPE bapicurr_d
      RAISING   ZCX_conversion_ext_int ,

    "! Translates the ISO code for the language into the SAP internal format.
    "!
    "! @parameter iso_code | ISO code for the language
    "! @parameter sap_code | SAP code for the language
    language_code_ext_to_int
      IMPORTING
                VALUE(iso_code) TYPE laiso
      EXPORTING
                VALUE(sap_code) TYPE spras
      RAISING   ZCX_conversion_ext_int ,

    "! Translates the SAP internal code for the language into the ISO Code.
    "!
    "! @parameter sap_code | SAP code for the language
    "! @parameter iso_code | ISO code for the language
    language_code_int_to_ext
      IMPORTING
                VALUE(sap_code) TYPE spras
      EXPORTING
                VALUE(iso_code) TYPE laiso
      RAISING   ZCX_conversion_ext_int ,

    "! Translates the ISO code for the unit of measure into the SAP internal format.
    "!
    "! @parameter iso_code | ISO code for the unit of measure
    "! @parameter sap_code | SAP code for the unit of measure
    "! @parameter unique   | Boolean value indicating if more than one SAP code is mapped to the ISO code
    unit_of_measure_ext_to_int
      IMPORTING
                VALUE(iso_code) TYPE isocd_unit
      EXPORTING
                VALUE(sap_code) TYPE msehi
                VALUE(unique)   TYPE xfeld
      RAISING   ZCX_conversion_ext_int ,

    "! Translates the SAP internal code for the unit of measure into the ISO code.
    "!
    "! @parameter sap_code | SAP code for the unit of measure
    "! @parameter iso_code | ISO code for the unit of measure
    unit_of_measure_int_to_ext
      IMPORTING
                VALUE(sap_code) TYPE msehi
      EXPORTING
                VALUE(iso_code) TYPE isocd_unit
      RAISING   ZCX_conversion_ext_int.

ENDINTERFACE.
