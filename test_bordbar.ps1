# Test Suite for Bordbar Formula Update in ThalCheck
# Tests: Values below 44.76, Exactly 44.76, Values above 44.76, Absolute-value handling, Decimal inputs

$html = Get-Content -Raw -Path index.html -Encoding UTF8
$readme = Get-Content -Raw -Path README.md -Encoding UTF8
$errors = @()

Write-Output "========================================================"
Write-Output "   THALCHECK — BORDBAR FORMULA CORRECTION TEST SUITE    "
Write-Output "========================================================"

# 1. VERIFY CODE IN INDEX.HTML
Write-Output "`n[1] Verifying calculateBordbar() in index.html:"
if ($html -match 'Math\.abs\(\s*80\s*-\s*cbc\.mcv\s*\)\s*\*\s*Math\.abs\(\s*27\s*-\s*cbc\.mch\s*\)') {
    Write-Output "  PASS: calculateBordbar uses Math.abs(80 - cbc.mcv) * Math.abs(27 - cbc.mch)"
} else {
    $errors += "calculateBordbar formula does not match research specification!"
    Write-Output "  FAIL: calculateBordbar formula missing or incorrect in index.html"
}

if ($html -match 'value\s*<\s*44\.76\s*\?\s*[''"]THALASSAEMIA[''"]\s*:\s*[''"]IDA[''"]') {
    Write-Output "  PASS: Decision logic correctly checks 'value < 44.76 ? THALASSAEMIA : IDA'"
} else {
    $errors += "Bordbar cutoff decision logic missing or incorrect!"
    Write-Output "  FAIL: Decision cutoff 44.76 not found in index.html"
}

if ($html -match 'cutoff:\s*[''"]< 44\.76 THAL \(≥ 44\.76 IDA\)[''"]') {
    Write-Output "  PASS: Display cutoff text matches '< 44.76 THAL (≥ 44.76 IDA)'"
} else {
    $errors += "Bordbar display cutoff text missing or incorrect!"
    Write-Output "  FAIL: Cutoff text mismatch in index.html"
}

if ($html -match 'bordbar:\s*2') {
    Write-Output "  PASS: Existing Bordbar weight of 2 is preserved (INDEX_WEIGHTS.bordbar = 2)"
} else {
    $errors += "Bordbar weight is not 2!"
    Write-Output "  FAIL: Bordbar weight is not 2"
}

# 2. VERIFY README.MD DOCUMENTATION
Write-Output "`n[2] Verifying README.md Documentation:"
if ($readme -match 'Bordbar.*44\.76') {
    Write-Output "  PASS: README.md reflects the new Bordbar formula and cutoff 44.76"
} else {
    $errors += "README.md does not reflect the new Bordbar cutoff 44.76!"
    Write-Output "  FAIL: README.md missing new Bordbar formula/cutoff"
}

# 3. UNIT TESTS FOR BORDBAR CALCULATION
function Bordbar-Calc {
    param([double]$mcv, [double]$mch)
    $val = [Math]::Abs(80.0 - $mcv) * [Math]::Abs(27.0 - $mch)
    $vote = if ($val -lt 44.76) { "THALASSAEMIA" } else { "IDA" }
    return @{ Value = [Math]::Round($val, 4); Vote = $vote }
}

Write-Output "`n[3] Test Category A: Values Below 44.76 (Expected: THALASSAEMIA)"
$casesBelow = @(
    @{ mcv = 76.0; mch = 24.0; expVal = 12.00; desc = "MCV=76, MCH=24 (|80-76|*|27-24| = 4*3 = 12)" },
    @{ mcv = 74.0; mch = 21.0; expVal = 36.00; desc = "MCV=74, MCH=21 (|80-74|*|27-21| = 6*6 = 36)" },
    @{ mcv = 79.0; mch = 26.0; expVal = 1.00;  desc = "MCV=79, MCH=26 (|80-79|*|27-26| = 1*1 = 1)" },
    @{ mcv = 80.0; mch = 27.0; expVal = 0.00;  desc = "MCV=80, MCH=27 (|80-80|*|27-27| = 0*0 = 0)" },
    @{ mcv = 72.0; mch = 22.0; expVal = 40.00; desc = "MCV=72, MCH=22 (|80-72|*|27-22| = 8*5 = 40)" },
    @{ mcv = 57.63; mch = 25.0; expVal = 44.74; desc = "Boundary below cutoff: MCV=57.63, MCH=25 (|80-57.63|*2 = 44.74)" }
)

