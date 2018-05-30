# Docker Image for [mrtazz/checkmake](https://github.com/mrtazz/checkmake)

Tiny ~1 MB Docker image for the Checkmake Makefile linter CLI tool.

```console
$ docker images mandrean/checkmake

REPOSITORY                  TAG                 IMAGE ID            CREATED             SIZE
mandrean/checkmake          latest              7d7100743a1e        23 minutes ago      1.04MB
```

## Usage

#### Show help

```console
$ docker run --rm mandrean/checkmake
```

#### Example

```console
$ docker run --rm -v "${PWD}:/work" -w /work mandrean/checkmake Makefile

  phonydeclared   Target "all" should be           82
                  declared PHONY.
```
