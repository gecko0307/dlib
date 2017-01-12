[![Build Status](https://travis-ci.org/gecko0307/dlib.svg?branch=master)](https://travis-ci.org/gecko0307/dlib)
dlib
====
[![dlib-logo.png](/logo/dlib-logo.png)](/logo/dlib-logo.png)

dlib is a growing collection of native D language libraries useful for various higher-level projects - such as game engines, rendering pipelines and multimedia applications. It is written in D2 and has no external dependencies aside D's standard library, Phobos.

Read more [here](https://github.com/gecko0307/dlib/wiki).

Currently dlib contains the following packages:

* dlib.async - event loop and asynchronous programming capabilities

* dlib.core - basic functionality used by other modules (manual memory management, streams, OOP for structs, etc.)

* dlib.container - generic data structures (GC-free dynamic and associative arrays and more)

* dlib.filesystem - abstract FS interface and its implementations for Windows and POSIX filesystems

* dlib.functional - some functional programming idioms (HOFs, combiners, quantifiers, etc.)

* dlib.math - linear algebra and numerical analysis (vectors, matrices, quaternions, linear system solvers etc.)

* dlib.geometry - computational geometry (ray casting, primitives, intersection, etc.)

* dlib.image - image processing (8 and 16 bits per channel, floating point operations, filtering, FFT, HDRI, graphics formats support including JPEG and PNG)

* dlib.audio - sound processing (8 and 16 bits per sample, synthesizers, WAV export and import)

* dlib.network - networking and web functionality

* dlib.memory - allocators and memory management functions

* dlib.text - text processing

* dlib.xml - lightweight XML parser (UTF-8)

* dlib.coding - various data compression and coding algorithms

Documentation
-------------
Please, refer to [the wiki](https://github.com/gecko0307/dlib/wiki). Also HTML documentation can be generated from wiki pages using [this](https://github.com/gecko0307/dlib/tree/master/gendoc) set of tools. Be aware that documentation is currently incomplete.

For support and overall discussions, use our [Gitter chat room](https://gitter.im/gecko0307/dlib).

License
-------
Copyright (c) 2011-2017 Timur Gafarov, Martin Cejp, Andrey Penechko, Vadim Lopatin, Nick Papanastasiou, Oleg Baharev, Roman Chistokhodov, Eugene Wissner. Distributed under the Boost Software License, Version 1.0 (see accompanying file COPYING or at http://www.boost.org/LICENSE_1_0.txt).

