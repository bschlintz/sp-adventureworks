# AdventureWorks for SharePoint
## What's included
A subset of the AdventureWorks sales database which includes the following lists: Address, Customer, CustomerAddress, Product, ProductCategory, ProductDescription, ProductModel, ProductModelProductDescription, SalesOrderDetail and SalesOrderHeader. 

I've also included ProductImages, which was a binary SQL data type on the Product table, that I extracted into a document library. You can join a product to its associate thumbnail image by referencing the ThumbnailPhotoFileName column in the Product list.

## How to get it
You can add the Adventure works lists and library to your SharePoint site using the steps below. Please note, you will need a newer version of the [SharePoint PnP PowerShell](https://github.com/SharePoint/PnP-PowerShell) module installed.

#### Step 1: Clone the repo
From a PowerShell window, clone the [sp-adventureworks](https://github.com/bschlintz/sp-adventureworks) github repository to your filesystem.
```
git clone https://github.com/bschlintz/sp-adventureworks.git
```
#### Step 2: Provision the lists and load data
Run CreateLists.ps1 specifying a `-SiteUrl`. Optionally, you may skip loading the data by using the `-SkipLoadData` flag. If you choose to load the data later, you can run `.\LoadData.ps1` specifying a `-SiteUrl`.
```
.\CreateLists.ps1 -SiteUrl https://{tenant}.sharepoint.com/sites/{advworks} [-SkipLoadData]
```
#### Step 3: Wait
List items and files will be loaded in batches using CSOM to speed up the process, but it'll still take about 15 minutes to finish. If you're curious, check out the batching logic in [LoadData.ps1](https://github.com/bschlintz/sp-adventureworks/blob/master/LoadData.ps1) while you wait!

#### Step 4: Check it out
You should now have several new lists on your site. Check them out!