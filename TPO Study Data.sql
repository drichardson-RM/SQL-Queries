select * from (
select	R.CompanyID,
		c.Name as client,
		R.RoofID, 
		--R.Region,
		case 
			when R.State in ('ME','NH','VT','MA','MD','NY','NJ','DE','PA','VA','RI','CT') then 'Northeast'
			when R.State in ('WI','MI','IL','IN','OH','KY','WV') then 'Midwest'
			when R.State in ('TN','NC','SC','GA','AL','MS','FL') then 'Southeast'
			when R.State in ('MN','IA','MO','KS','NE','WY','MT','ID','UT','CO') then 'North Central'
			when r.State in ('NM','OK','AR','LA','TX') then 'South Central'
			when R.State in ('CA','NV','AZ') and r.latitude < 37 then 'Southwest'
			when r.state in ('CA') and r.latitude > 37 and r.latitude < 38.3779 and r.longitude < -120.75 and r.longitude > -122.75 then 'Bay Area'
			when r.state in ('NV') and r.latitude > 37 and r.latitude < 39.8289 and r.longitude < -118.795 then 'Reno'
			when r.state in ('WA','OR','CA','NV') and r.latitude > 37 then 'Northwest'
		else null
		end Region,
		r.latitude,
		r.longitude,
		R.Market,
		R.RoofName as 'Property/Roof Section',
		R.Address,
		R.City,
		R.State,
		R.Country,
		R.LastRoofYear,
		Man.Name as 'Manufacturer',
		R.RoofType,
		R.RoofTypeGroup,
		R.Notes,
		case when r.rooftype like '%45%' then .045
			when r.rooftype like '%60%' then .060
			when assembly.thickness like '%45%' then .045
			when assembly.thickness like '%60%' then .060
			when assembly.thickness like '%48%' then .048
			when assembly.thickness like '%50%' then .050
			when assembly.thickness like '%80%' then .080
			when assembly.thickness like '%55%' then .055
			else null
			end OriginalThickness,
		Year(i.DateCompleted) as 'TPO Study Year',
		TPS.ThicknessReading,
		assembly.Layer,
		Assembly.Description, 
		Assembly.Thickness
from		tblRoofs R
		join tblInspections I on r.roofid = i.roofid and year(i.estimateddate) = 2020
		join tblInspectionTpoPvcStudy TPS on TPS.InspectionID = i.inspectionID
		join tblCompanies Man on r.Manufacturer = Man.companyID
		join tblCompanies C on r.companyID = c.companyID
		left outer join 	(
						select 
							RA.ID, RA.RoofID, RA.Layer, RA.Description, RA.Thickness, 
							row_number() over( partition by roofid order by ID desc) as rnk 
						from 	tblRoofAssembly RA 
						where 	RA.Layer = 'Membrane'
						) Assembly on Assembly.RoofID = r.RoofId and Assembly.rnk = 1 
where	--R.CompanyID = 3522 and
		R.IsActive = 1 and r.consultant = 3023 and r.country = 'USA' and tps.ThicknessReading > 0 and r.rooftype not like '%fleece%') a
where a.OriginalThickness > a.ThicknessReading