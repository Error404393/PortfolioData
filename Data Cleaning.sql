/*

Cleaning Data in SQL Queries

*/

Select * 
from PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-----------------------------------------------------------------------

-- Populate	Property Address Data

Select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null 
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


----------------------------------------------------------------------------------

-- Breaking out address into Individual Columns	(Address, City, State)

Select PropertyAddress
from PortfolioProject..NashvilleHousing

Select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as address	

From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
add PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE PortfolioProject..NashvilleHousing
add PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




select * 
from PortfolioProject..NashvilleHousing

select OwnerAddress 
from PortfolioProject..NashvilleHousing

select 
PARSENAME (Replace(OwnerAddress, ',', '.'), 3)
, PARSENAME (Replace(OwnerAddress, ',', '.'), 2)
, PARSENAME (Replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing 





ALTER TABLE PortfolioProject..NashvilleHousing
add OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME (Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
add OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME (Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
add OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME (Replace(OwnerAddress, ',', '.'), 1)


Select *
from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject..NashvilleHousing


Update PortfolioProject..NashvilleHousing
SET SoldAsVacant =	Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END

-------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES


with RowNumCTE as (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY parcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER by
					UniqueID
					) row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
order by PropertyAddress

--For delete Duplicates Data
DELETE
from RowNumCTE
where row_num > 1


select *
from PortfolioProject..NashvilleHousing



-----------------------------------------------------------

-- Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate