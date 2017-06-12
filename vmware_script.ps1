$run_program = 'C:\Users\Frikky\Documents\dev\vmrun.exe'
#$target_vmx = 'H:\Kali\Kali.vmx'
$test_target= 'H:\Kali\Kali.vmx'
$vmx_import = ' -T pro start '

$script = $run_program + $vmx_import + $test_target

#Read file
#$test_target = 'C:\Users\Frikky\Documents\hei.txt'
$test_file = Get-Content $test_target

# Clear file
"" | Set-Content $test_target

# Boolean1
$poweron_fullscreen = ""
$poweron_viewmode = ""
$last_viewmode = ""

# Boolean2
$poweron_fullscreen2 = ""
$poweron_viewmode2 = ""
$last_viewmode2 = ""

# Sjekk med array -contains "value" forst
$Search_vars = 'gui.fullScreenAtPowerOn = "TRUE"', 'gui.viewModeAtPowerOn = "fullscreen"', 'gui.lastPoweredViewMode = "fullscreen"'

# First test to see if arguments are in file
If ($test_file -contains $Search_vars[0]) {
	$poweron_fullscreen = "TRUE"
} 
If ($test_file -contains $Search_vars[1]) {
	$poweron_viewmode = "TRUE"
}
If ($test_file -contains $Search_vars[2]) {
	$last_viewmode = "TRUE"
}

# Testing individual parts
#for ($i = 0; $i -le $test_file.Length; $i++) {
Foreach ($Line in $test_file) {
	$tmp = ""
	# DOESNT WORK FOR SOME FREAKING REASON
	if ($Line -match "gui.fullScreenAtPowerOn") {
		if (-Not ($poweron_fullscreen -match "TRUE")) {
			Write-Host "hello"
			$Search_vars[0] | Add-Content $test_target
		} 
		$poweron_fullscreen2 = "TRUE"	
	} Elseif ($Line -match "gui.viewModeAtPowerOn") {
		if (-Not ($poweron_viewmode -match "TRUE")) {
			$Search_vars[1] | Add-Content $test_target
		}
		$poweron_viewmode2 = ""
	} Elseif ($Line -match "gui.lastPoweredViewMode") {
		if (-Not ($last_viewmode -match "TRUE")) {
			$Search_vars[2] | Add-Content $test_target
		} 
		$last_viewmode2 = ""
	} Else {
		$Line | Add-Content $test_target
	}
}

# Last bugcheck
if (-Not ($poweron_fullscreen2 -eq "TRUE")) {
	$Search_vars[0] | Add-Content $test_target
}
if (-Not ($poweron_viewmode2 -eq "TRUE")) {
	$Search_vars[1] | Add-Content $test_target
}
if (-Not ($last_viewmode2 -eq "TRUE")) {
	$Search_vars[2] | Add-Content $test_target
}

Invoke-Expression $script
Write-Host "DONE! :D"