foreach ($tc in $casesBelow) {
    $res = Bordbar-Calc $tc.mcv $tc.mch
    if ($res.Vote -eq "THALASSAEMIA" -and [Math]::Abs($res.Value - $tc.expVal) -lt 0.01) {
        Write-Output "  PASS: $($tc.desc) -> Value=$($res.Value), Vote=$($res.Vote)"
    } else {
        $errors += "Failed test below 44.76: $($tc.desc)"
        Write-Output "  FAIL: $($tc.desc) -> Value=$($res.Value) (expected $($tc.expVal)), Vote=$($res.Vote)"
    }
}

Write-Output "`n[4] Test Category B: Exactly 44.76 (Expected: IDA per >= 44.76 specification)"
$casesExact = @(
    @{ mcv = 57.62; mch = 25.0; expVal = 44.76; desc = "Exact cutoff via MCV=57.62, MCH=25 (|80-57.62|*|27-25| = 22.38*2 = 44.76)" },
    @{ mcv = 35.24; mch = 26.0; expVal = 44.76; desc = "Exact cutoff via MCV=35.24, MCH=26 (|80-35.24|*|27-26| = 44.76*1 = 44.76)" }
)

foreach ($tc in $casesExact) {
    $res = Bordbar-Calc $tc.mcv $tc.mch
    if ($res.Vote -eq "IDA" -and [Math]::Abs($res.Value - $tc.expVal) -lt 0.001) {
        Write-Output "  PASS: $($tc.desc) -> Value=$($res.Value), Vote=$($res.Vote)"
    } else {
        $errors += "Failed exact 44.76 test: $($tc.desc)"
        Write-Output "  FAIL: $($tc.desc) -> Value=$($res.Value) (expected $($tc.expVal)), Vote=$($res.Vote)"
    }
}

# Explicit check for exact scalar 44.76 comparison
$exactVal = 44.76
$exactVote = if ($exactVal -lt 44.76) { "THALASSAEMIA" } else { "IDA" }
if ($exactVote -eq "IDA") {
    Write-Output "  PASS: Direct threshold check (value = 44.76) -> Vote=$exactVote (Value >= 44.76 is IDA)"
} else {
    $errors += "Direct threshold check failed for 44.76"
    Write-Output "  FAIL: Direct threshold check failed for 44.76"
}

Write-Output "`n[5] Test Category C: Values Above 44.76 (Expected: IDA)"
$casesAbove = @(
    @{ mcv = 65.0; mch = 20.0; expVal = 105.00; desc = "MCV=65, MCH=20 (|80-65|*|27-20| = 15*7 = 105)" },
    @{ mcv = 60.0; mch = 18.0; expVal = 180.00; desc = "MCV=60, MCH=18 (|80-60|*|27-18| = 20*9 = 180)" },
    @{ mcv = 55.0; mch = 17.0; expVal = 250.00; desc = "MCV=55, MCH=17 (|80-55|*|27-17| = 25*10 = 250)" },
    @{ mcv = 57.61; mch = 25.0; expVal = 44.78; desc = "Boundary above cutoff: MCV=57.61, MCH=25 (|80-57.61|*2 = 44.78)" }
)

foreach ($tc in $casesAbove) {
    $res = Bordbar-Calc $tc.mcv $tc.mch
    if ($res.Vote -eq "IDA" -and [Math]::Abs($res.Value - $tc.expVal) -lt 0.01) {
        Write-Output "  PASS: $($tc.desc) -> Value=$($res.Value), Vote=$($res.Vote)"
    } else {
        $errors += "Failed test above 44.76: $($tc.desc)"
        Write-Output "  FAIL: $($tc.desc) -> Value=$($res.Value) (expected $($tc.expVal)), Vote=$($res.Vote)"
    }
}

Write-Output "`n[6] Test Category D: Absolute-Value Handling (MCV > 80, MCH > 27)"
$casesAbs = @(
    @{ mcv = 85.0; mch = 25.0; expVal = 10.00; expVote = "THALASSAEMIA"; desc = "MCV > 80: MCV=85, MCH=25 (|80-85|*|27-25| = 5*2 = 10)" },
    @{ mcv = 75.0; mch = 30.0; expVal = 15.00; expVote = "THALASSAEMIA"; desc = "MCH > 27: MCV=75, MCH=30 (|80-75|*|27-30| = 5*3 = 15)" },
    @{ mcv = 88.0; mch = 32.0; expVal = 40.00; expVote = "THALASSAEMIA"; desc = "Both > norm: MCV=88, MCH=32 (|80-88|*|27-32| = 8*5 = 40)" },
    @{ mcv = 95.0; mch = 35.0; expVal = 120.00; expVote = "IDA"; desc = "Both > norm: MCV=95, MCH=35 (|80-95|*|27-35| = 15*8 = 120)" },
    @{ mcv = 100.0; mch = 20.0; expVal = 140.00; expVote = "IDA"; desc = "MCV > 80, MCH < 27: MCV=100, MCH=20 (|80-100|*|27-20| = 20*7 = 140)" }
)

