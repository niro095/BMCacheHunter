<#
.SYNOPSIS 
This Script can be used for Threat Hunting/Digital Forensics purposes.
To hunt for malicious/suspicious strings in BMC files.
The Script Made especially as a PoC for BSIDES TLV 2021, The Script is a joined effort of Nir Saias, Yossi Sassi and Rotem Lipowitch.

.DESCRIPTION
We relaying on third-party 

.PARAMETER ComputerList
List of computers separated using newline.

.PARAMETER IOCList
File in a CSV format of IOC's following the next pattern - [IOC],[Description].
#>

[cmdletbinding()]
param (
    [string]$ComputerList = "$(Get-Location)\Computer_list.txt",
    [string]$IOCList = "$(Get-Location)\IOC.txt"
)

$style = @"
<style>
    th, td {
        padding: 5px;
        text-align: left;    
    }

    body {
        background: #eee
    }

    .icons i {
        color: #b5b3b3;
        border: 1px solid #b5b3b3;
        padding: 6px;
        margin-left: 4px;
        border-radius: 5px;
        cursor: pointer
    }

    .activity-done {
        font-weight: 600
    }

    .list-group li {
        margin-bottom: 12px
    }

    .list-group-item {}

    .list li {
        list-style: none;
        padding: 10px;
        border: 1px solid #e3dada;
        margin-top: 12px;
        border-radius: 5px;
        background: #fff
    }

    .checkicon {
        color: green;
        font-size: 19px
    }

    .date-time {
        font-size: 12px
    }

    .profile-image img {
        margin-left: 3px
    }
</style>
"@

