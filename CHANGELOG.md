dlib 0.21.0 beta1 - TBD
-----------------------
- **dlib.text**
  - **Breaking change:** deprecated module `dlib.text.unmanagedstring` has been removed
  - **Breaking change:** deprecated method `String.byDChar` has been removed
  - `UTF16Decoder` and `UTF16Encoder` are deprecated, use `UTF16LEDecoder` and `UTF16LEEncoder` instead
- **dlib.image**
  - **Breaking change:** deprecated module `dlib.image.io.io` has been removed
  - `load` and `save` are deprecated, use `loadImage` and `saveImage` instead
  - `loadAnimated` and `saveAnimated` are deprecated, use `loadAnimatedImage` and `saveAnimatedImage` instead
  - `loadHDRI` and `saveHDRI` are deprecated, use `loadHDRImage` and `saveHDRImage` instead
- **dlib.container**
  - **Breaking change:** deprecated alias `DynamicArray` has been removed
- **dlib.coding**
  - **Breaking change:** deprecated module `dlib.coding.hash` has been removed
- **dlib.audio**
  - `load` and `save` are deprecated, use `loadSound` and `saveSound` instead
- **Misc**
  - Switched from Travis CI to GitHub Actions for running integration tests.

dlib 0.20.0 - 16 Oct, 2020
--------------------------
No changes since dlib 0.20.0 beta1.

dlib 0.20.0 beta1 - 10 Oct, 2020
--------------------------------
- **dlib.image**
  - `dlib.image.io.io` is deprecated, import `dlib.image.io` instead
- **dlib.audio**
  - New package: `dlib.audio.io`
- **dlib.text**
  - `dlib.text.unmanagedstring` is deprecated, use `dlib.text.str` instead
  - `String.byDChar` is deprecated, use `String.decode` instead
  - `UTF8Decoder.byDChar` is deprecated, use `UTF8Decoder.decode` instead
  - `UTF16Decoder.byDChar` is deprecated, use `UTF16Decoder.decode` instead
- **dlib.coding**
  - `dlib.coding.hash` is deprecated, use `std.digest` instead
- **dlib.container**
  - `dlib.container.array.DynamicArray` is deprecated, use `dlib.container.array.Array` instead
