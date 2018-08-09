configuration MSFT_xSQLServerSetup_InstallSqlEngineAsSystem_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlInstallCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlServiceCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlAdministratorCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlAgentServiceCredential
    )

    Import-DscResource -ModuleName 'PSDscResources'
    Import-DscResource -ModuleName 'xStorage'
    Import-DscResource -ModuleName 'xSQLServer'

    node localhost {
        xMountImage 'MountIsoMedia'
        {
            ImagePath   = $Node.ImagePath
            DriveLetter = $Node.DriveLetter
            Ensure      = 'Present'
        }

        xWaitForVolume WaitForMountOfIsoMedia
        {
            DriveLetter      = $Node.DriveLetter
            RetryIntervalSec = 5
            RetryCount       = 10
        }

        User 'CreateSqlServiceAccount'
        {
            Ensure   = 'Present'
            UserName = Split-Path -Path $mockSqlServiceCredential.UserName -Leaf
            Password = $mockSqlServiceCredential
        }

        User 'CreateSqlAgentServiceAccount'
        {
            Ensure   = 'Present'
            UserName = Split-Path -Path $SqlAgentServiceCredential.UserName -Leaf
            Password = $SqlAgentServiceCredential
        }

        User 'CreateSqlInstallAccount'
        {
            Ensure   = 'Present'
            UserName = Split-Path -Path $SqlInstallCredential.UserName -Leaf
            Password = $SqlInstallCredential
        }

        User 'CreateSqlAdminAccount'
        {
            Ensure   = 'Present'
            UserName = Split-Path -Path $SqlAdministratorCredential.UserName -Leaf
            Password = $SqlAdministratorCredential
        }

        WindowsFeature 'NetFramework45'
        {
            Name   = 'NET-Framework-45-Core'
            Ensure = 'Present'
        }

        xSQLServerSetup 'Integration_Test'
        {
            InstanceName          = $Node.InstanceName
            Features              = $Node.Features
            SourcePath            = "$($Node.DriveLetter):\"
            BrowserSvcStartupType = 'Automatic'
            SQLCollation          = $Node.SQLCollation
            SQLSvcAccount         = $SqlServiceCredential
            AgtSvcAccount         = $SqlAgentServiceCredential
            ASSvcAccount          = $SqlServiceCredential
            InstallSharedDir      = $Node.InstallSharedDir
            InstallSharedWOWDir   = $Node.InstallSharedWOWDir
            UpdateEnabled         = $Node.UpdateEnabled
            SuppressReboot        = $Node.SuppressReboot
            ForceReboot           = $Node.ForceReboot

            # This must be set if using SYSTEM account to install.
            SQLSysAdminAccounts   = @(
                $SqlAdministratorCredential.UserName
            )

            DependsOn             = @(
                '[xMountImage]MountIsoMedia'
                '[User]CreateSqlServiceAccount'
                '[User]CreateSqlAgentServiceAccount'
                '[User]CreateSqlInstallAccount'
                '[User]CreateSqlAdminAccount'
                '[WindowsFeature]NetFramework45'
            )
        }
    }
}