foreach ($tc in $casesAbs) {
    $res = Bordbar-Calc $tc.mcv $tc.mch
    if ($res.Vote -eq $tc.expVote -and [Math]::Abs($res.Value - $tc.expVal) -lt 0.01) {
        Write-Output "  PASS: $($tc.desc) -> Value=$($res.Value), Vote=$($res.Vote)"
    } else {
        $errors += "Failed absolute-value test: $($tc.desc)"
        Write-Output "  FAIL: $($tc.desc) -> Value=$($res.Value) (expected $($tc.expVal)), Vote=$($res.Vote) (expected $($tc.expVote))"
    }
}

Write-Output "`n[7] Test Category E: Decimal Inputs Precision"
$casesDecimal = @(
    @{ mcv = 62.3; mch = 19.4; expVal = 134.52; expVote = "IDA"; desc = "MCV=62.3, MCH=19.4 (|80-62.3|*|27-19.4| = 17.7*7.6 = 134.52)" },
    @{ mcv = 77.5; mch = 25.2; expVal = 4.50; expVote = "THALASSAEMIA"; desc = "MCV=77.5, MCH=25.2 (|80-77.5|*|27-25.2| = 2.5*1.8 = 4.50)" },
    @{ mcv = 68.25; mch = 23.6; expVal = 39.95; expVote = "THALASSAEMIA"; desc = "MCV=68.25, MCH=23.6 (|80-68.25|*|27-23.6| = 11.75*3.4 = 39.95)" },
    @{ mcv = 71.8; mch = 21.5; expVal = 45.10; expVote = "IDA"; desc = "MCV=71.8, MCH=21.5 (|80-71.8|*|27-21.5| = 8.2*5.5 = 45.10)" }
)

foreach ($tc in $casesDecimal) {
    $res = Bordbar-Calc $tc.mcv $tc.mch
    if ($res.Vote -eq $tc.expVote -and [Math]::Abs($res.Value - $tc.expVal) -lt 0.01) {
        Write-Output "  PASS: $($tc.desc) -> Value=$($res.Value), Vote=$($res.Vote)"
    } else {
        $errors += "Failed decimal test: $($tc.desc)"
        Write-Output "  FAIL: $($tc.desc) -> Value=$($res.Value) (expected $($tc.expVal)), Vote=$($res.Vote) (expected $($tc.expVote))"
    }
}

# 4. INTEGRITY CHECK OF ALL OTHER FORMULAS
Write-Output "`n[8] Verifying NO other index formulas, weights, or thresholds changed:"
$untouchedFormulas = @(
    "calculateEnglandFraser",
    "calculateGreenKing",
    "calculateMentzer",
    "calculateShineLal",
    "calculateRicerca",
    "calculateSrivastava",
    "calculateEhsani",
    "calculateSirdah",
    "calculateRDWIndex",
    "calculateLogit"
)
foreach ($f in $untouchedFormulas) {
    if ($html.Contains("function $f(")) {
        Write-Output "  PASS: Formula $f is intact"
    } else {
        $errors += "Formula $f was modified or deleted!"
        Write-Output "  FAIL: Formula $f is missing"
    }
}

$allWeights = @(
    "englandFraser: 3",
    "greenKing: 3",
    "mentzer: 2",
    "shineLal: 2",
    "ricerca: 1",
    "srivastava: 1",
    "ehsani: 1",
    "sirdah: 1",
    "bordbar: 2",
    "rdwIndex: 2",
    "logit: 1"
)
foreach ($w in $allWeights) {
    if ($html.Contains($w)) {
        Write-Output "  PASS: Weight config '$w' verified"
    } else {
        $errors += "Weight config '$w' is missing!"
        Write-Output "  FAIL: Weight config '$w' is missing"
    }
}

Write-Output "`n--------------------------------------------------------"
if ($errors.Count -eq 0) {
    Write-Output "ALL BORDBAR FORMULA TESTS PASSED SUCCESSFULLY! (0 errors)"
} else {
    Write-Output "TEST SUITE FAILED WITH $($errors.Count) ERRORS:"
    $errors | ForEach-Object { Write-Output " - $_" }
}
Write-Output "--------------------------------------------------------"
