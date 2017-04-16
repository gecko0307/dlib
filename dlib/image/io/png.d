/*
Copyright (c) 2011-2017 Timur Gafarov, Martin Cejp, Vadim Lopatin

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module dlib.image.io.png;

private
{
    import std.stdio;
    import std.math;
    import std.string;
    import std.range;

    import dlib.core.memory;
    import dlib.core.stream;
    import dlib.core.compound;
    import dlib.filesystem.local;
    import dlib.math.utils;
    import dlib.math.interpolation;
    import dlib.coding.zlib;
    import dlib.image.color;
    import dlib.image.image;
    import dlib.image.animation;
    import dlib.image.io.io;
}

// uncomment this to see debug messages:
//version = PNGDebug;

static const ubyte[8] PNGSignature = [137, 80, 78, 71, 13, 10, 26, 10];
static const ubyte[4] IHDR = ['I', 'H', 'D', 'R'];
static const ubyte[4] IEND = ['I', 'E', 'N', 'D'];
static const ubyte[4] IDAT = ['I', 'D', 'A', 'T'];
static const ubyte[4] PLTE = ['P', 'L', 'T', 'E'];
static const ubyte[4] tRNS = ['t', 'R', 'N', 'S'];
static const ubyte[4] bKGD = ['b', 'K', 'G', 'D'];
static const ubyte[4] tEXt = ['t', 'E', 'X', 't'];
static const ubyte[4] iTXt = ['i', 'T', 'X', 't'];
static const ubyte[4] zTXt = ['z', 'T', 'X', 't'];

// APNG chunks
static const ubyte[4] acTL = ['a', 'c', 'T', 'L'];
static const ubyte[4] fcTL = ['f', 'c', 'T', 'L'];
static const ubyte[4] fdAT = ['f', 'd', 'A', 'T'];

enum ColorType: ubyte
{
    Greyscale = 0,      // allowed bit depths: 1, 2, 4, 8 and 16
    RGB = 2,            // allowed bit depths: 8 and 16
    Palette = 3,        // allowed bit depths: 1, 2, 4 and 8
    GreyscaleAlpha = 4, // allowed bit depths: 8 and 16
    RGBA = 6,           // allowed bit depths: 8 and 16
    Any = 7             // one of the above
}

enum FilterMethod: ubyte
{
    None = 0,
    Sub = 1,
    Up = 2,
    Average = 3,
    Paeth = 4
}

struct PNGChunk
{
    uint length;
    ubyte[4] type;
    ubyte[] data;
    uint crc;

    void free()
    {
        if (data.ptr)
            Delete(data);
    }
}

struct PNGHeader
{
    union
    {
        struct
        {
            uint width;
            uint height;
            ubyte bitDepth;
            ubyte colorType;
            ubyte compressionMethod;
            ubyte filterMethod;
            ubyte interlaceMethod;
        };
        ubyte[13] bytes;
    }
}

struct AnimationControlChunk
{
    uint numFrames;
    uint numPlays;

    void readFromBuffer(ubyte[] data)
    {
        *(&numFrames) = *(cast(uint*)data.ptr);
        numFrames = bigEndian(numFrames);
        *(&numPlays) = *(cast(uint*)(data.ptr+4));
        numPlays = bigEndian(numPlays);
    }
}

enum DisposeOp: ubyte
{
    None = 0,
    Background = 1,
    Previous = 2
}

enum BlendOp: ubyte
{
    Source = 0,
    Over = 1
}

struct FrameControlChunk
{
    uint sequenceNumber;
    uint width;
    uint height;
    uint x;
    uint y;
    ushort delayNumerator;
    ushort delayDenominator;
    ubyte disposeOp;
    ubyte blendOp;

    void readFromBuffer(ubyte[] data)
    {
        *(&sequenceNumber) = *(cast(uint*)data.ptr);
        sequenceNumber = bigEndian(sequenceNumber);
        *(&width) = *(cast(uint*)(data.ptr+4));
        width = bigEndian(width);
        *(&height) = *(cast(uint*)(data.ptr+8));
        height = bigEndian(height);
        *(&x) = *(cast(uint*)(data.ptr+12));
        x = bigEndian(x);
        *(&y) = *(cast(uint*)(data.ptr+16));
        y = bigEndian(y);
        *(&delayNumerator) = *(cast(ushort*)(data.ptr+20));
        delayNumerator = bigEndian(delayNumerator);
        *(&delayDenominator) = *(cast(ushort*)(data.ptr+22));
        delayDenominator = bigEndian(delayDenominator);
        disposeOp = data[24];
        blendOp = data[25];
    }
}

struct PNGImage
{
    // Common PNG data
    PNGHeader hdr;
    uint numChannels;
    uint bitDepth;
    uint bytesPerChannel;
    bool isAnimated = false;

    // Data for indexed PNG
    ubyte[] palette;
    ubyte[] transparency;
    uint paletteSize = 0;

    // APNG data
    uint numFrames = 1;
    uint numLoops = 0;
    bool decodingFirstFrame;
    FrameControlChunk frame;

    ZlibDecoder decoder;

    ubyte[] frameBuffer;
    uint frameSize;

    ubyte[] filteredBuffer;
    uint filteredBufferSize;

    void initDecoder()
    {
        ubyte[] buffer;

        if (decoder.buffer.length)
        {
            //Delete(decoder.buffer);
            buffer = decoder.buffer;
        }
        else
        {
            uint bufferLength = hdr.width * hdr.height * numChannels * bytesPerChannel + hdr.height; 
            buffer = New!(ubyte[])(bufferLength);
        }

        decoder = ZlibDecoder(buffer);
    }

    void initFrameBuffer()
    {
        if (frameBuffer.length)
            Delete(frameBuffer);

        if (filteredBuffer.length)
            Delete(filteredBuffer);

        frameBuffer = New!(ubyte[])(hdr.width * hdr.height * numChannels * bytesPerChannel);
        filteredBuffer = New!(ubyte[])(hdr.width * hdr.height * numChannels * bytesPerChannel);
    }

    void free()
    {
        if (decoder.buffer.length)
            Delete(decoder.buffer);

        if (frameBuffer.length)
            Delete(frameBuffer);

        if (filteredBuffer.length)
            Delete(filteredBuffer);

        if (palette.length)
            Delete(palette);

        if (transparency.length)
            Delete(transparency);
    }
}

class PNGLoadException: ImageLoadException
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}

/*
 * Load PNG from file using local FileSystem.
 * Causes GC allocation
 */
