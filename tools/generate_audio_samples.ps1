Add-Type -AssemblyName System.Core

$Root = Split-Path -Parent $PSScriptRoot
$OutputDir = Join-Path $Root "assets\audio\sfx"
$SampleRate = 44100
$VariantCount = 3
$Events = @(
    "player_shot",
    "enemy_hit",
    "enemy_destroy",
    "player_hurt",
    "player_die",
    "boss_hit",
    "power_up",
    "bomb_pickup",
    "bomb",
    "boss_warning",
    "boss_phase",
    "boss_break",
    "stage_clear"
)

function Get-Sine([double]$Frequency, [double]$TimeSeconds) {
    return [math]::Sin([math]::PI * 2.0 * $Frequency * $TimeSeconds)
}

function Get-Triangle([double]$Frequency, [double]$TimeSeconds) {
    return [math]::Asin((Get-Sine $Frequency $TimeSeconds)) * (2.0 / [math]::PI)
}

function Get-Square([double]$Frequency, [double]$TimeSeconds) {
    if ((Get-Sine $Frequency $TimeSeconds) -ge 0.0) {
        return 1.0
    }
    return -1.0
}

function Get-SmoothStep([double]$Value) {
    $Value = [math]::Max(0.0, [math]::Min(1.0, $Value))
    return $Value * $Value * (3.0 - 2.0 * $Value)
}

function Get-Envelope([double]$Ratio, [double]$Attack, [double]$Hold, [double]$Release) {
    if ($Ratio -le $Attack) {
        return Get-SmoothStep ($Ratio / [math]::Max($Attack, 0.000001))
    }
    if ($Ratio -le $Hold) {
        return 1.0
    }
    return 1.0 - (Get-SmoothStep (($Ratio - $Hold) / [math]::Max($Release, 0.000001)))
}

function Get-Seed([string]$Text) {
    $hash = 23
    foreach ($char in $Text.ToCharArray()) {
        $hash = (($hash * 31) + [int][char]$char) -band 0x7fffffff
    }
    return $hash
}

function Get-PitchedNoise([System.Random]$Random, [double]$Tone, [double]$Spread) {
    $noiseA = (($Random.NextDouble() * 2.0) - 1.0) * $Spread
    $noiseB = (($Random.NextDouble() * 1.4) - 0.7) * $Spread * 0.65
    return $noiseA + $noiseB + ($Tone * (1.0 - $Spread))
}

function Get-EventSpec([string]$Name, [int]$Variant) {
    switch ($Name) {
        "player_shot" { return @{ duration = 0.072; base = 560.0 + ($Variant * 22.0); gain = 0.42 } }
        "enemy_hit" { return @{ duration = 0.062; base = 210.0 + ($Variant * 16.0); gain = 0.40 } }
        "enemy_destroy" { return @{ duration = 0.17; base = 118.0 + ($Variant * 8.0); gain = 0.58 } }
        "player_hurt" { return @{ duration = 0.11; base = 165.0 + ($Variant * 12.0); gain = 0.48 } }
        "player_die" { return @{ duration = 0.23; base = 130.0 + ($Variant * 8.0); gain = 0.58 } }
        "boss_hit" { return @{ duration = 0.12; base = 155.0 + ($Variant * 10.0); gain = 0.52 } }
        "power_up" { return @{ duration = 0.16; base = 620.0 + ($Variant * 20.0); gain = 0.42 } }
        "bomb_pickup" { return @{ duration = 0.19; base = 320.0 + ($Variant * 18.0); gain = 0.44 } }
        "bomb" { return @{ duration = 0.42; base = 108.0 + ($Variant * 6.0); gain = 0.63 } }
        "boss_warning" { return @{ duration = 0.26; base = 182.0 + ($Variant * 7.0); gain = 0.48 } }
        "boss_phase" { return @{ duration = 0.32; base = 200.0 + ($Variant * 14.0); gain = 0.50 } }
        "boss_break" { return @{ duration = 0.52; base = 94.0 + ($Variant * 6.0); gain = 0.70 } }
        "stage_clear" { return @{ duration = 0.38; base = 392.0 + ($Variant * 14.0); gain = 0.40 } }
        default { throw "Unknown event: $Name" }
    }
}

