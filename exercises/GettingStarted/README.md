# Getting Started: Understand the sample scenario how to mitigate a missing released SAP API
<!-- description --> 

# Introduction

Learn how the clean core extensibility model based on the clean core level concept works and how to mitigate a missing released SAP API by wrapping an appropriate classic API.

- [You will learn](#you-will-learn)
- [Verify technical requirements](#verify-technical-requirements)
- [Summary & Next Exercise](#summary)


## You will learn 
- How the the clean core extensibility model based on the clean core level concept works for SAP S/4HANA Cloud Private Edition and SAP S/4HANA
- The concept how to build wrappers around _classic APIs_ to facilitate their use in Level A applications — for example, leveraging `BAPI_PR_CREATE` to create purchase requisitions
- The sample business scenario that will be used to show how to mitigate a missing released SAP API by wrapping a _classic API_ that is listed in the [cloudification repository](https://sap.github.io/abap-atc-cr-cv-s4hc/?q=BAPI_PR_CREATE) is based on the use of the BAPI `BAPI_PR_CREATE` to create purchase requisitions.

> ℹ️ This hands-on workshop follows the assumption that there is no suitable released API to create purchase requisitions, and we therefore need to find and wrap an unreleased API as a suitable alternative.   
> 
> Please be aware that we follow this assumption simply for illustrative purposes, as SAP does indeed provide a released API to create purchase requisitions (see [Integrate released purchase requisition API into Shopping Cart Business Object](https://developers.sap.com/tutorials/abap-s4hanacloud-purchasereq-integrate-api.html)).

# Understand the Clean Core Level Concept for SAP S/4HANA Cloud Private Edition and SAP S/4HANA

Familiarize yourself with the Clean Core Level Concept by reading the blog post [Why Clean Core matters - Get some insights into our brand new Extensibility Whitepaper](https://community.sap.com/t5/technology-blog-posts-by-sap/why-clean-core-matters-get-some-insights-into-our-brand-new-extensibility/ba-p/14163750).

# Understand the concept how to mitigate missing released SAP APIs in SAP S/4HANA Cloud Private Edition and SAP S/4HANA

Learn the concept how to mitigate missing released SAP APIs by reading:  
- the blog post [How to mitigate missing publicly released SAP APIs – The ABAP Cloud API enablement guide](https://blogs.sap.com/2023/05/24/abap-cloud-how-to-mitigate-missing-released-sap-apis-in-sap-s-4hana-cloud-private-edition-and-sap-s-4hana-the-new-abap-cloud-api-enablement-guide/) and 
- the official SAP guidelines [ABAP Cloud API Enablement Guidelines for SAP S/4HANA Cloud, private edition, and SAP S/4HANA](https://www.sap.com/documents/2023/05/b0bd8ae6-747e-0010-bca6-c68f7e60039b.html).

# Understand the sample scenario used for the tutorial group

User can launch custom online shop application to order a gadget. When gadgets are ordered, a purchase requisition is automatically created in the S/4HANA system.

In this scenario you have a Shopping Cart business object built with the ABAP RESTful Application Programming Model (RAP) for an online shop application using **ABAP Cloud Development**. You then want to be able to create purchase requisitions for the shopping cart entries. In an ideal case, this could be achieved by making use of a released SAP API. 

In this hands-on exercise we will show you how to deal with the case where no convenient released SAP API is available to create purchase requisitions: you will find a suitable classic API to use as an alternative to a released API, you will wrap it using **Classic ABAP Development** and then release the wrapper for use in ABAP Cloud development a **(released custom API)**. You will then integrate this wrapper into your Shopping Cart RAP BO. As a final product, you will have a RAP BO using **ABAP Cloud Development** that will consume the released wrapper to create purchase requisitions for your Shopping Cart RAP BO entries.



<img src="images/scenario_overview.png" alt="Scenario overview" width="70%">

For productive use, you would develop your RAP BO in the productive package `ZCUSTOM_DEVELOPMENT` in your SAP S/4HANA system as suggested in the Developer Extensibility guidelines [Create Structure Package](https://help.sap.com/docs/ABAP_PLATFORM_NEW/b5670aaaa2364a29935f40b16499972d/076bbbf3fe584439938b27f49daa6765.html?version=202210.000), and you would develop the wrapper in a dedicated package of software component `HOME`, for instance `ZAPI_DEVELOPMENT`. For the scope of this tutorial group we will follow a simplified approach, and you will use local development packages `ZLOCAL` and `$TMP` rather than productive packages.

# Verify technical requirements

> ⚠️ This step is not needed for SAP-led events such as _ABAP Developer Days_ and _SAP CodeJam_.

The following requirements are needed for this tutorial group:

- If your system is running on feature pack stack 1 (SAP S/4HANA 2022 release), you have imported the [SAP Note 3250849](https://launchpad.support.sap.com/#/notes/3250849), [SAP Note 3294354](https://launchpad.support.sap.com/#/notes/3294354), [SAP Note 3330593](https://launchpad.support.sap.com/#/notes/3330593) and [SAP Note 3280851](https://launchpad.support.sap.com/#/notes/3280851) into your system.
- If your system is running on feature pack stack 0 (SAP S/4HANA 2023 release), you have imported the [SAP Note 3350873](https://launchpad.support.sap.com/#/notes/3350873)
- [You are connected to your SAP S/4HANA system in the ABAP Development Tool (ADT) in Eclipse](abap-s4hanacloud-login)
- You have a user in the system with full development authorizations.
- You have set up developer extensibility as described in the official documentation [Set Up Developer Extensibility](https://help.sap.com/docs/ABAP_PLATFORM_NEW/b5670aaaa2364a29935f40b16499972d/31367ef6c3e947059e0d7c1cbfcaae93.html?version=202210.000). In particular: the `ZLOCAL` development package is available and you have set up an ABAP Test Cockpit check variant (we will refer to this as 'ATC Check Variant' throughout the tutorial group).

> We suggest to follow this hands-on workshop using [SAP S/4HANA, fully-activated appliance](https://blogs.sap.com/2018/12/12/sap-s4hana-fully-activated-appliance-create-your-sap-s4hana-1809-system-in-a-fraction-of-the-usual-setup-time/) in SAP Cloud Appliance Library for an easy start without the need for system setup, as the `ZLOCAL` development package is automatically available, as well as the needed ATC check variant and the material used for the gadget shopping cart entries.


# Summary 
[^Top of page](#)

Now that you've learned 
- how the clean core extensibility model based on the clean core level concept works for SAP S/4HANA Cloud Private Edition and SAP S/4HANA,
- the concept how to mitigate missing released SAP APIs using custom wrappers around classic APIs, 
- the sample business scenario that will be used to show how to mitigate a missing released SAP API by wrapping a BAPI that is listed as a classic API,
- and eventually verify the technical requirements,

you can continue with the next exercise - **[Exercise 1: Implement a Wrapper for the "Create Purchase Requisition" (BAPI_PR_CREATE) function module](../ex1/README.md)**.

---
