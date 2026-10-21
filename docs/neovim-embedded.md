# Arduino and ESP32 in LazyVim

Arduino CLI builds/uploads sketches; Arduino Language Server provides `.ino`
completion, and clangd handles regular C/C++ projects. Tools are installed through
Homebrew (Arduino CLI) and Mason (language servers and clang-format).

## Start a sketch

```sh
arduino-cli sketch new Blink
arduino-cli board list
arduino-cli board listall
```

Create `Blink/sketch.yaml` alongside `Blink/Blink.ino`:

```yaml
default_fqbn: arduino:avr:uno
default_port: /dev/cu.REPLACE_WITH_YOUR_BOARD_PORT
default_port_config:
  baudrate: '115200'
```

Select the FQBN for your actual board:

- Uno R3: `arduino:avr:uno`
- Classic Nano: `arduino:avr:nano` (some clones need
  `arduino:avr:nano:cpu=atmega328old`)
- Generic classic ESP32 Dev Module: `esp32:esp32:esp32`

The ESP32 example is not for S2/S3/C3 boards. Confirm your module and board options
before uploading. `arduino-cli board list` may show an unknown board for USB-serial
adapters; use `board listall` to choose the correct target.

Open the sketch with `nvim Blink/Blink.ino`. Save all edited source buffers before
building (the shortcut saves the current buffer). After changing `default_fqbn`,
restart the Arduino language server or reopen Neovim.

## Shortcuts

| Key | Action |
| --- | --- |
| `<leader>ab` | Build; compiler diagnostics go to quickfix |
| `<leader>au` | Build and upload |
| `<leader>am` | Serial monitor using sketch.yaml port and baud rate |
| `<leader>al` | List connected boards |
| `<leader>cf` | Format with clang-format |

Close the serial monitor with Ctrl-C before uploading so it releases the port.
Use `Serial.begin(115200)` in your sketch to match the example monitor settings.

Equivalent commands, run from the sketch directory:

```sh
arduino-cli compile .
arduino-cli compile --upload .
arduino-cli monitor
arduino-cli lib search ArduinoJson
arduino-cli lib install ArduinoJson
```

## Other embedded C/C++ projects

The clangd extra is enabled. Generate `compile_commands.json` with your build
system so clangd can discover include paths and defines. Vendor SDKs, cross-compiler
adjustments, and hardware debugging need target-specific configuration.