$HTML = @"
<!doctype html>
<html>
    <head>
        <meta charset='utf-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1'>
        <title>BMC ThreatHunter - Bsides 2021</title>
        <link href='https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css' rel='stylesheet'>
        <link href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css' rel='stylesheet'>
        <script type='text/javascript' src='https://cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js'></script>
        {0}
    </head>
    <body oncontextmenu='return false' class='snippet-body'>
    <div class="logo">
		<a href="https://10root.com/" title="10root" class="site_logo" rel="home" itemprop="url" data-fontsize="18">
		    <!--?xml version="1.0" encoding="UTF-8"?--> <svg xmlns="http://www.w3.org/2000/svg" width="225.381" height="71.999" viewBox="0 0 225.381 71.999"><g id="logo_negativ" data-name="logo negativ" transform="translate(112.691 36)"><g id="Group_483" data-name="Group 483" transform="translate(-112.691 -36)"><g id="Group_480" data-name="Group 480" transform="translate(155.042 37.279)"><path id="Path_1127" data-name="Path 1127" d="M161.833,49.213c-1.574,0-1.672-1.672-1.672-2.755V43.015c0-.984-.2-3.148,1.672-3.148s1.082,1.476,1.181,2.263h2.263a6.1,6.1,0,0,0-.1-.984,3.148,3.148,0,0,0-3.345-3.246c-3.738,0-3.935,2.361-4.033,5.607v1.771c0,3.345.3,5.8,4.033,5.8s3.345-1.771,3.443-4.033V46.36h-2.361C162.916,47.147,163.112,49.213,161.833,49.213Z" transform="translate(-157.603 -37.894)" fill="#00a3c9"></path><path id="Path_1128" data-name="Path 1128" d="M171.914,41.153a10.723,10.723,0,0,0-.787,2.361h0a8.56,8.56,0,0,0-.59-1.968L169.258,38.3H166.7l3.246,7.182v5.312h2.361V45.482l3.246-7.182H173Z" transform="translate(-157.748 -37.9)" fill="#00a3c9"></path><path id="Path_1129" data-name="Path 1129" d="M182.809,44.1h0a2.459,2.459,0,0,0,1.476-2.656,3.345,3.345,0,0,0-.59-2.263,2.951,2.951,0,0,0-2.656-.885H177.3V50.793h4.132a2.853,2.853,0,0,0,3.05-2.263,6,6,0,0,0,.2-1.574C184.58,45.382,184.088,44.3,182.809,44.1Zm-3.148-4.033h1.082c1.082,0,1.279.492,1.279,1.476a2.46,2.46,0,0,1-.3,1.377c-.393.492-1.082.394-1.672.394h-.394Zm1.869,8.756a3.443,3.443,0,0,1-1.377.1h-.492V45.186h.885c1.476,0,1.672.59,1.672,1.968s-.1,1.377-.689,1.672Z" transform="translate(-157.92 -37.899)" fill="#00a3c9"></path><path id="Path_1130" data-name="Path 1130" d="M193.493,48.925h-4.23V45.088H193.2V43.219h-3.935V40.071h4.23V38.3H187V50.794h6.493Z" transform="translate(-158.077 -37.9)" fill="#00a3c9"></path><path id="Path_1131" data-name="Path 1131" d="M198.061,45.383h.393a7.083,7.083,0,0,1,1.968.2c.787.2.787,1.279.787,2.066a12.79,12.79,0,0,0,.3,3.148h2.558v-.2c-.59-.394-.492-3.443-.492-3.935S203.177,44.6,201.8,44.4h0c1.574-.2,1.869-1.672,1.869-3.05a3.467,3.467,0,0,0-3.542-3.05H195.7V50.794h2.361Zm0-5.312h1.672c.885,0,1.476.3,1.476,1.672s-.59,1.771-1.377,1.771h-1.771Z" transform="translate(-158.218 -37.9)" fill="#00a3c9"></path><path id="Path_1132" data-name="Path 1132" d="M161.437,63.22c-.689-.492-1.279-.885-1.279-1.771s.492-1.181,1.279-1.181,1.377,1.082,1.377,2.263h2.263c0-1.279.1-4.132-3.64-4.132s-3.64,1.181-3.64,3.345a3.542,3.542,0,0,0,.59,1.968c.984,1.279,2.459,1.968,3.64,2.853a1.869,1.869,0,0,1,.885,1.672,1.279,1.279,0,0,1-1.476,1.476c-1.181,0-1.476-.885-1.476-2.066v-.689H157.6v.885c0,2.263.984,3.837,3.738,3.837s3.837-1.279,3.837-3.64a3.246,3.246,0,0,0-1.082-2.656,21.251,21.251,0,0,0-2.656-2.164Z" transform="translate(-157.6 -38.226)" fill="#00a3c9"></path><path id="Path_1133" data-name="Path 1133" d="M167.6,71.194h6.493V69.325h-4.132V65.488H173.8V63.619h-3.837V60.471h4.132V58.7H167.6Z" transform="translate(-157.762 -38.231)" fill="#00a3c9"></path><path id="Path_1134" data-name="Path 1134" d="M180.233,69.613c-1.574,0-1.672-1.672-1.672-2.755V63.415c0-.984-.2-3.148,1.672-3.148s1.082,1.476,1.181,2.263h2.263a6.1,6.1,0,0,0-.1-.984,3.148,3.148,0,0,0-3.345-3.246c-3.738,0-3.935,2.361-4.033,5.607v1.771c0,3.345.3,5.8,4.033,5.8s3.345-1.771,3.443-4.033V66.76h-2.361C181.414,67.547,181.512,69.613,180.233,69.613Z" transform="translate(-157.902 -38.225)" fill="#00a3c9"></path><path id="Path_1135" data-name="Path 1135" d="M191.707,67.259c0,1.181-.1,2.361-1.574,2.361s-1.672-1.181-1.672-2.361V58.7H186.1v8.756c0,2.755.885,4.132,3.935,4.132s3.935-1.279,3.935-4.132V58.7h-2.361Z" transform="translate(-158.063 -38.231)" fill="#00a3c9"></path><path id="Path_1136" data-name="Path 1136" d="M204.47,66.962c0-1.181-.394-2.066-1.771-2.263h0c1.574-.2,1.869-1.672,1.869-3.05a3.467,3.467,0,0,0-3.542-3.05H196.6V71.192h2.361V65.782h.393a6.985,6.985,0,0,1,1.968.2c.787.2.787,1.279.787,2.066a12.788,12.788,0,0,0,.3,3.148h2.558V71C204.372,70.6,204.47,67.552,204.47,66.962Zm-3.64-3.05h-1.869V60.469h1.672c.885,0,1.476.3,1.476,1.672s-.492,1.771-1.279,1.869Z" transform="translate(-158.233 -38.23)" fill="#00a3c9"></path><rect id="Rectangle_88" data-name="Rectangle 88" width="2.361" height="12.543" transform="translate(48.893 20.469)" fill="#00a3c9"></rect><path id="Path_1137" data-name="Path 1137" d="M211.5,60.471h2.656V71.194h2.361V60.471h2.656V58.7H211.5Z" transform="translate(-158.475 -38.231)" fill="#00a3c9"></path><path id="Path_1138" data-name="Path 1138" d="M226.4,58.7l-1.082,2.853a10.722,10.722,0,0,0-.787,2.361h0a8.559,8.559,0,0,0-.59-1.968L222.658,58.7H220.1l3.246,7.182v5.312h2.361V65.882l3.246-7.182Z" transform="translate(-158.614 -38.231)" fill="#00a3c9"></path></g><path id="Path_1139" data-name="Path 1139" d="M43.777,11.2a4.525,4.525,0,0,0-4.132,3.64L24.593,62.258l-9.346-18.4H6L20.265,69.636l.394.492a5.312,5.312,0,0,0,5.9,1.771c3.443-1.181,3.935-5.411,5.017-8.46L46.138,19.66l.2-.689h115L163.8,11.3Z" transform="translate(-0.097 -0.182)" fill="#00a3c9"></path><g id="Group_481" data-name="Group 481" transform="translate(40.826 22.02)"><path id="Path_1140" data-name="Path 1140" d="M83.071,22.4a14.208,14.208,0,0,0-10.034,3.542Q69.2,29.483,69.2,36.172V57.717q0,6.69,3.64,10.231t9.739,3.542a14.166,14.166,0,0,0,9.936-3.542q3.837-3.542,3.837-10.231V36.172q0-6.788-3.64-10.33A13.379,13.379,0,0,0,83.071,22.4Zm4.82,34.334a8.952,8.952,0,0,1-1.279,5.116,4.23,4.23,0,0,1-3.738,1.869q-5.116,0-5.116-6.985V37.55a10.428,10.428,0,0,1,1.181-5.607,4.329,4.329,0,0,1,3.935-1.869,4.132,4.132,0,0,1,3.738,1.869,10.231,10.231,0,0,1,1.279,5.607Z" transform="translate(-41.95 -22.383)" fill="#000"></path><path id="Path_1141" data-name="Path 1141" d="M116.071,22.4a14.208,14.208,0,0,0-10.034,3.542q-3.837,3.542-3.837,10.33V57.717q0,6.69,3.64,10.231t9.739,3.542a14.166,14.166,0,0,0,9.936-3.542q3.837-3.542,3.837-10.231V36.172q0-6.788-3.64-10.33a13.379,13.379,0,0,0-9.641-3.443Zm4.82,34.334a8.952,8.952,0,0,1-1.279,5.116,4.23,4.23,0,0,1-3.738,1.869q-5.116,0-5.116-6.985V37.55a10.428,10.428,0,0,1,1.181-5.607,4.329,4.329,0,0,1,3.935-1.869,4.132,4.132,0,0,1,3.738,1.869,10.231,10.231,0,0,1,1.279,5.607Z" transform="translate(-42.485 -22.383)" fill="#000"></path><path id="Path_1142" data-name="Path 1142" d="M132.8,23.1v7.673h8.264V70.911h8.46V30.773h10.133l2.459-7.673Z" transform="translate(-42.982 -22.395)" fill="#000"></path><path id="Path_1143" data-name="Path 1143" d="M64.619,45.333A20.954,20.954,0,0,0,65.9,37.365q0-7.477-2.951-10.92T53.01,23.1H50.649L48.19,30.675h4.722q2.656,0,3.542,1.672a10.428,10.428,0,0,1,.984,5.017,10.33,10.33,0,0,1-.984,5.017,3.738,3.738,0,0,1-3.542,1.672H43.959L41.5,51.629H52.518l6,19.184h8.854L60.29,50.154A9.247,9.247,0,0,0,64.619,45.333Z" transform="translate(-41.5 -22.395)" fill="#000"></path></g><g id="Group_482" data-name="Group 482"><path id="Path_1144" data-name="Path 1144" d="M0,4.829v5.312L5.214,6.009V36.8h4.23V.5H5.509Z" transform="translate(0 -0.008)" fill="#000"></path><path id="Path_1145" data-name="Path 1145" d="M20.967,0C15.556,0,12.9,3.246,12.9,9.739V27.447c0,6.493,2.755,9.838,8.067,9.838s8.067-3.345,8.067-9.838V9.739C29.034,3.246,26.378,0,20.967,0Zm2.755,31.874a2.853,2.853,0,0,1-2.755,1.279,2.951,2.951,0,0,1-2.755-1.279,10.625,10.625,0,0,1-.787-4.919V10.33a10.625,10.625,0,0,1,.787-4.919,2.951,2.951,0,0,1,2.755-1.279,2.853,2.853,0,0,1,2.755,1.279,10.92,10.92,0,0,1,.787,4.919V26.857A10.92,10.92,0,0,1,23.721,31.874Z" transform="translate(-0.209)" fill="#000"></path></g></g></g></svg> 									<!-- <img src="" alt="" itemprop="logo"> -->
		</a>
        <div class="logo-title">
	        An SB Security Group Company
	    </div>
	</div>
    <div class="container mt-5">
    <div class="row">
        <div class="col-md-12">
            <div class="d-flex justify-content-between align-items-center activity">
                <div><span class="activity-done">Report BMC ThreatHunter </span></div>
                <div class="icons"><i class="fa fa-search"></i><i class="fa fa-ellipsis-h"></i></div>
            </div>
            <div class="mt-3">
                <ul class="list list-inline">
					{1}
                </ul>
            </div>
        </div>
    </div>
