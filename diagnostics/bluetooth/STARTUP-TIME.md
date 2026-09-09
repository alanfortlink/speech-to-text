# How we cut Bluetooth microphone startup time

Measured on a Sony WH-1000XM5 over an Intel AX210, PipeWire 1.6.8, WirePlumber
0.5.17, kernel 7.2.3. Times are after the dictation key press.

| | before | after |
|---|---|---|
| mic link (eSCO) up | 0.7–1.0 s, sometimes never | 0.26–0.49 s |
| first real audio at the daemon | 1.5–1.7 s, or never | 1.06–1.43 s |
| "Listening" in the bar | 2.1 s on a timer, even with no audio | 1.19–1.43 s, only on real audio |

## What changed

| Change | Where it lives | Gain |
|---|---|---|
| Daemon indicator: green on real audio only (RMS > 0.0005 or three consecutive non-silent chunks), no timer | `daemon/sttd.py` | the bar cannot claim to listen to a dead mic |
| WirePlumber profile-switch timeout 500 ms → 50 ms | `~/.local/share/wireplumber/scripts/device/autoswitch-bluetooth-profile.lua` | link up ~0.45 s sooner |
| A2DP auto-connect rule narrowed to the XM5 | `~/.config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf` | no 5 s pages of absent devices at login |
| btusb driver patch `0002` | `/usr/lib/modules/<kernel>/updates/btusb.ko` | mic link no longer comes up silent when a page overlaps it |
| PipeWire bluez5 patches `0001` + `0003` | `~/.local/lib/spa-0.2/bluez5/` via `SPA_PLUGIN_DIR` drop-ins | no stale-error dead takes; back-to-back takes work |

Only the first row is part of this repo. The rest are machine-level and are
described, with patches and measurements, in [HANDOFF.md](HANDOFF.md).

## Why ~0.9 s is the floor

```
key press
0.00 s ─┬─ daemon starts pw-record on camera-effects-mic
        │
        │   Camera Effects notices the client (250 ms poll),
        │   opens its helper stream, WirePlumber waits 50 ms,
        │   then asks BlueZ for the headset profile
        │
0.30 s ─┼─ eSCO link up (the headset must leave sniff mode,
        │   then the radio sets up the synchronous link: ~0.1 s)
        │
        │   headset sends encoded digital silence while its own
        │   mic path starts and mSBC syncs: ~0.5–0.6 s
        │   (measured at the decoder; Linux cannot shorten it)
        │
0.85 s ─┼─ first non-zero samples leave the headset
        │   Camera Effects processing + 50 ms chunking
0.90 s ─┴─ first real audio reaches the daemon
```

What is left on the Linux side is the ~0.25 s before the profile switch is
even requested. The daemon could ask for the headset profile itself when
capture starts, but the WirePlumber autoswitch script only restores a profile
it switched, so the daemon would have to restore A2DP too. Not done.

The headset's silence after link-up and the eSCO setup are hardware. Words
spoken in the first ~0.9 s are lost unless the microphone is already in
hands-free mode, which drops playback to mono, so it is off by default
(`warmMic`).
