# param($ccEmails, $toEmails, $password)
# Configure logging
$logFile = "email_log.txt"

function Write-Log {
    param (
        [string]$message,
        [string]$level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp $level $message" | Out-File -Append -FilePath $logFile
}

function Send-Email {
    param (
        [string]$subject,
        [string]$body,
        [string[]]$toEmails,
        [string[]]$ccEmails,
        [string]$fromEmail,
        [pscredential]$credential,
        [string[]]$attachmentPaths
    )
    try {
        Write-Log "Creating email message"
        $msg = New-Object System.Net.Mail.MailMessage
        $msg.From = $fromEmail
        $msg.To.Add($toEmails -join ',')
        $msg.CC.Add($ccEmails -join ',')
        $msg.Subject = $subject
        $msg.Body = $body
        $msg.IsBodyHtml = $true

        foreach ($attachmentPath in $attachmentPaths) {
            $attachment = New-Object System.Net.Mail.Attachment($attachmentPath)
            $attachment.Name = [System.IO.Path]::GetFileName($attachmentPath)
            $msg.Attachments.Add($attachment)
        }

        Write-Log "Connecting to SMTP server"
        $smtp = New-Object Net.Mail.SmtpClient("mail.bot.or.th", 587)
        $smtp.EnableSsl = $true
        $smtp.Credentials = $credential
        $smtp.Send($msg)
        Write-Log "Email sent successfully"
    } catch {
        Write-Log "Failed to send email: $_" "ERROR"
    }
}

function ParseRobotResults {
    param (
        [string]$xmlFile
    )
    Write-Log "Parsing XML file: $xmlFile"
    if (-Not (Test-Path $xmlFile)) {
        Write-Log "XML file not found: $xmlFile" "ERROR"
        return 0, 0
    }

    try {
        [xml]$xml = Get-Content $xmlFile
    } catch {
        Write-Log "Failed to parse XML file: $_" "ERROR"
        return 0, 0
    }

    $passCount = 0
    $failCount = 0

    foreach ($suite in $xml.robot.suite) {
        Write-Log "Processing suite: $($suite.name)"
        foreach ($test in $suite.test) {
            $status = $test.status.status
            Write-Log "Test: $($test.name), Status: $status"
            if ($status -eq "PASS") {
                $passCount++
            } elseif ($status -eq "FAIL") {
                $failCount++
            }
        }
    }

    Write-Log "Total Passed: $passCount, Total failed: $failCount"
    return $failCount, $passCount
}

function Main {
    # Export Document
    $xmlFileExportDoc = (Get-Item -Path Env:OutputFileExportDocPATH).Value
    $resultExportDoc = ParseRobotResults -xmlFile $xmlFileExportDoc
    $failCountExportDoc = $resultExportDoc[0]
    $passCountExportDoc = $resultExportDoc[1]
    # Track Document
    $xmlFileTrackDoc = (Get-Item -Path Env:OutputFileTrackDocPATH).Value
    $resultTrackDoc = ParseRobotResults -xmlFile $xmlFileTrackDoc
    $failCountTrackDoc = $resultTrackDoc[0]
    $passCountTrackDoc = $resultTrackDoc[1]

    $passAllCount = $passCountTrackDoc + $passCountExportDoc
    $failAllCount = $failCountTrackDoc + $failCountExportDoc

    $subject = "[BOTDoc][Test] : Passed: $passAllCount, Failed: $failAllCount"
    $tableRowsExportDoc = "<tr style='background-color:#dae9f8'><td>รายงานนำเสนอ</td><td>$passCountExportDoc</td><td>$failCountExportDoc</td></tr>"
    $tableRowsTrackDoc = "<tr style='background-color:#dae9f8'><td>แผนงานนำเสนอ</td><td>$passCountTrackDoc</td><td>$failCountTrackDoc</td></tr>"
    $body = @"
<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<style>
    table, th, td {
        border: 1px solid black;
        border-collapse: collapse;
        text-align: center;
    }
</style>
<body>
    <table style="width:100%">
        <tr style="background-color:#004B8D">
            <th style="color:#FFFFFF; width:60%">Test Scenario</th>
            <th style="color:#167d22; width:20%">Passed</th>
            <th style="color:#ff0000; width:20%">Failed</th>
        </tr>
        $tableRowsExportDoc
        $tableRowsTrackDoc
    </table>
    <br>
    <br>
    BOTDoc Release: <a href="https://azuredevops.bot.or.th/BOTCollection/y7_robot_framework_pilot/_release?_a=releases&view=all&definitionId=1">Link To Azure Release Pipeline</a><br>
    <br>
    BOTDoc Testscript: <a href="https://bankofthailand.sharepoint.com/:x:/s/ExternalBOTDocumentPlatform/Ed4iGAolx1Nb7NrS7uAUB7ag8EDOUAMEJOyFLB2Wlg7e-oI?e=">Link To Testscript</a><br>
    <br>
    <br>
</body>
</html>
"@
    $toEmails = (Get-Item -Path Env:ToEmail).Value -split ','
    $ccEmails = (Get-Item -Path Env:CcEmail).Value -split ','
    $fromEmail = (Get-Item -Path Env:FromEmail).Value
    $password = (Get-Item -Path Env:EmailPassword).Value
    $passwordSecure = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($fromEmail, $passwordSecure)
    $logExportDocPath = (Get-Item -Path Env:LogFileExportDocPATH).Value
    $logTrackDocPath = (Get-Item -Path Env:LogFileTrackDocPATH).Value
    $attachmentPaths = @($logExportDocPath, $logTrackDocPath)
    Send-Email -subject $subject -body $body -toEmails $toEmails -ccEmails $ccEmails -fromEmail $fromEmail -credential $credential -attachmentPaths $attachmentPaths
}

Main