function Get-EventSample([string]$Name, [int]$Variant, [int]$Index, [int]$SampleCount, [hashtable]$Spec, [System.Random]$Random) {
    $t = [double]$Index / [double]$SampleRate
    $ratio = [double]$Index / [double][math]::Max($SampleCount - 1, 1)
    $base = [double]$Spec.base

    switch ($Name) {
        "player_shot" {
            $freq = $base * (1.0 - ($ratio * 0.16))
            $body = (Get-Triangle $freq $t) * 0.72 + (Get-Sine ($freq * 0.5) $t) * 0.28
            return (Get-PitchedNoise $Random $body 0.18) * (Get-Envelope $ratio 0.08 0.38 0.62)
        }
        "enemy_hit" {
            $freq = $base * (1.0 - ($ratio * 0.10))
            $body = (Get-Triangle $freq $t) * 0.65 + (Get-Sine ($freq * 1.8) $t) * 0.20
            return (Get-PitchedNoise $Random $body 0.28) * (Get-Envelope $ratio 0.04 0.22 0.78)
        }
        "enemy_destroy" {
            $freq = $base * (1.0 - ($ratio * 0.58))
            $body = (Get-Sine $freq $t) * 0.34 + (Get-Triangle ($freq * 0.5) $t) * 0.26
            $boom = (Get-Square ($base * 0.34) $t) * 0.14
            return (Get-PitchedNoise $Random ($body + $boom) 0.58) * (Get-Envelope $ratio 0.03 0.12 0.88)
        }
        "player_hurt" {
            $wobble = 1.0 + ((Get-Sine 7.0 $t) * 0.06)
            $freq = $base * $wobble
            $body = (Get-Square $freq $t) * 0.34 + (Get-Triangle ($freq * 1.3) $t) * 0.24
            return (Get-PitchedNoise $Random $body 0.30) * (Get-Envelope $ratio 0.04 0.28 0.72)
        }
        "player_die" {
            $freq = [math]::Max(55.0, $base * (1.0 - ($ratio * 0.72)))
            $body = (Get-Square $freq $t) * 0.18 + (Get-Triangle ($freq * 0.6) $t) * 0.24
            return (Get-PitchedNoise $Random $body 0.62) * (Get-Envelope $ratio 0.03 0.16 0.84)
        }
        "boss_hit" {
            $freq = $base * (1.0 - ($ratio * 0.24))
            $body = (Get-Triangle $freq $t) * 0.42 + (Get-Square ($freq * 0.48) $t) * 0.18
            return (Get-PitchedNoise $Random $body 0.36) * (Get-Envelope $ratio 0.03 0.28 0.72)
        }
        "power_up" {
            $step = 1.0 + ($ratio * 0.42)
            $toneA = Get-Sine ($base * $step) $t
            $toneB = Get-Sine ($base * $step * 1.26) ($t + 0.004)
            return (($toneA * 0.52) + ($toneB * 0.36)) * (Get-Envelope $ratio 0.08 0.54 0.46)
        }
        "bomb_pickup" {
            $step = 1.0 + ($ratio * 0.28)
            $body = (Get-Triangle ($base * $step) $t) * 0.46 + (Get-Sine ($base * 1.7 * $step) $t) * 0.28
            return $body * (Get-Envelope $ratio 0.06 0.46 0.54)
        }
        "bomb" {
            $freq = [math]::Max(42.0, $base * (1.0 - ($ratio * 0.64)))
            $body = (Get-Sine $freq $t) * 0.20 + (Get-Square ($freq * 0.42) $t) * 0.18
            $sweep = (Get-Triangle (($base * 2.1) * (1.0 - ($ratio * 0.84))) $t) * 0.12
            return (Get-PitchedNoise $Random ($body + $sweep) 0.62) * (Get-Envelope $ratio 0.02 0.18 0.82)
        }
        "boss_warning" {
            if ([math]::Floor($t / 0.085) % 2 -eq 0) {
                $pulse = (Get-Square $base $t) * 0.36 + (Get-Square ($base * 1.52) $t) * 0.12
                return $pulse * (Get-Envelope $ratio 0.02 0.76 0.24)
            }
            return 0.0
        }
        "boss_phase" {
            $rise = 1.0 + ($ratio * 1.15)
            $body = (Get-Triangle ($base * $rise) $t) * 0.38 + (Get-Sine ($base * 0.5 * $rise) $t) * 0.18
            return (Get-PitchedNoise $Random $body 0.18) * (Get-Envelope $ratio 0.04 0.72 0.28)
        }
        "boss_break" {
            $freq = [math]::Max(36.0, $base * (1.0 - ($ratio * 0.74)))
            $body = (Get-Square ($freq * 0.5) $t) * 0.16 + (Get-Triangle $freq $t) * 0.18
            $crack = (Get-Sine (($base * 2.4) * (1.0 - ($ratio * 0.52))) $t) * 0.14
            return (Get-PitchedNoise $Random ($body + $crack) 0.70) * (Get-Envelope $ratio 0.02 0.16 0.84)
        }
        "stage_clear" {
            $chord = (Get-Sine $base $t) * 0.28 +
                (Get-Sine ($base * 1.26) ($t + 0.004)) * 0.24 +
                (Get-Sine ($base * 1.50) ($t + 0.008)) * 0.20
            return $chord * (Get-Envelope $ratio 0.08 0.58 0.42)
        }
        default {
            return 0.0
        }
    }
}

