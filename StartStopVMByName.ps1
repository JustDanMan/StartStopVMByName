<#
    .DESCRIPTION
        A runbook which start or stop VMs by name

    .NOTES
        AUTHOR: Daniel Vigano
        LASTEDIT: Feb 23, 2023
#>

workflow StartStopVMByName {
    param (
        [Parameter(Mandatory=$true)]
        [String]$SubscriptionID,

        [Parameter(Mandatory=$true)]
        [String]$VMName,

        [Parameter(Mandatory=$true)]
        [Boolean]$Shutdown
    )

    try
    {
        "Logging in to Azure..."
        Connect-AzAccount -Identity
    }
    catch {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }

	Set-AzContext -SubscriptionId $SubscriptionID

    $VMs = Get-AzResource -ResourceType "Microsoft.Compute/virtualMachines" -Name $VMName

    foreach -Parallel ($VM in $VMs)
    {    
        if($Shutdown) {
            Write-Output ("Stopping " + $vm.Name)
            Stop-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Force
        }
        else {
            Write-Output ("Starting " + $vm.Name)
            Start-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
        }
    }
}