SuperImage loadPNG(string filename)
{
    InputStream input = openForInput(filename);
    auto img = loadPNG(input);
    input.close();
    return img;
}

/*
 * Load animated PNG (APNG) from file using local FileSystem.
 * Causes GC allocation
 */
SuperAnimatedImage loadAPNG(string filename)
{
    InputStream input = openForInput(filename);
    auto img = loadAPNG(input);
    input.close();
    return img;
}

/*
 * Save PNG to file using local FileSystem.
 * Causes GC allocation
 */
void savePNG(SuperImage img, string filename)
{
    OutputStream output = openForOutput(filename);
    Compound!(bool, string) res = savePNG(img, output);
    output.close();

    if (!res[0])
        throw new PNGLoadException(res[1]);
}

/*
 * Load PNG from stream using default image factory.
 * Causes GC allocation
 */
SuperImage loadPNG(InputStream istrm)
{
    Compound!(SuperImage, string) res =
        loadPNG(istrm, defaultImageFactory);
    if (res[0] is null)
        throw new PNGLoadException(res[1]);
    else
        return res[0];
}

/*
 * Load animated PNG (APNG) from stream using default animated image factory.
 * Causes GC allocation
 */
SuperAnimatedImage loadAPNG(InputStream istrm)
{
    Compound!(SuperImage, string) res =
        loadPNG(istrm, animatedImageFactory);
    if (res[0] is null)
        throw new PNGLoadException(res[1]);
    else
        return cast(SuperAnimatedImage)res[0];
}

/*
 * Load PNG from stream using specified image factory.
 * GC-free
 */
