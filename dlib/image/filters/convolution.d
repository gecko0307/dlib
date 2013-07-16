module dlib.image.filters.convolution;

private
{
    import std.algorithm;

    import dlib.image.image;
    import dlib.image.color;
}

SuperImage convolve(SuperImage img, 
                    float[] kernel, 
                    uint kw = 3, 
                    uint kh = 3,
                    float divisor = 1.0f, 
                    float offset = 0.5f,
                    bool normalize = true,
                    bool useAlpha = true)
in
{
    assert(img.data.length);
    assert(kernel.length == kw * kh);
}
body
{
    auto res = img.dup;
    float kernelSum = reduce!((a,b) => a + b)(kernel);

    foreach(y; 0..img.height)
    foreach(x; 0..img.width)
    {
        float alpha = ColorRGBAf(img[x, y]).a;

        ColorRGBAf csum = ColorRGBAf();

        foreach(ky; 0..kh)
        foreach(kx; 0..kw)
        {
            int iy = y + (ky - kh/2);
            int ix = x + (kx - kw/2);

            // Extend
            if (ix < 0) ix = 0;
            if (ix >= img.width) ix = img.width - 1;
            if (iy < 0) iy = 0;
            if (iy >= img.height) iy = img.height - 1;

            // TODO:
            // Wrap

            auto pix = ColorRGBAf(img[ix, iy]);
            auto k = kernel[kx + ky * kw];

            csum += pix * k;
        }

        if (normalize)
        {
            offset = 0.0f;
            divisor = kernelSum;

            if (divisor == 0.0f)
            {
                divisor = 1.0f; 
                offset = 0.5f;
            }

            if (divisor < 0.0f)
                offset = 1.0f;
        }

        csum = csum / divisor + offset;

        if (!useAlpha)
            csum.a = alpha;

        res[x,y] = csum.convert(img.bitDepth);
    }

    return res;
}

// Various convolution kernels
struct Kernel
{
    enum float[]

    Identity = 
    [
        0, 0, 0,
        0, 1, 0,
        0, 0, 0
    ],

    BoxBlur = 
    [
        1, 1, 1,
        1, 1, 1,
        1, 1, 1
    ],

    GaussianBlur = 
    [
        1, 2, 1,
        2, 4, 2,
        1, 2, 1
    ],

    Sharpen = 
    [
        -1, -1, -1,
        -1, 11, -1,
        -1, -1, -1
    ],
    
    Emboss = 
    [
       -1, -1,  0, 
       -1,  0,  1, 
        0,  1,  1, 
    ],
    
    EdgeEmboss = 
    [
        -1.0f, -0.5f, -0.0f,
        -0.5f,  1.0f,  0.5f,
        -0.0f,  0.5f,  1.0f
    ],

    EdgeDetect = 
    [
        -1, -1, -1, 
        -1,  8, -1, 
        -1, -1, -1, 
    ],

    Laplace = 
    [
        0,  1,  0, 
        1, -4,  1, 
        0,  1,  0, 
    ];
}

