
--Standardizing Date Column
SELECT *
  FROM [MyPortfolioProject].[dbo].[NashvilleHousingData]

Select SaleDate
from NashvilleHousingData

Alter Table NashvilleHousingData
Add SaleDateConverted Date;

update NashvilleHousingData
set SaleDateConverted = CONVERT(date,SaleDate)

select SaleDate, SaleDateConverted
from NashvilleHousingData


--Populating Property Address Data

select *
from NashvilleHousingData
where PropertyAddress is null
order by 2

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
from NashvilleHousingData a
Join NashvilleHousingData b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
from NashvilleHousingData a
Join NashvilleHousingData b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


-- Splitting other Address into Individual Columns (Address, City, State)

select PropertyAddress
from NashvilleHousingData


select PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from NashvilleHousingData

Alter Table NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousingData
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

update NashvilleHousingData
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from NashvilleHousingData

----------------------------

select OwnerAddress
from NashvilleHousingData

select OwnerAddress,
PARSENAME(Replace(OwnerAddress, ',','.'), 3)
,PARSENAME(Replace(OwnerAddress, ',','.'), 2)
,PARSENAME(Replace(OwnerAddress, ',','.'), 1)
from NashvilleHousingData


Alter Table NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousingData
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)

Alter Table NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousingData
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

Alter Table NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

update NashvilleHousingData
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)



--Changing Ys and Ns to Yes and No in the "SoldasVacant" Column of the dataset

select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousingData
group by SoldAsVacant
order by 2


select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
  End
from NashvilleHousingData

Update NashvilleHousingData
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						Else SoldAsVacant
				   End
				   
				   

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousingData
group by SoldAsVacant
order by 2



----Removing Duplicates
---Note that I don't apply these method to actual databases; as deletion only happens in very specific occasions
---The following were done to showcase knowledge of the process and functions


--Using CTE

With RowNumCTE as( 
select*,
ROW_NUMBER() Over(
			Partition by ParcelID,
			PropertyAddress,
			SaleDate,
			SalePrice,
			LegalReference,
			TotalValue
			Order by UniqueID
            ) row_num
from NashvilleHousingData
)
Select *
from RowNumCTE
where row_num>1
--order by ParcelID


--Deleting unused columns

Select *
From NashvilleHousingData

Alter table NashvilleHousingData
Drop column SaleDate, OwnerAddress, PropertyAddress,TaxDistrict


---Further cleaning

Select *
From NashvilleHousingData





--- Importing Data using OPENROWSET and BULK INSERT	


sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

USE MyPortfolioProject 
GO 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 
GO 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 
GO 


--Using BULK INSERT

USE MyPortfolioProject;
GO
BULK INSERT NashvilleHousingData FROM 'C:\Users\Admin\Downloads\Nashville Housing Data for Data Cleaning.csv'
WITH (
     FIELDTERMINATOR = ',',
     ROWTERMINATOR = '\n'
);
GO
