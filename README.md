# Speech to Text

Dictation for Omarchy: press a key, talk, press it again, and the words are pasted where your cursor is. A live waveform and the words as they are recognised show in the bar while you talk; every recording is kept with its text so you can play it back, copy or paste it again.

> Tested only on **Omarchy 4** (Arch Linux, Hyprland, omarchy-shell).

## What you get

- **One key per language** (default: `SUPER ALT D` for English; set your own in Settings). Press to start, press again to stop and paste. Esc discards.
- **+ Return** per language: also press Return after pasting (for chat boxes and prompts).
- **Ask your agent**: a second key per language hands the text to Omarchy's default coding agent (`omarchy default agent`) instead of pasting it.
- **Live waveform and live text** in the bar: yellow while the microphone connects, green while it listens; the bar goes back to the icon the moment the text is pasted.
- **Stop is instant**: the recording is transcribed at every pause while you talk, so only the last phrase is left when you stop.
- **History** of every recording (text + audio) with play, copy, paste, paste-and-send and delete, searchable, in the bar popup.
- **Languages** picked from Whisper's list; the model a language needs is downloaded by itself the first time (about 150 MB for the default model; the bar shows the progress). English-only models are swapped for the multilingual one.
- **Engine**: Omarchy's own dictation engine, [voxtype](https://github.com/peteonrails/voxtype) (local Whisper), by default, so there is nothing new to install. whisper.cpp (`whisper-cli`) and any custom command are also supported (Settings → Advanced).
- **Safe key bindings**: a key that anything else already uses is refused, never taken over.
- Local only. Nothing leaves your machine.

## Install

```bash
omarchy plugin add https://github.com/alanfortlink/speech-to-text.git --enable
```

That is all: the microphone icon appears in the bar, the daemon starts with the shell and applies the key bindings itself (nothing in `~/.config/hypr` is touched).

Optional: `~/.config/omarchy/plugins/alanfortlink.speech-to-text/install.sh` puts the `stt` command on your PATH. From a checkout anywhere else, `./install.sh` also links the checkout into the plugins directory (handy for development).

Requires `voxtype` (Omarchy ships it: `omarchy-voxtype-install`), `pipewire`, `wtype`, `wl-clipboard`, `curl`. All present on a stock Omarchy.

## Use

- Press the language's key, talk, press it again. `Esc` discards while recording. The first press for a new language downloads its model; the bar shows "Getting ready…" until it is there.
- Click the microphone icon for History and Settings. Right-click it to start recording; while recording, click the waveform to stop, right-click to discard.
- Settings: one row per language: the Dictate key (click it, press the key; Backspace clears), the + Return switch, and the Ask-agent key. The first row is the default language; use the arrows to reorder. Add languages from the picker.
- `stt` from a terminal: `stt toggle --lang en [--enter]`, `stt status --follow`, `stt history`, `stt paste ID`, `stt set liveText false`.

## Files

| What | Where |
|---|---|
| Config | `~/.config/speech-to-text/config.json` |
| History database and audio | `~/.local/share/speech-to-text/` |
| Models | `~/.local/share/voxtype/models/` (shared with voxtype) |
| Daemon socket and log | `$XDG_RUNTIME_DIR/speech-to-text/` |

## Uninstall

```bash
~/.config/omarchy/plugins/alanfortlink.speech-to-text/install.sh --uninstall
omarchy plugin remove alanfortlink.speech-to-text
```
