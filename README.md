<img align="left" alt="dlib logo" src="https://github.com/gecko0307/dlib/raw/master/logo/dlib-logo.png" height="66" />

dlib is a growing collection of native D language libraries useful for various higher-level projects - such as game engines, rendering pipelines and multimedia applications. It is written in D2 and has no external dependencies aside D's standard library, Phobos. 

dlib is created and maintained by [Timur Gafarov](https://github.com/gecko0307).

[![Travis Build Status](https://travis-ci.org/gecko0307/dlib.svg?branch=master)](https://travis-ci.org/gecko0307/dlib)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/90mrqd6hq7i2twap?svg=true)](https://ci.appveyor.com/project/gecko0307/dlib)
[![DUB Package](https://img.shields.io/dub/v/dlib.svg)](https://code.dlang.org/packages/dlib)
[![DUB Downloads](https://img.shields.io/dub/dm/dlib.svg)](https://code.dlang.org/packages/dlib)
[![License](http://img.shields.io/badge/license-boost-blue.svg)](http://www.boost.org/LICENSE_1_0.txt)
[![Codecov](https://codecov.io/gh/gecko0307/dlib/branch/master/graph/badge.svg)](https://codecov.io/gh/gecko0307/dlib)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/gecko0307/dlib?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Patreon button](https://img.shields.io/badge/patreon-donate-yellow.svg)](http://patreon.com/gecko0307 "Become a Patron!")

If you like dlib, please support its development on [Patreon](https://www.patreon.com/gecko0307) or [Liberapay](https://liberapay.com/gecko0307). You can also make one-time donation via [PayPal](https://www.paypal.me/tgafarov). Thanks in advance!

**Important:** dlib doesn't support macOS. Please, read the [manifesto](https://github.com/gecko0307/dlib/wiki/Why-doesn't-dlib-support-macOS).

What's inside
-------------
Currently dlib contains the following packages:
* dlib.core - basic functionality used by other modules (manual memory management, streams, OOP for structs, etc.)
* dlib.container - generic data structures (GC-free dynamic and associative arrays and more)
* dlib.filesystem - abstract FS interface and its implementations for Windows and POSIX filesystems
* dlib.functional - some functional programming idioms (HOFs, range primitives, etc.)
* dlib.math - linear algebra and numerical analysis (vectors, matrices, quaternions, linear system solvers etc.)
* dlib.geometry - computational geometry (ray casting, primitives, intersection, etc.)
* dlib.image - image processing (8-bit, 16-bit and 32-bit floating point channels, common filters and convolution kernels, resizing, FFT, HDRI, animation, graphics formats I/O: JPEG, PNG/APNG, BMP, TGA, HDR)
* dlib.audio - sound processing (8 and 16 bits per sample, synthesizers, WAV export and import)
* dlib.network - networking and web functionality
* dlib.memory - allocators and memory management functions
* dlib.text - text processing
* dlib.serialization - data serialization (XML and JSON parsers)
* dlib.coding - various data compression and coding algorithms

Supported Compilers
-------------------
dlib is automatically tested for compatibility with latest two releases of DMD and LDC. Older releases formally are not supported, but in practice usually are, to some extent. Minimal compiler frontend version required is 2.079.0 (DMD 2.079.0, LDC 1.9.0). There's no guaranteed support for GDC and other D compilers.

Documentation
-------------
Please, refer to [the wiki](https://github.com/gecko0307/dlib/wiki). Be aware that documentation is currently incomplete. I'm currently running a [Patreon campaign](https://www.patreon.com/gecko0307) to reach $100 funding per month - help me get there to finish the documentation.

For quick support and overall discussions, use [Gitter chat room](https://gitter.im/gecko0307/dlib).

License
-------
Copyright (c) 2011-2019 Timur Gafarov, Martin Cejp, Andrey Penechko, Vadim Lopatin, Nick Papanastasiou, Oleg Baharev, Roman Chistokhodov, Eugene Wissner, Roman Vlasov, Basile Burg, Valeriy Fedotov, Ferhat Kurtulmuş. Distributed under the Boost Software License, Version 1.0 (see accompanying file COPYING or at http://www.boost.org/LICENSE_1_0.txt).

Sponsors
--------
Rafał Ziemniewski, Kumar Sookram, Aleksandr Kovalev, Robert Georges, WebFreak, SARFEX.

Users
-----
* [Dagon](https://github.com/gecko0307/dagon) - 3D game engine for D
* [dmech](https://github.com/gecko0307/dmech) - physics engine
* [Atrium](https://github.com/gecko0307/atrium) - work-in-progress first person puzzle game
* [DlangUI](https://github.com/buggins/dlangui) - native UI toolkit for D
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
