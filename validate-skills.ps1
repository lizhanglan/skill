# 技能文件验证脚本
# 验证所有技能文件的格式一致性

$ErrorActionPreference = "Stop"
$skillDir = "."

Write-Host "=== 技能文件格式验证 ===" -ForegroundColor Cyan
Write-Host "开始时间: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# 1. 检查所有.md文件
$mdFiles = Get-ChildItem -Path $skillDir -Recurse -Filter "*.md" -File | 
    Where-Object { $_.FullName -notlike "*\.adapters\*" } |
    Where-Object { $_.Name -ne "README.md" }

Write-Host "找到 $($mdFiles.Count) 个技能文件:" -ForegroundColor Green
$mdFiles | ForEach-Object { Write-Host "  - $($_.FullName.Replace("$skillDir\", ""))" }

Write-Host ""
Write-Host "=== 开始验证 ===" -ForegroundColor Cyan

$validationResults = @()
$hasErrors = $false

foreach ($file in $mdFiles) {
    Write-Host "验证: $($file.Name)" -ForegroundColor Gray
    $content = Get-Content $file.FullName -Raw
    
    # 检查YAML frontmatter
    if ($content -match "^---\s*\n(.*?)\n---\s*\n") {
        $yamlContent = $matches[1]
        
        # 检查必需字段
        $requiredFields = @("title", "domain", "keywords", "triggers", "scope")
        $missingFields = @()
        
        foreach ($field in $requiredFields) {
            if ($yamlContent -notmatch "^$field:") {
                $missingFields += $field
            }
        }
        
        if ($missingFields.Count -gt 0) {
            Write-Host "  ❌ 缺少必需字段: $($missingFields -join ', ')" -ForegroundColor Red
            $hasErrors = $true
            $validationResults += [PSCustomObject]@{
                File = $file.Name
                Status = "FAIL"
                Issues = "缺少字段: $($missingFields -join ', ')"
            }
        } else {
            Write-Host "  ✅ YAML frontmatter 完整" -ForegroundColor Green
            $validationResults += [PSCustomObject]@{
                File = $file.Name
                Status = "PASS"
                Issues = "无"
            }
        }
        
        # 检查文件结构（简单检查）
        $lines = Get-Content $file.FullName
        $hasCorePrinciples = $false
        $hasSpecDetails = $false
        $hasAntiPatterns = $false
        $hasUseCases = $false
        
        foreach ($line in $lines) {
            if ($line -match "^# ") {
                $title = $line
            } elseif ($line -match "^## 核心原则") {
                $hasCorePrinciples = $true
            } elseif ($line -match "^## 规范细则") {
                $hasSpecDetails = $true
            } elseif ($line -match "^## 反例") {
                $hasAntiPatterns = $true
            } elseif ($line -match "^## 适用场景") {
                $hasUseCases = $true
            }
        }
        
        $structureIssues = @()
        if (-not $hasCorePrinciples) { $structureIssues += "缺少'核心原则'部分" }
        if (-not $hasSpecDetails) { $structureIssues += "缺少'规范细则'部分" }
        if (-not $hasAntiPatterns) { $structureIssues += "缺少'反例'部分" }
        if (-not $hasUseCases) { $structureIssues += "缺少'适用场景'部分" }
        
        if ($structureIssues.Count -gt 0) {
            Write-Host "  ⚠️  结构问题: $($structureIssues -join '; ')" -ForegroundColor Yellow
        } else {
            Write-Host "  ✅ 文件结构完整" -ForegroundColor Green
        }
        
    } else {
        Write-Host "  ❌ 缺少YAML frontmatter" -ForegroundColor Red
        $hasErrors = $true
        $validationResults += [PSCustomObject]@{
            File = $file.Name
            Status = "FAIL"
            Issues = "缺少YAML frontmatter"
        }
    }
    
    Write-Host ""
}

# 2. 检查README.md中的触发索引
Write-Host "=== 检查README.md触发索引 ===" -ForegroundColor Cyan
$readmeContent = Get-Content "$skillDir\README.md" -Raw

# 从README中提取所有文件引用
$readmeFiles = [regex]::Matches($readmeContent, '\[.*?\]\((.*?\.md)\)') | 
    ForEach-Object { $_.Groups[1].Value } |
    Select-Object -Unique

Write-Host "README.md中引用了 $($readmeFiles.Count) 个文件:" -ForegroundColor Gray
$readmeFiles | ForEach-Object { Write-Host "  - $_" }

# 检查引用的文件是否存在
$missingInReadme = @()
foreach ($file in $mdFiles) {
    $relativePath = $file.FullName.Replace("$skillDir\", "").Replace("\", "/")
    if ($readmeFiles -notcontains $relativePath) {
        $missingInReadme += $relativePath
    }
}

if ($missingInReadme.Count -gt 0) {
    Write-Host "  ⚠️  README.md中缺少以下文件的引用:" -ForegroundColor Yellow
    $missingInReadme | ForEach-Object { Write-Host "    - $_" }
} else {
    Write-Host "  ✅ README.md引用完整" -ForegroundColor Green
}

# 3. 生成验证报告
Write-Host ""
Write-Host "=== 验证报告 ===" -ForegroundColor Cyan
Write-Host "验证文件数: $($mdFiles.Count)"
Write-Host "通过: $($validationResults | Where-Object { $_.Status -eq 'PASS' } | Measure-Object | Select-Object -ExpandProperty Count)"
Write-Host "失败: $($validationResults | Where-Object { $_.Status -eq 'FAIL' } | Measure-Object | Select-Object -ExpandProperty Count)"

if ($hasErrors) {
    Write-Host ""
    Write-Host "❌ 验证发现错误:" -ForegroundColor Red
    $validationResults | Where-Object { $_.Status -eq 'FAIL' } | ForEach-Object {
        Write-Host "  - $($_.File): $($_.Issues)" -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host ""
    Write-Host "✅ 所有技能文件验证通过!" -ForegroundColor Green
    Write-Host "完成时间: $(Get-Date)" -ForegroundColor Yellow
    exit 0
}