using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Import-Module -Name Terminal-Icons

if ($host.Name -eq 'ConsoleHost')
{
    Import-Module PSReadLine
}

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# 設定按下 Ctrl+d 可以退出 PowerShell 執行環境
Set-PSReadlineKeyHandler -Chord ctrl+d -Function ViExit

# 設定按下 Ctrl+w 可以刪除一個單字
Set-PSReadlineKeyHandler -Chord ctrl+w -Function BackwardDeleteWord

# 設定按下 Ctrl+e 可以移動游標到最後面(End)
Set-PSReadlineKeyHandler -Chord ctrl+e -Function EndOfLine

# 設定按下 Ctrl+a 可以移動游標到最前面(Begin)
Set-PSReadlineKeyHandler -Chord ctrl+a -Function BeginningOfLine

#Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
#Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# This key handler shows the entire or filtered history using Out-GridView. The
# typed text is used as the substring pattern for filtering. A selected command
# is inserted to the command line without invoking. Multiple command selection
# is supported, e.g. selected by Ctrl + Click.
Set-PSReadLineKeyHandler -Key F7 `
                         -BriefDescription History `
                         -LongDescription 'Show command history' `
                         -ScriptBlock {
    $pattern = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
    if ($pattern)
    {
        $pattern = [regex]::Escape($pattern)
    }

    $history = [System.Collections.ArrayList]@(
        $last = ''
        $lines = ''
        foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath))
        {
            if ($line.EndsWith('`'))
            {
                $line = $line.Substring(0, $line.Length - 1)
                $lines = if ($lines)
                {
                    "$lines`n$line"
                }
                else
                {
                    $line
                }
                continue
            }

            if ($lines)
            {
                $line = "$lines`n$line"
                $lines = ''
            }

            if (($line -cne $last) -and (!$pattern -or ($line -match $pattern)))
            {
                $last = $line
                $line
            }
        }
    )
    $history.Reverse()

    $command = $history | Out-GridView -Title History -PassThru
    if ($command)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
    }
}


# F1 for help on the command line - naturally
Set-PSReadLineKeyHandler -Key F1 `
                         -BriefDescription CommandHelp `
                         -LongDescription "Open the help window for the current command" `
                         -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $commandAst = $ast.FindAll( {
        $node = $args[0]
        $node -is [CommandAst] -and
            $node.Extent.StartOffset -le $cursor -and
            $node.Extent.EndOffset -ge $cursor
        }, $true) | Select-Object -Last 1

    if ($commandAst -ne $null)
    {
        $commandName = $commandAst.GetCommandName()
        if ($commandName -ne $null)
        {
            $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
            if ($command -is [AliasInfo])
            {
                $commandName = $command.ResolvedCommandName
            }

            if ($commandName -ne $null)
            {
                Get-Help $commandName -ShowWindow
            }
        }
    }
}

Set-PSReadLineKeyHandler -Key '"',"'" `
                         -BriefDescription SmartInsertQuote `
                         -LongDescription "Insert paired quotes if not already on a quote" `
                         -ScriptBlock {
    param($key, $arg)

    $quote = $key.KeyChar

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    # If text is selected, just quote it without any smarts
    if ($selectionStart -ne -1)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $quote + $line.SubString($selectionStart, $selectionLength) + $quote)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
        return
    }

    $ast = $null
    $tokens = $null
    $parseErrors = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)

    function FindToken
    {
        param($tokens, $cursor)

        foreach ($token in $tokens)
        {
            if ($cursor -lt $token.Extent.StartOffset) { continue }
            if ($cursor -lt $token.Extent.EndOffset) {
                $result = $token
                $token = $token -as [StringExpandableToken]
                if ($token) {
                    $nested = FindToken $token.NestedTokens $cursor
                    if ($nested) { $result = $nested }
                }

                return $result
            }
        }
        return $null
    }

    $token = FindToken $tokens $cursor

    # If we're on or inside a **quoted** string token (so not generic), we need to be smarter
    if ($token -is [StringToken] -and $token.Kind -ne [TokenKind]::Generic) {
        # If we're at the start of the string, assume we're inserting a new string
        if ($token.Extent.StartOffset -eq $cursor) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }

        # If we're at the end of the string, move over the closing quote if present.
        if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }
    }

    if ($null -eq $token -or
        $token.Kind -eq [TokenKind]::RParen -or $token.Kind -eq [TokenKind]::RCurly -or $token.Kind -eq [TokenKind]::RBracket) {
        if ($line[0..$cursor].Where{$_ -eq $quote}.Count % 2 -eq 1) {
            # Odd number of quotes before the cursor, insert a single quote
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
        }
        else {
            # Insert matching quotes, move cursor to be in between the quotes
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
        }
        return
    }

    # If cursor is at the start of a token, enclose it in quotes.
    if ($token.Extent.StartOffset -eq $cursor) {
        if ($token.Kind -eq [TokenKind]::Generic -or $token.Kind -eq [TokenKind]::Identifier -or 
            $token.Kind -eq [TokenKind]::Variable -or $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
            $end = $token.Extent.EndOffset
            $len = $end - $cursor
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote + $line.SubString($cursor, $len) + $quote)
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
            return
        }
    }

    # We failed to be smart, so just insert a single quote
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
}

