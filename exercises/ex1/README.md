 # Exercise 1: Implement a Wrapper for the "Create Purchase Requisition" (BAPI_PR_CREATE) function module
<!-- description --> Learn how to wrap the BAPI_PR_CREATE in your SAP S/4HANA system and release it for consumption in ABAP for cloud development.

## Prerequisites

When you want to perform this script in your own SAP S/4HANA system the following prerequisites must be met:     

- You have to have a system based on **SAP S/4HANA 2022 or 2023** on premise or private cloud.
- You have to have enabled Developer extensibility as described in the [SAP Online Help](https://help.sap.com/docs/ABAP_PLATFORM_NEW/b5670aaaa2364a29935f40b16499972d/31367ef6c3e947059e0d7c1cbfcaae93.html?q=set%20up%20developer%20extensibility&locale=en-US)   

## Introduction
Now that you're connected to your SAP S/4HANA system, go ahead with this exercise where you will learn how to deal with the situation where there is no convenient released SAP API for creating purchase requisitions. 

The [ABAP Cloud API Enablement Guidelines for SAP S/4HANA Cloud Private Edition and SAP S/4HANA](https://www.sap.com/documents/2023/05/b0bd8ae6-747e-0010-bca6-c68f7e60039b.html) recommend using a _Classic API_ such as an appropriate BAPI as an alternative to a released API, wrapping it, and then releasing the wrapper for _use in cloud 
development_. 

In a later exercise you will then create a Shopping Cart RAP business object for a Fiori elements online shopping app using the ABAP Cloud development model and integrate this wrapper to create purchase requisitions.

- [You will learn](#you-will-learn)
- [Summary & Next Exercise](#summary--next-exercise)  


## You will learn
- How to generate a wrapper interface, a wrapper class and a factory class for the `BAPI_PR_CREATE`.
- How to create an ABAP package in a software component with 
language version ABAP for Cloud Development (superpackage: `ZLOCAL`)   
- How to test that the wrapper objects have been released for for _use in cloud development_.

> **Reminder:**   
> Don't forget to replace all occurences of the placeholder **`###`** with your assigned group number in the exercise steps below.  
> You can use the ADT function **Replace All** (**Ctrl+F**) for the purpose.   
> If you don't have a group number, choose a 3-digit suffix and use it for all exercises.


## Step 1: Get to know the BAPI _`BAPI_PR_CREATE`_ via the BAPI Explorer

<details>
  <summary>🔵 Click to expand!</summary>
  
The first step is to look for a suitable classic API to create purchase requisitions. You can use the BAPI Explorer for this purpose. Connect to the backend of your SAP S/4HANA system and start transaction **`BAPI`** by opening the embedded SAP GUI (**Ctrl+6**) and entering **`/nBAPI`** in the command field. For the purpose of this tutorial, we will use the non-released BAPI **`BAPI_PR_CREATE`**.

For that, switch to the **Alphabetical** view (1), look for the Business Object **`PurchaseRequisition`** (2), find and click on the method **`CreateFromData1`** (3). You can see that its function module is the **`BAPI_PR_CREATE`** (4).

<!-- ![BAPI explorer](images/bapi_explorer.png) -->
<img alt="BAPI explorer" src="images/bapi_explorer.png" width="70%">

In the **Documentation** tab you can find more information on what the BAPI is used for (in this case: to create purchase requisitions) and you can find examples for various scenarios and how to fill the respective parameter values.

In the **Tools** section you can click on the **Function Builder** and then click on **Display** to see the required parameters:

<!-- ![BAPI explorer - Tools](images/bapi_explorer-tools.png) -->
<img alt="BAPI explorer - Tools" src="images/bapi_explorer-tools.png" width="70%">

<!-- ![BAPI explorer - Function Builder](images/bapi_explorer-function_builder.png) -->
<img alt="BAPI explorer - Function Builder" src="images/bapi_explorer-function_builder.png" width="70%">

>The `BAPI_PR_CREATE` has a `TESTRUN` parameter that can be used to call the BAPI in validation mode. Some BAPI have a similar test mode that can be used to validate input data. It is best practice to make use of this test mode, if available, as we will address in more details in a later [exercise](./exercises/ex5/Readme.md) of this hands-on.

</details>

## Step 2: Create a development package in HOME or an existing software component for classic ABAP

You will develop the wrapper in a dedicated package under the structure package **`ZTIER2`** in your SAP S/4HANA system.   

<details>
  <summary>🔵 Click to expand</summary>
  
  1. In ADT, open your SAP S/4HANA system project folder, right click on it and select **New** > **ABAP Package** and enter the following values:   

     - Name:         **`ZTIER2_###`**   
     - Superpackage: **`ZTIER2`**      
     - Description:  **`Group ### - Tier2`.**      

  2. Select **Add to favorite packages** for easy access later on. Keep the Package Type as **Development** and click on **Next**.  

  3. Do not change anything in the following wizard window (where the software component HOME is selected), and click on **Next**.       

     <img alt="Create Tier 2 package" src="images/create_tier2_package_2.png" width="70%">    

  4. Create a new transport request and give it a meaningful name such as `classic ABAP development - Group ###` so that it can be more easily identified. 
     Then click on **Finish**. The package will be created.   


</details>  

## Step 3: Generate a technical wrapper class, interface and factory class

You now want to wrap the API `BAPI_PR_CREATE`. For this we create an interface, a wrapper class and a factory class:

<details>
  <summary>🔵 Click to expand</summary>

> **The interface:**     
> Depending on your specific use-case, you normally would need to access only certain specific functionalities and methods of the BAPI you want to expose. An ABAP Interface is the perfect development object for this purpose. The interface simplifies and restricts the usage of the underlying BAPI for the specific use-case, by exposing only the parameters that are needed. As a consequence, non-wrapped functionalities are forbidden.

> **The wrapper class:**    
> In addition you need a class to wrap the BAPI (implementing the interface) and implement its methods. The wrapper class has a method defined in the private section, `call_bapi_pr_create`, which has access to all the parameters of the underlying BAPI. Having this type of central private method is best practice. Internally, the wrapper class has access to all the parameters and then the interface has virtual access to all of these parameters and exposes publicly only the ones that are needed depending on the specific use-case. 

> **C1-release for use in cloud development:**    
> Since we plan to access the wrapped BAPI using the ABAP Cloud development model, it is good to provide the possibility to test it, and to keep wrapping-specific coding using the ABAP Cloud development model to a minimum. For this reason, the interface approach is recommended, and the wrapper class will not be released directly for consumption in ABAP for cloud development, but rather will be accessible via a factory class that will also be created.

> **The factory class:**
> A factory class is used to control the instantiation of the wrapper class and in order to be able to use it in ABAP for cloud development it has to be released for use in ABAP for cloud development. 

This approach has the advantage of a clear control of when and where an instance of the wrapper class is created, and in the event in which several wrapper classes are needed all their instantiations could be handled inside one single factory class.  Also, in case of wrapper classes this has the advantage that in case the wrapper class is changed throughout it's software lifecycle, at a later point in time a different class could be initialized, without changes to the consumer implementation. In this tutorial we follow the [clean code best practices](https://blogs.sap.com/2022/05/05/how-to-enable-clean-code-checks-for-abap/) for ABAP development. For example: the wrapper class is ready for ABAP Unit Tests and [ABAP Doc](https://blogs.sap.com/2013/04/29/abap-doc/) is implemented.

**Create the wrapper interface**

In order to create the wrapper interface, right click on your previously created package `ZTIER2_###` and select **New > ABAP Interface** and input the Name `ZIF_WRAP_BAPI_PR_###`.

Copy and paste the following code into your previously created interface:

<details>
  <summary>🟡📄 Click to expand and view or copy the source code!</summary>

```ABAP

      INTERFACE ZIF_WRAP_BAPI_PR_###
      PUBLIC.

      TYPES:
        BEGIN OF bapimereqheader,
          preq_no         TYPE banfn,
          pr_type         TYPE bsart,
          ctrl_ind        TYPE bsakz,
          general_release TYPE gsfrg,
          create_ind      TYPE estkz,
          item_intvl      TYPE pincr,
          last_item       TYPE lponr,
          auto_source     TYPE kzzuo,
          memory          TYPE membf,
          hold_complete   TYPE bapimereqpostflag,
          hold_uncomplete TYPE bapimereqpostflag,
          park_complete   TYPE bapimereqpostflag,
          park_uncomplete TYPE bapimereqpostflag,
          memorytype      TYPE memorytype,
        END OF bapimereqheader.

      TYPES:
        BEGIN OF bapimereqheaderx,
          preq_no         TYPE bapiupdate,
          pr_type         TYPE bapiupdate,
          ctrl_ind        TYPE bapiupdate,
          general_release TYPE bapiupdate,
          create_ind      TYPE bapiupdate,
          item_intvl      TYPE bapiupdate,
          last_item       TYPE bapiupdate,
          auto_source     TYPE bapiupdate,
          memory          TYPE bapiupdate,
          hold_complete   TYPE bapiupdate,
          hold_uncomplete TYPE bapiupdate,
          park_complete   TYPE bapiupdate,
          park_uncomplete TYPE bapiupdate,
          memorytype      TYPE bapiupdate,
        END OF bapimereqheaderx.
      TYPES:
        char1             TYPE c LENGTH 000001.

      TYPES:
        _bapiparex        TYPE STANDARD TABLE OF bapiparex WITH DEFAULT KEY.

      TYPES:
        BEGIN OF bapimereqaccountx,
          preq_item        TYPE bnfpo,
          serial_no        TYPE dzekkn,
          preq_itemx       TYPE bapiupdate,
          serial_nox       TYPE bapiupdate,
          delete_ind       TYPE bapiupdate,
          creat_date       TYPE bapiupdate,
          quantity         TYPE bapiupdate,
          distr_perc       TYPE bapiupdate,
          net_value        TYPE bapiupdate,
          gl_account       TYPE bapiupdate,
          bus_area         TYPE bapiupdate,
          costcenter       TYPE bapiupdate,
          sd_doc           TYPE bapiupdate,
          itm_number       TYPE bapiupdate,
          sched_line       TYPE bapiupdate,
          asset_no         TYPE bapiupdate,
          sub_number       TYPE bapiupdate,
          orderid          TYPE bapiupdate,
          gr_rcpt          TYPE bapiupdate,
          unload_pt        TYPE bapiupdate,
          co_area          TYPE bapiupdate,
          costobject       TYPE bapiupdate,
          profit_ctr       TYPE bapiupdate,
          wbs_element      TYPE bapiupdate,
          network          TYPE bapiupdate,
          rl_est_key       TYPE bapiupdate,
          part_acct        TYPE bapiupdate,
          cmmt_item        TYPE bapiupdate,
          rec_ind          TYPE bapiupdate,
          funds_ctr        TYPE bapiupdate,
          fund             TYPE bapiupdate,
          func_area        TYPE bapiupdate,
          ref_date         TYPE bapiupdate,
          tax_code         TYPE bapiupdate,
          taxjurcode       TYPE bapiupdate,
          nond_itax        TYPE bapiupdate,
          acttype          TYPE bapiupdate,
          co_busproc       TYPE bapiupdate,
          res_doc          TYPE bapiupdate,
          res_item         TYPE bapiupdate,
          activity         TYPE bapiupdate,
          grant_nbr        TYPE bapiupdate,
          cmmt_item_long   TYPE bapiupdate,
          func_area_long   TYPE bapiupdate,
          budget_period    TYPE bapiupdate,
          service_doc      TYPE bapiupdate,
          service_item     TYPE bapiupdate,
          service_doc_type TYPE bapiupdate,
        END OF bapimereqaccountx.
      TYPES:
        _bapimereqaccountx TYPE STANDARD TABLE OF bapimereqaccountx WITH DEFAULT KEY.

      TYPES:
        BEGIN OF bapimereqitemimp ,
          preq_item                     TYPE bnfpo,
          ctrl_ind                      TYPE bsakz,
          delete_ind                    TYPE eloek,
          pur_group                     TYPE ekgrp,
          preq_name                     TYPE afnam,
          short_text                    TYPE txz01,
          material                      TYPE matnr18,
          material_external             TYPE mgv_material_external,
          material_guid                 TYPE mgv_material_guid,
          material_version              TYPE mgv_material_version,
          pur_mat                       TYPE ematn18,
          pur_mat_external              TYPE mgv_pur_mat_external,
          pur_mat_guid                  TYPE mgv_pur_mat_guid,
          pur_mat_version               TYPE mgv_pur_mat_version,
          plant                         TYPE ewerk,
          store_loc                     TYPE lgort_d,
          trackingno                    TYPE bednr,
          matl_group                    TYPE matkl,
          suppl_plnt                    TYPE reswk,
          quantity                      TYPE bamng,
          unit                          TYPE bamei,
          preq_unit_iso                 TYPE bamei_iso,
          preq_date                     TYPE badat,
          del_datcat_ext                TYPE lpein,
          deliv_date                    TYPE eindt,
          rel_date                      TYPE frgdt,
          gr_pr_time                    TYPE webaz,
          preq_price                    TYPE bapicurext,
          price_unit                    TYPE epein,
          item_cat                      TYPE pstyp,
          acctasscat                    TYPE knttp,
          distrib                       TYPE vrtkz,
          part_inv                      TYPE twrkz,
          gr_ind                        TYPE wepos,
          gr_non_val                    TYPE weunb,
          ir_ind                        TYPE repos,
          des_vendor                    TYPE wlief,
          fixed_vend                    TYPE flief,
          purch_org                     TYPE ekorg,
          agreement                     TYPE konnr,
          agmt_item                     TYPE ktpnr,
          info_rec                      TYPE infnr,
          mrp_ctrler                    TYPE dispo,
          bomexpl_no                    TYPE sernr,
          val_type                      TYPE bwtar_d,
          commitment                    TYPE xoblr,
          closed                        TYPE ebakz,
          reserv_no                     TYPE rsnum,
          fixed                         TYPE bafix,
          po_unit                       TYPE bstme,
          po_unit_iso                   TYPE bstme_iso,
          rev_lev                       TYPE revlv,
          pckg_no                       TYPE packno,
          kanban_ind                    TYPE kbnkz,
          po_price                      TYPE bpueb,
          int_obj_no                    TYPE cuobj,
          promotion                     TYPE waktion,
          batch                         TYPE charg_d,
          cmmt_item                     TYPE fipos,
          funds_ctr                     TYPE fistl,
          fund                          TYPE bp_geber,
          matl_cat                      TYPE attyp,
          address2                      TYPE adrnr_mm,
          address                       TYPE adrn2,
          customer                      TYPE ekunnr,
          supp_vendor                   TYPE emlif,
          sc_vendor                     TYPE lblkz,
          valuation_spec_stock          TYPE kzbws,
          currency                      TYPE waers,
          currency_iso                  TYPE bapiisocd,
          vend_mat                      TYPE idnlf,
          manuf_prof                    TYPE mprof,
          langu                         TYPE spras,
          langu_iso                     TYPE spras_iso,
          validity_object               TYPE techs,
          fw_order                      TYPE sfordn,
          fw_order_item                 TYPE fordp,
          plnd_delry                    TYPE plifz,
          deliv_time                    TYPE lzeit,
          ref_req                       TYPE refbn,
          ref_req_item                  TYPE rfbps,
          grant_nbr                     TYPE gm_grant_nbr,
          func_area                     TYPE fkber,
          req_blocked                   TYPE blckd,
          reason_blocking               TYPE blckt,
          version                       TYPE revno,
          procuring_plant               TYPE beswk,
          ext_proc_prof                 TYPE meprofile,
          ext_proc_ref_doc              TYPE eprefdoc,
          ext_proc_ref_item             TYPE eprefitm,
          funds_res                     TYPE kblnr_fi,
          res_item                      TYPE kblpos,
          suppl_stloc                   TYPE reslo,
          prio_urgency                  TYPE prio_urg,
          prio_requirement              TYPE prio_req,
          new_bom_explosion             TYPE bom_expl,
          minremlife                    TYPE mhdrz,
          period_ind_expiration_date    TYPE dattp,
          budget_period                 TYPE fm_budget_period,
          bras_nbm                      TYPE j_1bnbmco1,
          matl_usage                    TYPE j_1bmatuse,
          mat_origin                    TYPE j_1bmatorg,
          in_house                      TYPE j_1bownpro,
          indus3                        TYPE j_1bindus3,
          req_segment                   TYPE sgt_rcat16,
          stk_segment                   TYPE sgt_scat16,
          avail_date                    TYPE dat00,
          material_long                 TYPE matnr40,
          pur_mat_long                  TYPE ematn40,
          req_seg_long                  TYPE sgt_rcat40,
          stk_seg_long                  TYPE sgt_scat40,
          expected_value                TYPE commitment,
          limit_amount                  TYPE sumlimit,
          producttype                   TYPE product_type,
          serviceperformer              TYPE serviceperformer,
          startdate                     TYPE mmpur_servproc_period_start,
          enddate                       TYPE mmpur_servproc_period_end,
          spe_crm_ref_so                TYPE /spe/ref_vbeln_crm,
          spe_crm_ref_item              TYPE /spe/ref_posnr_crm,
          expert_mode                   TYPE mmpur_pr_ssp_expert_mode,
          txs_business_transaction      TYPE txs_business_transaction,
          txs_usage_purpose             TYPE txs_usage_purpose,
          tax_code                      TYPE mwskz,
          delivery_address_type         TYPE purdeliveryaddrtype,
          contract_for_limit            TYPE ctr_for_limit,
          iscrreplicationbeforeapproval TYPE mmpur_pr_cen_reqn_repl_bfr_app,
          mmpur_pr_cen_reqn_app_rpld_pr TYPE mmpur_pr_cen_reqn_app_rpld_pr,
          ssp_author                    TYPE mmpur_req_d_author,
          ssp_requestor                 TYPE mmpur_req_d_requestor,
          ssp_catalogid                 TYPE bbp_ws_service_id,
          contract_item_for_limit       TYPE ctr_item_for_limit,
        END OF bapimereqitemimp.
      TYPES:
        _bapimereqitemimp               TYPE STANDARD TABLE OF bapimereqitemimp WITH DEFAULT KEY.

      TYPES:
        BEGIN OF bapimereqitemx ,
          preq_item                     TYPE bnfpo,
          preq_itemx                    TYPE bapiupdate,
          ctrl_ind                      TYPE bapiupdate,
          delete_ind                    TYPE bapiupdate,
          pur_group                     TYPE bapiupdate,
          preq_name                     TYPE bapiupdate,
          short_text                    TYPE bapiupdate,
          material                      TYPE bapiupdate,
          material_external             TYPE bapiupdate,
          material_guid                 TYPE bapiupdate,
          material_version              TYPE bapiupdate,
          pur_mat                       TYPE bapiupdate,
          pur_mat_external              TYPE bapiupdate,
          pur_mat_guid                  TYPE bapiupdate,
          pur_mat_version               TYPE bapiupdate,
          plant                         TYPE bapiupdate,
          store_loc                     TYPE bapiupdate,
          trackingno                    TYPE bapiupdate,
          matl_group                    TYPE bapiupdate,
          suppl_plnt                    TYPE bapiupdate,
          quantity                      TYPE bapiupdate,
          unit                          TYPE bapiupdate,
          preq_unit_iso                 TYPE bapiupdate,
          preq_date                     TYPE bapiupdate,
          del_datcat_ext                TYPE bapiupdate,
          deliv_date                    TYPE bapiupdate,
          rel_date                      TYPE bapiupdate,
          gr_pr_time                    TYPE bapiupdate,
          preq_price                    TYPE bapiupdate,
          price_unit                    TYPE bapiupdate,
          item_cat                      TYPE bapiupdate,
          acctasscat                    TYPE bapiupdate,
          distrib                       TYPE bapiupdate,
          part_inv                      TYPE bapiupdate,
          gr_ind                        TYPE bapiupdate,
          gr_non_val                    TYPE bapiupdate,
          ir_ind                        TYPE bapiupdate,
          des_vendor                    TYPE bapiupdate,
          fixed_vend                    TYPE bapiupdate,
          purch_org                     TYPE bapiupdate,
          agreement                     TYPE bapiupdate,
          agmt_item                     TYPE bapiupdate,
          info_rec                      TYPE bapiupdate,
          mrp_ctrler                    TYPE bapiupdate,
          bomexpl_no                    TYPE bapiupdate,
          val_type                      TYPE bapiupdate,
          commitment                    TYPE bapiupdate,
          closed                        TYPE bapiupdate,
          reserv_no                     TYPE bapiupdate,
          fixed                         TYPE bapiupdate,
          po_unit                       TYPE bapiupdate,
          po_unit_iso                   TYPE bapiupdate,
          rev_lev                       TYPE bapiupdate,
          pckg_no                       TYPE bapiupdate,
          kanban_ind                    TYPE bapiupdate,
          po_price                      TYPE bapiupdate,
          int_obj_no                    TYPE bapiupdate,
          promotion                     TYPE bapiupdate,
          batch                         TYPE bapiupdate,
          cmmt_item                     TYPE bapiupdate,
          funds_ctr                     TYPE bapiupdate,
          fund                          TYPE bapiupdate,
          matl_cat                      TYPE bapiupdate,
          address2                      TYPE bapiupdate,
          address                       TYPE bapiupdate,
          customer                      TYPE bapiupdate,
          supp_vendor                   TYPE bapiupdate,
          sc_vendor                     TYPE bapiupdate,
          valuation_spec_stock          TYPE bapiupdate,
          currency                      TYPE bapiupdate,
          currency_iso                  TYPE bapiupdate,
          vend_mat                      TYPE bapiupdate,
          manuf_prof                    TYPE bapiupdate,
          langu                         TYPE bapiupdate,
          langu_iso                     TYPE bapiupdate,
          validity_object               TYPE bapiupdate,
          fw_order                      TYPE bapiupdate,
          fw_order_item                 TYPE bapiupdate,
          plnd_delry                    TYPE bapiupdate,
          deliv_time                    TYPE bapiupdate,
          ref_req                       TYPE bapiupdate,
          ref_req_item                  TYPE bapiupdate,
          grant_nbr                     TYPE bapiupdate,
          func_area                     TYPE bapiupdate,
          req_blocked                   TYPE bapiupdate,
          reason_blocking               TYPE bapiupdate,
          version                       TYPE bapiupdate,
          procuring_plant               TYPE bapiupdate,
          ext_proc_prof                 TYPE bapiupdate,
          ext_proc_ref_doc              TYPE bapiupdate,
          ext_proc_ref_item             TYPE bapiupdate,
          funds_res                     TYPE bapiupdate,
          res_item                      TYPE bapiupdate,
          suppl_stloc                   TYPE bapiupdate,
          prio_urgency                  TYPE bapiupdate,
          prio_requirement              TYPE bapiupdate,
          new_bom_explosion             TYPE bapiupdate,
          minremlife                    TYPE bapiupdate,
          period_ind_expiration_date    TYPE bapiupdate,
          budget_period                 TYPE bapiupdate,
          bras_nbm                      TYPE bapiupdate,
          matl_usage                    TYPE bapiupdate,
          mat_origin                    TYPE bapiupdate,
          in_house                      TYPE bapiupdate,
          indus3                        TYPE bapiupdate,
          req_segment                   TYPE bapiupdate,
          stk_segment                   TYPE bapiupdate,
          avail_date                    TYPE bapiupdate,
          material_long                 TYPE bapiupdate,
          pur_mat_long                  TYPE bapiupdate,
          req_seg_long                  TYPE bapiupdate,
          stk_seg_long                  TYPE bapiupdate,
          expected_value                TYPE bapiupdate,
          limit_amount                  TYPE bapiupdate,
          producttype                   TYPE bapiupdate,
          serviceperformer              TYPE bapiupdate,
          startdate                     TYPE bapiupdate,
          enddate                       TYPE bapiupdate,
          spe_crm_ref_so                TYPE bapiupdate,
          spe_crm_ref_item              TYPE bapiupdate,
          expert_mode                   TYPE bapiupdate,
          tax_code                      TYPE bapiupdate,
          delivery_address_type         TYPE bapiupdate,
          contract_for_limit            TYPE bapiupdate,
          iscrreplicationbeforeapproval TYPE bapiupdate,
          mmpur_pr_cen_reqn_app_rpld_pr TYPE bapiupdate,
          ssp_author                    TYPE bapiupdate,
          ssp_requestor                 TYPE bapiupdate,
          ssp_catalogid                 TYPE bapiupdate,
          contract_item_for_limit       TYPE bapiupdate,
        END OF bapimereqitemx.
      TYPES:
        _bapimereqitemx TYPE STANDARD TABLE OF bapimereqitemx WITH DEFAULT KEY.

      TYPES:
        _bapiret2       TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

      METHODS bapi_pr_create
        IMPORTING
          !prheader    TYPE bapimereqheader OPTIONAL
          !prheaderx   TYPE bapimereqheaderx OPTIONAL
          !testrun     TYPE char1 OPTIONAL
        EXPORTING
          !number      TYPE banfn
          !prheaderexp TYPE bapimereqheader
            CHANGING
          !pritem      TYPE _bapimereqitemimp
          !pritemx     TYPE _bapimereqitemx OPTIONAL
          !return      TYPE _bapiret2 OPTIONAL.
      ENDINTERFACE.
```
</details>

**Create the wrapper factory class**

Next, create the wrapper factory class. Right click on your package `ZTIER2_###` and select **New > ABAP Class** and input the Name `ZCL_F_WRAP_BAPI_PR_###`:

Copy and paste the following code into your previously created factory class:

<details>
  <summary>🟡📄 Click to expand and view or copy the source code!</summary>

```ABAP
  CLASS ZCL_F_WRAP_BAPI_PR_### DEFINITION
    PUBLIC
    FINAL
    CREATE PRIVATE.

    PUBLIC SECTION.

      CLASS-METHODS create_instance
        IMPORTING
          !destination  TYPE rfcdest OPTIONAL
        RETURNING
          VALUE(result) TYPE REF TO ZIF_WRAP_BAPI_PR_###.
    PROTECTED SECTION.
    PRIVATE SECTION.

      METHODS constructor.
  ENDCLASS.

  CLASS ZCL_F_WRAP_BAPI_PR_### IMPLEMENTATION.

    METHOD constructor.
    ENDMETHOD.

    METHOD create_instance.
      result = NEW ZCL_WRAP_BAPI_PR_###( destination = destination  ).
    ENDMETHOD.
  ENDCLASS.  
```
</details>

**Hint:** At this point, it is not yet possible to save and activate the class. To achieve this, the wrapper class described in the next section must first be created. Once the wrapper class is created, the factory class can also be saved and activated.

**Create the BAPI wrapper class**

Now create the BAPI wrapper class. Right click on your package `ZTIER2_###` and select **New > ABAP Class** and input the Name `ZCL_WRAP_BAPI_PR_###`:

Copy and paste the following code into your previously created wrapper class:

<details>
  <summary>🟡📄 Click to expand and view or copy the source code!</summary>

```ABAP
 CLASS ZCL_WRAP_BAPI_PR_### DEFINITION
    PUBLIC
    CREATE PRIVATE

    GLOBAL FRIENDS ZCL_F_WRAP_BAPI_PR_###.

    PUBLIC SECTION.


      INTERFACES ZIF_WRAP_BAPI_PR_###.
    PROTECTED SECTION.

      DATA destination TYPE rfcdest .
    PRIVATE SECTION.

      METHODS call_bapi_pr_create
        IMPORTING
          !prheader     TYPE ZIF_WRAP_BAPI_PR_###~bapimereqheader OPTIONAL
          !prheaderx    TYPE ZIF_WRAP_BAPI_PR_###~bapimereqheaderx OPTIONAL
          !testrun      TYPE ZIF_WRAP_BAPI_PR_###~char1 OPTIONAL
        EXPORTING
          !number       TYPE banfn
          !prheaderexp  TYPE ZIF_WRAP_BAPI_PR_###~bapimereqheader
        CHANGING
          !extensionin  TYPE ZIF_WRAP_BAPI_PR_###~_bapiparex OPTIONAL
          !extensionout TYPE ZIF_WRAP_BAPI_PR_###~_bapiparex OPTIONAL
          !praccountx   TYPE ZIF_WRAP_BAPI_PR_###~_bapimereqaccountx OPTIONAL
          !pritem       TYPE ZIF_WRAP_BAPI_PR_###~_bapimereqitemimp
          !pritemx      TYPE ZIF_WRAP_BAPI_PR_###~_bapimereqitemx OPTIONAL
          !return       TYPE ZIF_WRAP_BAPI_PR_###~_bapiret2 OPTIONAL

        RAISING
          cx_root.

      METHODS constructor
        IMPORTING
          !destination TYPE rfcdest .
  ENDCLASS.

  CLASS ZCL_WRAP_BAPI_PR_### IMPLEMENTATION.


    METHOD call_bapi_pr_create.
      DATA: _rfc_message_ TYPE c LENGTH 255.
      CALL FUNCTION 'BAPI_PR_CREATE' DESTINATION me->destination
        EXPORTING
          prheader              = prheader
          prheaderx             = prheaderx
          testrun               = testrun
        IMPORTING
          number                = number
          prheaderexp           = prheaderexp
        TABLES
          extensionin           = extensionin
          extensionout          = extensionout
          praccountx            = praccountx
          pritem                = pritem
          pritemx               = pritemx
          return                = return.
    ENDMETHOD.

    METHOD constructor.
      me->destination = destination.
    ENDMETHOD.

    METHOD ZIF_WRAP_BAPI_PR_###~bapi_pr_create.
      TRY.
          me->call_bapi_pr_create(
          EXPORTING
            prheader = prheader
            prheaderx = prheaderx
            testrun = testrun
          IMPORTING
            number = number
            prheaderexp = prheaderexp
          CHANGING
            return = return
            pritemx = pritemx
            pritem = pritem

        ).
        CATCH cx_root INTO DATA(lx_root_pr_create).

      ENDTRY.
    ENDMETHOD.
  ENDCLASS.
```
</details>

Now it should be possible to active both, the wrapper class and the factory class.

</details>  

## Step 4: Create a package in a software component with language version ABAP for Cloud Development   

**Hint:** In case no CAL instance of a preconfigured SAP S/4HANA appliance is used, please set up for developer extensibility to get `ZTIER1` package as described in section **Prerequisites**.    

<details>
  <summary>🔵 Click to expand</summary>

  1. In ADT, open your SAP S/4HANA system project folder, right click on it and select **New** > **ABAP Package**.
  2. Enter the following values:         

     - Name:         **`Z_PURCHASE_REQ_###`**
     - Superpackage: **`ZTIER1`**
     - Description:  **`Group ### - Tier1`.**      

     Select **Add to favorite packages** for easy access later on. Keep the Package Type as **Development** and click on **Next**.    

  7. Click on **Next** and then **Next** again. Select a suitable transport request (or create a new one if needed) and then click on **Finish**.

    
      
</details>

## Step 5: Release the wrapper interface and factory class

Now you need to release the wrapper interface and wrapper factory class for consumption in ABAP Cloud Development. To do this, you need to add a Release Contract (C1) to both objects for use system-internally (Contract C1).

In your Project Explorer open the ABAP Interface you created. In the **Properties** tab click on the **API State** tab and then click on the green plus icon next to the Use System-Internally (Contract C1).

<img alt="C1 Release Interface" src="images/C1_Release_Interface.png" width="70%">

Make sure the **Release State** is set to **Released** and check the option **Use in Cloud Development**:

<img alt="Set release state" src="images/C1_Release_Interface_Set_Release_State.png" width="70%">

Click on Next. The changes will be validated. No issues should arise.
Click on Next and then click on Finish.

The API State tab will now show the new Release State:

<img alt="C1 Released Interface" src="images/C1_Released_Interface.png" width="70%">

Repeat the same steps to release the factory class you created:

<img alt="C1 Release Factory" src="images/C1_Released_Factory.png" width="70%">

>You will not release the wrapper class.


## Step 6: Test the technical wrapper class with console application in ABAP for cloud development

The wrapper you just created is now released for consumption in ABAP for cloud development. You can test this by creating a console application in ABAP for cloud development to call the wrapper. 

We will use this class that calls the wrapper also to add a conversion functionality and to simplify the signature of the method that is used to create a purchase requistion as well. 

For this you have created a dedicated package **`Z_PURCHASE_REQ_###`** for this test in ABAP for cloud development by using **`ZTIER1`** as the super-package of your package in your SAP S/4HANA System.

<details>
  <summary>🔵 Click to expand</summary>  
   
1. Create a class for the console application.  
   Right click on the newly created package **`Z_PURCHASE_REQ_###`** and select **New** > **ABAP Class** and enter the following values:  
    - **Name**: **`zcl_wrap_purchase_req_bapi_###`**   
    - **Description**: **Wrapper and test class**  

2. Click on **Next**, select a suitable transport request (or create a new one if needed) and then click on **Finish**.

3. You can check that the newly created class is a ABAP for cloud development class by checking that the **ABAP Language Version** is `ABAP Language for Cloud Development` in the **Properties** > **General** tab:

<!-- ![Console application language](images/console_application_language.png) -->
<img alt="Console application language" src="images/console_application_language.png" width="70%">

4. Implement the newly created class as shown below. The class calls the wrapper factory class and, given some input parameter values like the delivery date and the item price, creates a purchase requisition for that specific item and prints the information to the console.   
         
 <details>
  <summary>🟡📄 Click to expand and view or copy the source code!</summary>

```ABAP

CLASS zcl_wrap_purchase_req_bapi_### DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    DATA use_conversions TYPE abap_boolean VALUE abap_true READ-ONLY.

    METHODS bapi_pr_create
      IMPORTING purchase_req_header TYPE zif_wrap_bapi_pr_###=>bapimereqheader
                purchase_req_items  TYPE zif_wrap_bapi_pr_###=>_bapimereqitemimp
                test_run            TYPE abap_bool
      EXPORTING pr_return_msg       TYPE zif_wrap_bapi_pr_###=>_bapiret2
      RETURNING VALUE(result)       TYPE banfn.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS zcl_wrap_purchase_req_bapi_### IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA pr_returns TYPE bapirettab.

    "if the data element banfn is not released for the use in cloud develoment in your system
    "you have to use the shadow type zif_wrap_bapi_pr_###=>banfn
    DATA number  TYPE banfn  .
    "DATA number  TYPE zif_wrap_bapi_pr_###=>banfn  .

    DATA purchase_req_header TYPE zif_wrap_bapi_pr_###=>bapimereqheader .
    DATA purchase_req_items  TYPE zif_wrap_bapi_pr_###=>_bapimereqitemimp .

    DATA test_run TYPE abap_boolean .

    purchase_req_header = VALUE #( pr_type = 'NB' ).

    purchase_req_items = VALUE #( (
                              preq_item  = '00010'
                              plant      = '1010'
                              acctasscat = 'U'
                              currency   = 'EUR'                              
                              deliv_date = cl_abap_context_info=>get_system_date(  ) + 14   "format: yyyy-mm-dd (at least 10 days)
                              material   = 'ZPRINTER01'
                              matl_group = 'A001'
                              preq_price = '100'
                              quantity   = '1'
                              unit       = 'ST'
                              pur_group = '001'
                              purch_org = '1010'
                              short_text = 'ZPRINTER01'
                    ) ).

    "just for testing purposes "
*    use_conversions = abap_false.
*    purchase_req_items[ 1 ]-currency = 'JPY'.

    "in addition you can try out to use the BAPI in the test mode
*   test_run = abap_true.

    bapi_pr_create(
      EXPORTING
        purchase_req_header     = purchase_req_header
        purchase_req_items      = purchase_req_items
        test_run                = test_run
      IMPORTING
        pr_return_msg = pr_returns
      RECEIVING
        result        = number
    ).

    COMMIT WORK AND WAIT.

    IF test_run = abap_true.
      out->write( | test_run | ).
    ELSE.
      out->write( |purchase requisition number: { number  } | ).

      SELECT * FROM I_PurchaseRequisitionItemAPI01 WHERE PurchaseRequisition = @number
                                         INTO TABLE @DATA(purchase_requisitions).

      LOOP AT purchase_requisitions INTO DATA(purchase_requisition).
        out->write( | Item: { purchase_requisition-PurchaseRequisitionItem } Amount { purchase_requisition-PurchaseRequisitionPrice }  { purchase_requisition-PurReqnItemCurrency }| ).
      ENDLOOP.

    ENDIF.

    LOOP AT pr_returns INTO DATA(bapiret2_line).
      out->write( |bapi_return { bapiret2_line-type } : { bapiret2_line-message } | ).
    ENDLOOP.

  ENDMETHOD.

  METHOD bapi_pr_create.

*    DATA prheader TYPE zif_wrap_bapi_pr_###=>bapimereqheader .
    DATA prheaderx TYPE zif_wrap_bapi_pr_###=>bapimereqheaderx .
    DATA pritem  TYPE zif_wrap_bapi_pr_###=>_bapimereqitemimp .
    DATA pritemx  TYPE zif_wrap_bapi_pr_###=>_bapimereqitemx  .
    DATA pritemx_line LIKE LINE OF pritemx.
    DATA prheaderexp  TYPE zif_wrap_bapi_pr_###=>bapimereqheader .
    DATA conversion_message_line TYPE bapiret2.

    "if the data element banfn is not released for the use in cloud develoment in your system
    "you have to use the shadow type zif_wrap_bapi_pr_###=>banfn
    DATA number  TYPE banfn  .
    "DATA number  TYPE zif_wrap_bapi_pr_###=>banfn  .
    DATA conversion_messages TYPE bapirettab.

    prheaderx = VALUE #( pr_type = 'X' ).

    "item data has to be converted
    pritem = purchase_req_items.

    LOOP AT pritem ASSIGNING FIELD-SYMBOL(<pritem_line>).

      pritemx_line =
                      VALUE #(
                               preq_item  = '00010'
                               plant      = 'X'
                               acctasscat = 'X'
                               currency   = 'X'
                               deliv_date = 'X'
                               material   = 'X'
                               matl_group = 'X'
                               preq_price = 'X'
                               quantity   = 'X'
                               unit       = 'X'
                               pur_group  = 'X'
                               purch_org  = 'X'
                               short_text = 'X'
                              ) .

      APPEND pritemx_line TO pritemx.

      IF use_conversions = abap_true.

        TRY.

            zcl_conversion_ext_int=>get_instance( )->currency_amount_int_to_ext(
              EXPORTING
                currency    = <pritem_line>-Currency
                sap_amount  = CONV #( <pritem_line>-preq_price )
              IMPORTING
                bapi_amount = DATA(bapi_amount)
            ).

            zcl_conversion_ext_int=>get_instance( )->currency_code_int_to_ext(
              EXPORTING
                sap_code = <pritem_line>-Currency
              IMPORTING
                iso_code = DATA(bapi_currency)
            ).

            <pritem_line>-preq_price = bapi_amount.
            <pritem_line>-Currency = bapi_currency.

          CATCH zcx_conversion_ext_int INTO DATA(conversion_exception).

            conversion_message_line-id = conversion_exception->if_t100_message~t100key-msgid.
            conversion_message_line-number = conversion_exception->if_t100_message~t100key-msgno.
            conversion_message_line-type = if_abap_behv_message=>severity-warning.
            conversion_message_line-message_v1 = conversion_exception->attr1.
            conversion_message_line-message_v2 = conversion_exception->attr2.
            APPEND conversion_message_line TO conversion_messages.

        ENDTRY.
      ENDIF.
    ENDLOOP.

    TRY.
        zcl_f_wrap_bapi_pr_###=>create_instance( )->bapi_pr_create(
            EXPORTING
              prheader  = purchase_req_header
              prheaderx = prheaderx
              testrun   = test_run
            IMPORTING
              number      = number
              prheaderexp = prheaderexp
            CHANGING
              pritem          = pritem
              pritemx         = pritemx
              return          = pr_return_msg
              )
          .
        result = number.

        APPEND LINES OF conversion_messages TO pr_return_msg.

      CATCH cx_root INTO DATA(error).
        "does not happen since there is no rfc call
        ASSERT 1 = 2.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.

```
 </details>   

5. Save and activate your changes.   

6. Now run this class  by pressing F9.   

7. You shall see an output as follows:

   <img alt="Console output test class" src="images/console_output_test_class.png" width="70%">   

> Tip:  
> Add a breakpoint in the `bapi_pr_create()` method of your coding where your technical wrapper class `zcl_f_wrap_bapi_pr_###` is being called.    
> `zcl_f_wrap_bapi_pr_###=>create_instance( )->bapi_pr_create`   
  
 </details>



## Step 7: Understand conversion problems

### Introduction

For historical reasons currency amounts in the SAP system, are all stored with two decimal places. Currency amounts thus have to be converted from an SAP system format to a format that can be understood externally, if a currency has a different number of decimal places. For example, a currency amount stored SAP internally as 100.00 may de-facto mean 10000 if it is about Japanese Yen.  

Another use case where conversion takes place between the data format that is used externally and the data that is used withing an SAP system is the conversion of currency codes and unit codes between SAP internal and external (ISO) ones.   

Since BAPI's have been designed as external API's they expect that data is provided in the external format. The data of the payload of an OData request that is accessible in the behavior implementation class has however already been converted to the SAP internal format.   

This means that when calling a BAPI we have to convert data such as amounts back to the external format. In the ABAP language version **ABAP Standard** you would be able to use the function modules such as `currency_amount_sap_to_idoc` to perform this conversion.   

Since this function module and other function modules that perform these conversions are however **not released** for the use in cloud development, a wrapper class is needed. For your convenience we have provided the class `zcl_conversion_ext_int` for this purpose that is available in systems that have been provided by SAP for hands-on workshops. It is planned to provide a class as part of the SAP standard in the near future as well. This class is also planned to be made available as SAP Note for lower releases.   

<details>
  <summary>🔵 Click to expand to check the conversion problem!</summary>
  

### Check the conversion problem  

1. Open the class `zcl_wrap_purchase_req_bapi_###` in ADT.
2. Start the class by pressing **F9**.
3. Navigate to the `main` method
4. Remove the comment **Ctrl+>** from the lines   

   ```   
   *   use_conversions = abap_false.`
   *   purchase_req_items[ 1 ]-currency = 'JPY'.
   ```  
   <img alt="Change wrapper class I" src="images/06_000_adapt_wrapper_class.png" width="70%">   

5. Your code should now look like as follows:   

   <img alt="Change wrapper class I" src="images/06_010_adapt_wrapper_class.png" width="70%">   
   
8. Save and activate your changes.
9. Start the class by pressing **F9**.  

   <img alt="Change wrapper class I" src="images/06_020_adapt_wrapper_class.png" width="70%">   
 
By setting the global variable `use_conversions` to `abap_false` for testing purposes you have changed the behavior of your wrapper class such, that:   
- now Japanese Yen will be used to create the purchase requisition and that
- in method `bapi_pr_create()` now the conversion class `zcl_conversion_ext_int` is not used anymore to convert the amount from the SAP internal format to the external format   

As a result the value stored in the purchase requisition would be `1 JPY` instead of the intended amount `100 JPY`.   
  
</details>   

## Step 8: Fix conversion problem using released conversion class

Navigate to the method `bapi_pr_create()` in your wrapper class `zcl_wrap_purchase_req_bapi_###`.    

Here you see that the wrapper class takes the values of the incoming payload stored in the import parameter `purchase_req_items` and moves it to the internal table `pritem` because the values of the import parameter are read-only.   

Using the class C1-released class `zcl_conversion_ext_int` the content of the fields `amount` and `currency` are being converted from the SAP internal format to the external format expected by the BAPI.    

The variable `use_conversions` is read-only and set to `abap_true` when instanticiating the class and has only been set to `abap_false` for testing purposes in the `main()` method.   

<details>
  <summary>🔵 Click to expand the source code!</summary>   
  
```

    "item data has to be converted
    pritem = purchase_req_items.

    LOOP AT pritem ASSIGNING FIELD-SYMBOL(<pritem_line>).

      pritemx_line =
                      VALUE #(
                               preq_item  = '00010'
                               plant      = 'X'
                               acctasscat = 'X'
                               currency   = 'X'
                               deliv_date = 'X'
                               material   = 'X'
                               matl_group = 'X'
                               preq_price = 'X'
                               quantity   = 'X'
                               unit       = 'X'
                               pur_group  = 'X'
                               purch_org  = 'X'
                               short_text = 'X'
                              ) .

      APPEND pritemx_line TO pritemx.

      IF use_conversions = abap_true.

        TRY.

            zcl_conversion_ext_int=>get_instance( )->currency_amount_int_to_ext(
              EXPORTING
                currency    = <pritem_line>-Currency
                sap_amount  = CONV #( <pritem_line>-preq_price )
              IMPORTING
                bapi_amount = DATA(bapi_amount)
            ).

            zcl_conversion_ext_int=>get_instance( )->currency_code_int_to_ext(
              EXPORTING
                sap_code = <pritem_line>-Currency
              IMPORTING
                iso_code = DATA(bapi_currency)
            ).

            <pritem_line>-preq_price = bapi_amount.
            <pritem_line>-Currency = bapi_currency.

          CATCH zcx_conversion_ext_int INTO DATA(conversion_exception).

            conversion_message_line-id = conversion_exception->if_t100_message~t100key-msgid.
            conversion_message_line-number = conversion_exception->if_t100_message~t100key-msgno.
            conversion_message_line-type = if_abap_behv_message=>severity-warning.
            conversion_message_line-message_v1 = conversion_exception->attr1.
            conversion_message_line-message_v2 = conversion_exception->attr2.
            APPEND conversion_message_line TO conversion_messages.

        ENDTRY.
      ENDIF.
    ENDLOOP.



```  

</details>    



 
<!--    

## Step 8: Run ATC checks and request exemptions \[OPTIONAL\]

> **Note**: This exercise is optional. 

You will now need to run ATC checks on the objects you created and request exemptions to use non-released API.

<details>
  <summary>🔵 Click to expand</summary>  

To run the ATC checks right click on the `$Z_PURCHASE_REQ_TIER2_###` package and select **Run As** > **ABAP Test Cockpit With...** and select your ATC check variant. Confirm by clicking on **OK**.   


<img alt="ATC checks - interface error" src="images/select_atc_check_variant.png" width="70%">

The result of the ATC check will appear in the ATC Problems tab. As expected, you will get ATC check errors because you are using an non-released API:


<img alt="ATC checks - interface error" src="images/interface_atc_checks.png" width="70%">

>Note that there are ATC checks errors for both the interface and the wrapper class. You will need to request an exemption for each of the two objects.

Right click on any one of the interface related errors in the ATC Problems tab and choose **Request Exemption**. You can then request an exemption for the whole interface by selecting `Interface (ABAP Objects)` under the `Apply exemption To` tab:


<img alt="Request exemptions for the whole interface" src="images/interface_request_exemption.png" width="70%">

Click **Next**, choose a valid approver, a reason to request the exemptions and input a justification for it. Then click on **Finish**.


<img alt="Approver and justification" src="images/approver_and_justification.png" width="70%">

Proceed in the same way to request an exemption for the whole wrapper class.

>How to maintain approvers and how to approve exemptions is beyond the scope of this tutorial. After a maintained approver has approved the exemptions, you can verify it by running ATC checks again in ADT: no issue should arise.

</details>

-->   

<!--
## Step 10: Check the results in the SAP standard `Purchase Requisition - Professional` App

You can  use the app **Manage Purchase Requisition - Professional** to check the purchase requistions that you have created using your console application.   

<details>
  <summary>🔵 Click to expand</summary>
  
  1. In a preconfigured appliance system, the standard **Manage Purchase Requisition - Professional** app can be started using the ABAP Fiori Launchpad using the following URL, where you will replace `xxx.xxx.xxx.xxx` with your assigned system IP address:     
  
     https://xxx.xxx.xxx.xxx:44301/sap/bc/ui2/flp?sap-client=100&sap-language=EN#PurchaseRequisition-maintain
    
     > **Hint:** Alternatively, you can launch the ABAP Fiori launchpad using the transaction code **`/ui2/flp`** (`/n/ui2/flp`) and then search for the app *Manage Purchase Requisition - Professional*.

     **Manage Purchase Requistion - SAP standard application**   
     ![Manage Purchase Requistion - Professional](../ex4/images/pr_professional_app.png)  
    
     Now you can search for the created purchase requisition number.

     > **Note**
     > Before checking the results in the ADT Fiori Elements preview make sure to clear the cache by pressing **F12** and by selecting **clear cache and refresh**. Otherwise you might run into the issue that the button 
       of the action is visible but not functional.   

</details>
-->

## Summary & Next Exercise
[^Top of page](#)

Now that you've... 
- created a wrapper interface, a factory class and an implementing wrapper class for the BAPI_PR_CREATE, and
- have tested the C1-released wrapper for consumption in ABAP for cloud development,

you can continue with the next exercise - **[Exercise 2 - Create a Shopping Cart Business Object](../ex2/README.md)**.

---
