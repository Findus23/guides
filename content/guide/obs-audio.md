---
title: "How to stream audio of a single program/game using OBS and PulseAudio"
date: 2020-04-13
categories:
  - audio
  - pulseaudio
  - obs
  - streaming
author: Lukas Winkler
cc_license: true
aliases:
  - /books/how-to-stream-audio-of-a-single-programgame-using-obs-and-pulseaudio
---

You want to stream a game like the Jackbox Party packs to your friends, but use the same computer for voice chat at the same time without that audio appearing on the stream?

Then this might be a solution.
<!--more-->
## Prerequisites

- some Linux distribution (I am doing this on Debian Testing, but it should work anywhere, where PulseAudio is running)
- PulseAudio
- `pavucontrol`
    - you can probably do the same without a GUI or the audio settings of your desktop environment, but `pavucontrol` gives a nice overview
    - you can install it with `sudo apt install pavucontrol` on Debian/Ubuntu
- [OBS](https://obsproject.com/) (or any other program using the audio channel)

### Sources and more Information

This guide is mostly an extended summary of [https://obsproject.com/forum/resources/include-exclude-audio-sources-using-pulseaudio-linux.95/](https://obsproject.com/forum/resources/include-exclude-audio-sources-using-pulseaudio-linux.95/).

## Creating a null sink

### Getting familiar with `pactl`

First we want to take a look at all output channels (or `sinks`):

```bash
➜  ~ pactl list short sinks
1       alsa_output.pci-0000_1f_00.3.iec958-stereo      module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED
2       alsa_output.pci-0000_1d_00.1.hdmi-stereo-extra1 module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED
3       bluez_sink.38_18_4C_BE_25_8B.a2dp_sink  module-bluez5-device.c  s16le 2ch 44100Hz       RUNNING
```

Sink `3` are my bluetooth headphones, so I want to use those later to output all sounds.

In case the naming isn't as obvious in your case, you can look at `pavucontrol` which should show you, which sink you are using at the moment. (While you are playing audio, the last column should also say `RUNNING`)

### Creating a null sink

A null sink is a output channel that doesn't correspond to a hardware device. Later we will use it to tell OBS to only stream audio from this channel.

```bash
➜  ~ pactl load-module module-null-sink
28
```
As `null` is an ugly name, we will set this channel's description to `OBS` (so this is what `pavucontrol` and your desktop environments audio settings will show you).

```bash
➜  ~ pacmd update-sink-proplist null device.description=OBS
➜  ~ pactl list short sinks
1       alsa_output.pci-0000_1f_00.3.iec958-stereo      module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED
2       alsa_output.pci-0000_1d_00.1.hdmi-stereo-extra1 module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED
3       bluez_sink.38_18_4C_BE_25_8B.a2dp_sink  module-bluez5-device.c  s16le 2ch 44100Hz       RUNNING
4       null    module-null-sink.c      s16le 2ch 44100Hz       SUSPENDED
```

## Combining Sinks

Now you could change the output channel of your game to the `OBS` null sink and the audio would be redirected there. Unfortunatly this also means that you won't be able to hear it anymore.

To solve this, we can create a combine-sink to redirect the audio to both channels. The two numbers have to be the IDs of your speaker/headphones and the null sink.


```bash
➜  ~ pactl list short sinks
1       alsa_output.pci-0000_1f_00.3.iec958-stereo      module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED
2       alsa_output.pci-0000_1d_00.1.hdmi-stereo-extra1 module-alsa-card.c      s16le 2ch 44100Hz       SUSPENDED
3       bluez_sink.38_18_4C_BE_25_8B.a2dp_sink  module-bluez5-device.c  s16le 2ch 44100Hz       RUNNING
4       null    module-null-sink.c      s16le 2ch 44100Hz       SUSPENDED

➜  ~ pactl load-module module-combine-sink slaves=3,4
30
```

### Set up OBS

In case you want to stream the newly created null channel, you can right-click the audio in the audio-mixer and select the `OBS` null channel.

### Setting up the audio

Now you can open `pavucontrol` (or audio settings of your desktop environment) and switch to the *Playback* tab. There should be an entry for every program playing audio (the game, the voice chat, etc.). For each of them you can now select your speaker/headphones if only you should hear it (e.g. voice chat), *Simultaneous Output* if the audio should be redirected to the stream and you also want hear it. Or you redirect the audio directly to the `OBS` channel if only the stream should hear it.

You can also set the volume for all programs and channels here.
