/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select [SaleDate], CONVERT (date, [SaleDate])
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN [SaleDate] date


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
Select [ParcelID], [PropertyAddress]
From PortfolioProject.dbo.NashvilleHousing 
WHERE [PropertyAddress] IS NULL
ORDER BY [ParcelID]

Select a.[ParcelID], a.[PropertyAddress], b.[PropertyAddress], ISNULL(a.[PropertyAddress],b.[PropertyAddress])
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.[ParcelID] = b.[ParcelID]
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.[PropertyAddress] IS NULL

UPDATE a
SET [PropertyAddress] = ISNULL(a.[PropertyAddress],b.[PropertyAddress])
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.[ParcelID] = b.[ParcelID]
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.[PropertyAddress] IS NULL
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- NVARCHAR can store Unicode data while VARCHAR can't
Select [PropertyAddress], 
		SUBSTRING([PropertyAddress], 1, CHARINDEX(',',[PropertyAddress])-1) AS Address,
		--SUBSTRING([PropertyAddress], CHARINDEX(',',[PropertyAddress])+1, LEN([PropertyAddress]) - CHARINDEX(',',[PropertyAddress])) AS city,
		SUBSTRING([PropertyAddress], CHARINDEX(',',[PropertyAddress])+1, LEN([PropertyAddress]) ) AS City
From PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD [PropertyStreet] NVARCHAR(255);

UPDATE NashvilleHousing
SET [PropertyStreet] = SUBSTRING([PropertyAddress], 1, CHARINDEX(',',[PropertyAddress])-1)

ALTER TABLE NashvilleHousing
ADD [PropertyCity] NVARCHAR(50);

UPDATE NashvilleHousing
SET [PropertyCity] = SUBSTRING([PropertyAddress], CHARINDEX(',',[PropertyAddress])+1, LEN([PropertyAddress]) )

Select *
From PortfolioProject.dbo.NashvilleHousing

SELECT 
     REVERSE(PARSENAME(REPLACE(REVERSE([OwnerAddress]), ',', '.'), 1)) AS [Street],
	 REVERSE(PARSENAME(REPLACE(REVERSE([OwnerAddress]), ',', '.'), 2)) AS [City],
     REVERSE(PARSENAME(REPLACE(REVERSE([OwnerAddress]), ',', '.'), 3)) AS [State]
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD [OwnerStreet] NVARCHAR(255);

UPDATE NashvilleHousing
SET [OwnerStreet] = REVERSE(PARSENAME(REPLACE(REVERSE([OwnerAddress]), ',', '.'), 1))

ALTER TABLE NashvilleHousing
ADD [OwnerCity] NVARCHAR(255);

UPDATE NashvilleHousing
SET [OwnerCity] =  REVERSE(PARSENAME(REPLACE(REVERSE([OwnerAddress]), ',', '.'), 2))

ALTER TABLE NashvilleHousing
ADD [OwnerState] NVARCHAR(255);

UPDATE NashvilleHousing
SET [OwnerState] = REVERSE(PARSENAME(REPLACE(REVERSE([OwnerAddress]), ',', '.'), 3))

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT [SoldAsVacant], COUNT([SoldAsVacant])
From PortfolioProject.dbo.NashvilleHousing
GROUP BY [SoldAsVacant]
ORDER BY 2


Select [SoldAsVacant],
	CASE WHEN [SoldAsVacant] ='Y' THEN 'Yes'
		 WHEN [SoldAsVacant] ='N' THEN 'No'
		 ELSE [SoldAsVacant]
		 END
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET [SoldAsVacant] = 	CASE WHEN [SoldAsVacant] ='Y' THEN 'Yes'
		 WHEN [SoldAsVacant] ='N' THEN 'No'
		 ELSE [SoldAsVacant]
		 END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER( 
		PARTITION BY [ParcelID]
					,[PropertyAddress]
					,[SaleDate]
					,[SalePrice]
					,[LegalReference] 
		ORDER BY [UniqueID ])
	row_num
From PortfolioProject.dbo.NashvilleHousing
--ORDER BY [ParcelID]
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

DELETE
FROM RowNumCTE
WHERE row_num > 1

CREATE OR ALTER VIEW View_NashvilleHousing AS
SELECT *,
	ROW_NUMBER() OVER( 
		PARTITION BY [ParcelID]
					,[PropertyAddress]
					,[SaleDate]
					,[SalePrice]
					,[LegalReference] 
		ORDER BY [UniqueID ])
	row_num
From PortfolioProject.dbo.NashvilleHousing

SELECT *
FROM View_NashvilleHousing
WHERE row_num > 1

DELETE
FROM View_NashvilleHousing
WHERE row_num > 1
---------------------------------------------------------------------------------------------------------

-- Delete Unused Column
CREATE OR ALTER VIEW View_NashvilleHousing2 AS
SELECT [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyStreet]
	  ,[PropertyCity]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerStreet]
	  ,[OwnerCity]
	  ,[OwnerState]
      ,[Acreage]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
FROM View_NashvilleHousing

SELECT *
FROM View_NashvilleHousing2

DROP VIEW View_NashvilleHousing
