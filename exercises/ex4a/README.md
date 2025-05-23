# Exercise 5: Integrate with classic BOR Events

## Technical background

BOR is a legacy framework, which is not cloud-ready and hence not available for direct customer usage in SAP S/4HANA Cloud public edition or SAP BTP ABAP Environment. As a cloud-ready alternative to BOR, it is recommended to use RAP events (available from SAP S/4HANA Release 2022), if available and applicable.

If one needs to use BOR events, e. g. to leverage Event Linkages, you can consume BOR events in customer and partner extensions. Event Linkages are maintained in transaction Maintain Event Linkages (SWE2). 

Here you have to register a class that implements the interface `BI_EVENT_HANDLER_STATIC`.  

For more details see the SAP Note [3478579 - Business Object Repository in context of Clean Core](https://me.sap.com/notes/3478579) .   

## Demo scenario 

When creating purchase requistions the underlying frameworks are raising classic BOR events as well as newer RAP based events. To demonstrate the use of classic BOR events we have prepared a class `zrap640_cl_handle_pr_events` for your convenience that has been linked using transaction **SWE2** to the event `CREATED` of the object type `CL_MM_PUR_WF_OBJECT_PR`.   

> Please note:
> Since it is not possible to perform the linkage of a class in transactino SWE2 in parallel with different users we have provided a single class and have registered the same for you beforehand.   

The class `zrap640_cl_handle_pr_events` implements interface `bi_event_handler_static` and in method `bi_event_handler_static~on_event` the code retrieves:  
- the purchase requisition number   
- the username of the end user that has created the purchase requisition   

It then stores the username `zrap640_evt_hdl` into the pre-configured table `zrap640_evt_hdl`.   

Open the class `zrap640_cl_handle_pr_event` in [ADT](adt://S4H/sap/bc/adt/oo/classes/zrap640_cl_handle_pr_events?version=active) or check the source code here: 

<details>
  <summary>🔵 Click to expand the source code</summary>

```   
CLASS zrap640_cl_handle_pr_events DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES bi_event_handler_static .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zrap640_cl_handle_pr_events IMPLEMENTATION.


  METHOD bi_event_handler_static~on_event.

    TYPES : BEGIN OF t_event_handle,
              purchase_requisition TYPE c LENGTH 10,
              created_by           TYPE  abp_creation_user,
            END OF t_event_handle.

*    DATA line TYPE t_event_handle.
    DATA line TYPE zrap640_evt_hdl.
    DATA table_name TYPE dd03l-tabname.
    DATA purchase_requisition TYPE string.
    "user name in the fourteen-character structure US<SY-UNAME>.
    DATA event_raised_by TYPE string.


    TRY.
        event_container->get(
          EXPORTING
            name  =  '_EVT_OBJKEY'
          IMPORTING
            value = purchase_requisition ).

      CATCH cx_swf_cnt_elem_not_found cx_swf_cnt_elem_type_conflict cx_swf_cnt_unit_type_conflict cx_swf_cnt_container.
        "handle exception
    ENDTRY.



    TRY.
        event_container->get(
          EXPORTING
            name  =  '_EVT_CREATOR'
          IMPORTING
            value = event_raised_by ).

        "remove 'US'
        event_raised_by = substring( val = event_raised_by off = 2 ).

      CATCH cx_swf_cnt_elem_not_found cx_swf_cnt_elem_type_conflict cx_swf_cnt_unit_type_conflict cx_swf_cnt_container.
        "handle exception
    ENDTRY.

    line-created_by = event_raised_by.
    line-purchase_requisition = purchase_requisition.

    "table_name = Z<sy-uname>
    table_name = 'Z' && event_raised_by.

    INSERT zrap640_evt_hdl FROM @line.
    COMMIT WORK and wait.

    INSERT (table_name) FROM @line.
    COMMIT WORK and wait.

  ENDMETHOD.
ENDCLASS.
```

</details>   

### Check content of table `zrap640_evt_hdl` 

1. Open the table `zrap640_evt_hdl` in ADT.   
2. Press **F8** to start the data preview.
3. Choose **Add filter --> CREATED_BY** from the menu.
4. Enter the name of your user in upper case **DEVELOPER###**

> Hint:   
> It can take a while (up to x minutes) until the event that has been raised has been captured by the event handler class.   

As a result you will see several entries that stem from the purchase requisitions you have created beforehand.

### Create your own table to collect purchase requisition BOR events

1. Create a table `ZDEVELOPER###`
2. Add the following code

```
@EndUserText.label : 'Collect BOR events'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zdeveloper### {

  key client               : abap.clnt not null;
  key purchase_requisition : abap.char(10) not null;
  created_by               : abp_creation_user;

}
```
3. Save and activate your changes

Now create a new purchase requisition using your RAP business object or using the command line test class that you have created beforehand.

Check the content of your table using the data preview by pressing **F8**.   


   
   
   



## Summary & Next Exercise
[^Top of page](#)

Now that you've... 
- integrated a wrapper class in a RAP BO during the save sequence,
- implemented a new action in RAP BO to call the wrapper class and use it to create a purchase requisition, and 
- exposed the action via service binding,
- checked the use of classic BOR events,   

you are done. 

However there is **optional** exercise that you might want to perform - **[Exercise 6 (optional) - Provide Authorizations to Users for non-Released Authorization Objects checked by the "Create Purchase Requisition" function module](../ex5/README.md)**.   



