---
title: "How to quickly convert file formats"
date: 2023-08-08
categories:
  - collection
  - file formats
author: Lukas Winkler
description: This is a collection of a few useful commands for converting files between formats that I use all the time.
cc_license: true
toc: true
---

This is a collection of a few useful commands for converting files between formats that I use all the time.

<!--more-->

## Audio

### Audio → FLAC

lossless if converting from e.g. WAV

```bash
flac --best input.wav
```

### Audio → Opus

Check [Opus Recommended Settings](https://wiki.xiph.org/Opus_Recommended_Settings) for the ideal bitrate for your use case.
24 Kb/s is a good basis for very small files that are still high quality for voice recordings. Only use `--downmix-mono` if you don't loose information by merging stereo audio to mono.

```bash
opusenc --bitrate 24 --downmix-mono input.wav output.opus
```

## PDFs

### PDF → Extracted Images

```bash
mkdir tmp
pdfimages input.pdf -all tmp/name
```

This will extract all images that are contained in the input pdf to `tmp/name-000.png`, `tmp/name-001.jpg`, etc.

### PDF → PNG

```bash
pdftoppm input.pdf slides -png -scale-to 1080 -progress
```

This will generate images like `slides-1.png` for every page of the PDF with the specified width. With e.g. `-scale-to 3840` one can quickly convert a PDF of presentation slides to images for a high quality 4K video. 

### PDF → compressed PDF

[source](https://askubuntu.com/questions/113544/how-can-i-reduce-the-file-size-of-a-scanned-pdf-file/256449#256449)

Sometimes I have a PDF that is far too large (hundreds of MB for a simple document) because it was generated in an ineffcient way. Using ghostscript can in many cases reduce the file size dramatically while decreasing the quality only a bit.

```bash
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dPrinted=false -dNOPAUSE -dBATCH -sOutputFile=small.pdf input.pdf 
```

Depending on the required quality, `/ebook` can be replaced with one of `/printer`, `/prepress` and `/default` (or `/screen` for a very bad quality). See the [documentation](https://ghostscript.readthedocs.io/en/latest/VectorDevices.html#controls-and-features-specific-to-postscript-and-pdf-input) for more information

### PDF → PDF with OCR

```bash
ocrmypdf -cdr --force-ocr input.pdf ocr.pdf -l deu
```

Check the [documentation](https://ocrmypdf.readthedocs.io/en/latest/cookbook.html) for more information.

