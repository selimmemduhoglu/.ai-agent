/***************************************************************************************************
* IRS Forward iþlemlerde çalýþan Nazým hesaplarýn deðiþtirilmesi
***************************************************************************************************/

USE NetTrexAcc

DECLARE @ComponentIdList VARCHAR(MAX);

SELECT @ComponentIdList = STUFF((
    SELECT ';' + CAST(Id AS VARCHAR)
    FROM 
	(
	
		select c.Id
		from AccEngineComponent c
		join AccEngineComponentType ct on ct.Code = c.ComponentTypeCode
		join accEngineGroup g on c.GroupId = g.Id
		left join AccEngineDynamicRule gr on gr.Id = g.ValidationRuleId
		join accEngineEvent e on g.EventId = e.Id
		join accEngineItem i on i.Id = e.ItemId
		where i.Path like 'TREX/DV/IRS/%'
		and e.EventTypeCode = 'OnOpening'
		and ct.Code = '500' -- Value Date Contingent
		and (gr.[Rule] = 'TxnModel.ReceiveValueDate.getTime() <= TxnModel.LogicalDate.getTime()' or
		     gr.[Rule] = 'TxnModel.ReceiveValueDate.getTime() > TxnModel.LogicalDate.getTime()') 

	) AS DistinctIds
    FOR XML PATH('')), 1, 1, '');


DELETE FROM accEngineAccountRule WHERE ComponentId IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@ComponentIdList, ';'));
DELETE FROM accEngineComponent WHERE Id IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@ComponentIdList, ';'));