Compound!(SuperImage, string) loadPNG(
    InputStream istrm,
    SuperImageFactory imgFac)
{
    PNGImage png;

    SuperImage img = null;
    SuperAnimatedImage animImg = null;
    SuperImage tmpImg = null;

    void finalize()
    {
        png.free();

        // don't close the stream, just release our reference
        istrm = null;
    }

    Compound!(SuperImage, string) error(string errorMsg)
    {
        finalize();
        if (img)
        {
            img.free();
            img = null;
        }
        if (tmpImg)
        {
            tmpImg.free();
            tmpImg = null;
        }
        return compound(img, errorMsg);
    }

    ubyte[8] signatureBuffer;

    if (!istrm.fillArray(signatureBuffer))
    {
        return error("loadPNG error: signature check failed");
    }

    version(PNGDebug)
    {
        writeln("----------------");
        writeln("PNG Signature: ", signatureBuffer);
        writeln("----------------");
    }

    bool endChunk = false;
    while (!endChunk && istrm.readable)
    {
        PNGChunk chunk;
        auto res = readChunk(&png, istrm, &chunk);

        if (!res[0])
        {
            chunk.free();
            return error(res[1]);
        }
        else
        {
            if (chunk.type == IEND)
            {
                endChunk = true;
                chunk.free();
            }
            else if (chunk.type == IHDR)
            {
                res = readIHDR(&png, &chunk);
                chunk.free();
                if (!res[0])
                {
                    return error(res[1]);
                }

                png.decodingFirstFrame = true;
                png.frame.width = png.hdr.width;
                png.frame.height = png.hdr.height;
                png.frame.x = 0;
                png.frame.y = 0;

                png.initFrameBuffer();
                png.initDecoder();
            }
            else if (chunk.type == IDAT)
            {
                png.decoder.decode(chunk.data);
                chunk.free();
            }
            else if (chunk.type == PLTE)
            {
                png.palette = chunk.data;
            }
            else if (chunk.type == tRNS)
            {
                png.transparency = chunk.data;

                if (png.hdr.colorType == ColorType.Palette)
                {
                    if (png.transparency.length > 0)
                        png.numChannels = 4;
                    else
                        png.numChannels = 3;
                }

                version(PNGDebug)
                {
                    writefln("transparency.length = %s", png.transparency.length);
                }

                png.initFrameBuffer();
                png.initDecoder();
            }
            else if (chunk.type == acTL)
            {
                AnimationControlChunk animControl;
                animControl.readFromBuffer(chunk.data); 
                png.numFrames = animControl.numFrames;
                png.numLoops = animControl.numPlays;
                png.isAnimated = true;

                version(PNGDebug)
                {
                    writefln("numFrames = %s", png.numFrames);
                    writefln("numLoops = %s", png.numLoops);
                }

                chunk.free();
            }
            else if (chunk.type == fcTL)
            {
                png.frame.readFromBuffer(chunk.data);

                version(PNGDebug)
                {
                    writefln("sequenceNumber = %s", png.frame.sequenceNumber);
                    writefln("frameWidth = %s", png.frame.width);
                    writefln("frameHeight = %s", png.frame.height);
                    writefln("frameX = %s", png.frame.x);
                    writefln("frameY = %s", png.frame.y);
                    writefln("disposeOp = %s", cast(DisposeOp)png.frame.disposeOp);
                    writefln("blendOp = %s", cast(BlendOp)png.frame.blendOp);
                }

                png.initDecoder();

                chunk.free();
            }
            else if (chunk.type == fdAT)
            {
                uint dataSequenceNumber;
                *(&dataSequenceNumber) = *(cast(uint*)chunk.data.ptr);
                dataSequenceNumber = bigEndian(dataSequenceNumber);

                png.decoder.decode(chunk.data[4..$]);
                chunk.free();
            }
            else
            {
                chunk.free();
            }

            version(PNGDebug)
            {
                writeln("----------------");
            }
        }

        if (png.decoder.hasEnded)
        {
            if (img is null)
            {
                tmpImg = imgFac.createImage(png.hdr.width, png.hdr.height, png.numChannels, png.bitDepth);
                img = imgFac.createImage(png.hdr.width, png.hdr.height, png.numChannels, png.bitDepth, png.numFrames);

                if (png.isAnimated)
                    animImg = cast(SuperAnimatedImage)img;
            }

            res = fillFrameBuffer(&png);
            if (res[0])
            {
                if (png.decodingFirstFrame)
                {
                    png.decodingFirstFrame = false;

                    if (tmpImg.data.length != png.frameBuffer.length)
                    {
                        return error("loadPNG error: uncompressed data length mismatch");
                    }

                    tmpImg.data[] = png.frameBuffer[0..png.frameSize];
                    img.data[] = tmpImg.data[];

                    if (animImg)
                    {
                        disposeFrame(&png, animImg, tmpImg, true);
                    }
                }
                else
                {
                    blitFrame(&png, png.frameBuffer, tmpImg);

                    img.data[] = tmpImg.data[];

                    uint f = animImg.currentFrame;
                    animImg.currentFrame = f - 1;
                    disposeFrame(&png, animImg, tmpImg, false);
                    animImg.currentFrame = f;
                }

                if (animImg)
                {
                    if (animImg.currentFrame == animImg.numFrames-1)
                    {
                        // Last frame, stop here
                        animImg.currentFrame = 0;
                        break;
                    }
                }
            }
            else
            {
                return error(res[1]);
            }

            if (animImg)
            {
                animImg.advanceFrame();
            }
            else
            {
                // Stop decoding if we don't need animation
                break;
            }
        }
    }

    finalize();
    return compound(img, "");
}

