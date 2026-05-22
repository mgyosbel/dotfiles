# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── install.sh          # dependency bootstrap
├── stow.sh             # symlink manager
├── install/
│   ├── lib/            # shared shell helpers
│   └── deps/           # one file per dependency
├── ghostty/            # package: ghostty config
├── nvim/               # package: neovim config
├── tmux/               # package: tmux config + scripts
├── wallpapers/         # wallpapers (not stowed)
└── zsh/                # package: zsh config
```

Each top-level directory (except `install/` and `wallpapers/`) is a **stow package**. Its contents mirror the structure of `$HOME`, so stow can symlink them into place.

---

## Setup on a new machine

### 1. Clone the repo

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
```

### 2. Install dependencies

```bash
./install.sh
```

This installs all required tools for the current platform (macOS via Homebrew, Linux via apt). See [Dependency management](#dependency-management) for options.

### 3. Symlink dotfiles

```bash
./stow.sh
```

This creates symlinks from `$HOME` into the repo for each package. See [Stow](#stow) for details.

---

## Stow

### How it works

Stow maps the contents of each package directory to `$HOME`. For example:

```
dotfiles/zsh/.zshrc  →  ~/.zshrc
dotfiles/nvim/.config/nvim/  →  ~/.config/nvim/
dotfiles/tmux/.tmux.conf  →  ~/.tmux.conf
```

### Using `stow.sh`

```bash
./stow.sh
```

- If a symlink already exists pointing to this repo: restows it (`stow -R`, idempotent)
- If nothing exists at the target: creates the symlink
- If a real file exists at the target: prints a `[CONFLICT]` warning and skips — **never overwrites**

To resolve a conflict, back up and remove the real file, then re-run `./stow.sh`.

### Adding a new package

1. Create a directory at the repo root named after the tool
2. Mirror the `$HOME` path inside it — e.g. for `~/.config/foo/config`:
   ```
   dotfiles/foo/.config/foo/config
   ```
3. Run `./stow.sh` — it will pick up the new package automatically

### Removing a package

```bash
cd ~/dotfiles
stow -D <package>
```

This removes the symlinks without deleting anything from the repo.

---

## Dependency management

### Install everything

```bash
./install.sh
```

### Install specific deps

```bash
./install.sh neovim tmux
```

### Preview without making changes

```bash
./install.sh --dry-run
```

### List all available deps

```bash
./install.sh --list
```

Dependencies are defined as individual modules in `install/deps/`. Each module is a self-contained shell file that knows how to check if the tool is installed and how to install it per platform.

### Adding a new dependency

1. Create `install/deps/<name>.sh` with three functions:

```bash
dep_name()         { echo "mytool"; }
dep_is_installed() { command -v mytool &>/dev/null; }
dep_install() {
  case "$PLATFORM" in
    macos) brew_install mytool ;;
    linux) apt_install mytool ;;
  esac
}
```

2. Add `<name>` to `ALL_DEPS` in `install/lib/registry.sh` at the desired install order position.

Optional metadata functions:

```bash
# Only run on specific platforms
dep_platforms() { echo "macos"; }

# Require another dep to be installed first
dep_requires()  { echo "go"; }
```

---

## Updating

After pulling changes on any machine:

```bash
git pull
./stow.sh   # restows any new or changed packages
```
