/*
Copyright (c) 2016-2023 Timur Gafarov

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

/**
 * Generic sound interfaces and their implementations
 *
 * Copyright: Timur Gafarov 2016-2023.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.audio.sound;

import std.math;
import dlib.audio.sample;

/**
 * Generalized sound stream class.
 * This can be used to implement any type of sound,
 * including compressed audio streams.
 */
abstract class StreamedSound
{
    /// Number of channels per sample
    @property uint channels();

    /// Number of samples per second, in Hz
    @property uint sampleRate();

    /// Number of bits in each sample channel
    @property uint bitDepth();

    /// Number of bytes in each sample (bitDepth / 8 * channels)
    @property uint sampleSize()
    {
        return (bitDepth / 8) * channels;
    }

    /// Sample format
    @property SampleFormat sampleFormat();

    /// Fill in the buffer with next portion of sound data.
    /// Function returns actual number of bytes written.
    /// At the end of a stream, zero is returned.
    ulong stream(ubyte[] buffer);

    /// Return to the start of a stream
    void reset();
}

/**
 * Sound that can be seeked
 */
abstract class SeekableSound: StreamedSound
{
    /// Number of samples
    @property ulong size();

    /// Duration, in seconds
    @property double duration();

    float opIndex(uint chan, ulong pos);
    float opIndexAssign(float sample, uint chan, ulong pos);
}

/**
 * Sound that is fully kept in memory
 */
abstract class Sound: SeekableSound
{
    /// Raw byte data
    @property ref ubyte[] data();

    /// Make exact copy of the sound
    @property Sound dup();

    /// Make empty sound of the same format
    Sound createSameFormat(uint ch, double dur);
}

/**
 * Generic Sound implementation
 */
class GenericSound: Sound
{
    protected:
    ubyte[] _data;
    ulong _size;
    double _duration;
    uint _channels;
    uint _sampleRate;
    uint _bitDepth;
    SampleFormat _format;

    public:
    this(Sound ras)
    {
        auto rasData = ras.data;
        allocateData(rasData.length);
        for(size_t i = 0; i < _data.length; i++)
            _data[i] = rasData[i];
        _size = ras.size;
        _duration = ras.duration;
        _channels = ras.channels;
        _sampleRate = ras.sampleRate;
        _bitDepth = ras.bitDepth;
        _format = ras.sampleFormat;
    }

    this(double dur,
         uint freq,
         uint numChannels,
         SampleFormat f)
    {
        _duration = dur;
        _sampleRate = freq;
        _channels = numChannels;
        _size = cast(ulong)ceil(dur * freq);
        _format = f;
        if (f == SampleFormat.U8 || f == SampleFormat.S8)
            _bitDepth = 8;
        else if (f == SampleFormat.U16 || f == SampleFormat.S16)
            _bitDepth = 16;
        size_t dataSize = cast(size_t)(_size * (numChannels * (_bitDepth / 8)));
        allocateData(dataSize);
    }

    this(size_t dataSize,
         ulong numSamples,
         double dur,
         uint numChannels,
         uint freq,
         uint bitdepth,
         SampleFormat f)
    {
        allocateData(dataSize);
        _size = numSamples;
        _duration = dur;
        _channels = numChannels;
        _sampleRate = freq;
        _bitDepth = bitdepth;
        _format = f;
    }

    override @property ulong size()
    {
        return _size;
    }

    override @property double duration()
    {
        return _duration;
    }

    override @property uint channels()
    {
        return _channels;
    }

    override @property uint sampleRate()
    {
        return _sampleRate;
    }

    override @property uint bitDepth()
    {
        return _bitDepth;
    }

    override @property SampleFormat sampleFormat()
    {
        return _format;
    }

    override @property ref ubyte[] data()
    {
        return _data;
    }

    protected:
    size_t position; // sample position

    protected void allocateData(size_t size)
    {
        _data = new ubyte[size];
    }

    public:
    override ulong stream(ubyte[] buffer)
    {
        size_t ssize = sampleSize();
        size_t bytePos = position * ssize;
        size_t sizeInBytes = cast(size_t)_size * ssize;

        size_t bytesWritten = buffer.length;
        if (bytePos + buffer.length >= sizeInBytes)
            bytesWritten = sizeInBytes - bytePos;

        for(size_t i = bytePos; i < bytePos + bytesWritten; i++)
        {
            buffer[i] = _data[i];
        }

        return bytesWritten;
    }

    override void reset()
    {
        position = 0;
    }

    override float opIndex(uint chan, ulong pos)
    {
        size_t ssize = sampleSize();
        uint sampleChannelSize = _bitDepth / 8;
        ubyte* samplePtr = &_data[cast(size_t)pos * ssize] + chan * sampleChannelSize;
        return toFloatSample(samplePtr, _format);
    }

    override float opIndexAssign(float s, uint chan, ulong pos)
    {
        size_t ssize = sampleSize();
        uint sampleChannelSize = _bitDepth / 8;
        ubyte* samplePtr = &_data[cast(size_t)pos * ssize] + chan * sampleChannelSize;
        fromFloatSample(samplePtr, _format, s);
        return s;
    }

    override @property Sound dup()
    {
        return new GenericSound(this);
    }

    override Sound createSameFormat(uint ch, double dur)
    {
        return new GenericSound(dur, _sampleRate, ch, _format);
    }
}

/**
 * GenericSound object factory
 */
interface GenericSoundFactory
{
    GenericSound createSound(
        size_t dataSize,
        ulong numSamples,
        double dur,
        uint numChannels,
        uint freq,
        uint bitdepth,
        SampleFormat f);
}

/**
 * GenericSoundFactory implementation for Sound class
 */
class DefaultGenericSoundFactory: GenericSoundFactory
{
    GenericSound createSound(
        size_t dataSize,
        ulong numSamples,
        double dur,
        uint numChannels,
        uint freq,
        uint bitdepth,
        SampleFormat f)
    {
        return new GenericSound(
            dataSize,
            numSamples,
            dur,
            numChannels,
            freq,
            bitdepth,
            f
        );
    }
}

private __gshared DefaultGenericSoundFactory _defaultGenericSoundFactory;

/**
 * GenericSoundFactory singleton
 */
DefaultGenericSoundFactory defaultGenericSoundFactory()
{
    if (!_defaultGenericSoundFactory)
        _defaultGenericSoundFactory = new DefaultGenericSoundFactory();
    return _defaultGenericSoundFactory;
}
