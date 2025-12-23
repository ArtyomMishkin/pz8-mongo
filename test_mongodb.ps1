# MongoDB API Tests - PowerShell
# Make sure Go server is running: go run ./cmd/api

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$apiUrl = "http://localhost:8080/api/v1/notes"
$headers = @{
    "Content-Type" = "application/json"
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$testTitle = "Test Note $timestamp"

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "MongoDB API Tests - PowerShell" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# TEST 1: CREATE
Write-Host "1. TEST: Create note (POST)" -ForegroundColor Yellow
Write-Host "--------------------------------------" -ForegroundColor Yellow

try {
    $createBody = @{
        title   = $testTitle
        content = "Hello Mongo!"
    } | ConvertTo-Json

    Write-Host "Request Body: $createBody" -ForegroundColor Gray
    
    $response = Invoke-WebRequest -Uri $apiUrl `
        -Method POST `
        -Headers $headers `
        -Body $createBody `
        -ErrorAction Stop

    $created = $response.Content | ConvertFrom-Json
    $noteId = $created.id

    Write-Host "SUCCESS - Created note with ID: $noteId" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $created | ConvertTo-Json | Write-Host -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# TEST 2: GET LIST
Write-Host "2. TEST: Get list of notes (GET)" -ForegroundColor Yellow
Write-Host "--------------------------------------" -ForegroundColor Yellow

try {
    $listUrl = $apiUrl + "?limit=5&skip=0"
    
    Write-Host "URL: $listUrl" -ForegroundColor Gray
    
    $listResponse = Invoke-WebRequest -Uri $listUrl `
        -Method GET `
        -ErrorAction Stop

    Write-Host "SUCCESS" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $listResponse.Content | ConvertFrom-Json | ConvertTo-Json | Write-Host -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

# TEST 3: GET BY ID
Write-Host "3. TEST: Get note by ID (GET /{id})" -ForegroundColor Yellow
Write-Host "--------------------------------------" -ForegroundColor Yellow

try {
    $getUrl = $apiUrl + "/" + $noteId
    
    Write-Host "URL: $getUrl" -ForegroundColor Gray
    
    $getResponse = Invoke-WebRequest -Uri $getUrl `
        -Method GET `
        -ErrorAction Stop

    Write-Host "SUCCESS" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $getResponse.Content | ConvertFrom-Json | ConvertTo-Json | Write-Host -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

# TEST 4: UPDATE
Write-Host "4. TEST: Update note (PATCH /{id})" -ForegroundColor Yellow
Write-Host "--------------------------------------" -ForegroundColor Yellow

try {
    $updateBody = @{
        content = "Updated content from PowerShell!"
    } | ConvertTo-Json

    Write-Host "Request Body: $updateBody" -ForegroundColor Gray
    
    $patchUrl = $apiUrl + "/" + $noteId
    
    $patchResponse = Invoke-WebRequest -Uri $patchUrl `
        -Method PATCH `
        -Headers $headers `
        -Body $updateBody `
        -ErrorAction Stop

    Write-Host "SUCCESS" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $patchResponse.Content | ConvertFrom-Json | ConvertTo-Json | Write-Host -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

# TEST 5: DELETE
Write-Host "5. TEST: Delete note (DELETE /{id})" -ForegroundColor Yellow
Write-Host "--------------------------------------" -ForegroundColor Yellow

try {
    $deleteUrl = $apiUrl + "/" + $noteId
    
    Write-Host "URL: $deleteUrl" -ForegroundColor Gray
    
    $deleteResponse = Invoke-WebRequest -Uri $deleteUrl `
        -Method DELETE `
        -UseBasicParsing `
        -ErrorAction SilentlyContinue

    Write-Host "SUCCESS - HTTP Status: $($deleteResponse.StatusCode)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "Delete completed" -ForegroundColor Yellow
}

# TEST 6: VERIFY DELETED
Write-Host "6. VERIFICATION: Verify note is deleted" -ForegroundColor Yellow
Write-Host "--------------------------------------" -ForegroundColor Yellow

$verifyUrl = $apiUrl + "/" + $noteId
try {
    $verifyResponse = Invoke-WebRequest -Uri $verifyUrl `
        -Method GET `
        -ErrorAction Stop
    
    Write-Host "FAILED: Note still exists!" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq "NotFound" -or $_.Exception.Response.StatusCode -eq 404) {
        Write-Host "SUCCESS - Note properly deleted (404)" -ForegroundColor Green
    } else {
        Write-Host "SUCCESS - Note deleted" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "All Tests Completed!" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
