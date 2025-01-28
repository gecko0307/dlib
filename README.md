dlib2
=====
This is the development branch of dlib 2.0, the successor of [dlib](https://github.com/gecko0307/dlib), a general-purpose library for D language. Currently it is not usable, you are recommended to use dlib 1.x instead.

Project goals
-------------
* `betterC` and `@nogc` compliancy at different API layers
* Independence from Phobos for core functionality
* Become a minimal standard library: include standard I/O, math, data manipulation, etc
* Extensive unit testing.

Architecture
------------
dlib 2.0 will consist of several API layers:
1. `dcore` - `betterC`-compliant low-level procedural API, a minimal standard library replacement. Completely standalone. Possible support for bare metal/WebAssembly/ARM. Uses only `betterC` parts of Phobos, like `std.traits` and system APIs.
2. `dlib2` - `@nogc` object-oriented API with high-level features. Serves as an abstract interface for system APIs. Will support at least Unix and Windows.
3. `dlib` - classic dlib 0.x/1.x API. As much functionality as possible will go to `dcore` and `dlib2`, this API will be only for backwards compatibility.
4. `dlib3` - a home for experimental/optional features.

Platform support
----------------
dlib 2.0 will support at least Unix and Windows, x86 and x86_64. There is possibility of ARM and WebAssembly support for `dcore`. 

Progress
--------
* [x] `dcore.memory` - memory allocator for D objects (classic `New`/`Delete`)
* [ ] `dcore.stdio` - standard C I/O for platforms that support it
* [ ] `dcore.stdlib` - `malloc/free` for platforms that support it
* [ ] `dcore.math` - highly portable math functions, using hardware optimizations where possible
* [ ] `dcore.random` - presudo-random number generator based on C `rand`
* [x] `dcore.sys` - retrieve system information
* [ ] `dcore.process` - cross-platform process API
* [ ] `dcore.time` - cross-platform date and time API
* [ ] `dcore.thread` - cross-platform multithreading API
* [x] `dcore.mutex` - cross-platform thread synchronization primitive
* [ ] `dcore.linker` - cross-platform dynamic library linker
* [ ] `dcore.text` - string processing, UTF-8 decoder
* [ ] `dcore.container` - `betterC` containers and data structures
