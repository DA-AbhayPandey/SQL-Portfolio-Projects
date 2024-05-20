Select*
From Portfolio..NashvilleHousing

--Data Cleaning Project

--1 Standardize date Format
Select Saledate, CONVERT(Date,Saledate)
From Portfolio..NashvilleHousing

Update Portfolio..NashvilleHousing
Set Saledate = CONVERT(Date,Saledate)

Alter Table Portfolio..NashvilleHousing
add SaleDateOnly date

Update Portfolio..NashvilleHousing
Set SaleDateOnly = CONVERT(Date,Saledate)

Select SaleDateOnly, CONVERT(Date,Saledate)
From Portfolio..NashvilleHousing

--2 Populate property address data
Select PropertyAddress 
From Portfolio..NashvilleHousing
Where propertyaddress is null
--Research - Same Parcel ID have same address, So Add same address for same parcel id if the address is null

Select a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio].[dbo].[NashvilleHousing] a
join [Portfolio].[dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio].[dbo].[NashvilleHousing] a
join [Portfolio].[dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--3 Breaking out address into columns (address, city, state)
Select OwnerAddress
From Portfolio..NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
From Portfolio..NashvilleHousing

Alter Table Portfolio..NashvilleHousing
add PropertySplitAddress nvarchar(255)

Update Portfolio..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table Portfolio..NashvilleHousing
add PropertySplitCity nvarchar(255)

Update Portfolio..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From Portfolio..NashvilleHousing

Alter Table Portfolio..NashvilleHousing
add PropertyOwnerAddress nvarchar(255),
PropertyOwnerCity nvarchar(255),
PropertyOwnerState nvarchar(255)

Update Portfolio..NashvilleHousing
Set PropertyOwnerAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PropertyOwnerCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PropertyOwnerState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select*
From Portfolio..NashvilleHousing

--4 Change Y and N to Yes & No in 'SoldAsvacant'
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Portfolio..NashvilleHousing
Group by SoldAsVacant

Select
Case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
End
From Portfolio..NashvilleHousing

Update Portfolio..NashvilleHousing
Set SoldAsVacant =
Case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
End

--5 Delete Unused Column
Select*
From Portfolio..NashvilleHousing

Alter table Portfolio..NashvilleHousing
Drop column PropertyOwnerCity

--5 Delete Duplicate
Select PropertyAddress, Count(PropertyAddress) over (partition by PropertyAddress) as DuplicatePropertyNo
From Portfolio..NashvilleHousing

Delete from Portfolio..NashvilleHousing
Where DuplicatePropertyNo > 1

