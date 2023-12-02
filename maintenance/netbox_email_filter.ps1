# Define the path of the input file and the output file
$inputFilePath = "C:\path\to\your\inputfile.txt"
$outputFilePath = "C:\path\to\your\outputfile.txt"

# Import the email addresses from the file, remove duplicates
$emailList = Get-Content -Path $inputFilePath | Sort-Object -Unique

# Join the email addresses with commas
$commaSeparatedEmails = $emailList -join ','

# Export the comma-separated emails to a new file
$commaSeparatedEmails | Out-File -FilePath $outputFilePath

# Optional: Display a message when done
Write-Host "Emails have been processed and saved to $outputFilePath"