function Write-Wav([string]$Path, [int16[]]$Samples) {
    $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
    $writer = New-Object System.IO.BinaryWriter($stream)
    try {
        $dataSize = $Samples.Length * 2
        $writer.Write([System.Text.Encoding]::ASCII.GetBytes("RIFF"))
        $writer.Write([int]($dataSize + 36))
        $writer.Write([System.Text.Encoding]::ASCII.GetBytes("WAVE"))
        $writer.Write([System.Text.Encoding]::ASCII.GetBytes("fmt "))
        $writer.Write([int]16)
        $writer.Write([int16]1)
        $writer.Write([int16]1)
        $writer.Write([int]$SampleRate)
        $writer.Write([int]($SampleRate * 2))
        $writer.Write([int16]2)
        $writer.Write([int16]16)
        $writer.Write([System.Text.Encoding]::ASCII.GetBytes("data"))
        $writer.Write([int]$dataSize)
        foreach ($sample in $Samples) {
            $writer.Write([int16]$sample)
        }
    }
    finally {
        $writer.Close()
        $stream.Close()
    }
}

if (-not (Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

foreach ($eventName in $Events) {
    for ($variant = 1; $variant -le $VariantCount; $variant++) {
        $spec = Get-EventSpec $eventName $variant
        $sampleCount = [int]([double]$spec.duration * $SampleRate)
        $random = [System.Random]::new((Get-Seed "$eventName-$variant"))
        $samples = New-Object 'System.Int16[]' $sampleCount
        for ($index = 0; $index -lt $sampleCount; $index++) {
            $value = Get-EventSample $eventName $variant $index $sampleCount $spec $random
            $value = [math]::Tanh($value * [double]$spec.gain * 1.55)
            $clamped = [math]::Max(-1.0, [math]::Min(1.0, $value))
            $samples[$index] = [int16]([math]::Round($clamped * 32767.0))
        }
        $targetPath = Join-Path $OutputDir ("{0}_{1:d2}.wav" -f $eventName, $variant)
        Write-Wav $targetPath $samples
    }
}

Write-Host "Generated samples into: $OutputDir"
