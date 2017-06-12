# Gets a record of the C volume, e.g. with C: at position 5 and MBR at 1
$vbr = Get-ForensicVolumeBootRecord -VolumeName C:

# To setup the dd command (like linux) which uses information from $vbr.
# The examples below should be equivalent. 
# ex: dd if="C:" of="tmp" skip=512 ibs=1024
# Invoke-ForensicDD -InFile "C:" -OutFile "tmp" -Offset 512 -BlockSize 1024
$props = @{
    InFile = "\\.\C:"
    Offset = ($vbr.mftStartIndex * $vbr.BytesPerCluster)
    BlockSize = $vbr.BytesPerFileRecord
    Count = 1
}
# Uses the @props format for the dd command.
#Invoke-ForensicDD @props | Format-Hex

# Gets the .NET filerecord object of position 0 on the C: drive. $MBR is at pos 1 and C: at pos. 5.
$record = Get-ForensicFileRecord -VolumeName C: -Index 0

#$record | Get-Member -MemberType Properties | Format-Table

# Finds structures with the name attribute "DATA", e.g. binwalk or file does the same.
$data = $record.Attribute | Where-Object {$_.Name -eq 'DATA'}

# Loops through the data previously recieved and finds items, parsing them to the "MFT file".
# Remember that this does not override a previous file, but instead adds to the file if ran twice.
<#
foreach($dr in $data.DataRun){
    $props = @{
        InFile = "\\.\C:"
        OutFile = "C:\MFT"
        Offset = ($dr.StartCluster * $vbr.BytesPerCluster)
        BlockSize = $vbr.BytesPerCluster
        Count = $dr.ClusterLength
    }
    Invoke-ForensicDD @props
}
#>


# Gets the master file table of the C volume, saved to $mft
$mft = Get-ForensicFileRecord -VolumeName C:

# Gets information/attributes about $record (line 18)
$record | Get-Member -MemberType Method

#$Shows the total $mft length
$mft.length

# Saves the C-drive, located at index 5
$root = Get-ForensicFileRecord -VolumeName C: -Index 5

# Sets the variable index to where the name is index allocation. Apparently the NameString $I30 is important (from another video)
$index = $root.Attribute | Where-Object {$_.Name -eq "INDEX_ALLOCATION"}

# Same as for record, printing attributes of the $index variables
$index | Get-Member -MemberType Method

# Prints root directory as hex. Looking into it makes you able to see e.g. program files etc as hex. 
# This is also most likely where Get-ForensicChildItem is used to further investigate directories and files.
@($index.GetBytes("\\.\C:")) | Format-Hex 

# To prove the point, this one finds the "MFT" file earlier made in the script. Grep \o/
#@($index.GetBytes("\\.\C:")) | Format-Hex | Select-String -Pattern "M\.F\.T"

Get-ForensicChildItem "C:\"
$mft[207270]

Get-ForensicFileRecordIndex -Path "C:\Program Files"
Get-ForensicContent -Path "C:\$AttrDef" -Encoding Unicode
Get-ForensicContent -Path $mft[86691].FullName