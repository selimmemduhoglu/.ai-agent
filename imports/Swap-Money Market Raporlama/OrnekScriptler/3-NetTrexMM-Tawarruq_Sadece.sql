USE NetTrexCommon
GO
-- Menu de Tawarruq oluşturuldu.


IF NOT EXISTS (SELECT 1 FROM FrameworkMenu WHERE MenuKey = 'TawarruqKey')
BEGIN
    INSERT INTO FrameworkMenu 
    (
        ApplicationName,
        Description,
        MenuKey,
        MenuType,
        Value,
        ForcedUrl,
        ForcedPermission,
        Icon,
        IsActive,
        ItemOrderId,
        ParentId,
        StateDate,
        StateId,
        StateMaker
    )
    VALUES
    (
        'Trex.WebUI',                    
        'Tawarruq',                      
        'TawarruqKey',                  
        'ControllerAction',             
        'Tawarruq/Index',                
        NULL,                            
        NULL,                           
        'fa-solid fa-handshake',       
        1,                               
        15,                              
        17,                           
        GETDATE(),                     
        18,                           
        'system'                       
    );
    
    PRINT 'Tawarruq menu item added successfully.';
    PRINT 'Menu Location: Treasury > Money & Market > Tawarruq';
    PRINT 'Menu Order: After REPO Transactions (ItemOrderId: 15)';
END
ELSE
BEGIN
    PRINT 'Tawarruq menu item already exists in FrameworkMenu table.';
END;

GO


USE NetTrexCommon
GO

-- Temel roller
EXEC sp_FrameworkAddPermission @PermissionName = 'Tawarruq_Maker', @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = 'Tawarruq_Checker', @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = 'Tawarruq_Displayer', @ApplicationName = 'Trex.WebUI';

GO

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/Index'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/Load'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/Preview'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/History'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/SelectAcc'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/GetLogicalReferencesForTawarruq'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/GetTransactionDataByLogicalReference'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/GetCustomerBrokers'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/GetCurrency'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/SelectCustomerAccounts'

--
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/TxnType'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/GetOpeningCount'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/Get'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/Accounting'



exec sp_FrameworkAddPermissionAction 'MmTransaction_Displayer', 'Trex.WebUI', 'MmTransaction/GetProductDefinition'
exec sp_FrameworkAddPermissionAction 'MmTransaction_Displayer', 'Trex.WebUI', 'MmTransaction/GetMmLogicalDate'


-- MAKER
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/Form'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/Get'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/Create'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/Update'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/Delete'

--
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/GetLogicalReferencesForTawarruq'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/GetTransactionDataByLogicalReference'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/GetCustomerBrokers'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/GetCurrency'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/SelectCustomerAccounts'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/TxnType'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/GetOpeningCount'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/History'

exec sp_FrameworkAddPermissionAction 'MmTransaction_Maker', 'Trex.WebUI', 'MmTransaction/GetProductDefinition'
exec sp_FrameworkAddPermissionAction 'MmTransaction_Maker', 'Trex.WebUI', 'MmTransaction/GetMmLogicalDate'
exec sp_FrameworkAddPermissionAction 'MmTransaction_Displayer', 'Trex.WebUI', 'MmTransaction/Get'


-- CHECKER
exec sp_FrameworkAddPermissionAction 'Tawarruq_Checker', 'Trex.WebUI', 'Tawarruq/Verify'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Checker', 'Trex.WebUI', 'Tawarruq/SecondVerify'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Checker', 'Trex.WebUI', 'Tawarruq/Reject'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Checker', 'Trex.WebUI', 'Tawarruq/Preview'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Checker', 'Trex.WebUI', 'Tawarruq/History'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Checker', 'Trex.WebUI', 'Tawarruq/Get'



-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/SwiftMessagePreview'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI', 'Tawarruq/SendSwiftMessage'

-- MAKER
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/SwiftMessagePreview'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Maker', 'Trex.WebUI', 'Tawarruq/SendSwiftMessage'

-- CHECKER
exec sp_FrameworkAddPermissionAction 'Tawarruq_Checker', 'Trex.WebUI', 'Tawarruq/SwiftMessagePreview'
exec sp_FrameworkAddPermissionAction 'Tawarruq_Checker', 'Trex.WebUI', 'Tawarruq/SendSwiftMessage'




GO
