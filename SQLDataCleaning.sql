--Cleaning Data

Select * from SQLDataCleaning.dbo.NashvilleHousing

--Standardize Date Format
Select SaleDateConverted, CONVERT(Date,SaleDate) from dbo.NashvilleHousing
--Updating the dataset
update NashvilleHousing set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashVilleHousing
Add SaleDateConverted Date;

update NashvilleHousing set SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data

Select * from SQLDataCleaning.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
From 
SQLDataCleaning.dbo.NashvilleHousing a 
join 
SQLDataCleaning.dbo.NashvilleHousing b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
From 
SQLDataCleaning.dbo.NashvilleHousing a 
join 
SQLDataCleaning.dbo.NashvilleHousing b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
from SQLDataCleaning.dbo.NashvilleHousing

-- SELECT
-- SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address
-- from SQLDataCleaning.dbo.NashvilleHousing

SELECT
    RTRIM(SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM SQLDataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress));


SELECT * FROM SQLDataCleaning.dbo.NashvilleHousing

Select OwnerAddress From SQLDataCleaning.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
From SQLDataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

-- ALTER TABLE NashvilleHousing
-- DROP COLUMN OwnerSplitState;

Select * From SQLDataCleaning.dbo.NashvilleHousing

-- Change Y and N to Yes and No
Select Distinct(SoldAsVacant), Count(SoldAsVacant) countingSAV
from SQLDataCleaning.dbo.NashvilleHousing
Group by SoldAsVacant
Order by countingSAV

Select SoldAsVacant, 
CASE 
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
Else SoldAsVacant
End
From SQLDataCleaning.dbo.NashvilleHousing;

Update NashvilleHousing
SET SoldAsVacant = CASE 
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
Else SoldAsVacant
End

--Remove Duplicates
WITH RowNumCTE AS(
Select *,ROW_NUMBER() OVER (
PARTITION BY 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY
	UniqueID) row_num
From SQLDataCleaning.dbo.NashvilleHousing
-- order by ParcelID
)
--DELETE
--From RowNumCTE 
--where row_num>1 
-- order by PropertyAddress

Select * 
from RowNumCTE
where row_num>1
order by PropertyAddress;

--delete unused columns

Select *
from SQLDataCleaning.dbo.NashvilleHousing;

ALTER TABLE SQLDataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress;

ALTER TABLE SQLDataCleaning.dbo.NashvilleHousing
DROP COLUMN SaleDate;

