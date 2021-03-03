<img align="left" alt="dlib logo" src="https://github.com/gecko0307/dlib/raw/master/logo/dlib-logo.png" height="66" />

dlib is a high-level general purpose library for D language intended to game engine developers. It provides basic building blocks for writing graphics-intensive applications: containers, data streams, linear algebra and image decoders. 

dlib has no external dependencies aside D's standard library. dlib is created and maintained by [Timur Gafarov](https://github.com/gecko0307).

[![GitHub Actions CI Status](https://github.com/gecko0307/dlib/workflows/CI/badge.svg)](https://github.com/gecko0307/dlib/actions?query=workflow%3ACI)
[![DUB Package](https://img.shields.io/dub/v/dlib.svg)](https://code.dlang.org/packages/dlib)
[![DUB Downloads](https://img.shields.io/dub/dm/dlib.svg)](https://code.dlang.org/packages/dlib)
[![License](http://img.shields.io/badge/license-boost-blue.svg)](http://www.boost.org/LICENSE_1_0.txt)
[![Codecov](https://codecov.io/gh/gecko0307/dlib/branch/master/graph/badge.svg)](https://codecov.io/gh/gecko0307/dlib)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/gecko0307/dlib?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Patreon button](https://img.shields.io/badge/patreon-donate-yellow.svg)](http://patreon.com/gecko0307 "Become a Patron!")

If you like dlib, please support its development on [Patreon](https://www.patreon.com/gecko0307) or [Liberapay](https://liberapay.com/gecko0307). You can also make one-time donation via [PayPal](https://www.paypal.me/tgafarov). Thanks in advance!

**Important:** if you want to use dlib on macOS then, please, first read the [manifesto](https://github.com/gecko0307/dlib/wiki/Why-doesn't-dlib-support-macOS).

What's inside
-------------
Currently dlib consists of the following packages:
* [dlib.core](http://gecko0307.github.io/dlib/docs/dlib/core.html) - basic functionality used by other modules (memory management, streams, threads, etc.)
* [dlib.container](http://gecko0307.github.io/dlib/docs/dlib/container.html) - generic data structures (GC-free dynamic and associative arrays and more)
* [dlib.filesystem](http://gecko0307.github.io/dlib/docs/dlib/filesystem.html) - abstract FS interface and its implementations for Windows and POSIX filesystems
* [dlib.math](http://gecko0307.github.io/dlib/docs/dlib/math.html) - linear algebra and numerical analysis (vectors, matrices, quaternions, linear system solvers, interpolation functions, etc.)
* [dlib.geometry](http://gecko0307.github.io/dlib/docs/dlib/geometry.html) - computational geometry (ray casting, primitives, intersection, etc.)
* [dlib.image](http://gecko0307.github.io/dlib/docs/dlib/image.html) - image processing (8-bit, 16-bit and 32-bit floating point channels, common filters and convolution kernels, resizing, FFT, HDRI, animation, graphics formats I/O: JPEG, PNG/APNG, BMP, TGA, HDR)
* [dlib.audio](http://gecko0307.github.io/dlib/docs/dlib/audio.html) - sound processing (8 and 16 bits per sample, synthesizers, WAV export and import)
* [dlib.network](http://gecko0307.github.io/dlib/docs/dlib/network.html) - networking and web functionality
* [dlib.memory](http://gecko0307.github.io/dlib/docs/dlib/memory.html) - memory allocators
* [dlib.text](http://gecko0307.github.io/dlib/docs/dlib/text.html) - text processing, GC-free strings, Unicode decoding and encoding
* [dlib.serialization](http://gecko0307.github.io/dlib/docs/dlib/serialization.html) - data serialization (XML and JSON parsers)
* [dlib.coding](http://gecko0307.github.io/dlib/docs/dlib/coding.html) - various data compression and coding algorithms
* [dlib.concurrency](http://gecko0307.github.io/dlib/docs/dlib/concurrency.html) - a thread pool.

Supported Compilers
-------------------
dlib is automatically tested for compatibility with latest two releases of DMD and LDC. Older releases formally are not supported, but in practice usually are, to some extent. There's no guaranteed support for GDC and other D compilers.

Documentation
-------------
There are [ddox documentation](https://gecko0307.github.io/dlib/docs/dlib.html) generated from source code (`dub build --build=ddox`) and [GitHub wiki](https://github.com/gecko0307/dlib/wiki). Be aware that documentation is currently incomplete. I'm running a [Patreon campaign](https://www.patreon.com/gecko0307) to reach $100 funding per month - help me get there to finish the documentation.

For quick support and overall discussions, use [Gitter chat room](https://gitter.im/gecko0307/dlib).

License
-------
Copyright (c) 2011-2021 Timur Gafarov, Martin Cejp, Andrey Penechko, Vadim Lopatin, Nick Papanastasiou, Oleg Baharev, Roman Chistokhodov, Eugene Wissner, Roman Vlasov, Basile Burg, Valeriy Fedotov, Ferhat Kurtulmuş. Distributed under the Boost Software License, Version 1.0 (see accompanying file COPYING or at http://www.boost.org/LICENSE_1_0.txt).

Sponsors
--------
Rafał Ziemniewski, Kumar Sookram, Aleksandr Kovalev, Robert Georges, Jan Jurzitza (WebFreak), Rais Safiullin (SARFEX), Benas Cernevicius, Koichi Takio.

Users
-----
* [Dagon](https://github.com/gecko0307/dagon) - 3D game engine for D
* [dmech](https://github.com/gecko0307/dmech) - physics engine
* [Atrium](https://github.com/gecko0307/atrium) - work-in-progress first person puzzle game
* [DlangUI](https://github.com/buggins/dlangui) - native UI toolkit for D
* [rengfx](https://github.com/xdrie/rengfx) - game engine based on raylib
* [Voxelman](https://github.com/MrSmith33/voxelman) - voxel-based game engine
* [Laser Patriarch](http://ludumdare.com/compo/ludum-dare-36/?action=preview&uid=14310) - Ludum Dare 36 participant, a rougelike with random maps
* [Anchovy](https://github.com/MrSmith33/anchovy) - multimedia library for games and graphics apps
* [RIP](https://github.com/LightHouseSoftware/rip) - image processing and analysis library by LightHouse Software
* [GeneticAlgorithm](https://github.com/Hnatekmar/GeneticAlgorithm) - genetic algorithms library
* [Orb](https://github.com/claudemr/orb) - a game/engine with procedural content
* [Leptbag](https://github.com/thotgamma/LeptbagCpp) - physics simulator by Gamma-Lab. Written in C++, but supports D plugins
* [aoynthesizer](https://github.com/AODQ/aoynthesizer) - sound synthesizer based on Lisp-like scripting language
* [D-VXLMapPreview](https://github.com/rakiru/D-VXLMapPreview) - isometric preview generator for Ace of Spades and Iceball maps
* [dlib-webp](https://github.com/georgy7/dlib-webp) - WebP image format decoder based on libwebp
* [SMSFontConverter](https://github.com/Doom2fan/SMSFontConverter) - a program for generating Sega Master System fonts.

If you use dlib, please tell me by email (gecko0307@gmail.com), and I'll add your link to the list.
