# Migration from ~/env

## Activation record — this Mac

Activated the desktop profile on 2026-10-18 with explicit approval.

- Repository: `/Users/yosbel.martinez/dotfiles`
- Verified backup: `/Users/yosbel.martinez/dotfiles-backup-20261018-143901`
  (owner-only directory; 46 original files verified byte-for-byte and with
  matching permission modes before replacement).
- Replaced 38 individually backed-up managed-file conflicts, then successfully
  previewed and applied `./stow.sh --apply --profile desktop`.
- Verified all 44 deployed file links resolve into the correct package. Shared
  `.config`, Neovim/Zsh config directories, and `.local/bin` remain real directories.
- Preserved six unmanaged Neovim files byte-for-byte, including `.env` and the
  existing backup/documentation files.
- Merged GOPRIVATE and SOFTHSM2_CONF into `~/.zshrc.local`, preserving every byte
  of its original content outside the explicit addition. Existing credentials
  remain local and were not copied into this repository.
- Created `~/.config/zsh/local.zsh` for the documented machine-specific aliases
  and SDK paths, and `~/.config/nvim/local.lua` for the previous enterprise
  Copilot/proxy settings. All local override files remain real machine-local files.
- Moved the native Ghostty config into the backup's matching home-relative path;
  `~/.config/ghostty/config` now links to the shared configuration. No alternate
  `config.ghostty` was found in the inspected native directory; XDG_CONFIG_HOME
  was unset in the activation environment.
- Application launches, plugin/cache updates, and live session reloading were
  not performed as part of activation. They require separate approval. Existing
  application processes may retain their previously loaded settings.

Stop using the `~/env` copy-based Makefile for these destinations. Keep `~/env`
and this backup until application smoke tests and a Linux deployment are verified.
Repository changes are still uncommitted and have not been pushed.

### Rollback for this activation

Preview removal using `./stow.sh --delete --profile desktop`. After explicit
approval, apply removal, restore the backed-up managed files and original
`.zshrc.local` from the backup, and restore the native Ghostty config. The newly
created Zsh and Neovim local override files should be reviewed separately before
removing them; they did not exist in the original backup. Empty Stow-created
directories can remain. Never restore the entire home or delete shared `.config`
or `.local` directories as a shortcut.

## Baseline and scope

Use the live macOS configuration as the baseline, consulting both `~/env` and the
previous dotfiles versions when reconciling differences. Target macOS and
Debian/Ubuntu. Repository preparation, validation, and live activation are
separate approval steps; request explicit approval before each writing operation
or clearly described batch of writes.

## Repository preparation

- [x] Move the four existing packages under `packages/` without content changes.
- [x] Add explicit common and desktop package profiles.
- [x] Replace top-level conflict guessing with a preview-first Stow wrapper.
- [x] Add root ignore rules for local files and backups.
- [ ] Reconcile the configuration below before deployment.
- [x] Implement approved dependency-bootstrap repairs.
- [ ] Validate actual bootstrap and application behavior on Debian/Ubuntu before
      treating a fresh Linux machine as fully supported.

## Configuration reconciliation

### Zsh and Starship

- [x] Use live `~/.zshrc` and `~/.zprofile` as the baseline (both matched `env`
      during inspection).
- [x] Add `.zprofile` to the Zsh package and preserve Homebrew initialization.
- [x] Separate common, macOS, and Linux shell configuration.
- [x] Replace username-specific paths with `$HOME` or discovered tool paths.
- [x] Preserve cached initialization while guarding missing/failed commands and
      registering completions after completion initialization.
- [x] Review machine-specific networking aliases, SDK paths, and work settings;
      define local override loading and document migration in `docs/zsh-local.md`.
- [x] With separate approval, merge the documented machine-local settings into
      live override files before activation, preserving existing local content.
- [x] Keep login banners restricted to interactive terminal sessions.
- [x] Add `packages/starship/.config/starship.toml` from the live file and add
      the package to both profiles.
- [x] Add guarded Starship shell initialization.
- [x] Add Starship dependency coverage (Homebrew on macOS; user-local upstream
      installation on Linux).

### Neovim

