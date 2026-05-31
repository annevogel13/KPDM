# Decision Tree Prolog Tests

This repository contains a small Prolog decision-tree example and a test script `inference_checks.sh`.

Files:

- `tree.pl` — decision-tree logic (loads facts from `knowledge_base.pl`).
- `knowledge_base.pl` — node and leaf facts (kept separate for clarity).
- `inference_checks.sh` — test runner that executes several example queries.

## Running the tests (common)

From the project root (`/KPDM`):

Make the script executable (one-time):

```bash
chmod +x inference_checks.sh
```

Run the test script:

```bash
./inference_checks.sh
```

Or run with `sh` without changing permissions:

```bash
sh inference_checks.sh
```

Run a single query example:

```bash
swipl -q -s tree.pl -g "decision_tree('A',120,30,R), writeln(R), halt."
```

## Ubuntu

Install SWI-Prolog:

```bash
sudo apt update
sudo apt install swi-prolog -y
```

Verify installation:

```bash
swipl --version
```

Then run the tests as shown above.

## macOS

If you have Homebrew installed:

```bash
brew update
brew install swi-prolog
```

Alternatively download the installer from the SWI-Prolog website.

Verify installation:

```bash
swipl --version
```

Then run the tests as shown above.

## Windows

Option 1 — Installer:

- Download the SWI-Prolog installer from https://www.swi-prolog.org/Download.html and run it.

Option 2 — Chocolatey (command line):

```powershell
choco install swi-prolog -y
```

After installing, open `cmd.exe` or PowerShell and run:

```powershell
swipl --version
```

To run the tests from Windows, you can use the WSL bash shell (recommended) or run SWI-Prolog directly:

```powershell
swipl -q -s tree.pl -g "decision_tree('A',120,30,R), writeln(R), halt."
```

Notes:

- The test script `inference_checks.sh` is a POSIX shell script; on Windows use WSL or Git Bash to run it as-is.
- `tree.pl` loads `knowledge_base.pl` from the same directory, so run commands from the repository root or provide full paths.
