# dotfiles

Personal configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).
Target platforms: macOS and Debian/Ubuntu.

## Migration status

The repository layout and preview-first Stow wrapper are in place. The approved
live Neovim changes and Starship configuration have been imported. Portable Zsh
fragments and local-override hooks are implemented and tested in isolation. tmux
clipboard selection and helper portability are implemented. Ghostty's live
appearance is imported into a shared configuration. Live machine-local settings,
Ghostty path activation, and real Linux/application validation remain
pending. Follow [the migration checklist](docs/migration.md) before activating
the packages on an existing machine.

## Structure

```text
dotfiles/
├── .gitignore
├── README.md
├── install.sh                 # dependency bootstrap
├── install/
│   ├── lib/                   # shared installation helpers
│   └── deps/                  # per-dependency installation modules
├── stow.sh                    # preview-first symlink manager
├── profiles/
│   ├── common                 # zsh, starship, nvim, tmux
│   └── desktop                # zsh, starship, nvim, tmux, ghostty
├── packages/
│   ├── zsh/                   # .zshrc, .zprofile, .config/zsh/*.zsh
│   ├── starship/.config/starship.toml
│   ├── nvim/.config/nvim/
│   ├── tmux/
│   │   ├── .tmux.conf
│   │   └── .local/bin/
│   └── ghostty/.config/ghostty/config
├── docs/
│   ├── migration.md
│   ├── zsh-local.md
│   ├── neovim-local.md
│   ├── neovim-embedded.md
│   └── neovim-LICENSE
└── wallpapers/                # assets, not deployed by Stow
```

Only directories under `packages/` are Stow packages. Each mirrors paths relative
to the target directory, normally `$HOME`. For example:

```text
packages/zsh/.zshrc                     -> ~/.zshrc
packages/nvim/.config/nvim/init.lua     -> ~/.config/nvim/init.lua
packages/tmux/.local/bin/tmux-dev-dir   -> ~/.local/bin/tmux-dev-dir
```

## Symlink management

GNU Stow must be installed separately before deployment. The wrapper runs with
stock macOS Bash 3.2 or newer Bash and resolves the repository from its own path.

```bash
# Show packages and profiles (does not require Stow)
./stow.sh --list
./stow.sh --help

# Preview the common profile; no symlinks are changed
./stow.sh

# Preview explicit packages instead of a profile
./stow.sh nvim tmux

# Apply after a successful preflight
./stow.sh --apply nvim tmux

# Preview or apply the desktop profile
./stow.sh --profile desktop
./stow.sh --apply --profile desktop

# Preview against an existing isolated target
./stow.sh --target /path/to/test-home nvim
```

`--profile` and explicit package names are mutually exclusive. Profiles are plain
text: one package per line, with blank lines and `#` comments allowed. They select
applications, not operating systems. Platform-specific configuration belongs in
the relevant application's configuration; installation handles package managers.

The wrapper passes all selected packages to Stow together, with explicit source
and target directories and `--no-folding`. Existing directories such as
`~/.config` remain real directories, and individual files become symlinks.
Deployment uses restow, so repeated runs reconcile the selected packages.

Every operation is simulated first. Only `--apply` proceeds to the actual Stow
operation. A failed preflight exits nonzero and prevents that apply invocation.
Preflight is not a transactional guarantee: avoid concurrent changes to the
repository or target during deployment. Ordinary Stow resource-file settings
(`.stowrc`) still apply; do not configure `--adopt` for this workflow.

### Conflicts

Stow reports conflicts at the relevant destinations. An existing real directory
is not by itself a conflict. When a managed file already exists, compare it with
the repository version, reconcile the desired content, and back up that specific
destination before trying again. Never remove all of `~/.config` or `~/.local`
to resolve a package conflict.

### Removing packages

```bash
./stow.sh --delete nvim          # preview
./stow.sh --apply --delete nvim  # remove links managed by this package
```

Unstowing keeps repository files. It does not restore pre-migration files; restore
those from your explicit backup if rolling back. Unstow a package before removing
its source directory or relocating this repository after deployment.

### Adding packages

