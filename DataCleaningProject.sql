-- Data cleaning Project
SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing
ORDER By SaleDate

-- Standardize Date format
SELECT SaleDateConverted, CAST(SaleDate as Date)--, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CAST(SaleDate as Date) 

--Populate Property Adress Data

SELECT ParcelID,COUNT(ParcelID)
FROM PortfolioProject.dbo.NashvilleHousing
Group By ParcelID
Having COUNT(ParcelID) > 1
Order By ParcelID

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is Null
Order By ParcelID

--Fixing Columns which are NULL
SELECT x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress, ISNULL(x.PropertyAddress, y.PropertyAddress)  
FROM PortfolioProject.dbo.NashvilleHousing x
JOIN PortfolioProject.dbo.NashvilleHousing y
	ON x.ParcelID = y.ParcelID
	and x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress is Null

UPDATE x
SET PropertyAddress = ISNULL(x.PropertyAddress, y.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing x
JOIN PortfolioProject.dbo.NashvilleHousing y
	ON x.ParcelID = y.ParcelID
	and x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress is Null

-- Deviding Adress into individual Columns

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)) -1) as Addres
,SUBSTRING(PropertyAddress,(CHARINDEX(',', PropertyAddress)) +1, LEN(PropertyAddress)) as city
FROM PortfolioProject.dbo.NashvilleHousing

--Altering Main Table
ALTER TABLE NashvilleHousing
ADD CorrectAdress nvarchar(255);
UPDATE NashvilleHousing
SET CorrectAdress = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)) -1)

ALTER TABLE NashvilleHousing
ADD CorrectCity nvarchar(255);
UPDATE NashvilleHousing
SET CorrectCity = SUBSTRING(PropertyAddress,(CHARINDEX(',', PropertyAddress)) +1, LEN(PropertyAddress))

-- Another type of Deviding Column By PARSENAME
SELECT OwnerAddress 
FROM PortfolioProject.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as street,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as city,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as state
FROM PortfolioProject.dbo.NashvilleHousing

-- Adding new columns to the main Table
ALTER TABLE NashvilleHousing
ADD OwnerStreet nvarchar(255);
UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) 

ALTER TABLE NashvilleHousing
ADD OwnerCity nvarchar(255);
UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255);
UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) 

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

--Changing some latters

SELECT Distinct(SoldAsVacant),  Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

SELECT SoldAsVacant
,CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

-- Delete Unused Columns

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress,TaxDistrict, SaleDate

--Clearing Dublicate data
SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing
Order By [UniqueID ]

-- Removing dublicate data from column ParcelID
-- 1 ST Way with CTE table
with CTETable as (
		SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY ParcelID,
										SalePrice,
										LegalReference 
										ORDER BY UniqueID ) rn 
		FROM NashvilleHousing)
SELECT *
FROM CTETable
WHERE rn > 1

-- 2 nd Way with subqueries
DELETE NashvilleHousing
WHERE [UniqueID ] IN(
SELECT * FROM (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID,
											SalePrice,
											LegalReference 
											ORDER BY UniqueID ) rn 
	FROM NashvilleHousing) x
WHERE x.rn >1)








