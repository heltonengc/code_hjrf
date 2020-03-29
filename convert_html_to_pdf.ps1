 $Destination = "C:\Users\$env_User\Documents"
 $Source = "C:\Users\$env_User\Documents\2020.htm"
function ConvertFrom-HTMLtoPDF 
 


{ 
    [CmdletBinding(ConfirmImpact = 'Low')] 
    param 
    ( 
        [Parameter(Mandatory = $true, 
                   ValueFromPipeline = $true, 
                   ValueFromPipelineByPropertyName = $false, 
                   Position = 0, 
                   HelpMessage = 'Input the HTML Code Here')] 
        [ValidateNotNull()] 
        [ValidateNotNullOrEmpty()] 
         
        $Source, 
        [Parameter(Mandatory = $true, 
                   ValueFromPipeline = $true, 
                   ValueFromPipelineByPropertyName = $false, 
                   Position = 1, 
                   HelpMessage = 'Input the Destination Path to save the PDF file.')] 
        [ValidateNotNull()] 
        [ValidateNotNullOrEmpty()] 
        [string] 
        $Destination 
    ) 
     
    Begin 
    { 
        Write-Verbose -Message 'Trying to Load the required assemblies' 
        try 
        { 
            Write-Verbose -Message 'Trying to load the iTextSharp assembly' 
            $itextsharploadstatus = $true 
            Add-Type -Path '.\bin\itextsharp.dll' -ErrorAction 'Stop' 
             
        } 
         
        catch 
        { 
            $itextsharploadstatus = $false 
             
            Write-Error -Message 'Error loading the XMLWorker Assembly' 
             
            return 
        } 
        if ($itextsharploadstatus) 
        { 
            Write-Verbose -Message 'Sucessfully loaded the iTextSharp Assembly' 
        } 
         
        try 
        { 
            $xmlworkerloadstatus = $true 
            Add-Type -Path '.\bin\itextsharp.xmlworker.dll' -ErrorAction 'Stop' 
             
        } 
         
        catch 
        { 
            $xmlworkerloadstatus = $false 
             
            Write-Error -Message 'Error loading the XMLWorker Assembly' 
             
            return 
        } 
        if ($xmlworkerloadstatus) 
        { 
            Write-Verbose -Message 'Sucessfully loaded the XMLWorker Assembly' 
        } 
         
        [String]$HTMLCode = $Source 
    } 
    Process 
    { 
         
        Write-Verbose -Message "Creating the Document object" 
         
        $PDFDocument = New-Object iTextSharp.text.Document 
         
        Write-Verbose -Message "Loading the reader" 
         
        $reader = New-Object System.IO.StringReader($HTMLCode) 
         
        Write-Verbose -Message "Defining the PDF Page Size" 
         
        $PDFDocument.SetPageSize([iTextSharp.text.PageSize]::A4) | Out-Null 
         
        Write-Verbose -Message "Creating the FileStream" 
         
        $Stream = [IO.File]::OpenWrite($Destination) 
         
        Write-Verbose -Message "Defining the Writer Object" 
         
        $Writer = [itextsharp.text.pdf.PdfWriter]::GetInstance($PDFDocument, $Stream) 
         
        Write-Verbose -Message "Defining the Initial Lead of the Document, BUGFix" 
         
        $Writer.InitialLeading = '12.5' 
         
        Write-Verbose -Message "Opening the document to input the HTML Code" 
         
        $PDFDocument.Open() 
         
        Write-Verbose -Message "Trying to parse the HTML into the opened document" 
        Try 
        { 
            $htmlparsestatus = $true 
             
            Invoke-Expression -Command { [iTextSharp.tool.xml.XMLWorkerHelper]::GetInstance().ParseXHtml($writer, $PDFDocument, $reader) } -ErrorAction 'Stop' 
        } 
        Catch [System.Exception] 
        { 
             
            $htmlparsestatus = $false 
             
            Write-Error -Message "Error parsing the HTML code" 
             
            $PDFDocument.close() 
             
            Write-Verbose -Message "Disposing the file so it can me moved or deleted" 
             
            $PDFDocument.Dispose() 
             
            Remove-Item -Path $Destination -Force | Out-Null 
             
            return 
             
        } 
        if ($htmlparsestatus) 
        { 
            Write-Verbose -Message "Sucessfully Created the PDF File" 
        } 
    } 
    End 
    { 
         
        Write-Verbose -Message "Closing the Document" 
         
        $PDFDocument.close() 
         
        Write-Verbose -Message "Disposing the file so it can me moved or deleted" 
         
        $PDFDocument.Dispose() 
         
        Write-Verbose -Message "Sucessfully finished the operation" 
         
    } 
} 