- [x] Import live `lazy-lock.json` and `lazyvim.json`.
- [x] Import live changes to `lua/plugins/lsp.lua`, `mason.lua`, and `octo.lua`.
- [x] Import the seven live plugin files missing from dotfiles:
      `arduino.lua`, `conform.lua`, `linters.lua`, `none-ls.lua`, `rest.lua`,
      `terraform.lua`, and `treesiter.lua`.
- [x] Preserve live `EMBEDDED.md` as `docs/neovim-embedded.md` and the accompanying
      live `LICENSE` as `docs/neovim-LICENSE`, both as exact copies.
- [x] Move enterprise Copilot/proxy assignments out of shared options and add
      an optional `stdpath("config")/local.lua` hook. Document this Mac's settings
      in `docs/neovim-local.md` and ignore the package-local filename in Git.
- [x] With separate approval, create/merge the live Neovim local settings before
      activation so this Mac retains its enterprise endpoint and proxy behavior.
- [ ] Review env-only `.NET`/lualine configuration separately; do not restore it
      automatically when it is absent from the live baseline.
- [ ] Review `.env` separately and keep machine-local data outside version
      control. Do not import `init.lua.bkp` as active configuration.

### tmux

- [x] Preserve tmux settings/bindings except the approved clipboard and TPM
      changes; preserve the helper's code/run/ai workflow with explicit targets.
- [x] Preserve the live sessionizer's maximum search depth of 3, versus 5 in the
      previous dotfiles version; review quoting and session lookup behavior.
- [x] Select clipboard support for macOS (`pbcopy`), Wayland (`wl-copy`), or X11
      (`xclip`) based on the available environment.
- [x] Guard optional TPM loading and retain executable permissions for helpers.
- [x] Cover TPM manager installation in bootstrap; configured plugins still
      require installation through TPM.

### Ghostty

- [x] Import desired settings from the live macOS file at
      `~/Library/Application Support/com.mitchellh.ghostty/config`.
- [x] Preserve Catppuccin Mocha, font size 16, transparency, and cursor settings.
- [x] Replace the absolute tmux path with `command = tmux` and preserve the live
      configured font name, `JetbrainsMono Nerd Font`.
- [ ] Verify font availability and tmux resolution in Ghostty's GUI launch
      environment on each machine.
- [x] Select `~/.config/ghostty/config` as the shared path, supported on both
      platforms according to https://ghostty.org/docs/config.
- [x] With separate activation approval, back up/reconcile the native macOS
      config, which loads after XDG settings. Check for `config.ghostty` files in
      both locations and any custom `XDG_CONFIG_HOME` before making the shared
      file authoritative.

## Bootstrap repairs

- [x] Remove `mapfile` dependency and support stock macOS Bash 3.2.
- [x] Make orchestrator `--dry-run` write-free, including the Homebrew path;
      metadata and presence checks must remain side-effect-free in modules.
- [x] Add narrowly scoped `as_root`, reject full root execution for installation,
      and keep apt-update state in a cleaned-up per-invocation temporary directory.
- [x] Convert Go/kubectl direct system writes to use the privilege
      helper; preserve the user's home for user-level tools and plugins.
- [x] Detect Debian/Ubuntu and amd64/arm64 in the shared orchestrator.
- [x] Use detected architecture for Linux Go/kubectl downloads; verify checksums
      before installation. Pin default Go 1.27.2 checksums from the upstream feed,
      support version/checksum overrides, and stage Go before replacing the old
      installation with restoration on failed activation.
- [x] Resolve kubecolor's Go executable independently of GOPATH; require Go only
      on Linux and honor GOBIN/user GOPATH for the installed binary.
- [x] Resolve declared prerequisites before dependents, detect cycles, isolate
      installer functions in fresh Bash processes, propagate failures, and check
      installed state after each module succeeds.
- [x] Validate Neovim >= 0.11.2 with LuaJIT, tmux >= 3.3, and fzf NUL I/O
      capabilities. Report incompatible post-install packages rather than success.
- [x] Repair NVM/Rust checks, custom locations, curl prerequisites, download
      failure handling, and profile-preserving installer flags. Recognize Ghostty
      application bundles on macOS.
- [x] Align syntax-highlighting installation with its configured load location.
- [x] Add Starship, autosuggestions, and TPM. Complete Git/Oh My Zsh prerequisites
      for Zsh plugins and curl/Git/Zsh prerequisites for Oh My Zsh. Preserve
      `.zshrc` and the login shell via the upstream installer's flags.