Set-PSReadLineKeyHandler -Key '(','{','[' `
                         -BriefDescription InsertPairedBraces `
                         -LongDescription "Insert matching braces" `
                         -ScriptBlock {
    param($key, $arg)

    $closeChar = switch ($key.KeyChar)
    {
        <#case#> '(' { [char]')'; break }
        <#case#> '{' { [char]'}'; break }
        <#case#> '[' { [char]']'; break }
    }

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    
    if ($selectionStart -ne -1)
    {
      # Text is selected, wrap it in brackets
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $key.KeyChar + $line.SubString($selectionStart, $selectionLength) + $closeChar)
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    } else {
      # No text is selected, insert a pair
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
}

Set-PSReadLineKeyHandler -Key ')',']','}' `
                         -BriefDescription SmartCloseBraces `
                         -LongDescription "Insert closing brace or skip" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
}

Set-PSReadLineKeyHandler -Key Backspace `
                         -BriefDescription SmartBackspace `
                         -LongDescription "Delete previous character or matching quotes/parens/braces" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -gt 0)
    {
        $toMatch = $null
        if ($cursor -lt $line.Length)
        {
            switch ($line[$cursor])
            {
                <#case#> '"' { $toMatch = '"'; break }
                <#case#> "'" { $toMatch = "'"; break }
                <#case#> ')' { $toMatch = '('; break }
                <#case#> ']' { $toMatch = '['; break }
                <#case#> '}' { $toMatch = '{'; break }
            }
        }

        if ($toMatch -ne $null -and $line[$cursor-1] -eq $toMatch)
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
        }
        else
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
        }
    }
}


# winget parameter completion
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
     param($commandName, $wordToComplete, $cursorPosition)
         dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
     }
}

oh-my-posh init pwsh --config "D:\git\personal-config\cmd\.ohmyposh-customize.omp.json" | Invoke-Expression
#oh-my-posh init pwsh | Invoke-Expression
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\unicorn.omp.json"  | Invoke-Expression

function gpp() {
    git pull
}

function gs() {
	git status
}

function gca(){
	git stage -A
	git commit -a
}


Set-Alias d docker
Set-Alias dc docker-compose
Set-Alias k kubecolor
Set-Alias kx kubectx
Set-Alias kns kubens
function kgp(){
	k get po $args
}

function env(){
    Get-ChildItem Env: | Sort-Object Name
}

function vs(){
	./*.sln
}
# If (Test-Path Alias:sleep) {Remove-Item Alias:sleep}
function gosleep(){
	taskkill /F /IM openvpn.exe
	shutdown -h
}

function hostfile(){
	notepad C:\Windows\System32\drivers\etc\hosts
}

function gpts() {
	D:\pull-team-shared.sh
}

function cc() {
	Clear-Host
}

function devdb(){
     D:\lets_use_devdb.ps1
}
function localdb(){
     D:\lets_use_localdb.ps1
}

function config() {
    code D:\git\personal-config\
}

function wd(){
    wsl docker $args
}

function wkmini(){
    wsl minikube $args
}

function wk(){
    wsl kubectl $args
}

function port(){
    $portResult = netstat -ano | findstr ":$args"
    Write-Output $portResult
    if ($null -eq $portResult) {
        Write-Output "Port $args is not in use. Please check OS preserved ports."
        netsh interface ipv4 show excludedportrange protocol=tcp
    }
}

function krl(){
    $pods = kubectl get pods -o json | ConvertFrom-Json

    $podContainers = @{}
    $podMemoryList = @()

    foreach ($pod in $pods.items)
    {
        $podName = $pod.metadata.name
        $podContainers[$podName] = @()

        foreach ($container in $pod.spec.containers)
        {
            $containerName = $container.name
            $requestedMemory = ConvertToMiB $container.resources.requests.memory
            $limitMemory = ConvertToMiB $container.resources.limits.memory
            $requestedCpu = $container.resources.requests.cpu
            $limitCpu = $container.resources.limits.cpu
            $podContainers[$podName] += @{ "Name" = $containerName; "RequestedMemory" = $requestedMemory; "LimitMemory" = $limitMemory; "RequestedCpu" = $requestedCpu; "LimitCpu" = $limitCpu }
        }
    }

    $podsInfo = kubectl top pod --containers --no-headers

    foreach ($pod_containerInfo in $podsInfo)
    {
        $data = ($pod_containerInfo -replace '\s+', ' ')
        $podName = $data.Split(" ")[0]
        $containerName = $data.Split(" ")[1]
        $usedMemory = $data.Split(" ")[3]
        $usedCpu = $data.Split(" ")[2]

        foreach ($container in $podContainers[$podName])
        {
            if ($containerName -ne $container["Name"])
            {
                continue
            }
            $requestedMemory = $container["RequestedMemory"]
            $limitMemory = $container["LimitMemory"]
            $requestedCpu = $container["RequestedCpu"]
            $limitCpu = $container["LimitCpu"]
            $alert = ''

            if ([double]$usedMemory.TrimEnd("Mi") -gt [double]$requestedMemory)
            {
                $alert = '*'
            }
            $podMemoryList += New-Object PSObject -Property @{
                Pod_Container = "${podName} (${containerName})"
                Mem_Used_Req_Limit = "${usedMemory}/${requestedMemory}Mi/${limitMemory}Mi"
                Cpu_Used_Req_Limit = "${usedCpu}/${requestedCpu}/${limitCpu}"
                UsedCpu = "${usedCpu}"
                MemExceedRequest = $alert
            }
        }
    }

    $podMemoryList | Format-Table -Property Pod_Container, Mem_Used_Req_Limit, Cpu_Used_Req_Limit, MemExceedRequest -AutoSize    

}

function ConvertToMiB {
    param (
        [Parameter(Mandatory=$true)]
        [string]$memory
    )

    $unit = $memory[-2..-1] -join ''   # 取出最後兩個字符作為單位

    switch ($unit) {
        "Gi" { [math]::Round([double]$memory.TrimEnd("Gi") * 1024) }   # 如果單位是 Gi，則將其轉換為 Mi
        "Mi" { [math]::Round([double]$memory.TrimEnd("Mi")) }   # 如果單位是 Mi，則直接返回
        "0m" { [math]::Round([double]$memory.TrimEnd("m")/1024/1024/1024) }   # 如果單位是 m -> bytes
        default { "0" }
    }
}

$env:myConfigRootPath = "D:\git\personal-config"
$env:pwshConfigFileName = "Microsoft.PowerShell_profile.ps1"
$env:pwshPath = "$env:USERPROFILE\Documents\Powershell"
$env:vsCodePath = "$env:APPDATA\Code\User"
$env:cursorPath = "$env:APPDATA\Cursor\User"
$env:vsCodeKeyBindingFileName = "keybindings.json"
$env:vsCodeSettingFileName = "settings.json"
$env:riderKeyMapPath = "$env:APPDATA\JetBrains\Rider2024.1\keymaps"
$env:riderKeyMapFileName = "Visual Studio _Migrated_.xml"
$env:webStormKeyMapPath = "$env:APPDATA\JetBrains\WebStorm2024.2\keymaps"
$env:webStormKeyMapFileName = "Windows copy.xml"
$env:gitConfigFileName = ".gitconfig"
function syncFromLocal(){
    Copy-Item $env:pwshPath\$env:pwshConfigFileName $env:myConfigRootPath\cmd\$env:pwshConfigFileName
    Copy-Item $env:vsCodePath\$env:vsCodeKeyBindingFileName $env:myConfigRootPath\vs-code\$env:vsCodeKeyBindingFileName
    Copy-Item $env:vsCodePath\$env:vsCodeSettingFileName $env:myConfigRootPath\vs-code\$env:vsCodeSettingFileName
    Copy-Item $env:cursorPath\$env:vsCodeKeyBindingFileName $env:myConfigRootPath\cursor\$env:vsCodeKeyBindingFileName
    Copy-Item $env:cursorPath\$env:vsCodeSettingFileName $env:myConfigRootPath\cursor\$env:vsCodeSettingFileName
    Copy-Item $env:riderKeyMapPath\$env:riderKeyMapFileName $env:myConfigRootPath\rider\$env:riderKeyMapFileName
    Copy-Item $env:webStormKeyMapPath\$env:webStormKeyMapFileName $env:myConfigRootPath\webStorm\$env:webStormKeyMapFileName
    Copy-Item $env:USERPROFILE\$env:gitConfigFileName $env:myConfigRootPath\git\$env:gitConfigFileName
}

function syncToLocal(){
    Copy-Item $env:myConfigRootPath\cmd\$env:pwshConfigFileName $env:pwshPath\$env:pwshConfigFileName
    Copy-Item $env:myConfigRootPath\vs-code\$env:vsCodeKeyBindingFileName $env:vsCodePath\$env:vsCodeKeyBindingFileName
    Copy-Item $env:myConfigRootPath\vs-code\$env:vsCodeSettingFileName $env:vsCodePath\$env:vsCodeSettingFileName
    Copy-Item $env:myConfigRootPath\cursor\$env:vsCodeKeyBindingFileName $env:cursorPath\$env:vsCodeKeyBindingFileName
    Copy-Item $env:myConfigRootPath\cursor\$env:vsCodeSettingFileName $env:cursorPath\$env:vsCodeSettingFileName
    Copy-Item $env:myConfigRootPath\rider\$env:riderKeyMapFileName $env:riderKeyMapPath\$env:riderKeyMapFileName 
    Copy-Item $env:myConfigRootPath\webStorm\$env:webStormKeyMapFileName $env:webStormKeyMapPath\$env:webStormKeyMapFileName 
    Copy-Item $env:myConfigRootPath\git\$env:gitConfigFileName $env:USERPROFILE\$env:gitConfigFileName 
}

#Enable kubectl autocompletion with alias k
(kubectl completion powershell)  -replace "'kubectl'", "'k'" | Out-String | Invoke-Expression

#install: Install-Module ZLocation -Scope CurrentUser 
Import-Module ZLocation


##########################
# Project folder name
$projectList = @(
    "namipaymentaccountapi",
    "namipromotionapi",
    "namiuserinfoapi",
    "shabondi",
    "hectorgraphql",
    "bartholomew",
    "robin"
)
# Git Path
$gitPath = "D:\git"
class PathObject{
    [string]$CsprojPath
    [string]$JobName
}
$watcherData = @{}
##########################
function startFileWatcher {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FolderPath,
        [Parameter(Mandatory=$true)]
        [string]$JobName,
        [Parameter(Mandatory=$true)]
        [string]$ProjectName
    )
    $object = [PathObject]::new()
    $object.CsprojPath = $FolderPath
    $object.JobName = $JobName
    $watcherData[$ProjectName] = $object
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $FolderPath
    $watcher.Filter = "*.cs"
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true
    $action = {
        $path = $Event.SourceEventArgs.FullPath
        $changeType = $Event.SourceEventArgs.ChangeType
        $fileName = Split-Path -Path $path -Leaf
        $ProjectName = ($path -split '\\')[2]
        $JobName = $watcherData[$ProjectName].JobName
        Remove-Job -Name $JobName -Force
        Start-Job -Name $JobName {cd $args[0]; dotnet run} -ArgumentList $watcherData[$ProjectName].CsprojPath
        Write-Host [$JobName] "::" $fileName "has been changed！" -ForegroundColor Yellow 
    }
    Register-ObjectEvent $watcher "Changed" -Action $action -SourceIdentifier "wt_$JobName"
    Start-Job -Name $JobName {cd $args[0]; dotnet run} -ArgumentList $FolderPath
}
function nami {
    # Delete Job
    if($args[0] -eq "-d"){
        $jobNames = (Get-Job | Where-Object { $_.State -eq "Running" -and $_.Name -notmatch "^wt_" }).Name
        while ($true) {
            Write-Host "Please select a Job:"
            for ($i = 0; $i -lt $jobNames.Count; $i++) {
                Write-Host ("[{0}] {1}" -f ($i + 1), $jobNames[$i])
            }
            $jobIndex = Read-Host "Please enter the job number:"
            if ([int]::TryParse($jobIndex, [ref]$null)) {
                $jobIndex = [int]$jobIndex - 1
                if ($jobIndex -ge 0 -and $jobIndex -le $jobNames.Count) {
                    $jobName = $jobNames[$jobIndex]
                    Remove-Job -Name $jobName -Force
                    Remove-Job -Name "wt_$jobName" -Force
                    Get-Job
                    break
                }
                else {
                    Write-Host "Invalid selection: $jobIndex"
                }
            }
            else {
                Write-Host "Invalid selection: $jobIndex"
            }
        }
    }
    # Run All project for Nami
    if($args[0] -eq "-all"){
        $visitedDirectories = @()
        $logMessages = @()
        Get-ChildItem -Recurse -Path $gitPath -Directory | 
        ForEach-Object {
            $projectDirectory = $_.FullName
            $projectName = $_.Name
            if ($visitedDirectories -notcontains $projectDirectory -and $projectList -contains $projectName) {
                $visitedDirectories += $projectDirectory
                $csprojFiles = Get-ChildItem $projectDirectory -Recurse -Filter "*$projectName.csproj" -File -ErrorAction SilentlyContinue | 
                            Where-Object { $_.Name -ilike "$projectName.csproj" }
                if ($csprojFiles.Count -gt 0) {
                    foreach ($csproj in $csprojFiles) {
                        $projectPath = $csproj.DirectoryName
                        $jobName = $csproj.Name.Replace(".csproj", "")
                        $existingJobs = Get-Job -Name $jobName -ErrorAction SilentlyContinue
                        if ($existingJobs.Count -eq 0) {
                            if ($visitedDirectories -notcontains $projectPath) {
                                $visitedDirectories += $projectPath
                                if ($logMessages -notcontains "Starting $projectPath") {
                                    $logMessages += "Starting $projectPath"
                                }
                                startFileWatcher -FolderPath $projectPath -JobName $jobName -ProjectName $projectName
                            } 
                        } 
                        elseif ($existingJobs[0].State -eq "Running") {
                            if ($logMessages -notcontains "Job $jobName is already running, skipping") {
                                $logMessages += "Job $jobName is already running, skipping"
                            }
                        } 
                        else {
                            if ($logMessages -notcontains "Job $jobName already exists, skipping") {
                                $watcherJobName = "wt_" + $existingJobs.Name
                                Remove-Job -Job $existingJobs -Force
                                Remove-Job -Name $watcherJobName -Force -ErrorAction SilentlyContinue
                                startFileWatcher -FolderPath $projectPath -JobName $jobName -ProjectName $projectName
                            }
                        }
                    }
                } else {
                    if ($logMessages -notcontains "No .csproj files found in $projectPath") {
                        $logMessages += "No .csproj files found in $projectPath"
                    }
                }
            }
        }
        $logMessages | ForEach-Object { Write-Output $_ }
        Get-Job
    }
}

