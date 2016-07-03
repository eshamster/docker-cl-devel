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

- In my environment, the layout of Emacs is often corrupted
  - This is temporally fixed by Ctrl-l, but very annoying...

---------

## Author

eshamster (hamgoostar@gmail.com)

## Copyright

Copyright (c) 2016 eshamster (hamgoostar@gmail.com)

## License

Distributed under the MIT License
