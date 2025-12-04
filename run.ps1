<#!
.SYNOPSIS
Bootstrap script to set up uv, create/sync venv, and register Jupyter kernel.

.DESCRIPTION
- Installs uv if not present (skips if already installed)
- Creates `.venv` if missing and syncs dependencies from `pyproject.toml`
- Optionally installs dev extras (linting/formatting/testing)
- Registers a Jupyter kernel named `saliency-cnn`
- Optional: install CUDA-specific PyTorch build via `-CudaVersion`

.PARAMETER Dev
Include dev extras (ruff, black, pytest) from `pyproject.toml`.

.PARAMETER CudaVersion
CUDA version key for PyTorch index (e.g., `cu121`). If provided, installs torch/torchvision for that CUDA version.

.EXAMPLE
# Standard setup
./run.ps1

.EXAMPLE
# Setup with dev tools
./run.ps1 -Dev

.EXAMPLE
# Setup with CUDA 12.1 PyTorch builds
./run.ps1 -CudaVersion cu121
#>
param(
    [switch]$Dev,
    [string]$CudaVersion
)

$ErrorActionPreference = 'Stop'

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Ok($msg) { Write-Host "[OK]  $msg" -ForegroundColor Green }
function Write-Err($msg) { Write-Host "[ERR] $msg" -ForegroundColor Red }

# Move to repo root (script location)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $scriptDir

try {
    Write-Info "Checking for uv..."
    $uvCmd = Get-Command uv -ErrorAction SilentlyContinue
    if (-not $uvCmd) {
        Write-Warn "uv not found; installing..."
        if ($PSVersionTable.Platform -eq 'Unix') {
            Invoke-Expression (curl -LsSf https://astral.sh/uv/install.sh)
        } else {
            iwr https://astral.sh/uv/install.ps1 -UseBasicParsing | iex
        }
        $uvCmd = Get-Command uv -ErrorAction SilentlyContinue
        if (-not $uvCmd) { throw "uv installation failed" }
        Write-Ok "uv installed"
    } else {
        Write-Ok "uv is present"
    }

    # Ensure venv exists
    $venvPath = Join-Path $scriptDir '.venv'
    if (-not (Test-Path $venvPath)) {
        Write-Info "Creating venv at .venv..."
        uv venv .venv
        Write-Ok "venv created"
    } else {
        Write-Info ".venv already exists; reusing"
    }

    # Sync dependencies
    Write-Info "Syncing dependencies from pyproject.toml..."
    if ($Dev) {
        uv sync --extra dev
    } else {
        uv sync
    }
    Write-Ok "Dependencies synced"

    # Optional: CUDA-specific torch/torchvision
    if ($CudaVersion) {
        Write-Info "Installing torch/torchvision for $CudaVersion..."
        uv pip install --index-url "https://download.pytorch.org/whl/$CudaVersion" torch torchvision --upgrade
        Write-Ok "CUDA PyTorch installed"
    }

    # Register ipykernel
    $kernelName = 'saliency-cnn'
    $kernelDisplay = 'Python (saliency-cnn)'
    Write-Info "Registering Jupyter kernel '$kernelDisplay'..."
    uv run python -m ipykernel install --user --name $kernelName --display-name $kernelDisplay
    Write-Ok "Kernel registered"

    Write-Ok "Setup complete. To activate: .\\.venv\\Scripts\\Activate.ps1"
}
catch {
    Write-Err $_
    exit 1
}
finally {
    Pop-Location
}