1. Create `packages/foo/` with the desired home-relative paths, for example
   `packages/foo/.config/foo/config`.
2. Preview with `./stow.sh foo`.
3. Add `foo` to the desired profile(s) if it should be selected there.
4. Apply with `./stow.sh --apply foo` when the preview is satisfactory.

Each destination must have one owner. Stow does not merge files from different
packages or provide platform override precedence. Keep documentation and
downloaded plugins outside deployable package content.

## Imported application configuration

Neovim includes the live plugin lockfile and LazyVim extras, updated LSP/Mason/Octo
configuration, and the Arduino, formatting, linting, REST, and Terraform plugin
files. The [Arduino/ESP32 guide](docs/neovim-embedded.md) and accompanying
[Neovim configuration license](docs/neovim-LICENSE) are preserved from the live
configuration. An optional machine-local `local.lua` loads at the end of shared
options, before plugin initialization. See [Neovim local settings](docs/neovim-local.md)
for the enterprise/proxy settings to preserve on this Mac during activation.

Starship's live `starship.toml` is included in both profiles. Zsh initializes it
when installed; `./install.sh starship` installs it with Homebrew on macOS or
the upstream installer into `~/.local/bin` on Linux.
Import verification compares source and destination bytes and parses JSON;
application behavior still needs smoke testing after reconciliation.

## Zsh

Zsh now loads shared environment settings, OS-specific fragments, available
Oh My Zsh plugins (or ordinary completion initialization), optional tool
integrations, and completions. Paths use `$HOME` and discovered Homebrew prefixes.
The login banner runs only in interactive terminal sessions.

Existing `~/.zshrc.local` loads early; optional `~/.config/zsh/local.zsh` loads
last. See [local migration and load order](docs/zsh-local.md) for this Mac's work,
networking, and SDK settings to preserve before activation. The shared package
does not create those local files. Shell fragments deploy to `~/.config/zsh`;
changing `XDG_CONFIG_HOME` alone does not relocate Stow's destinations.

Ten isolated Zsh scenarios and syntax checks pass on macOS. Optional tools were
controlled test doubles; real tool integration and Debian/Ubuntu startup still
need verification. ShellCheck does not support Zsh, so Zsh files are checked
with `zsh -n` and runtime tests instead.

## tmux

The copy-mode `y` binding uses `pbcopy` on macOS, `wl-copy` on Wayland, or `xclip`
on X11 when available; otherwise it uses tmux's internal buffer. Wayland takes
precedence when both Linux display types are available. Selection happens when
the config loads; reload after changing display environments or clipboard tools.
TPM loads only when `~/.tmux/plugins/tpm/tpm` is executable; `./install.sh tpm`
installs the manager. Install configured tmux plugins separately with prefix + I.

`tmux-sessionizer [directory]` uses exact session-name lookup and supports quoted
paths and optional project/home `.tmux-sessionizer` initialization. Interactive
selection needs fzf with `--read0`/`--print0`; it searches `$HOME` and, when present,
`$HOME/dev`, to depth 3 from each root. Session names use the directory basename
with dots/colons replaced by underscores; identical resulting names share a
session. Cancellation exits without changing sessions.

`tmux-dev-dir` runs from a tmux pane. It preserves the first window, closes the
other windows in that session, and builds `code`, `run`, and `ai` at indexes 1–3.
It sends `nvim .` and `opencode` to explicit pane IDs and quotes the current working
directory. The commands require those tools to be installed. All window changes
use session/window IDs rather than relying on another client's current window.

Nine isolated scenarios passed, including controlled helper commands and a
separate temporary tmux server for config parsing, clipboard branches, and TPM.
Linux clipboard branches used simulated tools on macOS; actual Linux execution
and application smoke tests remain pending.

## Ghostty

The desktop profile deploys `~/.config/ghostty/config` on macOS and Linux. It
preserves the live Catppuccin Mocha appearance, font size 16, transparency, and
cursor settings. `command = tmux` replaces the Mac-specific executable path;
tmux must be discoverable in Ghostty's launch environment, including when started
from the Dock rather than a shell. Verify that during activation.