- **Documentation**
  - Deploy-ready ddoc documentation for dlib now can be generated from source code using `dub --build=ddox`. It uses [scod](https://code.dlang.org/packages/scod) generator and is hosted [here](https://gecko0307.github.io/dlib/docs/dlib.html). Harbored-mod support has been dropped.
  - Many modules are now documented better.
- **Misc**
  - Added latest DMD (2.094.0, 2.093.1) and LDC (1.23.0) to Travis CI config.

dlib 0.19.2 - 26 Aug, 2020
--------------------------
- A couple of fixes for LDC
- New AppVeyor configuration.

dlib 0.19.1 - 24 July, 2020
---------------------------
- **dlib.network**
  - Fixed compilation under Windows
- **dlib.filesystem**
  - `isFile`, `isDir` properties now work for `StdFileSystem` entries
- **dlib.container**
  - `DynamicArray.readOnlyData`
- **dlib.text**
  - `String.toString` and `String.ptr` are now `const`
- **Misc**
  - Added latest DMD (2.093.0) and LDC (1.22.0) to Travis CI config.

dlib 0.19.0 - 31 May, 2020
--------------------------
Changes since beta2:
- **dlib.coding**, **dlib.filesystem**
  - Deprecation fixes
- **Misc**
  - Added latest DMD (2.092.0) to Travis CI config.

dlib 0.19.0 beta2 - 22 May, 2020
--------------------------------
Changes since beta1:
- **dlib.math**
  - Transformation of a vector with 4x4 matrix now doesn't include affinity check.
  - `dlib.math.transformation.scaling` fix.

dlib 0.19.0 beta1 - 8 May, 2020
-------------------------------
- **dlib.core**
  - New module `dlib.core.mutex`, a thin abstraction over platform-specific thread synchronization primitives.
  - `Thread.sleep`
- **dlib.concurrency**
  - New package that implements a simple thread pool.
- **dlib.image**
  - New module `dlib.image.render.text` that provides `drawText`, a function to render ASCII strings on images.
- **dlib.math**
  - **Breaking change:** deprecated modules `dlib.math.easing`, `dlib.math.smoothstep` have been removed.
  - **Breaking change:** tuple constructor of `Vector` now implicitly extends the last argument to all remaining components if the tuple is smaller than vector. This ensures e.g. `Vector3f(0) == Vector3f(0, 0, 0)`.
- **dlib.geometry**
  - **Breaking change:** deprecated modules `dlib.geometry.bezier`, `dlib.geometry.hermite` have been removed.
- **Breaking change:** deprecated package `dlib.functional` has been removed.
- **dlib.text**
  - `UTF16Encoder` in `dlib.text.utf16`.
  - `String` can now be constructed directly from `InputStream`.
  - **Breaking change:** deprecated property `String.cString` has been removed.
- **dlib.container**
  - `Queue` and `Stack` now use `DynamicArray` internally instead of `LinkedList`.
- **Misc**
  - Added latest DMD (2.091.1, 2.090.1) and LDC (1.21.0, 1.20.0) to Travis CI config.

dlib 0.18.0 - 28 Feb, 2020
--------------------------
No changes since dlib 0.18.0 beta1.

dlib 0.18.0 beta1 - 23 Feb, 2020
--------------------------------
- **dlib.math**
  - All interpolation functions moved to `dlib.math.interpolation`, which is now a package import. It includes `nearest`, `linear`, `bezier`, `catmullrom`, `hermite`, `smoothstep`, `easing` modules. Corresponding old modules (`dlib.math.easing`, `dlib.math.smoothstep`, `dlib.geometry.bezier`, `dlib.geometry.hermite`) are deprecated.
- **dlib.audio**
  - `SawtoothWaveSynth`, `TriangleWaveSynth` in `dlib.audio.synth`.
- **dlib.text**
  - `String` is now always null-terminated.
- **dlib.functional**
  - The whole package is now deprecated.
  - `dlib.functional.hof` module moved to `dlib.math.hof`.
  - `dlib.functional.range` module is deprecated, use `std.range.iota` instead.
- **Misc**
  - Added latest DMD (2.090.1, 2.089.1) and LDC (1.19.0, 1.18.0) to Travis CI config.

dlib 0.17.0 - 21 Oct, 2019
--------------------------
Changes since beta:
- **dlib.container**
  - `dlib.container.array`: iterating over array via `foreach_reverse`.

dlib 0.17.0 beta1 - 5 Oct, 2019
-------------------------------
- **dlib.core**
  - `BufferedStreamReader` in `dlib.core.stream` - a simple input range to read fixed chunks of data from an `InputStream`.
- **dlib.image**
  - **Breaking change:** `dlib.image.compleximage` has been removed.
  - `dlib.image.signal2d` is now fully GC-free.
  - Filtering of indexed images in PNG decoder is now supported (#142).
- **dlib.math**
  - `dlib.math.tensor` now uses `dlib.core.memory` for internal allocations.
  - **Breaking change:** deprecated function `identityQuaternion` has been removed. Use `Quaternion.identity` instead.
- **dlib.geometry**
  - **Breaking change:** deprecated aliases `bezierCurveFunc2D` and `bezierCurveFunc3D` have been removed. Use `bezierVector2` and `bezierVector3` instead.
- **Misc**
  - Added latest DMD (2.088.0, 2.087.1) and LDC (1.17.0, 1.16.0) to Travis CI config.

dlib 0.16.0 - 30 Mar, 2019
--------------------------
No changes since dlib 0.16.0 beta1.

dlib 0.16.0 beta1 - 4 Mar, 2019
-------------------------------
- **dlib.core**
  - `dlib.core.memory`: Memory profiler now reports file and line of each allocation. Now it is enabled in runtime using `enableMemoryProfiler` function.
  - `dlib.core.memory`: `Owner.deleteOwnedObject`.
- **dlib.text**
  - `dlib.text.lexer`: `Lexer.position`.
  - `dlib.text.unmanagedstring`: `String.cString`.
  - **Breaking change:** deprecated module `dlib.text.slicelexer` has been removed.
- **dlib.container**
  - `dlib.container.array`: `DynamicArray.removeFirst`.
  - **Breaking change:** deprecated module `dlib.container.hash` has been removed.
- **dlib.image**
  - **Breaking change:** deprecated module `dlib.image.parallel` has been removed.
- **dlib.math**
  - New module `dlib.math.easing` - some basic easing functions for fancy interpolation.
  - **Breaking change:** deprecated module `dlib.math.fixed` has been removed.
  - `dlib.math.quaternion`: fixed a bug in `Quaternion.rotationAxis`.
- **dlib.geometry**
  - `dlib.geometry.trimesh` not doesn't use GC.
- **dlib.serialization**
  - `dlib.serialization.json` - GC-free JSON parser.
- **dlib.functional**
  - **Breaking change:** deprecated module `dlib.functional.combinators`, `dlib.functional.quantifiers` has been removed.
  - **Breaking change:** deprecated `map`, `filter`, `reduce` functions from `dlib.functional.range` have been removed.
- **Misc**
  - Added latest DMD (2.085.0, 2.084.1) and LDC (1.13.0, 1.14.0) to Travis CI config.

dlib 0.15.0 - 9 Nov, 2018
-------------------------
- **dlib.container**
  - `opSlice` and `$` for `dlib.container.array.DynamicArray`.

dlib 0.15.0 beta1 - 4 Nov, 2018
-------------------------------
- **dlib.core**
  - **Breaking change**: temporarily removed `dlib.core.fiber` due to lacking Windows support. It is now in [fiber branch](https://github.com/gecko0307/dlib/tree/fiber) until finished.
- **dlib.text**
  - New module `dlib.text.unmanagedstring` that provides `String`, a GC-free UTF8 string type based on `DynamicArray`.
  - `UTF16Decoder` in `dlib.text.utf16`, `UTF8Encoder` in `dlib.text.utf8`.
  - `dlib.text.encodings` - a one-stop solution for handling text encodings in generic way. Decoder is any range that outputs `dchar`, encoder is any object that defines `size_t encode(dchar, ubyte[])`.
  - `dlib.text.common` that defines `DECODE_END` and `DECODE_ERROR` for decoders to use.
- **dlib.container**
  - `reserve` and `resize` for `dlib.container.array.DynamicArray` (#151).
  - **Breaking change**: deprecated `dlib.container.aarray` module has been removed. Use `dlib.container.dict` instead.
- **dlib.image**
  - Fixed unintentional fallthrough in `dlib.image.io.saveImage` that caused error on TGA image.
  - More accurate path filling in `dlib.image.canvas`.
  - `dlib.image.parallel` has been deprecated.
- **dlib.math**
  - **Breaking change**: deprecated `dlib.math.affine` module has been removed. Use `dlib.math.transformation` instead.
  - `dlib.math.fixed` has been deprecated.
- **dlib.functional**
  - `dlib.functional.quantifiers` has been deprecated.
  - Free functions in `dlib.functional.range` (`map`, `filter`, `reduce`) have been deprecated. Use corresponding Phobos functions instead.
- **Misc**
  - dlib now can be built with recent GNU D Compiler (GDC). **Note:** `dlib.math.sse` is not supported with GDC.
  - Added latest DMD (2.083.0, 2.082.1) and LDC (1.12.0) to Travis CI config.
  - Support for [harbored-mod](https://github.com/dlang-community/harbored-mod) documentation generator.

dlib 0.14.0 - 9 Jul, 2018
-------------------------
No changes since dlib 0.14.0 beta1.

dlib 0.14.0 beta1 - 8 Jul, 2018
-------------------------------
**Important:** dlib now officially doesn't support macOS. This is an act of protest against [Apple's drop of OpenGL support](https://developer.apple.com/macos/whats-new/#deprecationofopenglandopencl). While you probably still can use dlib's platform-independent and Posix-based functionality under macOS, there's no guarantee that this will continue, and compatibility issues will not be addressed. Read detailed manifesto [here](https://github.com/gecko0307/dlib/wiki/Why-dlib-doesn%27t-support-macOS%3F).

- **dlib.image**
  - **Breaking change:** `SuperImage.pixelFormat` now returns `uint` instead of `PixelFormat`. This allows extending dlib with custom pixel formats while maintaining compatibility with `PixelFormat`. Values from 0 to 255 are reserved for dlib, values 256 and above are application-specific. This change is just a new convention and will not break any existing logics, though explicit cast to `PixelFormat` may be required in some cases. Comparisons such as `img.pixelFormat == PixelFormat.RGB8` will work fine.
  - `PixelFormat.RGBA_FLOAT` is now deprecated, use `FloatPixelFormat.RGBAF32` from `dlib.image.hdri` instead.
  - Saving to HDR is now supported (`saveHDR` functions in `dlib.image.io.hdr`).
  - New filters: `dlib.image.filters.histogram` (generates an image histogram) and `dlib.image.filters.binarization` (image thresholding using Otsu's method).
  - ACES tonemapper (`hdrTonemapACES`) and average luminance function (`averageLuminance`) in `dlib.image.hdri`.
  - Improved `dlib.image.canvas`. Path rasterizer now natively does anti-aliasing. Fixed bug with rendering on non-square images.
- **dlib.audio**
  - Synthesizer framework (`dlib.audio.synth`). It allows to write synthesizers and use them to 'render' sounds, like in DAWs. Three built-in synthesizers are available: `SineWaveSynth`, `SquareWaveSynth`, `FMSynth`. To write actual data to `Sound` objects, two functions are available: `fillSynth` and `mixSynth`.
- **dlib.math**
  - New module `dlib.math.smoothstep` with sigmoid-like functions: `hermiteSmoothstep`, `rationalSmoothstep`.
- **dlib.core**
  - DMD 2.081.0 compatibility fix in `dlib.core.stream`.
- **Misc**
  - Added latest DMD (2.081.0, 2.080.1) and LDC (1.10.0) to Travis CI config. CI builds for macOS were stopped for reason mentioned above.

dlib 0.13.0 - 14 May, 2018
--------------------------
No changes since dlib 0.13.0 beta1.

dlib 0.13.0 beta1 - 9 May, 2018
-------------------------------
- **dlib.async** has been removed for security reasons. Currently there are no active contributors to maintain the package and fix bugs, so it is considered not safe to use due to potential data corruption or loss. There's [async branch](https://github.com/gecko0307/dlib/tree/async) for those who still want to use it, but for new projects it is strongly recommended to consider using more actively developed alternatives, such as [vibe-core](https://code.dlang.org/packages/vibe-core) or [Tanya](https://code.dlang.org/packages/tanya).
- **dlib.image**
  - New module `dlib.image.canvas` that provides `Canvas` class, a vector graphics engine inspired by HTML5 canvas. Currently it supports rasterizing arbitrary polygons and cubic Bezier paths, filled and outlined. It renders to user-provided `SuperImage`.
  - Improved HDR file decoder. Now it supports HDR files with magic string `#?RGBE`.
  - Reinhard and Hable tonemappers in `dlib.image.hdri`: `hdrTonemapReinhard` and `hdrTonemapHable`.
  - New filters in `dlib.image.filters.edgedetect`: `edgeDetectLaplace` and `edgeDetectSobel`.
  - New methods for `Color4f`: `toLinear` and `toGamma`.
  - Fixed bugs in `dlib.image.arithmetics` module.
- **dlib.math**
  - New functions in `dlib.math.vector`: `reflect`, `refract`, `faceforward`.
  - New functions in `dlib.math.utils`: `min2` and `max2`.
- **dlib.geometry**
  - New functions in `dlib.geometry.bezier`: `bezierTangentVector2` and `bezierTangentVector3`.
- **Misc**
  - Added latest DMD (2.080.0, 2.079.1) and LDC (1.9.0, 1.8.0) to Travis CI config.
  - dlib now does CI under Windows using [AppVeyor](https://www.appveyor.com/).

dlib 0.12.2 - 7 Nov, 2017
-------------------------
* Enum constants of type `Vector` now can be assigned to variables.
* Naming of functions in `dlib.geometry.bezier` is changed. `bezier` function is now `bezierCubic`, `bezierCurveFunc2D` is `bezierVector2`, `bezierCurveFunc3D` is `bezierVector3`. There are aliases with old names for backward compatibility.

dlib 0.12.1 - 28 Oct, 2017
--------------------------
* Fixed loading 16-bit PNG images
* Corrected Bézier function.

dlib 0.12.0 - 16 Oct, 2017
--------------------------
No changes since dlib 0.12.0 beta1.

dlib 0.12.0 beta1 - 9 Oct, 2017
-------------------------------
- **dlib.core**
  - New module `dlib.core.ownership` - a Delphi-like object ownership system. Objects are registered to parent object, which automatically deletes them when gets deleted itself. In many cases this can be a convenient trade-off between fully automatic and fully manual memory management.
  - New module `dlib.core.fiber` - initial fibers implementation (Linux-only for now).
- **dlib.container**
  - Containers now use Phobos-conforming method names. Old names are still supported via aliases.
  - `DynamicArray` now supports inserting and removing values by arbitrary indices (`insertKey` and `removeKey`).
  - `~=` operator support for `LinkedList`.
  - Full unittest coverage of `dlib.container.array`.
  - More unittests for `dlib.container.dict`.
- **dlib.image**
  - New class `UnmanagedAnimatedImage` - GC-free counterpart of `AnimatedImage`.
  - **Breaking change:** `dlib.image.tone.contrast` is now `dlib.image.filters.contrast`.
  - `dlib.image.fthread` is now based on `dlib.core.thread`.
- **dlib.filesystem**
  - File access rights in `FileStat`.
  - Nanosecond modification time precision support in `stat` under Posix.
- **dlib.math**
  - New direct solver (`solve`) in `dlib.math.linsolve` based on LUP decomposition.
- **dlib.geometry**
  - Frustum-sphere intersection test (`intersectsSphere`) for `dlib.geometry.frustum`.
- **dlib.coding**
  - **Breaking change:** `dlib.coding.huffman` is merged with `dlib.image.io.jpeg`.
- **Misc**
  - Added latest DMD (2.075.1, 2.076.0) and LDC (1.3.0, 1.4.0) to Travis CI config.

dlib 0.11.1 - 24 May, 2017
--------------------------
* Added `alphaOver` in `dlib.image.color`
* Fixed memory leak in `dlib.image.io.png`
* Deprecation fix: use `dlib.math.transformation` everywhere instead of `dlib.math.affine`.

dlib 0.11.0 - 3 May, 2017
-------------------------
Changes from beta:
* Merged `idct.d` with `jpeg.d`, use `dlib.math.transformation` in `dlib.image.transform`
* Added `hdrTonemapAverageLuminance` to `dlib.image.hdri`
* Fixed memory leak in HDR decoder

dlib 0.11.0 beta1 - 25 Apr, 2017
--------------------------------
- **dlib.core**
  - `New` and `Delete` in `dlib.core.memory` are now based on allocators from `dlib.memory`. By default `Mallocator` is used. It is possible to switch global allocator.
- **dlib.memory**
  - Added `GCallocator`, an allocator based on on D's built-in garbage collector.
- **dlib.image**
  - Full-featured APNG support in `dlib.image.io.png` with dispose and blend operations. Saving animations to APNG is also supported.
- **dlib.filesystem**
  - Added `traverseDir`, GC-free recursive directory scanner.
- **dlib.math**
  - `distance` and `distancesqr` overloads for 2D vectors.
  - `dlib.math.affine` is now deprecated. `dlib.math.transformation` should be used instead.
- **dlib.async**
  - Fixed segfault in event loop.
- **Misc**
  - Removed deprecated `dlib.xml` package. `dlib.serialization.xml` should be used instead.
  - Added latest DMD (2.074.0) and LDC (1.2.0) to Travis CI config.
  - A new logo and homepage for the project: https://gecko0307.github.io/dlib.

dlib 0.10.1 - 14 Mar, 2017
--------------------------
* Animated images and basic APNG support (unfinished, without dispose and blend operations, saving to APNG is also missing)
* Fixed some bugs in `dlib.text.slicelexer` and `dlib.serialization.xml`. `dlib.text.lexer.Lexer` is now an alias to `dlib.text.slicelexer.SliceLexer`
* Added latest DMD (2.073.2) and LDC (1.1.0) to Travis CI config.

dlib 0.10.0 - 23 Jan, 2017
--------------------------
Changes from beta:
- 64-bit fix in `dlib.network.socket` under Windows
- Unittest fix in `dlib.filesystem.local`
- Code cleanup, use consistent line endings and indentations everywhere
- EditorConfig support
- dlib now compiles with DMD 2.073.0 and LDC 1.1.0-beta6.

dlib 0.10.0 beta1 - 13 Jan, 2017
--------------------------------
- **dlib.async** - this new package provides a cross-platform event loop and asynchronous programming capabilities. It can be used to implement asynchronous servers. Under the hood the package is based on different multiplexing APIs: Epoll on Linux, IOCP on Windows, and Kqueue on BSD / OSX
- **dlib.memory** - new tools and interfaces to generalize memory allocation. There is `Allocator` interface, similar to Phobos' `IAllocator`, but simpler. There are also several implementations of this interface: `Mallocator` (malloc based allocator) and `MmapPool` (block based allocator for Posix systems with mmap/munmap support).
- **dlib.serialization** - a new home for XML (and, hopefully, other markup languages in future). `dlib.xml` is deprecated, but left with public imports for compatibility purpose
  - XML parser (`dlib.serialization.xml`) is now fully GC-free
- **dlib.network**
  - `dlib.network.socket`, a cross-platform socket API. Supports Windows and Posix
- **dlib.image**
  - Breaking change: redesign of `dlib.image.hdri` module. Now it supports manual memory allocation and has its own image factories. Also implemented simple tone mapping tool based on gamma compression to convert HDR images to LDR
  - Radiance HDR/RGBE format support (only loading for now)
- **dlib.container**
  - New module - `dlib.container.buffer`, an interface for input/output buffers
  - Fixed some issues in `dlib.container.array`
- **dlib.text**
  - Improved `SliceLexer` (fixed bug with multicharacter delimiters)
  - Added `dlib.text.utils.immutableCopy`
- **dlib.math**
  - `dlib.math.vector.normal` is now `dlib.math.vector.planeNormal`
- **Other improvements**
  - Added latest DMD (2.072.2) to Travis CI config.

Many thanks to [Eugene Wissner](https://github.com/belka-ew) for implementing `dlib.async`, `dlib.memory` and `dlib.network`.

dlib 0.9.2 - 11 Jun, 2016
-------------------------
- Fixed building with DMD 2.071.1

dlib 0.9.1 - 9 Jun, 2016
------------------------
- Added `SliceLexer` in `dlib.text`
- Fixed wrong `opApply` in `DynamicArray` and `Trie`

dlib 0.9.0 - 23 May, 2016
-------------------------
Changes from beta:
- Bugfix and unittests for `ArrayStream`
- Fixed loading of 32-bit BMP with bitfield masks.

dlib 0.9.0 beta1 - 14 May, 2016
-------------------------------
- dlib.network
  - A new package for networking. So far it contains only one module, `dlib.network.url` - an URL parser
- dlib.image
  - 2-dimensional iteration for images. Also there are now `ImageRegion` and `ImageWindowRange` that simplify writing kernel filters
  - `dlib.image.transform` module implements affine transformations for images: translation, rotation and scaling. Transformation with arbitrary 3x3 matrix is also possible
  - Improved BMP and TGA support: new color modes and RLE8 for BMP, saving BMP and TGA
  - Improved `boxBlur`
  - `getPixel` and `setPixe` in `Image` class are now public
- dlib.math
  - New `dlib.math.tensor` module implements generic multidimensional array, both with static and dynamic memory allocation
- dlib.container
  - Improved `LinkedList`, added range interface. Added unittests for `LinkedList` and `DynamicArray`
- dlib.text
  - `UTF8Decoder` and `Lexer` now support range interface. Added unittests for both
- Other improvements
  - Added latest DMD (2.071.0) to Travis CI config, added DUB service files to .gitignore.

dlib 0.8.1 - 13 Feb, 2016
-------------------------
Minor bugfix release: `saveWav` in `dlib.audio.io.wav` now uses `Sound` interface instead of `GenericSound` class.

dlib 0.8.0 - 12 Feb, 2016
-------------------------
Changes from beta:
* Fixed #87

dlib 0.8.0 beta1 - 7 Feb, 2016
------------------------------
* dlib.audio
  * `dlib.audio` is a new package for audio processing. Supports 8 and 16 bits per sample, arbitrary sample rate and number of channels. Includes generic sound interfaces (in-memory and streamed) and their implementations. Read more [here](https://github.com/gecko0307/dlib/wiki/dlib.audio).
  * `dlib.audio.synth` implements some basic sound synthesizers (sine wave and white noise)
  * `dlib.audio.io.wav` - uncompressed RIFF/WAV encoder and decoder
* dlib.image
  * All image filters, arithmetic operations, etc. now support manual memory management
  * New chroma key filter based on Euclidean distance (`dlib.image.filters.chromakey.chromaKeyEuclidean`)
  * New edge detection filter based on morphological gradient (`dlib.image.filters.edgedetect.edgeDetectGradient`)
  * Several important bugfixes (image convolution, lanczos and bicubic resampling, wrong deallocation of empty JPEGImage)
* dlib.core
  * Fixed erroneous deleting uninitialized thread in `dlib.core.thread`
* dlib.filesystem
  * Implemented missing methods in `dlib.filesystem.stdfs.StdFileSystem`: `openForIO`, `openDir`, `createDir`, `remove`. There is a known issue with `remove`: it doesn't delete directories under Windows
* Other improvements
  * Added [HTML documentation generator](https://github.com/gecko0307/dlib/tree/master/gendoc).

dlib 0.7.1 - 2 Dec, 2015
------------------------
Mostly bugfix release.
* Fixed wrong iteration of `dlib.container.dict.Trie`
* `_allocatedMemory` in `dlib.core.memory` is now marked as `__gshared`, thus working correctly with `dlib.core.thread`
* Fixed wrong behaviour of `nextPowerOfTwo` in `dlib.math.utils`
* Ambiguous `rotation` functions in `dlib.math.affine` and `dlib.math.quaternion` are renamed into `rotation2D` and `rotationQuaternion`, respectively
* Added `flatten` method for matrices.

dlib 0.7.0 - 2 Oct, 2015
------------------------
Changes from beta:
* Fixed 64-bit issues
* dlib now compiles with latest LDC
* Continuous integration using Travis-CI: https://travis-ci.org/gecko0307/dlib

dlib 0.7.0 beta1 - 28 Sep, 2015
-------------------------------
* dlib.core
  * Added GC-free, Phobos-independent thread module - `dlib.core.thread`
* dlib.text
  * A new package for GC-free text processing. Includes UTF-8 decoder (`dlib.text.utf8`) and general-purpose lexical analyzer (`dlib.text.lexer`)
* dlib.xml
  * XML parser is now GC-free and based on `dlib.text.lexer`
* dlib.container
  * Added GC-free LinkedList (`dlib.container.linkedlist`), Stack (`dlib.container.stack`), Queue (`dlib.container.queue`)
* dlib.image
  * Fixed segfault with non-transparent indexed PNG loading
* dlib.math
  * Fixed error with instancing of vectors with size larger than 4
* Other improvements
  * Added Travis-CI support

dlib 0.6.4 - 14 Sep, 2015
-------------------------
* Trie-based GC-free dictionary class (`std.container.dict`)
* Several performance optimizations in `dlib.math`: vector element access and multiplication for 3x3 and 4x4 matrices are now faster
* Fixed some 64-bit issues.

dlib 0.6.3 - 17 Aug, 2015
-------------------------
* Fixed `dlib.filesystem.stdfs` compilation under 64-bit systems
* Fixed PNG exporter bug with encoding non-compressible images
* Added basic drawing functions (`dlib.image.render.shapes`)

dlib 0.6.2 - 20 Jul, 2015
-------------------------
Bugfix release.
* Removed coordinates clamping on pixel write in dlib.image
* Fixed bug with PNG vertical flipping

dlib 0.6.1 - 6 Jul, 2015
------------------------
* Added memory profiler
* Fixed `dlib.math.sse` compilation on 64-bit systems

dlib 0.6.0 - 24 Jun, 2015
-------------------------
* dlib.core
  * Got rid of ManuallyAllocatable interface in manual memory management for classes. Added support for deleting via interface or parent class. Deleting can be abstractized with Freeable interface
* dlib.filesystem
  * Added GC-free implementations for FileSystem and file streams
* dlib.image
  * dlib.image.unmanaged provides generalized GC-free Image class with corresponding factory function
  * JPEG decoder had been greatly improved, added more subsampling modes support, COM and APPn markers detection. Decoder now understands virtually any imaginable baseline JPEGs, including those from digital cameras
* dlib.math
  * New module dlib.math.combinatorics with factorial, hyperfactorial, permutation, combinations, lucas number and other functions
  * dlib.math.sse brings x86 SSE-based optimizations for some commonly used vector and matrix operations, namely, 4-vector arythmetics, dot and cross product, 4x4 matrix multiplication.
* dlib.container
  * DynamicArray now supports indexing (as a syntactic sugar).

dlib 0.5.3 - 5 May, 2015
-----------------------
* Added Protobuf-style varint implementation (dlib.coding.varint)
* Streams are now ManuallyAllocatable
* Triangle struct in dlib.geometry.triangle now has tangent vectors
* Fixed unittest build failure (#59)

dlib 0.5.2 - 25 Feb, 2015
-------------------------
* Automated vector type conversion (#57), modulo operator for vectors (#58)
* Fixed warning in dlib.image.io.bmp (#56)

dlib 0.5.1 - 21 Feb, 2015
-------------------------
Small bugfix release:
* Fixed wrong module name in dlib.geometry.frustum
* Updated license information

dlib 0.5.0 - 20 Feb, 2015
-------------------------
* dlib.core
  * Added manual memory management support. dlib.core.memory provide memory allocators based on standard C malloc/free. They can allocate arrays, classes and structs
  * Added prototype-based OOP system for structs (dlib.core.oop) with support for multiple inheritance and parametric polymorphism
* dlib.image
  * Image loaders are now GC-free
  * dlib.image.io.zlib and dlib.image.io.huffman modules are moved to new package dlib.coding. dlib.image.io.bitio moved to dlib.core.
  * Image allocation is based on a factory interface that abstracts over GC or MMM
  * Improved support for indexed PNGs - added alpha channel support
* dlib.container
  * Added GC-free dynamic array implementation (dlib.container.array)
  * BST and AArray now use manual memory management
* dlib.math
  * Quaternion is now based on and interchangeable with Vector via incapsulation
  * Dual quaternion support (dlib.math.dualquaternion)
  * Fixed incorrect dual number `pow` implementation
* dlib.geometry
  * Breaking change: Frustum plane normals are now pointing outside frustum. Also Frustum-AABB intersection API is changed
  * Fixed bugs in AABB and Plane

dlib 0.4.1 - 30 Dec, 2014
-------------------------
* dlib.image
  * Baseline JPEG decoder (dlib.image.io.jpeg)
* dlib.math
  * New matrix printer with proper alignment (a la Matlab)

dlib 0.4.0 - 27 Oct, 2014
-------------------------
* dlib.filesystem
  * Platform-specific modules are now grouped by corresponding packages (dlib.filesystem.windows, dlib.filesystem.posix)
  * `findFiles` is now a free function and can be used with any `ReadOnlyFileSystem`
* dlib.math
  * Implemented LU decomposition for matrices (dlib.math.decomposition)
  * `dlib.math.linear` is now `dlib.math.linsolve`. Added `solveLU`, a new LU-based direct solver
  * Matrix inversion now uses LU decomposition by default (4x performance boost compared to old analytic method). 4x4 affine matrices use an optimized inversion, which is about 6 times faster
  * `dlib.math.utils` now uses `clamp` from latest Phobos if available
  * Removed deprecated functionality
* dlib.core:
  * Moved container modules (bst, linkedlist, etc) from dlib.core to separate package dlib.container. Removed useless dlib.core.method
* Overall: improved compatibility with DMD 2.067.

dlib 0.3.3 - 31 Jul, 2014
-------------------------
Mainly bugfix release. Changes:
* Fixed compilation with DMD 2.066
* Added dlib.geometry.frustum
* Improved dlib.math.quaternion

dlib 0.3.2 - 11 Jun, 2014
-------------------------
Bugfix release. The main improvement is fixed compilation with some versions of LDC.

dlib 0.3.1 - 13 May, 2014
-------------------------
Bugfix release. Changes:
* Improved dlib.image, added interpolated pixel reading
* Added matrix addition and subtraction, tensorProduct now works with any matrix sizes
* Addressed many bugs in dlib.image and dlib.math.

dlib 0.3.0 - 25 Mar, 2014
-------------------------
* dlib.core
  * Added simple yet robust I/O streams (dlib.core.stream), which are completely Phobos-independent
* dlib.filesystem
  * Abstract FS interface and it's implementations for Windows and POSIX filesystems
* dlib.image
  * Breaking change: all pixel I/O is now floating-point (via `Color4f`). This gives an opportunity to define image classes of arbitrary floating-point pixel formats and enables straightforward HDRI: sample 32-bit implementation provided in dlib.image.hdri
  * Pixel iteration now can be done with `row` and `col` ranges
  * Parallel filtering is now easy with dlib.image.parallel. You can add multithreading to your existing filter code with just a few changes
  * Added support for TGA and BMP formats (only loading for now)
  * All image format I/O is now stream-based
* dlib.math
  * Breaking change: matrices in dlib.math.matrix are now column-major
  * Imporved constness support in dlib.math.vector, as well as added unittest to the module. Using new string constructor, vectors now can be parsed from strings (e.g., `"[0, 1, 2]"`)
* Overall improvements & bugfixes
  * Much saner DUB support, addressed some serious problems with building, added configuration for pre-compiling as a static library

dlib 0.2.4 - 12 Dec, 2013
-------------------------
Bugfix release + added support for DMD 2.064 package modules.

dlib 0.2.3 - 6 Dec, 2013
------------------------
Bugfix release. Fixed issues with compiling on 64-bit systems.

dlib 0.2.1 - 20 Nov, 2013
-------------------------
Bugfix release.

dlib 0.2.0 - 11 Oct, 2013
-------------------------
* Added XML parser (alpha quality);
* Massive refactoring of the matrix implementation. All matrix types (Matrix2x2f, Matrix3x3f, Matrix4x4f) are now specializations of generic Matrix!(T,N) struct in dlib.math.matrix;
* Updated dlib.math.dual. Vectors of dual numbers can now be created;
* Added support for Hermite curves (dlib.geometry.hermite).

dlib 0.1.2 - 18 Jul, 2013
-------------------------
* Renamed ColorRGBA and ColorRGBAf into Color4 and Color4f;
* Added support for image convolution. There are several built-in kernels (Identity, BoxBlur, GaussianBlur, Sharpen, Emboss, EdgeEmboss, EdgeDetect, Laplace);
* Added support for HSV color space;
* Added Chroma Keying and Color Pass filters.

dlib 0.1.1 - 13 Jul, 2013
-------------------------
Bugfix release.

dlib 0.1.0 - 13 Jul, 2013
-------------------------
Initial release.

13 Jul, 2013
------------
Project moved to GitHub.

2012-2013
---------
Early development on code.google.com.

28 Sep, 2012
------------
Start as a public project.
