# 🧊 nix-dev-flake

A modular collection of [Nix flakes](https://nixos.wiki/wiki/Flakes) organized by development technologies — **Bun**, *
*Python**, **Terraform**, and **OpenTofu** — with a shared Nix shell environment and a unified root flake for
streamlined development.

---

## 📁 Repository Structure

```
.
├── bun/           # Flake for Bun (JS/TS) development
├── python/        # Flake for Python development with venv support
├── terraform/     # Flake for Terraform
├── opentofu/      # Flake for OpenTofu 
├── nix/
│   ├── shared.nix         # Shared/common packages and utilities
│   └── unfree-pkgs.nix    # Opt-in unfree package support
└── flake.nix      # Root flake that imports and merges all dev environments
```

---

## 🧪 Features

- ✅ **Per-technology dev shells** (`nix develop .#bun`, `.python`, `.terraform`, etc.)
- ✅ **Unified shell** (`nix develop`) with all tools from all stacks
- ✅ Centralized **shared dependencies** in `nix/shared.nix`
- ✅ Modular and maintainable configuration using [`flake-parts`](https://github.com/hercules-ci/flake-parts)
- ✅ Declarative, reproducible environments

---

## 💻 Getting Started

### Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled

### Clone the repository

```bash
git clone https://github.com/abeguin/nix-dev-flake.git 
```

or with [jj](https://github.com/jj-vcs/jj)

```bash
jj git clone --colocate https://github.com/abeguin/nix-dev-flake.git
```

```bash
cd nix-dev-flake
```

### Enter the combined development shell

```bash
nix develop
```

Or use a specific tech stack:

```bash
nix develop .#python
nix develop .#bun
nix develop .#terraform
nix develop .#opentofu
```

Or configure [nix-direnv](https://github.com/nix-community/nix-direnv) (should be installed separately) with a .envrc in
each directory.

```bash
use flake
```

---

## ❅ Flake templates

You can also use this directly using [nix flake init](https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-flake-init).

```bash
# default full stack
nix flake init -t  github:abeguin/nix-dev-flake
# bun
nix flake init -t  github:abeguin/nix-dev-flake#bun
# python
nix flake init -t  github:abeguin/nix-dev-flake#python
# opentofu
nix flake init -t  github:abeguin/nix-dev-flake#opentofu
# terraform
nix flake init -t  github:abeguin/nix-dev-flake#terraform
```

This allows to easily bootstrap a repository

---

## 📦 Technology Breakdown

| Folder       | Purpose                        | Tools Included                     |
|--------------|--------------------------------|------------------------------------|
| `bun/`       | JS/TS development with Bun     | `bun`                              |
| `python/`    | Python development environment | `python3`, `uv`, `venvShellHook`   |
| `terraform/` | Terraform infrastructure       | `terraform`, `tflint`              |
| `opentofu/`  | OpenTofu IaC setup             | `opentofu`, `tflint`               |
| `nix/`       | Shared logic                   | Common packages used across flakes |

---

## 🔄 How It Works

Each subdirectory (e.g., `python/`, `bun/`, etc.) is a standalone Nix flake exporting its own `devShell` and `packages`.

The **root flake** (`flake.nix`) imports and merges them into a single unified shell, allowing you to develop across
tech stacks with one consistent environment.

```nix
# Example from root flake:
combined = commonPackages ++ pythonPkgs ++ terraformPkgs ++ bunPkgs;
```

---

## 🧠 Why Use This?

- Work across multiple ecosystems (Python, JS, Terraform) with one tool
- Consistent dev environments for teams and CI/CD
- No more "works on my machine" bugs
- Great for monorepos or full-stack applications

---

## 📚 Resources

- [Nix Flakes Wiki](https://nixos.wiki/wiki/Flakes)
- [flake-parts](https://github.com/hercules-ci/flake-parts)

---

## 🙌 Contributing

Contributions welcome! Open an issue or PR to add support for new stacks, or to improve the existing structure.

---
