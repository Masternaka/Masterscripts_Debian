# media

Lightweight media tools.

- **clipmkv** — clip an mkv by start/end timestamps
- **mergemkvs** — concatenate every mkv in `~/Videos`
- **stripgeo** — remove GPS/location metadata from images

`clipmkv` and `mergemkvs` use ffmpeg's stream copy: no re-encode, no quality
loss, fast. `stripgeo` edits metadata only, never the image data.

## Requirements

ffmpeg + ffprobe (clipmkv, mergemkvs), exiftool (stripgeo), GNU coreutils.
Optional: `fzf` — `clipmkv`'s file picker uses it when present, else a
numbered list.

```bash
sudo apt install ffmpeg libimage-exiftool-perl   # Debian / Ubuntu
sudo dnf install ffmpeg perl-Image-ExifTool      # Fedora
sudo pacman -S ffmpeg perl-image-exiftool        # Arch
```

## Installation

```bash
git clone https://justaguy.dev/drew/butterscripts.git
cd butterscripts/media
install -m755 clipmkv mergemkvs stripgeo ~/.local/bin
```

Run any of them with `-h` for usage.

## clipmkv

```bash
clipmkv [file]
```

Clips an mkv by start/end timestamps via stream copy. Without an argument it
shows a picker for `~/Videos` (fzf if installed, otherwise a numbered list);
pass a path to skip it. Timestamps accept
`HH:MM:SS`, `MM:SS`, or seconds; a blank value means the file boundary. Output
defaults to `<basename>_clip[N].mkv` next to the source. After each clip you
can take another from the same source without re-running.

Because stream copy can only cut on keyframes, the actual start may land a
fraction earlier than requested — unavoidable without re-encoding.

## mergemkvs

```bash
mergemkvs
```

Concatenates every mkv in `~/Videos` in version-sort order. It probes each
file for duration, codec, resolution, framerate, and audio layout, then warns
before merging if free disk space is short or the inputs' parameters don't
match. After a successful merge it offers to move the sources into a
`sources_<name>/` subfolder.

```
$ mergemkvs
 1  1.mkv                                         0:42    18.4MB
 2  2.mkv                                         2:03   320.1MB
 3  3.mkv                                         0:18     8.0MB
3 files  3:03  346.5MB
output name: project
wrote: /home/drew/Videos/project.mkv

archive 3 sources to sources_project/? [y/N]
```

Inputs must share codec, resolution, framerate, audio layout, and timebase or
the output may have A/V drift — the script warns on mismatch but lets you
proceed.

## stripgeo

Strips GPS tags from images in place, leaving the rest of the metadata
(camera, timestamps) intact.

```bash
stripgeo photo.jpg              # one file
stripgeo ~/Pictures/*.jpg       # a glob
stripgeo -r ~/Pictures          # a directory, recursively
```

Flags:

- `-a, --all` — strip **all** metadata, not just GPS
- `-b, --backup` — keep originals as `<file>_original`
- `-r, --recursive` — descend into directories

By default the original is overwritten so no copy is left holding the
location data. With `-b` the `<file>_original` backups **still contain the
GPS tags** — delete them once you've confirmed the result.

It lists which files carried location data before stripping and verifies the
tags are gone afterward.

---

## License

GPL-2.0 - See [LICENSE](../LICENSE) for details.

## Support

<a href="https://www.buymeacoffee.com/justaguylinux" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy me a coffee" /></a>

## Connect

- [YouTube](https://youtube.com/@justaguylinux)
- [Butterforge](https://justaguy.dev/drew)
- [Discourse](https://lab.justaguylinux.com)
- [Fluxer](https://fluxer.gg/JfcV95PK)
- [Wiki](https://justaguy.wiki)
- [Mastodon](https://fosstodon.org/@justaguylinux)

---

Made with butter by JustAGuyLinux