</div>
	<script type='text/javascript' src='https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.bundle.min.js'></script>
	<script type='text/javascript'></script>
	</body>
</html>
"@

$comp_good = @"
<li class="d-flex justify-content-between">
	<div class="d-flex flex-row align-items-start"><i class="fa fa-plus-square" style="color:green"></i>
		<div class="ml-2">
			<h6 class="mb-0">{0} - Clean</h6>
			<div class="d-flex flex-row mt-1 text-black-50 date-time">
				<div><i class="fa fa-calendar-o"></i><span class="ml-2">{1}</span></div>
			</div>
		</div>
	</div>
	<div class="d-flex flex-row align-items-center">
		<div class="d-flex flex-column mr-2">
			
		</div> <i class="fa fa-ellipsis-h"></i>
	</div>
</li>
"@

$comp_bad = @"
<li class="d-flex justify-content-between">

	<div class="d-flex flex-row align-items-start"><i class="fa fa-minus-square" style="color:red"></i>
		<div class="ml-2">
			<h6 class="mb-0">{0} - IOC Found</h6>
			<div class="d-flex flex-row mt-1 text-black-50 date-time">
				<div><i class="fa fa-calendar-o"></i><span class="ml-2">{1}</span></div>
			</div>
			<table style="width:100%">
			  <tr>
				<th> No. </th>
                <th> User </th>
				<th> IOC Found</th>
				<th> Description </th>
			  </tr>
			  {2}
			</table>
		</div>
	</div>
	<div class="d-flex flex-row align-items-center">
		<div class="d-flex flex-column mr-2">
		   
		</div><i class="fa fa-ellipsis-h"></i>
	</div>
