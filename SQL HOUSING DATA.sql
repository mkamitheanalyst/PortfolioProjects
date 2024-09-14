


select *
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]


--Date Format

select SaleDate
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

--populate property Address Data

select *  
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] a
join PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] b
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] a
join PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] b
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


--Breaking Address into Individual columns (Address, City, State)


select PropertyAddress  
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
--where PropertyAddress is null
--order by ParcelID

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]


ALTER TABLE dbo.[Nashville Housing Data for Data Cleaning]
add PropertySplitAddress nvarchar(255);

update dbo.[Nashville Housing Data for Data Cleaning]
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table dbo.[Nashville Housing Data for Data Cleaning]
add PropertySplitCity nvarchar(255);

update dbo.[Nashville Housing Data for Data Cleaning]
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE '%Nashville%';

SELECT DB_NAME() AS CurrentDatabase;

USE [PortfolioProject];


select *
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]


select OwnerAddress
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

select 
PARSENAME(replace(OwnerAddress, ',', '.') ,3)
, PARSENAME(replace(OwnerAddress, ',', '.') ,2)
, PARSENAME(replace(OwnerAddress, ',', '.') ,1)
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]


ALTER TABLE dbo.[Nashville Housing Data for Data Cleaning]
add OwnerSplitAddress nvarchar(255);

update dbo.[Nashville Housing Data for Data Cleaning]
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.') ,3)

alter table dbo.[Nashville Housing Data for Data Cleaning]
add OwnerSplitCity nvarchar(255);

update dbo.[Nashville Housing Data for Data Cleaning]
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.') ,2)

ALTER TABLE dbo.[Nashville Housing Data for Data Cleaning]
add OwnerSplitState nvarchar(255);

update dbo.[Nashville Housing Data for Data Cleaning]
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.') ,1) 

select *
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]


--Changing 1 and 0 to Yes and No in SoldAsVacant field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
group by SoldAsVacant
order by 2

select SoldAsVacant
,   case when SoldAsVacant = '1' then 'Yes'
         when SoldAsVacant = '0' then 'No'
		 else SoldAsVacant 
		 end as SoldAsVacantDescription
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]


SELECT SoldAsVacant,
       CASE 
           WHEN SoldAsVacant = 1 THEN 'Yes'
           WHEN SoldAsVacant = 0 THEN 'No'
           ELSE CAST(SoldAsVacant AS VARCHAR) 
       END AS SoldAsVacantDescription
FROM PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning];



--Removing Duplicates

with RowNumCTE as (
select * ,
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
                  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  order by
				      UniqueID
					  ) row_num

from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
--order by ParcelID
)
select *
from RowNumCTE
WHERE row_num > 1
order by PropertyAddress

select *
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]


--Deleting Unused Columns

select *
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE  PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE  PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
DROP COLUMN SaleDate