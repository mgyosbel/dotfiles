# Go development in Neovim

The Go, test and DAP LazyVim extras are enabled in this configuration.

- **Compiler:** mise shims select Go for the current project. Run `mise install` in each project before opening Neovim.
- **Language server/debugger:** Mason supplies `gopls` and `delve`. Keep them compatible with the project's Go version. For Go 1.27, the verified versions are gopls 0.24.0 and Delve 1.27.0.
- **Linting:** nvim-lint uses `golangcilint` and prefers the binary selected by `mise which golangci-lint`, falling back to Mason. Packages are linted from their own module root, including nested modules. The separate `golangci_lint_ls` server is disabled to avoid duplicate diagnostics.
- **Formatting:** projects with `.golangci.yaml`, `.golangci.yml`, `.golangci.toml` or `.golangci.json` use `golangci-lint fmt --stdin` with that configuration. This requires golangci-lint v2 with formatters configured. Other projects use `goimports` followed by `gofumpt`.
- **Tests:** Neotest runs `go test -v -race -count=1`. It does not load Makefile environment files, enforce coverage thresholds or start integration-test services. Use the project's Make targets for those workflows.
- **Inlay hints:** disabled. Code lenses can be displayed with `<leader>cC` and executed with `<leader>cc`.

## Useful keys

| Key | Action |
| --- | --- |
| `gd` / `gr` / `K` | Definition / references / hover |
| `<leader>ca` / `<leader>cr` | Code action / rename |
| `<leader>cf` | Format buffer |
| `<leader>tr` / `<leader>tt` | Run nearest test / file |
| `<leader>ts` / `<leader>to` | Test summary / output |
| `<leader>db` / `<leader>td` | Toggle breakpoint / debug nearest test |

For service entry points containing multiple Go files, select **Debug Package** in the DAP configuration picker. Supply service-specific environment variables before launching Neovim, or through a project `.vscode/launch.json`.

## Maintenance

Use `:Mason` for editor tools and `:Lazy` for plugins. Updating plugins does not update Mason tools. Neotest must include the Neovim 0.12 Tree-sitter compatibility fix; the verified revision is recorded in `lazy-lock.json`.

Inspect the active setup using `:ConformInfo`, `:LazyFormatInfo`, `:checkhealth neotest-golang`, and:

```vim
:lua print(vim.fn.exepath("go"))
:lua print(vim.fn.system({"go", "version"}))
:lua print(vim.fn.exepath("gopls"))
:lua print(require("lint").linters.golangcilint().cmd)
```
