--Data Cleaning Project Nashville Housing Data 
--1.Populate columns with NULL values

SELECT * FROM NashvilleHousing;

UPDATE a SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a JOIN NashvilleHousing b
ON a.parcelid=b.parcelid  AND  a.uniqueid<> b.uniqueid
WHERE a.propertyaddress IS NULL;

SELECT * FROM NashvilleHousing 
--Break out Address into Individual Columns(Address,city,state)
ALTER TABLE NashvilleHousing
ADD PropertySPlitAddress NVARCHAR(255);
UPDATE NashvilleHousing
SET PropertySPlitAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) ;

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress));


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',', '.') ,3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress,',', '.') ,2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress,',', '.') ,1);

--Replace Y & N to Yes and No 
SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) 
FROM practice..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

UPDATE NashvilleHousing
SET SoldAsVacant= 
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
WHEN SoldAsVacant='N'THEN 'No'
ELSE SoldAsVacant
END;

--Remove Duplicates
WITH rownumCTE AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
ORDER BY UniqueID)ROW_NUM
FROM practice..NashvilleHousing 
);
--Delete Duplicates
DELETE FROM rownumCTE WHERE ROW_NUM >1 ;

--Delete unused columns
SELECT *FROM practice..NashvilleHousing
ALTER TABLE practice..NashvilleHousing DROP COLUMN propertyaddress,taxdistrict,owneraddress;