- [x] Document core version requirements and additional tools by workflow in README.
- [ ] Confirm workflow-specific tools, credentials, and plugin-managed runtimes
      are available on each target machine during application validation.

## Validation before activation

- [x] Validate the final five-package desktop profile under Bash 3.2 and 5.3
      using GNU Stow: all 44 file symlinks point to the expected package sources;
      shared directories remain real; repeated deployment is stable; preview
      and unstow preview do not change targets; removal preserves local Zsh and
      Neovim overrides, a local `.env`, and unrelated application/bin files.
      Repository sources remain unchanged by all link operations.
- [x] Run deployed login/interactive fragments in isolated real Zsh with optional
      tool initialization controlled, confirming early/final overrides. Use real
      Neovim with `-u NONE -i NONE -n` to parse all Lua files and execute shared
      options plus the local hook; parse imported JSON and Starship TOML. No
      plugins were initialized or downloaded. All eight final scenario groups
      passed; temporary scripts/fixtures were removed.
- [x] Pass 14 runtime/version scenario groups across Bash 3.2/5.3 for version
      thresholds, prereleases, LuaJIT, fzf flags, old-package postchecks, NVM/Cargo
      custom locations, installer failures/profile preservation, and Ghostty user
      bundle detection. ShellCheck passed for the entire installer. Temporary
      fixtures/scripts removed. Full live dry-run: 0 installed, 2 planned (Rust,
      NVM), 18 skipped, 0 failed; no real installation was performed.
- [x] Pass 20 isolated Go/kubectl/kubecolor portability scenario groups under
      Bash 3.2/5.3 covering amd64 and arm64, checksum/download failures, staging,
      replacement rollback, temporary cleanup, version validation, Homebrew
      branches, user binary destinations, and platform prerequisites. System
      paths were redirected in temporary copies, and privilege/download commands
      used fixtures. Bash syntax and ShellCheck passed. Temporary fixtures and
      scripts were removed. Live dry-run: 0 installed, 0 planned, 3 skipped,
      0 failed. Actual Linux binary execution remains pending.
- [x] Pass 12 isolated shell/tmux module scenario groups under Bash 3.2/5.3:
      Oh My Zsh flags and custom paths, plugin clone idempotence/incomplete
      checkout checks, executable TPM detection, both Starship platform branches,
      download failures, and prerequisite/registry declarations. ShellCheck
      passed. Temporary scripts and fixtures were removed; no real packages
      installed. A live dry-run of these modules and prerequisites reported
      0 installed, 0 planned, 10 skipped, 0 failed.
- [x] Pass 22 isolated bootstrap scenario groups across Bash 3.2 and 5.3:
      write-free previews and prerequisite deduplication, invalid names/cycles,
      ordered installation and cleanup, unmasked failures/dependent blocking,
      postcheck failure, unsupported module skips, scoped sudo and apt update
      once per run, missing-Homebrew preview, CPU mappings, synthetic Linux distro
      checks, and fake Homebrew bootstrap with environment initialization.
      ShellCheck and syntax checks passed. Temporary fixtures were removed.
- [x] Run the repaired full `--dry-run` against this Mac using Bash 3.2:
      0 installed, 3 planned, 14 skipped, 0 failed. Plans use current module checks;
      installed-location and version checks still need module-level refinement.
- [x] Pass four stubbed Neovim API scenarios: absent local file, preserved
      externally supplied endpoint, local overrides applied after defaults via a
      custom config path containing spaces, and surfaced invalid-local-file
      errors. Verify the Git ignore rule. Inspect installed LazyVim startup code
      to confirm user options load before plugin initialization. Temporary scripts
      and fixtures were removed; no Neovim/plugin runtime was launched.
- [x] Compare all nine imported Ghostty settings against the live config;
      only the approved change from the absolute tmux path to `tmux` differs.
      File-location precedence checked against upstream documentation. Ghostty
      was not launched; font discovery and GUI executable resolution are pending.
- [x] Pass nine isolated tmux scenarios covering exact session lookup, creation
      and hydration quoting, failed creation/invalid directories, cancelled and
      NUL-delimited fzf selection without `~/dev`, explicit dev-window/pane
      targets, real config parsing/macOS clipboard, simulated Linux clipboard
      fallbacks, and optional TPM under a home path containing spaces. Helper
      tests used a fake tmux command; config tests used a separate temporary
      server. Fixtures/server were cleaned up. Bash/Zsh syntax checks and
      ShellCheck for the Bash helper passed.
