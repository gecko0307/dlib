dlib2
=====
This is the development branch of dlib 2.0, the successor of [dlib](https://github.com/gecko0307/dlib), a general-purpose library for D language. Currently it is not usable, you are recommended to use dlib 1.x instead.

Project goals
-------------
* `betterC` and `@nogc` compliancy at different levels
* Independence from Phobos for core functionality
* Become a minimal standard library: include standard I/O, math, data manipulation, etc
* Extensive unit testing.

Architecture
------------
dlib 2.0 will consist of several API layers:
1. `dcore` - `betterC`-compliant low-level API, a minimal standard library replacement with I/O, math, data manipulation, etc
2. `dlib2` - `@nogc` API with high-level features. 
3. `dlib` - classic dlib 0.x/1.x API. As much functionality as possible will go to `dcore` and `dlib2`, this API will be only for backwards compatibility.
4. Probably `dlib3` - a home for experimental features.

Platform support
----------------
dlib 2.0 will support at least Unix and Windows, x86 and x86_64. There is possibility of ARM/Android support for `dcore`. 

Progress
--------
* [ ] dcore.container
* [ ] dcore.math
* [x] dcore.memory
* [ ] dcore.stdio
* [ ] dcore.text
