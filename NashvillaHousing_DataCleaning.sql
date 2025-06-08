/*

Nashville Housing Data Cleaning in SQL 

*/

Select *
From NashvilleHousingProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------
-- Standrized Data Format

--Select SaleDateConverted, CONVERT(Date, SaleDate) 
--From NashvilleHousingProject..NashvilleHousing



ALTER TABLE NashvilleHousingProject..NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousingProject..NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate);




-------------------------------------------------------------------------------------------------------------------------------------
-- Popuplate Property Address Data

Select * 
From NashvilleHousingProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousingProject..NashvilleHousing as a
Join NashvilleHousingProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousingProject..NashvilleHousing as a
Join NashvilleHousingProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null




-------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Addresses into Individual Columns (Address, City, State)

-- Property Address (Address, City) using SUBSTRING & CAHRINDEX

Select PropertyAddress
From NashvilleHousingProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City

From NashvilleHousingProject..NashvilleHousing



ALTER TABLE NashvilleHousingProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousingProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1);

ALTER TABLE NashvilleHousingProject..NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousingProject..NashvilleHousing
Set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress));




-- Owner Address (Address, City, State) using PARSENAME

Select OwnerAddress
From NashvilleHousingProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3), --Address
PARSENAME(REPLACE(OwnerAddress,',','.'),2), --City
PARSENAME(REPLACE(OwnerAddress,',','.'),1)	--State
From NashvilleHousingProject..NashvilleHousing

ALTER TABLE NashvilleHousingProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousingProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousingProject..NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousingProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE NashvilleHousingProject..NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousingProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

Select *
From NashvilleHousingProject..NashvilleHousing



-------------------------------------------------------------------------------------------------------------------------------------
-- Change 1 and 0 to Yes and NO in "Sold as Vacant" column


Select Distinct(SoldAsVacant)
From NashvilleHousingProject..NashvilleHousing


ALTER TABLE NashvilleHousingProject..NashvilleHousing
ALTER COLUMN SoldAsVacant varchar(10);


Update NashvilleHousingProject..NashvilleHousing
Set SoldAsVacant = 
Case When SoldAsVacant = '1' Then 'Yes'
	   When SoldAsVacant = '0' Then 'No'
	   Else SoldAsVacant
	   End;

Select *
From NashvilleHousingProject..NashvilleHousing



-------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates using CTE and Window Function

With RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice, 
				LegalReference
				ORDER BY
					UniqueID	
	) as row_num

From NashvilleHousingProject..NashvilleHousing
--Order BY ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order BY PropertyAddress;


Select *
From NashvilleHousingProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns 

ALTER TABLE NashvilleHousingProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict

Select *
From NashvilleHousingProject..NashvilleHousing