- [x] Check syntax for all eight Zsh files and pass ten isolated startup scenarios
      under macOS Zsh 5.9: missing tools/fallback completion, quiet noninteractive
      login, quiet redirected interactive login, deduplicated PATH, local load
      order, cache failure recovery, prompt/completion initialization with correct
      tool arguments and fzf fallback, installed-plugin filtering, Linux batcat
      fallback, and macOS prefix paths containing spaces. Test scripts and
      fixtures were removed; actual Debian/Ubuntu execution remains pending.
- [x] Verify all 15 approved live-file imports byte-for-byte, parse both imported
      JSON files and Starship TOML, and check both profiles reference existing
      packages with Starship listed exactly once. No application was loaded.
- [x] Run Bash syntax checks and ShellCheck on the new wrapper.
- [x] Verify every moved package file's content and executable flags are preserved
      (30 files checked against the Git index).
- [x] Exercise argument parsing, profiles, preview/apply dispatch, and failed
      preflight handling with a non-writing, in-memory Stow stub under Bash 3.2
      (15 checks passed; this does not replace real Stow integration testing).
- [x] Confirm existing GNU Stow 2.4.1 and create approved isolated test fixtures
      outside the live home configuration; no installation was needed.
- [x] Test preview (no target changes), existing `.config` directories, conflicts
      across packages, repeated restow, package/profile selection, and unstow.
- [x] Verify symlink behavior under macOS Bash 3.2 and Homebrew Bash 5.3.
- [ ] Verify symlink behavior on Debian/Ubuntu.
- [ ] Smoke-test application behavior on both operating systems after reconciliation.

### Integration test results

The initial run exposed a GNU Stow 2.4.1 argument-parsing incompatibility:
passing `--` before package names produced `No packages to stow or unstow`.
With explicit approval, the separator was removed from both Stow invocations.
Package names remain validated to begin with an alphanumeric character.

After the fix, 20 real-Stow scenarios passed: the following ten scenarios under
both `/bin/bash` (3.2) and Homebrew Bash (5.3) on macOS:

1. Default common-profile preview makes no target changes.
2. Explicit selection creates file symlinks, preserves real directories and
   executable helpers, and handles repository/target paths containing spaces.
3. Repeated restow preserves the deployed filesystem state.
4. Unstow preview makes no changes.
5. Unstow preserves unrelated files and package sources.
6. Desktop-profile deployment/removal handles all four packages present at the
   time of the integration run (before the Starship import).
7. A real-file conflict prevents deployment of every selected package.
8. A conflicting foreign dangling symlink is preserved.
9. Cross-package destination collisions prevent all deployment.
10. Restow handles added and removed package files.

With `--no-folding`, empty directories can remain after unstow. Tests verify
managed links are removed and unrelated contents are preserved rather than
requiring removal of empty directories.

All temporary scripts and fixture directories were removed. No application
configuration was loaded or deployed to the live home. These results establish
macOS behavior; Debian/Ubuntu execution and application smoke tests remain pending.

## Live activation (separate approval required)

1. Recheck live-versus-repository differences immediately before migration.
2. Agree on a backup directory and exact destination list. Back up individual
   managed files/directories, preserving machine-local files and existing links.
   Never remove all of `~/.config` or `~/.local`.
3. Confirm local overrides and the Ghostty authoritative path are ready.
4. Preview the chosen package/profile set using `./stow.sh`.
5. Resolve only the reported destination conflicts, with explicit approval for
   the required backup/move operations, then repeat the preview.
6. Apply with `./stow.sh --apply` and the same package/profile selection.
7. Verify fresh login and interactive shells, Neovim, tmux, Starship, and Ghostty.
8. Keep `env` and backups until the workflow has been verified on both platforms.
   Stop invoking the old copy-based Makefile for the migrated destinations.

## Rollback

Preview removal of the same packages with `./stow.sh --delete`, then obtain
approval before applying removal and restoring the corresponding backups.
Unstow removes managed links; it does not restore the original live files.
Keep the repository at the same location until its links have been removed.