/*
 * Load animated PNG (APNG) from stream using specified image factory.
 * GC-free
 */
Compound!(SuperAnimatedImage, string) loadAPNG(
    InputStream istrm,
    SuperImageFactory imgFac)
{
    SuperAnimatedImage img = null;
    auto res = loadPNG(istrm, imgFac);
    if (res[0])
        img = cast(SuperAnimatedImage)res[0];
    return compound(img, res[1]);
}

/*
 * Save PNG to stream.
 * GC-free
 */
Compound!(bool, string) savePNG(SuperImage img, OutputStream output)
in
{
    assert (img.data.length);
}
body
{
    Compound!(bool, string) error(string errorMsg)
    {
        return compound(false, errorMsg);
    }

    if (img.bitDepth != 8)
        return error("savePNG error: only 8-bit images are supported by encoder");

    bool writeChunk(ubyte[4] chunkType, ubyte[] chunkData)
    {
        PNGChunk hdrChunk;
        hdrChunk.length = cast(uint)chunkData.length;
        hdrChunk.type = chunkType;
        hdrChunk.data = chunkData;
        hdrChunk.crc = crc32(chain(chunkType[0..$], hdrChunk.data));

        if (!output.writeBE!uint(hdrChunk.length)
            || !output.writeArray(hdrChunk.type))
            return false;

        if (chunkData.length)
            if (!output.writeArray(hdrChunk.data))
                return false;

        if (!output.writeBE!uint(hdrChunk.crc))
            return false;

        return true;
    }

    bool writeHeader()
    {
        PNGHeader hdr;
        hdr.width = networkByteOrder(img.width);
        hdr.height = networkByteOrder(img.height);
        hdr.bitDepth = 8;
        if (img.channels == 4)
            hdr.colorType = ColorType.RGBA;
        else if (img.channels == 3)
            hdr.colorType = ColorType.RGB;
        else if (img.channels == 2)
            hdr.colorType = ColorType.GreyscaleAlpha;
        else if (img.channels == 1)
            hdr.colorType = ColorType.Greyscale;
        hdr.compressionMethod = 0;
        hdr.filterMethod = 0;
        hdr.interlaceMethod = 0;

        return writeChunk(IHDR, hdr.bytes);
    }

    output.writeArray(PNGSignature);
    if (!writeHeader())
        return error("savePNG error: write failed (disk full?)");

    //TODO: filtering
    ubyte[] raw = New!(ubyte[])(img.width * img.height * img.channels + img.height);
    foreach(y; 0..img.height)
    {
        auto rowStart = y * (img.width * img.channels + 1);
        raw[rowStart] = 0; // No filter

        foreach(x; 0..img.width)
        {
            auto dataIndex = (y * img.width + x) * img.channels;
            auto rawIndex = rowStart + 1 + x * img.channels;

            foreach(ch; 0..img.channels)
                raw[rawIndex + ch] = img.data[dataIndex + ch];
        }
    }

    ubyte[] buffer = New!(ubyte[])(64 * 1024);
    ZlibBufferedEncoder zlibEncoder = ZlibBufferedEncoder(buffer, raw);
    while (!zlibEncoder.ended)
    {
        auto len = zlibEncoder.encode();
        if (len > 0)
            writeChunk(IDAT, zlibEncoder.buffer[0..len]);
    }

    writeChunk(IEND, []);

    Delete(buffer);
    Delete(raw);

    return compound(true, "");
}

