SELECT *
FROM PortfolioProject..HousingData



-- Standardizing date format

SELECT DateOfSale , CONVERT(Date, SaleDate)
FROM PortfolioProject..HousingData

ALTER Table HousingData
ADD DateOfSale Date;

UPDATE HousingData
SET DateOfSale = CONVERT(Date, SaleDate)





-- Filling Empty Property Addresses

SELECT x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress, ISNULL(x.PropertyAddress, y.PropertyAddress)
FROM PortfolioProject..HousingData x
JOIN PortfolioProject..HousingData y
 ON x.ParcelID = y.ParcelID
 AND x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress is null


UPDATE x
SET PropertyAddress = ISNULL(x.PropertyAddress, y.PropertyAddress)
FROM PortfolioProject..HousingData x
JOIN PortfolioProject..HousingData y
 ON x.ParcelID = y.ParcelID
 AND x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress is null





-- Address divided into House Number, City etc


SELECT *
FROM PortfolioProject..HousingData


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS HouseNumber,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..HousingData



ALTER Table HousingData
ADD HouseNumber nvarchar(250);

UPDATE HousingData
SET HouseNumber = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)



ALTER Table HousingData
ADD City nvarchar(250);

UPDATE HousingData
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))




SELECT OwnerAddress
FROM PortfolioProject..HousingData

 
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 1)
FROM PortfolioProject..HousingData



ALTER TABLE HousingData
ADD OwnerHouseNumber nvarchar(250);

UPDATE HousingData
SET OwnerHouseNumber = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 3)


ALTER TABLE HousingData
ADD OwnerHouseCity nvarchar(250);

UPDATE HousingData
SET OwnerHouseCity = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 2)


ALTER TABLE HousingData
ADD OwnerHouseState nvarchar(250);



UPDATE HousingData
SET OwnerHouseState = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 1)







--Updating Sold As Vacant Column

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..HousingData
GROUP By SoldAsVacant



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject..HousingData



UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject..HousingData




-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
 PARTITION BY ParcelID,
 PropertyAddress,
 SalePrice,
 SaleDate,
 LegalReference
  ORDER BY UniqueID
  ) row_num


FROM PortfolioProject..HousingData
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



DELETE
FROM RowNumCTE
WHERE row_num > 1



-- Deleted Unused Columns


ALTER TABLE PortfolioProject..HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject..HousingData
DROP COLUMN SaleDate