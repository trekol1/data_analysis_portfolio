/*

Data Cleaning SQL Queries

*/

SELECT *
FROM Nashville_Housing_Data..Nashville_Housing;

/* Standardize Date Format */

-- Creating new column
ALTER TABLE Nashville_Housing_Data..Nashville_Housing
ADD SaleDateConverted DATE;

-- Populating new column with converted Date
UPDATE Nashville_Housing_Data..Nashville_Housing
SET SaleDateConverted = CONVERT(DATE, Saledate);

-- Checking results
SELECT SaleDateConverted
FROM Nashville_Housing_Data..Nashville_Housing;

/* Populate Property Address Data*/

--There are entries with missing PropertyAddress:
SELECT *
FROM Nashville_Housing_Data..Nashville_Housing
WHERE PropertyAddress IS NULL;

-- But I have noticed that entries sharing the same ParcelID tend to share the same PropertyAddress.
SELECT *
FROM Nashville_Housing_Data..Nashville_Housing
ORDER BY ParcelID

-- So let's look at all entries whose ParcelID is not uniqe
SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress
FROM Nashville_Housing_Data..Nashville_Housing a
JOIN Nashville_Housing_Data..Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ];

-- Now let's match missing PropertyAddress from the left table with existing PropertyAddress from the right table
SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing_Data..Nashville_Housing a
JOIN Nashville_Housing_Data..Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Now let's Update the table and Populate missing PropertyAddress
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing_Data..Nashville_Housing a
JOIN Nashville_Housing_Data..Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Let's check the results
SELECT *
FROM Nashville_Housing_Data..Nashville_Housing
WHERE PropertyAddress IS NULL;
--Great!	

/*Breaking out Address into Individual Columns (Address, City, State) */

SELECT PropertyAddress
FROM Nashville_Housing_Data..Nashville_Housing;


-- Splittinng PropertyAddress into Address and City
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS num_st,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS city
FROM Nashville_Housing_Data..Nashville_Housing;

-- Creating new column for Address
ALTER TABLE Nashville_Housing_Data..Nashville_Housing
ADD PropertySplitAddress NVARCHAR(255);

-- Populating new Address column
UPDATE Nashville_Housing_Data..Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

-- Creating new column for City
ALTER TABLE Nashville_Housing_Data..Nashville_Housing
ADD PropertySplitCity NVARCHAR(255);

-- Populating new City column
UPDATE Nashville_Housing_Data..Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Now let's do the same to OwnerAddress, but using PARSENAME instead of SUBSTRING
SELECT OwnerAddress
FROM Nashville_Housing_Data..Nashville_Housing;

-- Creating new columns
ALTER TABLE Nashville_Housing_Data..Nashville_Housing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE Nashville_Housing_Data..Nashville_Housing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE Nashville_Housing_Data..Nashville_Housing
ADD OwnerSplitState NVARCHAR(255);

-- Let's look at Address, City and State parts of OwnerAddress separately.
-- To do this using PARSENAME I have to replace ',' with '.'
SELECT REPLACE(OwnerAddress, ',', '.')
FROM Nashville_Housing_Data..Nashville_Housing;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Nashville_Housing_Data..Nashville_Housing;

-- Now let's populate new Split columns
UPDATE Nashville_Housing_Data..Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE Nashville_Housing_Data..Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE Nashville_Housing_Data..Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


/* Change Y and N to Yes and No in "Sold as Vacant" field */

SELECT SoldAsVacant
FROM Nashville_Housing_Data..Nashville_Housing;

-- SoldAsVacant field is not standardized
-- Let's see and count all distinct entries
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville_Housing_Data..Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

-- Let's generate new values that should be inserted
SELECT SoldAsVacant,
CASE 
   WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
END
FROM Nashville_Housing_Data..Nashville_Housing;

--Now Let's update SoldAsVacant field
UPDATE Nashville_Housing_Data..Nashville_Housing
SET SoldAsVacant = CASE 
   WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
END;

--Now let's again see and count all distinct entries to check the results
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville_Housing_Data..Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2
-- Great!


/* Remove Duplicates */

-- I will try to use ROW_NUMBER() function to check for rows that have same values in specified columns (ROW_NUMBER will encrease from 1 if it finds duplicate)
-- For example let's look for duplicating ParcelID:
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID ORDER BY UniqueID) row_num
FROM Nashville_Housing_Data..Nashville_Housing;

--Now let's look for rows that have same values in multiple columns:
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	ORDER BY UniqueID
	) row_num
FROM Nashville_Housing_Data..Nashville_Housing
ORDER BY ParcelID;

-- Now let's look only on duplicating rows:
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	ORDER BY UniqueID
	) row_num
FROM Nashville_Housing_Data..Nashville_Housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;

-- Now I can DELETE duplicates:
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	ORDER BY UniqueID
	) row_num
FROM Nashville_Housing_Data..Nashville_Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;

/* Delete Unused Columns */

-- I want to delete Addresses which I have splitted into different columns, and SaleDate which I have converted
ALTER TABLE Nashville_Housing_Data..Nashville_Housing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDateConverted;

SELECT *
FROM Nashville_Housing_Data..Nashville_Housing;