Compound!(bool, string) err(string msg)
{
    return compound(false, msg);
}

Compound!(bool, string) suc()
{
    return compound(true, "");
}

Compound!(bool, string) readChunk(
    PNGImage* png,
    InputStream istrm,
    PNGChunk* chunk)
{
    if (!istrm.readBE!uint(&chunk.length) ||
        !istrm.fillArray(chunk.type))
    {
        return err("loadPNG error: failed to read chunk, invalid PNG stream");
    }

    version(PNGDebug) writefln("Chunk length = %s", chunk.length);
    version(PNGDebug) writefln("Chunk type = %s", cast(char[])chunk.type);

    if (chunk.length > 0)
    {
        chunk.data = New!(ubyte[])(chunk.length);
        if (!istrm.fillArray(chunk.data))
        {
            return err("loadPNG error: failed to read chunk data, invalid PNG stream");
        }
    }

    version(PNGDebug) writefln("Chunk data.length = %s", chunk.data.length);

    if (!istrm.readBE!uint(&chunk.crc))
    {
        return err("loadPNG error: failed to read chunk CRC, invalid PNG stream");
    }

    uint calculatedCRC = crc32(chain(chunk.type[0..$], chunk.data));

    version(PNGDebug)
    {
        writefln("Chunk CRC = %X", chunk.crc);
        writefln("Calculated CRC = %X", calculatedCRC);
    }

    if (chunk.crc != calculatedCRC)
    {
        return err("loadPNG error: chunk CRC check failed");
    }

    return suc();
}

Compound!(bool, string) readIHDR(
    PNGImage* png,
    PNGChunk* chunk)
{
    PNGHeader* hdr = &png.hdr;

    if (chunk.data.length < hdr.bytes.length)
        return err("loadPNG error: illegal header chunk");

    hdr.bytes[] = chunk.data[0..hdr.bytes.length];
    hdr.width = bigEndian(hdr.width);
    hdr.height = bigEndian(hdr.height);

    version(PNGDebug)
    {
        writefln("width = %s", hdr.width);
        writefln("height = %s", hdr.height);
        writefln("bitDepth = %s", hdr.bitDepth);
        writefln("colorType = %s", hdr.colorType);
        writefln("compressionMethod = %s", hdr.compressionMethod);
        writefln("filterMethod = %s", hdr.filterMethod);
        writefln("interlaceMethod = %s", hdr.interlaceMethod);
    }

    bool supportedIndexed =
        (hdr.colorType == ColorType.Palette) &&
        (hdr.bitDepth == 1 ||
         hdr.bitDepth == 2 ||
         hdr.bitDepth == 4 ||
         hdr.bitDepth == 8);

    if (hdr.bitDepth != 8 && hdr.bitDepth != 16 && !supportedIndexed)
        return err("loadPNG error: unsupported bit depth");

    if (hdr.compressionMethod != 0)
        return err("loadPNG error: unsupported compression method");

    if (hdr.filterMethod != 0)
        return err("loadPNG error: unsupported filter method");

    if (hdr.interlaceMethod != 0)
        return err("loadPNG error: interlacing is not supported");

    if (hdr.colorType == ColorType.Greyscale)
        png.numChannels = 1;
    else if (hdr.colorType == ColorType.GreyscaleAlpha)
        png.numChannels = 2;
    else if (hdr.colorType == ColorType.RGB)
        png.numChannels = 3;
    else if (hdr.colorType == ColorType.RGBA)
        png.numChannels = 4;
    else if (hdr.colorType == ColorType.Palette)
    {
        if (png.transparency.length > 0)
            png.numChannels = 4;
        else
            png.numChannels = 3;
    }
    else
        return err("loadPNG error: unsupported color type");

    if (hdr.colorType == ColorType.Palette)
        png.bitDepth = 8;
    else
        png.bitDepth = hdr.bitDepth;

    png.bytesPerChannel = png.bitDepth / 8;

    version(PNGDebug)
    {
        writefln("bytesPerChannel = %s", png.bytesPerChannel);
    }

    return suc();
}

