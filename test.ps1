$chocoOut = choco list

$chocoOut = choco list

$lines = $chocoOut | Select-Object -Skip 1 | Select-Object -SkipLast 1

$pattern = '^(?<name>[a-zA-Z0-9.\-_]+) (?<version>[0-9][0-9a-zA-Z._]*)$'

$matches = @()

# Loop through each line and check for matches
foreach ($line in $lines) {
    $match = [regex]::Match($line, $pattern)
    if ($match.Success) {
        $matches += $match
    }
}

$matches | ForEach-Object {
    $_.Value
}