Install the font family `JetbrainsMono Nerd Font` (the live configured name) on
each machine, or explicitly choose another font. Configuration import does not
verify installed font availability or install fonts/tmux. `gtk-single-instance`
is a GTK-specific setting, retained for Linux.

According to [Ghostty's configuration documentation](https://ghostty.org/docs/config),
macOS native files under `~/Library/Application Support/com.mitchellh.ghostty/`
load after XDG files and override conflicting settings. The live native `config`
must be backed up and reconciled during activation so the shared file becomes
authoritative. Also inspect `config.ghostty` files at both locations on versions
supporting that filename; the legacy `config` filename remains supported.

If `XDG_CONFIG_HOME` is set, Ghostty uses that directory rather than `~/.config`.
This Stow package still targets `~/.config/ghostty/config`; resolve any custom XDG
path before activation. Native-path cleanup and GUI launch verification require
their own approved activation steps.

## Dependency bootstrap

The entry points are:

```bash
./install.sh --list
./install.sh --help
./install.sh --dry-run
./install.sh neovim tmux
```

The orchestrator supports stock macOS Bash 3.2 and newer Bash, detects macOS or
Debian/Ubuntu and amd64/arm64, validates dependency names and cycles before
installation, and orders declared prerequisites before their dependents.
`--dry-run` runs metadata/presence checks, reports planned installations separately,
and never invokes installers, Homebrew downloads/shellenv, sudo, or state-directory
creation. Modules must keep metadata and presence checks free of side effects.

For actual installation, use your normal user. The shared `as_root` helper uses
sudo only for system operations; user-level tools retain your home. The apt helper
updates its index once per invocation, using a temporary state directory shared
by module processes and removed on exit. Homebrew's environment is initialized
after bootstrap. Modules execute in fresh Bash processes with failure handling
and post-install presence checks. Failed dependencies block missing dependents;
independent dependencies continue, and the final status is nonzero on failure.

Shell/tmux dependencies now include Starship, TPM, and zsh-autosuggestions.
Zsh plugins install under `${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins`,
matching the shell loader. The old standalone syntax-highlighting checkout is
left in place. Checks require plugin entry points rather than only directories;
an incomplete existing checkout fails its postcheck and requires inspection,
rather than being overwritten. Oh My Zsh declares curl/Git/Zsh prerequisites and
sets `CHSH=no`, `RUNZSH=no`, and `KEEP_ZSHRC=yes` when invoking its installer.

Go and kubectl now select Linux amd64/arm64 downloads and verify SHA-256 before
system installation through the privilege helper. Go defaults to **1.27.2**,
with checksums recorded from https://go.dev/dl/?mode=json on 2026-10-18. Override
Linux installation with `GO_VERSION=x.y.z GO_SHA256=<official-archive-checksum>`;
another version requires its matching checksum. The module stages and validates
the extracted Go binary, copies it into root-owned staging under `/usr/local`,
then replaces `/usr/local/go`. If activation fails after moving the old install,
it attempts restoration; an unsuccessful restoration retains the backup path
and reports it. This is not an atomic upgrade and should not run concurrently.

Linux kubectl defaults to the upstream `stable.txt` release or accepts
`KUBECTL_VERSION=vx.y.z`; its checksum comes from the matching upstream `.sha256`
endpoint. It installs to `/usr/local/bin/kubectl`. Linux needs `sha256sum` and Go
extraction needs `tar` (normally available on Debian/Ubuntu). macOS continues to
use Homebrew for all three tools, independent of Linux version overrides.

kubecolor locates Go on PATH, then `/usr/local/go/bin/go`; it never treats GOPATH
as the compiler installation. Linux installs `@latest` into `GOBIN`, or the first
GOPATH entry's `bin`, defaulting to `$HOME/dev/go/bin`. Add custom destinations to
your PATH. Go is a prerequisite only for the Linux branch. Existing executables
are currently skipped by presence checks: these version settings select new
downloads, not automatic upgrades or downgrades of installed tools.

### Version requirements and runtime modules

- **Neovim >= 0.11.2 with LuaJIT**, matching both installed LazyVim's startup check
  and [upstream requirements](https://www.lazyvim.org/). The installer checks
  `nvim --version` without loading configuration. Prerelease version strings are
  not accepted as stable releases by this check.
- **tmux >= 3.3**, required by `allow-passthrough` (introduced in the 3.3 release
  notes); popup support is also available at this floor. Stable letter suffixes
  such as `3.3a` are accepted.
- **fzf with `--read0` and `--print0`** for the sessionizer. The installer checks
  advertised capabilities. `fzf --zsh` needs 0.48.0+, but older installations can
  use the existing `~/.fzf.zsh` or Debian completion-file fallback.

If apt/Homebrew leaves an incompatible executable on PATH, the module reports
failure with the required version/capabilities. It does not silently add another
package source or compile a replacement. Install a suitable release for that
machine and ensure it precedes any older executable on PATH before retrying.

NVM requires a nonempty `nvm.sh`, supports `NVM_DIR`, and retains the existing
v0.39.7 installer pin using script mode and `PROFILE=/dev/null`. It installs the
version manager, not Node. Rust detects a working Cargo on PATH or under
`${CARGO_HOME:-$HOME/.cargo}/bin`, and rustup uses `--no-modify-path`. Both declare
curl and propagate download/install failures. Add custom Cargo paths to local
shell settings if needed. Ghostty detection recognizes the CLI or its executable
in `/Applications/Ghostty.app` or `~/Applications/Ghostty.app`; Linux Ghostty
installation remains distro-specific and separate.

### Additional tools by workflow

The bootstrap covers its explicit registry, not every external tool referenced
by editor plugins or personal aliases. Before application smoke tests, review:

| Workflow | Additional requirements |
| --- | --- |
| LazyVim/search | Git >= 2.19, ripgrep, fd; optional lazygit; Nerd Font v3+ |
| Treesitter/native plugins | C compiler and tree-sitter-cli as required by the locked plugins |
| JavaScript/TypeScript and JS debugging | Node/npm through NVM; `ts-node` for the configured adapter |
| Go testing/linting | Go and golangci-lint; Mason-managed tools as configured |
| Terraform/HCL | terraform, packer; Mason-managed tflint/servers |
| Arduino/ESP32 | arduino-cli, board cores and serial access; see the embedded guide |
| GitHub integration | gh with authentication for Octo |
| tmux file manager/AI windows | yazi and opencode |
| Optional shell integrations | dotnet, nats, kubie, rbenv, Bun, gcloud, figlet/lolcat |
| Linux clipboard/terminal | wl-copy or xclip for the display environment; Ghostty if using the desktop profile |

Mason/plugin downloads and interactive credentials are not performed by Stow.
Actual Debian/Ubuntu installation and application smoke tests still need validation.

Twenty-two isolated scenario groups passed under Bash 3.2/5.3 using fake package
managers, metadata, and installer scripts. Linux distro detection used synthetic
release files in a temporary copy; real Debian/Ubuntu execution remains pending.
Twelve additional isolated module scenario groups passed for installer options,
custom plugin paths, executable/presence checks, clone idempotence, download
failures, Starship platform branches, and prerequisite/registry metadata. No real
packages were installed in these tests.
Twenty portability scenario groups passed across Bash 3.2/5.3 for both Linux
architecture branches, checksum/download failures, Go replacement rollback,
cleanup, macOS routing, and kubecolor executable/output-path selection. Tests
redirected system paths in temporary module copies and used fixture downloads
and privilege wrappers; they did not install actual Go/kubectl or run Linux binaries.
Fourteen runtime/version scenario groups passed under Bash 3.2/5.3, including
version boundaries, fzf capabilities, incompatible-package errors, NVM profile
preservation, custom Cargo paths, failed installers, and Ghostty bundle detection.

## Day-to-day workflow after migration

Edits to linked configuration files update the repository. Review changes with
Git, then commit and push deliberately. On another machine:

```bash
git pull
./stow.sh --profile desktop
./stow.sh --apply --profile desktop
```

Pulling changes can immediately affect already-linked files; Stow preview checks
link operations, not application behavior. Restow handles added or removed paths.
Choose the same profile used for that machine, and stop using the old `env`
copy-based Makefile once its destinations are Stow-managed.
