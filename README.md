dlib
====
[![dlib-logo.png](/logo/dlib-logo.png)](/logo/dlib-logo.png)

dlib is a growing collection of native D language libraries useful for various higher-level projects - such as game engines, rendering pipelines and multimedia applications. It is written in D2 and has no external dependencies aside D's standard library, Phobos.

Currently dlib contains the following packages:

* dlib.core - basic functionality used by other modules (manual memory management, streams, OOP for structs, etc.)

* dlib.container - generic data structures (GC-free dynamic and associative arrays and more)

* dlib.filesystem - abstract FS interface and its implementations for Windows and POSIX filesystems

* dlib.functional - some functional programming idioms (HOFs, combiners, quantifiers, etc.)

* dlib.math - linear algebra and numerical analysis (vectors, matrices, quaternions, linear system solvers etc.)

* dlib.geometry - computational geometry (ray casting, primitives, intersection, etc.)

* dlib.image - image processing (8 and 16-bits per channel, floating point operations, filtering, FFT, HDRI, graphics formats support including JPEG and PNG)

* dlib.xml - lightweight XML parser (UTF-8)

* dlib.coding - various data compression and coding algorithms

Documentation
-------------
Please, refer to [the wiki](https://github.com/gecko0307/dlib/wiki).

For support and overall discussions, use our [Gitter chat room](https://gitter.im/gecko0307/dlib).

License
-------
Copyright (c) 2011-2015 Timur Gafarov, Martin Cejp, Andrey Penechko, Vadim Lopatin, Nick Papanastasiou. Distributed under the Boost Software License, Version 1.0. (See accompanying file COPYING or at http://www.boost.org/LICENSE_1_0.txt)

