function Get-ADSIFGPassWordPolicy
{
<#
.SYNOPSIS
	This function will query and list Fine-Grained Password Policies in Active Directory

.DESCRIPTION
	This function will query and list Fine-Grained Password Policies in Active Directory
	it return 
	name : the Name of the Policy
	MinimumPasswordLength  : Minimum PassWord Size int
	passwordreversibleencryptionenabled : Encryption Type reversible (not secure) or not
	minimumpasswordage : The number of day before the user Can change the password
	maximumpasswordage : The number of day that a password can be used before the system requires the user to change it
	passwordcomplexityenabled : True of Fals
	passwordsettingsprecedence : Integer needed to determine which policy to apply in a user is mapped to more than one policy
	lockoutduration : Time in minute before reseting failed logon count
	lockoutobservationwindow : Time between 2 failed logoin attemps before reseting the counter to 0
	lockoutthreshold : Number of failed login attempt to trigger lockout
	psoappliesto : Groups and/or Users 
	WhenCreated
	WhenChanged

.PARAMETER  Name
	Specify the name of the policy to retreive
	
.PARAMETER Credential
    Specify the Credential to use

.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output
	
.EXAMPLE
	Get-ADSIFGPassWordPolicy 
    Retreive all the password policy on the current domain

.EXAMPLE
	get-ADSIFGPasswordPolicies -Name Name
    Retreive the password policy nammed 'Name' on the current domain
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
	github.com/lazywinadmin/AdsiPS
	Olivier Miossec
	@omiossec_med
#>
	


    [CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = "Name")]
		[String]$Name,
			
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Alias("Domain", "DomainDN", "SearchRoot", "SearchBase")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)



	BEGIN { } 

	PROCESS
	{
		TRY
		{
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.SearchRoot = $DomainDistinguishedName
			$Search.filter = "(objectclass=msDS-PasswordSettings)"
			IF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
				Write-Verbose -Message "Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}

					foreach ($Object in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!!!!!!!
				$Properties = @{
					"Name" = $Object.properties.name -as [string]
					"PasswordHistorylength" = $Object.Properties.Item("msds-passwordhistorylength") -as [int]
					"MinimumPasswordLength" = $Object.Properties.Item("msds-minimumpasswordlength") -as [int]
					"passwordreversibleencryptionenabled" = $Object.Properties.Item("msds-passwordreversibleencryptionenabled") -as [string]
					"minimumpasswordage" = $Object.Properties.Item("msds-minimumpasswordage") -as [string]
					"maximumpasswordage" = $Object.Properties.Item("msds-maximumpasswordage") -as [string]
					"passwordcomplexityenabled" = $Object.Properties.Item("msds-passwordcomplexityenabled") -as [string]
					"passwordsettingsprecedence" = $Object.Properties.Item("msds-passwordsettingsprecedence") -as [string]
					"lockoutduration" = $Object.Properties.Item("msds-lockoutduration") -as [string]
					"lockoutobservationwindow" = $Object.Properties.Item("msds-lockoutobservationwindow") -as [string]
					"lockoutthreshold" = $Object.Properties.Item("msds-lockoutthreshold") -as [string]
					"psoappliesto" = $Object.Properties.Item("msds-psoappliesto") -as [string]
					"WhenCreated" = $Object.properties.whencreated -as [string]
					"WhenChanged" = $Object.properties.whenchanged -as [string]
				}
				
				# Output the info
				New-Object -TypeName PSObject -Property $Properties
			}

		}
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSIFGPassWordPolicy End."
	}
}