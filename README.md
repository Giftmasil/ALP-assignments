# ALP Assignments

Assembly Language Programming assignments for the course.  
This repository is managed by **@Giftmasil** — all contributions go through pull requests.

---

## 📁 Repository Structure

```
ALP-assignments/
├── build.sh               ← the build & run script (DO NOT EDIT)
├── README.md              ← you are here
└── week-7/
    ├── q1_classify_number.asm
    ├── q2_add_arrays.asm
    └── q3_count_occurrences.asm
```

As new weeks are assigned, a new `week-N/` folder will be added following the same pattern.

---

## 🚀 Getting Started

### 1. Prerequisites

Make sure you have the following installed on your machine:

| Tool | What it does | Install command (Ubuntu/Debian) |
|------|-------------|--------------------------------|
| `git` | Version control | `sudo apt install git` |
| `nasm` | Assembles `.asm` → `.o` object files | `sudo apt install nasm` |
| `binutils` (`ld`) | Links `.o` → executable | usually pre-installed |

> **Windows users:** Use [WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/install) and run all commands inside the WSL terminal.

---

### 2. Clone the Repository

```bash
git clone https://github.com/Giftmasil/ALP-assignments.git
cd ALP-assignments
```

You only need to do this **once**. After that, just `git pull` to get the latest changes.

---

### 3. Keep Your Local Copy Up to Date

Before starting any new work, always pull the latest changes from `main`:

```bash
git checkout main
git pull origin main
```

---

## 🔨 Building and Running Programs

All assembly programs are built using the provided `build.sh` script.

### Basic Usage

```bash
# Build as 64-bit (this is what the course uses)
./build.sh week-7/q1_classify_number 64
```

The script will:

1. Assemble your `.asm` file with NASM (`elf64` format)
2. Link it into a runnable executable
3. Run it automatically and print the output

### Make the Script Executable (first time only)

If you get `Permission denied` when running `./build.sh`, run:

```bash
chmod +x build.sh
```

### Common Build Errors

| Error message | Likely cause | Fix |
|---|---|---|
| `nasm: command not found` | NASM not installed | `sudo apt install nasm` |
| `error: invalid combination of opcode and operands` | Wrong register — using `eax` instead of `rax` | Use 64-bit registers: `rax`, `rdi`, `rsi`, `rdx`, `rcx` |
| `Segmentation fault` | Program crashed at runtime | Check your syscall numbers (64-bit: `sys_write=1`, `sys_exit=60`) and that `rdi`/`rsi`/`rdx` are set correctly |
| `undefined symbol` | Label typo or missing section | Double-check your label names match exactly |

---

## 🌿 Branching & Contribution Workflow

This repo uses a **protected `main` branch**. You cannot push directly to `main`. All work goes through pull requests.

### Step-by-Step Guide

#### 1. Create your branch

Name your branch using this pattern: `week-N/qN-your-name`

```bash
# Example for Week 7, Question 1, student named "alice"
git checkout -b week-7/q1-alice
```

#### 2. Write your code

Open the starter `.asm` file for your question in VS Code (or any editor):

```bash
code week-7/q1_classify_number.asm
```

Fill in your solution following the hints in the file comments.

#### 3. Test your code locally

**Always test before pushing:**

```bash
./build.sh week-7/q1_classify_number
```

Make sure it builds and prints the expected output.

#### 4. Stage and commit your changes

```bash
git add week-7/q1_classify_number.asm
git commit -m "Week 7 Q1: implement number classifier with macros"
```

Write a meaningful commit message — say *what* you did, not just "update file".

#### 5. Push your branch

```bash
git push origin week-7/q1-alice
```

#### 6. Open a Pull Request

1. Go to the repository on GitHub
2. You will see a yellow banner: **"Compare & pull request"** — click it
3. Fill in the pull request template (it will appear automatically)
4. Set the base branch to `main`
5. Click **"Create pull request"**

#### 7. Wait for review

**ANYONE** will review your PR. The automated build check will also run — if it fails, fix the errors and push again (the PR updates automatically).

> ⚠️ **PRs that fail the automated build check will not be reviewed until the build is fixed.**

---

## 📏 Rules & Conventions

| Rule | Details |
|------|---------|
| **Branch protection** | No one can push directly to `main` — except @Giftmasil (bypass rights for emergency fixes) |
| **Required approvals** | Every PR needs 1 approval from any collaborator before merging |
| **Build must pass** | The automated NASM build check must pass before a PR can be merged |
| **No editing others' files or section** | Only modify your own `.asm` files or section - this is to prevent merge conflict, so if someone is working on a change on that section do not also be working on it |
| **No editing `build.sh`** | This is shared infrastructure — raise an issue if something is wrong with it |
| **Branch naming** | Use `week-N/qN-your-name` format |
| **Commit messages** | Be descriptive — `"Add Q1 solution with loop macro"` not `"update"` |

---

## 🤖 Automated Checks (GitHub Actions)

Every push and pull request automatically triggers:

| Check | What it does |
|-------|-------------|
| 🔧 **NASM Build Check** | Assembles and runs every `.asm` file in the repo. Fails if any program doesn't compile or crashes. |
| 📋 **PR Quality Check** | Ensures your PR has a meaningful title and a filled-in description. |

You can see the results of these checks on the PR page under the **Checks** tab. A green ✅ means it passed; a red ❌ means something needs fixing.

---

## ❓ FAQ

**Q: I cloned the repo but `./build.sh` says permission denied.**  
A: Run `chmod +x build.sh` once to make it executable.

**Q: My code builds fine locally but fails in GitHub Actions.**  
A: The CI runs on a fresh Ubuntu environment. Make sure you're not relying on anything installed manually that isn't in the build script. The most common cause is using 32-bit registers (`eax`, `ebx`) — remember everything here is **64-bit** (`rax`, `rdi`, `rsi`, `rdx`).

**Q: I accidentally committed to `main` locally. What do I do?**  
A: You can't push it anyway (branch is protected), but to clean up locally:

```bash
git checkout -b my-rescue-branch   # save your work to a new branch
git checkout main
git reset --hard origin/main       # reset main to match remote
```

**Q: Can I work on multiple questions in one branch?**  
A: Technically yes, but it's better practice to have one branch per question so reviews are focused.

---

## 📬 Contact

Open a GitHub Issue or better messege in the group if you have questions about the repo setup or the build script.  
