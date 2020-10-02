dlib2
=====
This is the development branch of dlib 2.0, the successor of [dlib](https://github.com/gecko0307/dlib), a general-purpose library for D language. Currently it is not usable, you are recommended to use dlib 1.x instead.

Project goals
-------------
* `betterC` compliancy
* Become a minimal standard library: include standard I/O, math, data manipulation, etc.
* WebAssembly support?
* ARM/Android support?
* Extensive unit testing

Architecture
------------
dlib2 will consist of two main packages, `dcore` and `dlib`. `dcore` will be minimal low-level standard library replacement with standard I/O, math, data manipulation, etc. `dlib` will be a compatibility layer that implements classic dlib API on top of `dcore`. Main goal is to move as much functionality as possible to `dcore`.

Progress
--------
* [ ] dcore.container
* [ ] dcore.math
* [x] dcore.memory
* [ ] dcore.stdio
* [ ] dcore.text