// Apply filtering and substitude palette colors if necessary
Compound!(bool, string) fillFrameBuffer(PNGImage* png)
{
    ubyte[] decodedBuffer = png.decoder.buffer;
    version(PNGDebug) writefln("decodedBuffer.length = %s", decodedBuffer.length);

    bool indexed = (png.hdr.colorType == ColorType.Palette);

    uint calculatedSize;
    if (indexed)
        calculatedSize = png.frame.width * png.frame.height * png.hdr.bitDepth / 8 + png.frame.height;
    else
        calculatedSize = png.frame.width * png.frame.height * png.numChannels + png.frame.height;

    png.frameSize = png.frame.width * png.frame.height * png.numChannels * png.bytesPerChannel;
    png.filteredBufferSize = calculatedSize - png.frame.height;

    version(PNGDebug)
    {
        writefln("calculatedSize = %s", calculatedSize);
        writefln("frameSize = %s", png.frameSize);
        writefln("filteredBufferSize = %s", png.filteredBufferSize);

        writefln("png.frameBuffer.length = %s", png.frameBuffer.length);
    }

    ubyte[] pdata = png.frameBuffer[0..png.frameSize];
    ubyte[] filteredBuffer = png.filteredBuffer[0..png.filteredBufferSize];

    if (decodedBuffer.length != calculatedSize)
    {
        return err("loadPNG error: image size and data mismatch");
    }

    // apply filtering to the image data
    auto res = filter(png, indexed, decodedBuffer, filteredBuffer);
    if (!res[0])
    {
        return err(res[1]);
    }

    // if a palette is used, substitute target colors
    if (indexed)
    {
        if (png.palette.length == 0)
            return err("loadPNG error: palette chunk not found");

        if (png.hdr.bitDepth == 8)
        {
            for (int i = 0; i < filteredBuffer.length; ++i)
            {
                ubyte b = filteredBuffer[i];
                pdata[i * png.numChannels + 0] = png.palette[b * 3 + 0];
                pdata[i * png.numChannels + 1] = png.palette[b * 3 + 1];
                pdata[i * png.numChannels + 2] = png.palette[b * 3 + 2];
                if (png.transparency.length > 0)
                    pdata[i * png.numChannels + 3] =
                        b < png.transparency.length ? png.transparency[b] : 255;
            }
        }
        else // bit depths 1, 2, 4
        {
            int srcindex = 0;
            int srcshift = 8 - png.hdr.bitDepth;
            ubyte mask = cast(ubyte)((1 << png.hdr.bitDepth) - 1);
            int sz = png.frame.width * png.frame.height;
            for (int dstindex = 0; dstindex < sz; dstindex++)
            {
                auto b = ((filteredBuffer[srcindex] >> srcshift) & mask);
                //assert(b * 3 + 2 < palette.length);
                pdata[dstindex * png.numChannels + 0] = png.palette[b * 3 + 0];
                pdata[dstindex * png.numChannels + 1] = png.palette[b * 3 + 1];
                pdata[dstindex * png.numChannels + 2] = png.palette[b * 3 + 2];

                if (png.transparency.length > 0)
                    pdata[dstindex * png.numChannels + 3] =
                        b < png.transparency.length ? png.transparency[b] : 255;

                if (srcshift <= 0)
                {
                    srcshift = 8 - png.hdr.bitDepth;
                    srcindex++;
                }
                else
                {
                    srcshift -= png.hdr.bitDepth;
                }
            }
        }
    }
    else
    {
        pdata[] = filteredBuffer[];
    }

    return suc();
}

