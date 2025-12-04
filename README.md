# Saliency CNN Workspace

This repo uses [uv](https://github.com/astral-sh/uv) for fast, reproducible Python environments.

## Quick Start (Windows/macOS/Linux)

### Install uv

Windows (PowerShell):

```powershell
iwr https://astral.sh/uv/install.ps1 -UseBasicParsing | iex
```

macOS/Linux (bash):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Create and sync the virtual environment

```powershell
cd c:\repos\project
uv venv .venv
uv sync
```

- This creates `.venv` and installs all `project.dependencies`.
- For dev tools (formatting/linting/tests):

```powershell
uv sync --extra dev
```

### Use the environment

```powershell
.\.venv\Scripts\Activate.ps1
python --version
```

### Jupyter notebooks

- Ensure the kernel is installed in the venv:

```powershell
uv run python -m ipykernel install --user --name saliency-cnn --display-name "Python (saliency-cnn)"
```

- In VS Code, select the kernel "Python (saliency-cnn)" for each notebook.

## CUDA note (PyTorch)

- The `pyproject.toml` uses CPU builds by default.
- If you need a specific CUDA build, you can override sources or install with the official index:

  ```powershell
  uv pip install --index-url https://download.pytorch.org/whl/cu121 torch torchvision --upgrade
  ```

  Adjust `cu121` to your CUDA version.

## Legacy pip users (optional)

If someone prefers `pip`/`requirements.txt`, generate one:

```powershell
uv pip compile pyproject.toml -o requirements.txt
```

Then:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Troubleshooting

- If VS Code doesn’t pick up the venv, set the interpreter to `.venv\Scripts\python.exe`.
- If OpenCV fails to import, ensure you’re on Python >= 3.10 and re-run `uv sync`.
