[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/abap-platform-rap640)](https://api.reuse.software/info/github.com/SAP-samples/abap-platform-rap640)

# RAP640 - Using ABAP Cloud to Build Extensions for SAP S/4HANA Cloud, Private Edition - Mitigating Missing Released SAP APIs in the 3-tier Extensibility Model
<!-- Please include descriptive title -->

<!--- Register repository https://api.reuse.software/register, then add REUSE badge:
[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/REPO-NAME)](https://api.reuse.software/info/github.com/SAP-samples/REPO-NAME)
-->

## Description
<!-- Please include SEO-friendly description -->

This repository contains the material for the hands-on session **RAP640 - Mitigating Missing Released SAP APIs in the 3-tier Extensibility Model** which is about mitigating missing released SAP APIs in the 3-tier Extensibility Model when building apps, services, and extensions with the ABAP Cloud development model on SAP S/4HANA Cloud Private Edition and SAP S/4HANA. 

**Table of Content**
- [Requirements for attending this workshop](#requirements-for-attending-this-workshop)
- [Overview](#overview)
- [Exercises](#exercises)
- [Solution Package](#solution-package)
- [Known Issues](#known-issues)
- [How to obtain support](#how-to-obtain-support)
- [Further Information](#further-information)


## 📋Requirements for attending this workshop 
[^Top of page](#)

To complete the practical exercises in this workshop, you need the latest version of the ABAP Development Tools for Eclipse (ADT) on your laptop or PC and the access to a suitable ABAP system - i.e. at least release 2022 of SAP S/4HANA Cloud Private Edition and SAP S/4HANA.

<details>
  <summary>Click to expand!</summary>

The requirements to follow the exercises in this repository are:
1. [Install the latest Eclipse platform and the latest ABAP Development Tools (ADT) plugin](https://developers.sap.com/tutorials/abap-install-adt.html)
2. [Adapt the Web Browser settings in your ADT installation](https://github.com/SAP-samples/abap-platform-rap-workshops/blob/main/requirements_rap_workshops.md#4-adapt-the-web-browser-settings-in-your-adt-installation)   

> ℹ️ **Regarding SAP-led events such as "ABAP Developer Day" and "SAP CodeJam"**:   
> → A dedicated ABAP system for the hands-on workshop participants will be provided.   
> → Access to the system details for the workshop will be provided by the instructors during the session.

</details>

## System access (workshops provided by SAP)

In a workshop that is conducted by SAP a SAP S/4HANA 2023 preconfigured appliance system will be provided to the workshop participants. 

The system details will be provided by the trainers. With the system details you can connect via ADT to the system as described in the following how-to-guide.   

[How to connect with ADT to a preconfigured appliance system](https://github.com/SAP-samples/abap-platform-rap-workshops/blob/main/how_to_connect_with_adt_to_preconfigure_appliance.md)

## 🔎Overview
[^Top of page](#)

<!-- #### Current Business Scenario -->
Learn about the current business scenario and the 3-tier extensibility model.
 
<details>
  <summary>Click to expand!</summary>
 
### About the Business Scenario 
  
In this hands-on workshop, we will guide you through the development of a custom wrapper for the ABAP Cloud enablement of an unreleased SAP BAPI for creating purchase requisitions, then a custom RAP BO and UI service on top of it to develop a transactional, design-capable, Fiori Elements-based list report app using RAP. Finally, you'll use your custom API wrapper in your custom RAP BO to integrate your custom app with the standard professional SAP Purchase Requisition app.

The resulting app will look like this:

<img src="images/shoppingcart01.png" alt="Shopping Cart  App" width="100%">
  
To set the business context, the scenario is the following: This demo scenario shows a custom and SAP Fiori elements-based shopping cart app built on-stack with RAP. The custom app is integrated with the standard Purchase Requisition app in SAP S/4HANA Materials Management using a custom wrapper on top of the unreleased SAP API `BAPI_CREATE_PR`.

### About the 3-Tier Extensibility Model

You will learn how to apply the [Cloud API Enablement Guidelines for SAP S/4HANA Cloud Private Edition and and SAP S/4HANA](https://www.sap.com/documents/2023/05/b0bd8ae6-747e-0010-bca6-c68f7e60039b.html) to consume an unreleased SAP API. You will learn how to mitigate missing released SAP APIs in the 3-tier extensibility model when working with ABAP Cloud on these two products.

<img src="images/3-tier-extmodel.png" alt="3-tier extensibility model" width="80%">

Learn more: [Understand the sample scenario how to mitigate a missing released SAP API](exercises/GettingStarted/README.md)
  
</details>


## 🛠Exercises
[^Top of page](#)

Follow these steps to build a custom wrapper for the ABAP Cloud enablement of an non-released SAP API for creating purchase requisitions, then a custom RAP BO and a UI service on top of it for a transactional, draft-enabled Fiori Elements list report app. Finally, you'll use your custom API wrapper in your custom RAP BO to integrate your custom app with the standard professional SAP Purchase Requisition app.


#### Main Exercises

| Exercises | -- |
| ------------- |  -- |
| [Exercise 1 - Implement a Wrapper for the "Create Purchase Requisition" (BAPI_PR_CREATE) function module](exercises/ex1/README.md) | -- |
| [Exercise 2 - Create a Shopping Cart Business Object](exercises/ex2/README.md) | -- |
| [Exercise 3 - Create Value Help, Enhance the Behavior Definition and Behavior Implementation of the Shopping Cart Business Object](exercises/ex3/README.md) | -- |
| [Exercise 4 - Integrate the Wrapper into the Shopping Cart Business Object](exercises/ex4/README.md) | -- |


#### Optional Exercises 

| Exercises | -- |
| ------------- |  -- |
| [Exercise 5 - Provide Authorizations to Users for Non-Released Authorization Objects checked by the "Create Purchase Requisition" (BAPI_PR_CREATE) function module](exercises/ex5/README.md) | -- |


## 📤Solution Package
[^Top of page](#)
 
You can import the solution package **`ZRAP640_SOL`** into your system* - i.e. at least the release 2022 of SAP S/4HANA Cloud Private Edition and SAP S/4HANA.

> ℹ️ **Regarding SAP-led events such as "ABAP Developer Day" and "SAP CodeJam"**:     
> The solution package **`ZRAP640_SOL`** is already imported into your dedicated system used during these events.

🚧 _More details coming soon_  
_ _


## 🔁Recordings
[^Top of page](#)

Watch the replay of a webcast on cloud API enablement for the 3-tier extensibility model held during SAP's Devtoberfest in 2023. 

📹 <a href="http://www.youtube.com/watch?feature=player_embedded&v=MThRxtNEHS0" target="_blank">Cloud API Enablement on SAP S/4HANA and SAP S/4HANA Cloud Private editions</a> 


## ⚠Known Issues
[^Top of page](#)

No known issues. 



## 🆘How to obtain support
[^Top of page](#)

[Create an issue](../../issues) in this repository if you find a bug or have questions about the content.
 
For additional support, [ask a question in SAP Community](https://answers.sap.com/questions/ask.html).


## Further Information
[^Top of page](#)

You can find further information here:
 - [Blog Post on how to mitigate missing released SAP APIs in SAP S/4HANA Cloud](https://blogs.sap.com/2023/05/24/abap-cloud-how-to-mitigate-missing-released-sap-apis-in-sap-s-4hana-cloud-private-edition-and-sap-s-4hana-the-new-abap-cloud-api-enablement-guide/) | SAP Community
 - [Detailed document on ABAP Cloud API Enablement Guidelines](https://www.sap.com/documents/2023/05/b0bd8ae6-747e-0010-bca6-c68f7e60039b.html) | Guide
 - [ABAP RESTful Application Programming Model (RAP)](https://community.sap.com/topics/abap/rap) | SAP Community page   
 - Most frequently asked questions: [ABAP Cloud FAQ](https://community.sap.com/topics/abap/abap-cloud-faq) | [RAP FAQ](https://blogs.sap.com/2020/10/16/abap-restful-application-programming-model-faq/)    
 - [RAP640 Tutorials Group: Mitigate Missing Released SAP API in the 3-tier Extensibility Model](https://developers.sap.com/group.sap-s4hana-extensibility-wrap-api.html) | SAP Developers' Center

<!--
## Contributing
If you wish to contribute code, offer fixes or improvements, please send a pull request. Due to legal reasons, contributors will be asked to accept a DCO when they create the first pull request to this project. This happens in an automated fashion during the submission process. SAP uses [the standard DCO text of the Linux Foundation](https://developercertificate.org/).
-->

## License
Copyright (c) 2024 SAP SE or an SAP affiliate company. All rights reserved. This project is licensed under the Apache Software License, version 2.0 except as noted otherwise in the [LICENSE](LICENSE) file.