void blitFrame(
    PNGImage* png,
    ubyte[] frameBuffer, 
    SuperImage img)
{
    for(uint y = 0; y < png.frame.height; y++)
    {
        for(uint x = 0; x < png.frame.width; x++)
        {
            Color4f c1 = img[png.frame.x + x, png.frame.y + y];
            Color4f c2 = getColor(png, frameBuffer, x, y);

            if (png.frame.blendOp == BlendOp.Source)
                img[png.frame.x + x, png.frame.y + y] = c2;
            else
            {
                Color4f c;
                float a = c2.a + c1.a * (1.0f - c2.a);
                if (a == 0.0f)
                    c = Color4f(0, 0, 0, 0);
                else
                {
                    c = (c2 * c2.a + c1 * c1.a * (1.0f - c2.a)) / a;
                    c.a = a;
                }
                img[png.frame.x + x, png.frame.y + y] = c;
            }
        }
    }
}

void disposeFrame(
    PNGImage* png, 
    SuperImage prevImg,
    SuperImage img,
    bool firstFrame)
{
    if (png.frame.disposeOp != DisposeOp.None)
    for(uint y = 0; y < png.hdr.height; y++)
    {
        for(uint x = 0; x < png.hdr.width; x++)
        {
            if (png.frame.disposeOp == DisposeOp.Previous && !firstFrame)
                img[x, y] = prevImg[x, y];
            else
                img[x, y] = Color4f(0, 0, 0, 0);
        }
    }
}

Color4f getColor(
    PNGImage* png,
    ubyte[] pixData,
    uint x, 
    uint y)
{
    uint bitDepth = png.bitDepth;
    uint channels = png.numChannels;
    uint pixelSize = png.bytesPerChannel * channels;
    uint index = (y * png.frame.width + x) * pixelSize;
    uint maxv = (2 ^^ bitDepth) - 1;

    Color4 res = Color4(0, 0, 0, 0);

    if (channels == 1 && bitDepth == 8)
    {
        auto v = pixData[index];
        res = Color4(v, v, v);
    }
    else if (channels == 2 && bitDepth == 8)
    {
        auto v = pixData[index];
        res = Color4(v, v, v, pixData[index+1]);
    }
    else if (channels == 3 && bitDepth == 8)
    {
        res = Color4(pixData[index], pixData[index+1], pixData[index+2], cast(ubyte)maxv);
    }
    else if (channels == 4 && bitDepth == 8)
    {
        res = Color4(pixData[index], pixData[index+1], pixData[index+2], pixData[index+3]);
    }
    else if (channels == 1 && bitDepth == 16)
    {
        ushort v = pixData[index] << 8 | pixData[index+1];
        res = Color4(v, v, v);
    }
    else if (channels == 2 && bitDepth == 16)
    {
        ushort v = pixData[index]   << 8 | pixData[index+1];
        ushort a = pixData[index+2] << 8 | pixData[index+3];
        res = Color4(v, v, v, a);
    }
    else if (channels == 3 && bitDepth == 16)
    {
        ushort r = pixData[index]   << 8 | pixData[index+1];
        ushort g = pixData[index+2] << 8 | pixData[index+3];
        ushort b = pixData[index+4] << 8 | pixData[index+5];
        ushort a = cast(ushort)maxv;
        res = Color4(r, g, b, a);
    }
    else if (channels == 4 && bitDepth == 16)
    {
        ushort r = pixData[index]   << 8 | pixData[index+1];
        ushort g = pixData[index+2] << 8 | pixData[index+3];
        ushort b = pixData[index+4] << 8 | pixData[index+5];
        ushort a = pixData[index+6] << 8 | pixData[index+7];
        res = Color4(r, g, b, a);
    }
    else
        assert(0);
    
    return Color4f(res, bitDepth);
}

/*
 * Performs the paeth PNG filter from pixels values:
 *   a = back
 *   b = up
 *   c = up and back
 */
pure ubyte paeth(ubyte a, ubyte b, ubyte c)
{
    int p = a + b - c;
    int pa = std.math.abs(p - a);
    int pb = std.math.abs(p - b);
    int pc = std.math.abs(p - c);
    if (pa <= pb && pa <= pc) return a;
    else if (pb <= pc) return b;
    else return c;
}

