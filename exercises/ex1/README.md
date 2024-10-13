# Exercise 1: Implement a Wrapper for the "Create Purchase Requisition" (BAPI_PR_CREATE) function module
<!-- description --> Learn how to wrap the BAPI_PR_CREATE in your SAP S/4HANA system and release it for consumption in tier 1.

## Prerequisites

When you want to perform this script in your own SAP S/4HANA system the following prerequisites must be met:     

- You have to have a system based on **SAP S/4HANA 2022 or 2023** on premise or private cloud.
- You have to have enabled Developer extensibility as described in the [SAP Online Help](https://help.sap.com/docs/ABAP_PLATFORM_NEW/b5670aaaa2364a29935f40b16499972d/31367ef6c3e947059e0d7c1cbfcaae93.html?q=set%20up%20developer%20extensibility&locale=en-US)   
- You have to apply the following notes:  

  - [SAP Note 3444292 - ACO Proxy creates unnecessary shadow types](https://me.sap.com/notes/3444292)  
  - [SAP Note 3457580 - SAP ACO - Duplicate Types for Table Parameters](https://me.sap.com/notes/3457580)
  - [SAP Note 3518177 - SAP ACO Proxy Improvements](https://me.sap.com/notes/3518177)
  - [SAP Note 3519098 - F4: fix function module value help](https://me.sap.com/notes/3519098)   (only relevant for SAP S/4 HANA 2023)   

## Introduction
Now that you're connected to your SAP S/4HANA system, go ahead with this exercise where you will learn how to deal with the situation where there is no convenient released SAP API for creating purchase requisitions. 

The [ABAP Cloud API Enablement Guidelines for SAP S/4HANA Cloud Private Edition and SAP S/4HANA](https://www.sap.com/documents/2023/05/b0bd8ae6-747e-0010-bca6-c68f7e60039b.html) recommend using a BAPI as an alternative to a released API, wrapping it, and then releasing the wrapper for consumption in tier 1. 

In a later exercise you will then create a Shopping Cart RAP business object for a Fiori elements online shopping app in Tier 1 and integrate this wrapper to create purchase requisitions.

- [You will learn](#you-will-learn)
- [Summary & Next Exercise](#summary--next-exercise)  


## You will learn
- How to generate a wrapper interface, a wrapper class and a factory class for the `BAPI_PR_CREATE` using transaction ACO_PROXY.
- How to test that the wrapper objects have been released for consumption in tier 1.

> **Reminder:**   
> Don't forget to replace all occurences of the placeholder **`###`** with your assigned group number in the exercise steps below.  
> You can use the ADT function **Replace All** (**Ctrl+F**) for the purpose.   
> If you don't have a group number, choose a 3-digit suffix and use it for all exercises.


## Step 1: Get to know the BAPI_PR_CREATE via the BAPI Explorer

<details>
  <summary>🔵 Click to expand!</summary>
  
The first step is to look for a suitable non-released API to create purchase requisitions. You can use the BAPI Explorer for this purpose. Connect to the backend of your SAP S/4HANA system and start transaction `BAPI`. For the purpose of this tutorial, we will use the non-released BAPI `BAPI_PR_CREATE`: switch to the **Alphabetical** view (1), look for the Business Object `PurchaseRequisition` (2), find and click on the method `CreateFromData1` (3). You can see that its function module is the `BAPI_PR_CREATE` (4).

<!-- ![BAPI explorer](images/bapi_explorer.png) -->
<img alt="BAPI explorer" src="images/bapi_explorer.png" width="70%">

In the **Documentation** tab you can find more information on what the BAPI is used for (in this case: to create purchase requisitions) and you can find examples for various scenarios and how to fill the respective parameter values.

In the **Tools** section you can click on the **Function Builder** and then click on **Display** to see the required parameters:

<!-- ![BAPI explorer - Tools](images/bapi_explorer-tools.png) -->
<img alt="BAPI explorer - Tools" src="images/bapi_explorer-tools.png" width="70%">

<!-- ![BAPI explorer - Function Builder](images/bapi_explorer-function_builder.png) -->
<img alt="BAPI explorer - Function Builder" src="images/bapi_explorer-function_builder.png" width="70%">

>The `BAPI_PR_CREATE` has a `TESTRUN` parameter that can be used to call the BAPI in validation mode. Some BAPI have a similar test mode that can be used to validate input data. It is best practice to make use of this test mode, if available, as we will address in more details in a later [tutorial](/exercises/ex5/Readme.md) of this group.

</details>

## Step 2: Create a development package

<!-- You will develop the wrapper in a dedicated package under the structure package `ZTIER2` in your SAP S/4HANA system. -->

You will develop the wrapper in a dedicated package  `TEST_TIER2_###` in your SAP S/4HANA system.  

<details>
  <summary>🔵 Click to expand</summary>
  
In ADT, open your SAP S/4HANA system project folder, right click on it and select **New** > **ABAP Package** and input the Name `TEST_TIER2_###` leave the field superpackage empty and enter a Description, e.g. `Package Tier2`.   Select **Add to favorite packages** for easy access later on. Keep the Package Type as **Development** and click on **Next**. Do not change anything in the following wizard window (where the software component HOME is selected), and click on **Next**.       

<!-- ![Create Tier 2 package](images/create_tier2_package.png) -->
<!--  <img alt="Create Tier 2 package" src="images/create_tier2_package_2.png" width="70%">  -->   

<img alt="Create Tier 2 package" src="images/new_package_test_tier2.png" width="70%">   



Create a new transport request and give it a meaningful name such as `Tier2 development - Group ###` so that it can be more easily identified. Then click on **Finish**. The package will be created.

</details>  

## Step 3: Create a wrapper class, interface and factory class

You now want to wrap the API `BAPI_PR_CREATE`. For this we use the transaction **ACO_PROXY** which has been enhanced so that it will generate the boiler plate coding for you to build a wrapper class.   

In the following we will explain in short the best practices that are behind the options you will have to choose when using transaction **ACO_PROXY**.  

> **The interface:**     
> Depending on your specific use-case, you normally would need to access only certain specific functionalities and methods of the BAPI you want to expose. An ABAP Interface is the perfect development object for this purpose. The interface simplifies and restricts the usage of the underlying BAPI for the specific use-case, by exposing only the parameters that are needed. As a consequence, non-wrapped functionalities are forbidden.

> **The wrapper class:**    
> In addition you need a class to wrap the BAPI (implementing the interface) and implement its methods. The wrapper class has a method defined in the private section, `call_bapi_pr_create`, which has access to all the parameters of the underlying BAPI. Having this type of central private method is best practice. Internally, the wrapper class has access to all the parameters and then the interface has virtual access to all of these parameters and exposes publicly only the ones that are needed depending on the specific use-case. 

> **C1-release for use in cloud in cloud development:**    
> Since we plan to access the wrapped BAPI in a different tier, it is good to provide the possibility to test it, and to keep wrapping-specific coding in tier 1 to a minimum. For this reason, the interface approach is recommended, and the wrapper class will not be released directly for consumption in tier 1, but rather will be accessible via a factory class that you will also be created.

> **The factory class:**
> A factory class is used to control the instantiation of the wrapper class and in order to be able to use it in Tier1 it has to be released for use in tier 1. 

This approach has the advantage of a clear control of when and where an instance of the wrapper class is created, and in the event in which several wrapper classes are needed all their instantiations could be handled inside one single factory class.  Also, in case of wrapper classes this has the advantage that in case the wrapper class is changed throughout it's software lifecycle, at a later point in time a different class could be initialized, without changes to the consumer implementation. In this tutorial we follow the [clean code best practices](https://blogs.sap.com/2022/05/05/how-to-enable-clean-code-checks-for-abap/) for ABAP development. For example: the wrapper class is ready for ABAP Unit Tests and [ABAP Doc](https://blogs.sap.com/2013/04/29/abap-doc/) is implemented.


<details>
  <summary>🔵 Click to expand</summary>

1. To create the interface, the class and the factory class for your BAPI start transaction ACO_PROXY.

    <!-- ![Start ACO_PROXY](images/start_aco_proxy_2.png) -->
    <img alt="Start ACO_PROXY" src="images/start_aco_proxy_2.png" width="100%"> 

2. Enter the following values

  **A. Function Modules**    
      - Here you can select one or more function modules that will be wrapped by one single class. Please enter here only `BAPI_PR_CREATE`.  
        
   **B. Specify repository object names**    
      - **Name of a proxy class**: Enter a name for the wrapper class, e.g. `ZCL_WRAP_BAPI_PR_###`.   
      - **Package**: Select `TEST_TIER2_###`.     ⚠️⚠️⚠️  (We use a package TEST_TIER2_### instead of ZTIER2_### as a workaround due to a bug in ACO_PROXY)   
      - **Create Interface**: Check the check box and choose a name for the interface, e.g. `ZIF_WRAP_BAPI_PR_###`  
      - **Create Factory Class**: Check the check box and choose a name for the factory class, e.g. `ZCL_F_WRAP_BAPI_PR_###`   

   **C. Options**   
      - Choose the radio-button **Class-Based Exceptions**       
      - Check the check box **Do not create Shadows of C1 Released Types**       
      - Check the check box **C1 Release**       
      - Check the check box **Create Private Methods**          

  and press F3 to continue.

3. Press the green check mark or **F8** to continue
   
4. Select optional values

   Transaction **ACO_PROXY** offers you to un-select optional values that shall not be part of the public interface.

   Only leave the following optional parameters of the 'BAPI_PR_CREATE' selected
   
   - NUMBER  
   - PRHEADEREXP  
   - PRHEADER  
   - PRHEADERX  
   - TESTRUN  
   - PRITEMX  
   - RETURN  

   and un-select all other optional parameters.   

   <img alt="Select optional parameters 1" src="images/rap640_parameter_010.png" width="70%">

   <img alt="Select optional parameters 2" src="images/rap640_parameter_020.png" width="70%">

   <img alt="Select optional parameters 3" src="images/rap640_parameter_030.png" width="70%">

</details>   

## Step 4: Test wrapper with console application in tier 1

The wrapper you just created is released for consumption in tier 1. You can test this by creating a console application in tier 1 to call the wrapper. We suggest to create a dedicated package **`Z_PURCHASE_REQ_TEST_###`** under in tier 1 by using **`ZLOCAL`** as the super-package of your package in your SAP S/4HANA System for this test.

<details>
  <summary>🔵 Click to expand</summary>  

1. In ADT, open your SAP S/4HANA system project folder, right click on it and select **New** > **ABAP Package** and input the Name **`Z_PURCHASE_REQ_TEST_###`** and a Description. Choose **`ZLOCAL`** as the superpackage:

<!-- ![Create test package](images/create_test_package.png) -->
<!-- <img alt="Create test package" src="images/create_test_package.png" width="70%">   --> 
<img alt="Create test package" src="images/new_package_zlocal.png" width="70%">

2. Click on **Next** and then **Next** again. Select a suitable transport request (or create a new one if needed) and then click on **Finish**. Now you can create the class for the console application. Right click on the newly created package and select **New** > **ABAP Class** and input the Name `ZCL_BAPI_WRAP_TEST_###` and a Description:

<!-- ![Create test class](images/create_test_class.png) -->
<img alt="Create test class" src="images/create_test_class.png" width="70%">

3. Click on **Next**, select a suitable transport request (or create a new one if needed) and then click on **Finish**.

4. You can check that the newly created class is a tier 1 class by checking that the **ABAP Language Version** is `ABAP Language for Cloud Development` in the **Properties** > **General** tab:

<!-- ![Console application language](images/console_application_language.png) -->
<img alt="Console application language" src="images/console_application_language.png" width="70%">

5. Implement the newly created class as shown below. The class calls the wrapper factory class and, given some input parameter values like the delivery date and the item price, creates a purchase requisition for that specific item and prints the information to the console.   
         
 <details>
  <summary>🟡📄 Click to expand and view or copy the source code!</summary>

```ABAP

CLASS zcl_bapi_wrap_test_### DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_bapi_wrap_test_### IMPLEMENTATION.
METHOD if_oo_adt_classrun~main.

    DATA pr_returns TYPE bapirettab.

    DATA prheader TYPE zif_wrap_bapi_pr_###=>bapimereqheader .
    DATA prheaderx TYPE zif_wrap_bapi_pr_###=>bapimereqheaderx .
    DATA number  TYPE zif_wrap_bapi_pr_###=>banfn  .
    DATA pritem  TYPE zif_wrap_bapi_pr_###=>_bapimereqitemimp .
    DATA pritemx  TYPE zif_wrap_bapi_pr_###=>_bapimereqitemx  .
    DATA prheaderexp  TYPE zif_wrap_bapi_pr_###=>bapimereqheader .

    DATA(myclass) = zcl_f_wrap_bapi_pr_###=>create_instance( ).

    prheader = VALUE #( pr_type = 'NB' ).
    prheaderx = VALUE #( pr_type = 'X' ).

    pritem           = VALUE #( (
                      preq_item  = '00010'
                      plant      = '1010'
                      acctasscat = 'U'
                      currency   = 'EUR'
                      deliv_date = cl_abap_context_info=>get_system_date(  ) + 14   "format: yyyy-mm-dd (at least 10 days)
                      material   = 'ZPRINTER01'
                      matl_group = 'A001'
                      preq_price = '100.00'
                      quantity   = '1'
                      unit       = 'ST'
                      pur_group = '001'
                      purch_org = '1010'
                      short_text = 'ZPRINTER01'
                    ) ).

    pritemx           = VALUE #( (
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
                      pur_group = 'X'
                      purch_org = 'X'
                      short_text = 'X'
                    ) ).

    TRY.
        myclass->bapi_pr_create(
          EXPORTING
            prheader = prheader
            prheaderx = prheaderx
            testrun = abap_false
          IMPORTING
            number   = number
            prheaderexp = prheaderexp
          CHANGING
            pritem = pritem
            pritemx = pritemx
     )
        .
      CATCH cx_aco_application_exception cx_aco_communication_failure cx_aco_system_failure INTO DATA(call_wrapper_exception).
        "handle exception
        out->write( |Exception occured: { call_wrapper_exception->get_text(  ) }| ).
    ENDTRY.
    out->write( |purchase requistion number: { number  } | ).
    LOOP AT pr_returns INTO DATA(bapiret2_line).
      out->write( |bapi_return: { bapiret2_line-message } | ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

```

 </details>   

6. Save and activate your changes.   

7. Now run this class  by pressing F9.   

8. You shall see an output as follows:

   <img alt="Console output test class" src="images/console_output_test_class.png" width="70%">   
   
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
- created a wrapper interface and implement a wrapper class for the BAPI_PR_CREATE, and
- released the wrapper for consumption in tier 1,

you can continue with the next exercise - **[Exercise 2 - Create a Shopping Cart Business Object](../ex2/README.md)**.

---
