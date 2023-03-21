/*
Cleaning Data in SQL Queries
*/

select *
from Nashville_Housing..NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDateConverted convert(date, SaleDate)
from Nashville_Housing..NashvilleHousing;

update NashvilleHousing
set SaleDate = convert(date, SaleDate);

alter table NashvilleHousing
add SaleDateConverted date; 

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate);

Select SaleDate, SaleDateConverted
from NashvilleHousing;

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- Using SUBSTRING to separate the address into diffent parts and then add those columns

select PropertyAddress
from Nashville_Housing..NashvilleHousing;

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from Nashville_Housing..NashvilleHousing

--adding the new columns

alter table Nashville_Housing..NashvilleHousing
add PropertySplitAddress nvarchar(255); 

update Nashville_Housing..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

alter table Nashville_Housing..NashvilleHousing
add PropertySplitCity nvarchar(255); 

update Nashville_Housing..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress));

select *
from Nashville_Housing..NashvilleHousing;

select OwnerAddress
from Nashville_Housing..NashvilleHousing;



-- Using PARSENAME to separate the address into different columns and adding them to the dataset

select 
PARSENAME(replace(OwnerAddress, ',', '.'),3)
, PARSENAME(replace(OwnerAddress, ',', '.'),2)
, PARSENAME(replace(OwnerAddress, ',', '.'),1)
from Nashville_Housing..NashvilleHousing;

-- adding the new columns to the dataset (same as above for substring, just change the column name and = to 

alter table Nashville_Housing..NashvilleHousing
add OwnerSplitAddress nvarchar(255); 

update Nashville_Housing..NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'),3);

alter table Nashville_Housing..NashvilleHousing
add OwnerSplitCity nvarchar(255); 

update Nashville_Housing..NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'),2);

alter table Nashville_Housing..NashvilleHousing
add OwnerSplitState nvarchar(255); 

update Nashville_Housing..NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'),1);

select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from Nashville_Housing..NashvilleHousing;



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville_Housing..NashvilleHousing
group by SoldAsVacant
order by 2;


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from Nashville_Housing..NashvilleHousing;


update Nashville_Housing..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- Not standard practice to remove data from a dataset, but this is for practice purposes (Raw Data)

with RowNumCTE as (
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 order by
					UniqueID
				) row_num
from Nashville_Housing..NashvilleHousing
--order by ParcelID
)
select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress;



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from Nashville_Housing..NashvilleHousing;

alter table Nashville_Housing..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table Nashville_Housing..NashvilleHousing
drop column SaleDate

-----------------------------------------------------------------------------------------------