Compound!(bool, string) filter(
      PNGImage* png,
      bool indexed,
      ubyte[] ibuffer,
      ubyte[] obuffer)
{
    uint width = png.frame.width;
    uint height = png.frame.height;
    uint channels = png.numChannels;

    uint scanlineSize;
    if (indexed)
        scanlineSize = width * png.hdr.bitDepth / 8 + 1;
    else
        scanlineSize = width * channels + 1;

    ubyte pback, pup, pupback, cbyte;

    for (int i = 0; i < height; ++i)
    {
        pback = 0;

        // get the first byte of a scanline
        ubyte scanFilter = ibuffer[i * scanlineSize];

        if (indexed)
        {
            // TODO: support filtering for indexed images
            if (scanFilter != FilterMethod.None)
            {
                return err("loadPNG error: filtering is not supported for indexed images");
            }

            for (int j = 1; j < scanlineSize; ++j)
            {
                ubyte b = ibuffer[(i * scanlineSize) + j];
                obuffer[(i * (scanlineSize-1) + j - 1)] = b;
            }
        }
        else
        for (int j = 0; j < width; ++j)
        {
            for (int k = 0; k < channels; ++k)
            {
                if (i == 0) pup = 0;
                else pup = obuffer[((i-1) * width + j) * channels + k];
                if (j == 0) pback = 0;
                else pback = obuffer[(i * width + j-1) * channels + k];
                if (i == 0 || j == 0) pupback = 0;
                else pupback = obuffer[((i-1) * width + j - 1) * channels + k];

                // get the current byte from ibuffer
                cbyte = ibuffer[i * (width * channels + 1) + j * channels + k + 1];

                // filter, then set the current byte in data
                switch (scanFilter)
                {
                    case FilterMethod.None:
                        obuffer[(i * width + j) * channels + k] = cbyte;
                        break;
                    case FilterMethod.Sub:
                        obuffer[(i * width + j) * channels + k] = cast(ubyte)(cbyte + pback);
                        break;
                    case FilterMethod.Up:
                        obuffer[(i * width + j) * channels + k] = cast(ubyte)(cbyte + pup);
                        break;
                    case FilterMethod.Average:
                        obuffer[(i * width + j) * channels + k] = cast(ubyte)(cbyte + (pback + pup) / 2);
                        break;
                    case FilterMethod.Paeth:
                        obuffer[(i * width + j) * channels + k] = cast(ubyte)(cbyte + paeth(pback, pup, pupback));
                        break;
                    default:
                        return err(format("loadPNG error: unknown scanline filter (%s)", scanFilter));
                }
            }
        }
    }

    return suc();
}

uint crc32(R)(R range, uint inCrc = 0) if (isInputRange!R)
{
    uint[256] generateTable()
    {
        uint[256] table;
        uint crc;
        for (int i = 0; i < 256; i++)
        {
            crc = i;
            for (int j = 0; j < 8; j++)
                crc = crc & 1 ? (crc >> 1) ^ 0xEDB88320UL : crc >> 1;
            table[i] = crc;
        }
        return table;
    }

    static const uint[256] table = generateTable();

    uint crc;

    crc = inCrc ^ 0xFFFFFFFF;
    foreach(v; range)
        crc = (crc >> 8) ^ table[(crc ^ v) & 0xFF];

    return (crc ^ 0xFFFFFFFF);
}

unittest
{
    import std.base64;

    InputStream png() {
        string minimal =
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADklEQVR42mL4z8AAEGAAAwEBAGb9nyQAAAAASUVORK5CYII=";

        ubyte[] bytes = Base64.decode(minimal);
        return new ArrayStream(bytes, bytes.length);
    }

    SuperImage img = loadPNG(png());

    assert(img.width == 1);
    assert(img.height == 1);
    assert(img.channels == 3);
    assert(img.pixelSize == 3);
    assert(img.data == [0xff, 0x00, 0x00]);

    createDir("tests", false);
    savePNG(img, "tests/minimal.png");
    loadPNG("tests/minimal.png");
}

