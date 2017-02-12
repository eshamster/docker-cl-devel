***This is obsoleted. [docker-cl-devel2](https://github.com/eshamster/docker-cl-devel2) is the successor.***

***Note: This can't be used for automated build in Dockerhub because this includes build for Emacs (that requires change of OS parameter).***

# Dockerfile: cl-devel

[WIP] A Dockerfile to configure Common Lisp development environment.

## Installation

```bash
$ docker pull eshamster/cl-devel
$ docker run -v <a host folder>:/home/dev/work/lisp -it eshamster/cl-devel /bin/bash
```

Note: `/home/dev/work/lisp` is a sym-link to `/home/dev/.roswell/local-projects`

## Description

This mainly consists of ...

- CentOS 6.8
- Roswell
  - The following CL implementations are installed in default
    - sbcl
    - sbcl-bin
    - ccl-bin/1.9
- Emacs 24.5 with slime

## Known issues

- In Docker 1.10, the layout of Emacs is often corrupted
  - Please use Docker 1.11 (or newer version)
    - Please see the issue for more information: <https://github.com/docker/docker/issues/15373>

---------

## Author

eshamster (hamgoostar@gmail.com)

## Copyright

Copyright (c) 2016 eshamster (hamgoostar@gmail.com)

## License

Distributed under the MIT License
