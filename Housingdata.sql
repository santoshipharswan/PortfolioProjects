/*

Cleaning data in sql
*/

--Housing data set for data cleaning.
SELECT *
FROM PortfolioProject..HousingData

--standarizing the date format

SELECT SaleDate
       CONVERT(DATE, SaleDate) 
FROM PortfolioProject..HousingData

ALTER TABLE PortfolioProject..HousingData
ADD Sale_Date date;

Update PortfolioProject..HousingData
SET Sale_Date = CONVERT(DATE, SaleDate) 


--populating property address data
SELECT *
FROM PortfolioProject..HousingData
WHERE PropertyAddress is null
ORDER BY ParcelID

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..HousingData AS a
JOIN PortfolioProject..HousingData AS b
ON a.ParcelID=b.ParcelID
   AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null




--Breaking out Address into Individual columns(address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..HousingData

ALTER TABLE PortfolioProject..HousingData
ADD StreetAddress VARCHAR(255);

Update PortfolioProject..HousingData
SET StreetAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject..HousingData
ADD City VARCHAR(255);
Update PortfolioProject..HousingData
SET City=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--owner address 
SELECT OwnerAddress
FROM PortfolioProject..HousingData

ALTER TABLE PortfolioProject..HousingData
ADD OwnerStreetAddress VARCHAR(255);
Update PortfolioProject..HousingData
SET OwnerStreetAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE PortfolioProject..HousingData
ADD OwnerCity VARCHAR(255);
Update PortfolioProject..HousingData
SET OwnerCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..HousingData
ADD OwnerState VARCHAR(255);
Update PortfolioProject..HousingData
SET OwnerState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--changing y and n to yes and no in 'sold as vaccant' field

SELECT DISTINCT(SoldAsVacant) ,COUNT(SoldAsVacant)
FROM PortfolioProject..HousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
       CASE WHEN SoldAsVacant='N' THEN 'No'
	        WHEN SoldAsVacant='Y' THEN 'Yes'
	   ELSE SoldAsVacant END
FROM PortfolioProject..HousingData

UPDATE PortfolioProject..HousingData
SET SoldAsVacant=CASE WHEN SoldAsVacant='N' THEN 'No'
	                  WHEN SoldAsVacant='Y' THEN 'Yes'
	             ELSE SoldAsVacant END



--Removing Duplicates
WITH RowNumCTE AS(
SELECT *,
      ROW_NUMBER() OVER(PARTITION BY ParcelID,
	                                 PropertyAddress,
									 SalePrice,
									 SaleDate,
									 LegalReference
									 ORDER BY UniqueID
									 ) row_num
FROM PortfolioProject..HousingData 
)
DELETE
FROM RowNumCTE
WHERE row_num>1



--Deleting unused columns
ALTER TABLE PortfolioProject..HousingData 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



