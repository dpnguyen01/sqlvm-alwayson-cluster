<#
.EXAMPLE
    This example shows how to set max degree of parallelism server
    configuration option with the automatic configuration.

    In the event this is applied to a Failover Cluster Instance (FCI), the
    ProcessOnlyOnActiveNode property will tell the Test-TargetResource function
    to evaluate if any changes are needed if the node is actively hosting the
    SQL Server instance.
#>
Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SysAdminAccount
    )

    Import-DscResource -ModuleName xSqlServer

    node localhost
    {
        xSQLServerMaxDop Set_SQLServerMaxDop_ToAuto
        {
            Ensure                  = 'Present'
            DynamicAlloc            = $true
            SQLServer               = 'SQLServer'
            SQLInstanceName         = 'DSC'
            PsDscRunAsCredential    = $SysAdminAccount
            ProcessOnlyOnActiveNode = $true
        }
    }
}