</li>
"@

$IOC_list = @" 
<tr>
<td> {0} </td>
<td> {1} </td>
<td> {2} </td>
<td> {3} </td>
</tr>
"@

function Collect-BMC
{
    Param([string]$ComputerList)

    Write-Host "*****Intialling Remote BMC Collection*****"

    $global:ArrayFolders = New-Object System.Collections.ArrayList
    $global:good_comp = New-Object System.Collections.ArrayList
    
    ForEach($computer in $(Get-Content $ComputerList))
    {
        $flag = $true
        Write-Host "*****Collects $computer*****"   
        $dest = "$($MyInvocation.PSScriptRoot)\BMC-Output\$computer"
        $null = mkdir $dest -ErrorAction SilentlyContinue

        foreach($user in (Get-ChildItem "\\$computer\C$\Users" -Directory))
        {
            $Path = "\\$computer\C$\Users\$($user.Name)\AppData\Local\Microsoft\Terminal Server Client\Cache"
            foreach($file in (Get-ChildItem $Path -ErrorAction SilentlyContinue))
            {
                $flag = $false
                $full_path = "$Path\$($file.Name)"
                $dest_path = "$dest\$($user.Name)\$($file.Name)"

                $null = mkdir "$dest\$($user.Name)" -ErrorAction SilentlyContinue
                Copy-Item $full_path -Destination $dest_path
                Parse-BMC -FileToParse $dest_path
            }
        }
        if($flag)
        {
            $null = $global:good_comp.Add($computer)
        }
    }
}

function Parse-BMC
{
    Param([string]$FileToParse)

    #Write-Host "*****Parse $FileToParse*****"   
    $null = mkdir "$FileToParse-folder" -ErrorAction SilentlyContinue
    $null = $global:ArrayFolders.Add($("$FileToParse-folder" | Out-String).Trim())

    $P = Start-Process -WindowStyle Hidden -FilePath "$($MyInvocation.PSScriptRoot)\tools\bmc-tools.exe" -ArgumentList "-s $FileToParse -v -b -d $FileToParse-folder" -PassThru
    $P.WaitForExit()
    #Start-ThreadJob -Name $FileToParse {Start-Process -FilePath "$($MyInvocation.PSScriptRoot)\tools\bmc-tools.exe" -ArgumentList "-s $FileToParse -v -b -d $FileToParse-folder"}
}

