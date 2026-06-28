# extract

One command to unpack any common archive format — no more remembering the right
`tar` flags or which tool handles `.7z`.

A small, portable Bash script. No runtime to install; just make it executable.

## Usage

```console
$ ./extract.sh archive.tar.gz
$ ./extract.sh a.zip b.tar.bz2 c.7z      # several at once
```

Install it on your PATH:

```console
$ install -m 755 extract.sh ~/.local/bin/extract
$ extract project.tar.xz
```

## Supported formats

| Extension                | Tool used    |
| ------------------------ | ------------ |
| `.tar.gz` `.tgz`         | `tar`        |
| `.tar.bz2` `.tbz2`       | `tar`        |
| `.tar.xz` `.txz`         | `tar`        |
| `.tar`                   | `tar`        |
| `.gz`                    | `gunzip`     |
| `.bz2`                   | `bunzip2`    |
| `.Z`                     | `uncompress` |
| `.zip`                   | `unzip`      |
| `.7z`                    | `7z`         |
| `.rar`                   | `unrar`      |

If the helper a format needs isn't installed, `extract` says so clearly instead
of failing with a cryptic error.

## License

[MIT](LICENSE)
