#######################################################################################################
# Script: Update nexthopip routes in a UDR for a specific route in a subscription- Azure
# Author: Ahmed Hussein - Microsoft 
# Date: Sept 2022
# Version: 1.0
# References: 
# GitHub: 
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
#
# IN NO EVENT SHALL MICROSOFT AND/OR ITS RESPECTIVE SUPPLIERS BE
# LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY
# DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
# WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
# ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE
# OF THIS CODE OR INFORMATION.
#
#
########################################################################################################

Param
(
  [Parameter (Mandatory= $true)]
  [string] $subid,
  [Parameter (Mandatory= $true)]
  [string] $oldnexthopip,
  [Parameter (Mandatory= $true)]
  [string] $newnexthopip
)

Connect-AzAccount -Identity

Select-AzSubscription -SubscriptionId $subid

# Get the List of routetables in a subscription that has the old nexthopip in its routes
$routTables = Get-AzRouteTable | where-Object {($_.Routes.NextHopIpAddress -EQ $oldnexthopip)}

if (!$routTables)
{ Write-Output "No Routes found for the NextHopIPAddress selected."}
else
{
#Loop through each RouteConfig to update with the new value
Foreach ($rtTable in $routTables) {
	$rtTableName = $rtTable.Name
	$rtTableRG = $rtTable.ResourceGroupName
	Write-Output $rtTableName , $rtTableRG
	$routeConfigs = Get-AzRouteTable -ResourceGroupName $rtTableRG -Name $rtTableName | Get-AzRouteConfig | where-Object {($_.NextHopIpAddress -EQ $oldnexthopip)}
	Foreach ($rtConfig in $routeConfigs) {
	#update the route config with the new nexthopip under the same name
			Write-output "Updating the route name"
			Write-output $rtConfig.Name
			Write-Output $rtConfig.AddressPrefix
			Get-AzRouteTable -ResourceGroupName $rtTableRG -Name $rtTableName | Set-AzRouteConfig -Name $rtConfig.Name -AddressPrefix $rtConfig.AddressPrefix -NextHopType VirtualAppliance -NextHopIpAddress $newnexthopip | Set-AzRouteTable
			Write-Output "Update is Done!"
	}
}
}



  