#Slice Wide BMP to Rectangle BMP
function RecSlice
{
    Param([System.Drawing.Bitmap]$bmp,[String]$Path)

    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    $ArrayJPG = New-Object -TypeName "System.Collections.ArrayList"
    $height = $($bmp).height
    $width = $($bmp).width
    $iter = [Math]::Floor($width / $height)

    for($i=0; $i -lt $iter; $i++)
    {
        $x = $i*$height
        $rect = New-Object System.Drawing.Rectangle($x,0,$height,$height)
        $slice = $bmp.Clone($rect, $bmp.PixelFormat)
        $slice.Save("$Path-Slice$i.bmp")
        [void]$ArrayJPG.add($(ConvertTo-JPG "$Path-Slice$i.bmp"))
    }
    return $ArrayJPG
}

#Convert BMP to Jpeg
function ConvertTo-JPG
{
    Param([String]$Path)
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    if ($Path -is [string])
        { $Path = get-childitem $Path }
        $Path | foreach {
        $i = new-object System.Drawing.Bitmap $($_)
        $FilePath = [IO.Path]::ChangeExtension($_, '.jpg');
        $i.Save($FilePath,"jpeg");
        $i.Dispose();
        Return $FilePath
        }
}

function IOC
{
    param([parameter(mandatory=$true)][ValidateNotNullOrEmpty()][String]$Path,[parameter(mandatory=$true)][ValidateNotNullOrEmpty()][String]$IOCList)
    $ioc_table = ""
    $counter = 0
    foreach($ioc in $(Get-Content $IOCList))
    {
        if (Select-String -Path $Path -Pattern $ioc.split(",")[0])
        {
            $counter++
            Write-Host -ForegroundColor Green "IOC Found!"
            Write-Host -ForegroundColor yellow "Computer: $($Path.Split('\')[-4]) , User: $($Path.Split('\')[-3])"
            Write-Host -ForegroundColor White "Match for: $ioc"
            $ioc_table += $IOC_list -f $counter, $($Path.Split('\')[-3]), $ioc.split(",")[0], $ioc.split(",")[1]
        }
    }

    if($counter)
    {
        $date = Get-Date
        $ret = $comp_bad -f $($Path.Split('\')[-4]),$date.ToString(), $ioc_table
        return $ret
    }
    else
    {
        $date = Get-Date
        $ret = $comp_good -f $($Path.Split('\')[-4]),$date.ToString()
        return $ret
    }

}

function main
{
    [cmdletbinding()]
    Param(
    [string]$ComputerList,[string]$IOCList
    )
    #$IOCList = "C:\Users\Administrator\Desktop\BSIDES\IOC.txt"
    
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    # 0. Collect BMC1
    # 1. Parse BMC
    Collect-BMC -ComputerList $ComputerList

    Write-Verbose "Array Folder: $global:ArrayFolders"
    # 2. slice $bmp to Rectangle
    $comp_html = ""
    foreach($folder in $global:ArrayFolders)
    {
        Write-Verbose "Folder: $Folder"
        $CacheFolder = $folder.split("\")[-1].split(".")[0];

        if (Test-Path "$folder\$CacheFolder.bin_collage.bmp")
        {
            Write-Verbose "formatting collage for OCR analyze"
            $bmp = New-Object System.Drawing.Bitmap("$folder\$CacheFolder.bin_collage.bmp");

            # 3. convert to jpg
            $ArrayJPG = RecSlice $bmp "$folder\$CacheFolder.bin_collage"
            foreach($JPG in $ArrayJPG)
            {
                #4. OCR
                $P = Start-Process -WindowStyle Hidden -FilePath "tesseract" -ArgumentList "$JPG $JPG.txt" -PassThru
                $P.WaitForExit()
            }

            (Get-Content "$folder\*.txt").Trim() | Where-Object{$_.length -gt 0} | Set-Content "$folder\$CacheFolder.bin_collage.txt"

            #5. IOC Finder
            $ioc_ret = IOC "$folder\$CacheFolder.bin_collage.txt" $IOCList 
            $comp_html += $ioc_ret
        }
        
    }

    foreach($g in $global:good_comp)
    {
        $date = Get-Date
        $ret = $comp_good -f $g, $date.ToString()
        $comp_html += $ret
    }

    $HTML -f $style, $comp_html | Set-Content "$($MyInvocation.PSScriptRoot)\BMC-ThreatHunter-Report.html"

}

main -ComputerList $ComputerList -IOCList $IOCList -Verbose
