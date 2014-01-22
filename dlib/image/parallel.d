module dlib.image.parallel;

private
{
    import std.parallelism;
    import dlib.functional.range;
    import dlib.image.image;
}

/*
 * This module simplifies parallel image processing,
 * allowing to write filters that run faster on multicore processors
 */

alias Range!uint PixRange;

struct Block
{
    uint x1, y1;
    uint x2, y2;
}

/*
 * Applies filter function to an image in parallel.
 * Divides image into blocks, creating a linear array of block min/max coordinates,
 * and then uses std.parallelism on this array to do multithreading job.
 * Parameters:
 * - img - input image
 * - ffunc - filter function that processes a single block
 * - bw, bh - block width and height (optional)
 *
 * Warning: do NOT modify original input image in your ffunc, or all the parallel stuff
 * will be screwed up. Always write pixels to a copy, and use the input image only
 * for reading.
 */
void parallelFilter(
     SuperImage img, 
     void delegate(PixRange blockRow, PixRange blockCol) ffunc, 
     uint bw = 100,
     uint bh = 100)
{
    if (bw > img.width)
        bw = img.width;
    if (bh > img.height)
        bh = img.height;

    uint numBlocksX = img.width / bw + ((img.width % bw) > 0);
    uint numBlocksY = img.height / bh + ((img.height % bh) > 0);

    Block[] blocks = new Block[numBlocksX * numBlocksY];
    foreach(x; 0..numBlocksX)
    foreach(y; 0..numBlocksY)
    {
        uint bx = x * bw;
        uint by = y * bh;

        uint bw1 = bw;
        uint bh1 = bh;

        if ((img.width - bx) < bw)
            bw1 = img.width - bx;
        if ((img.height - by) < bh)
            bh1 = img.height - by;

        blocks[y * numBlocksX + x] = Block(bx, by, bx + bw1, by + bh1);
    }

    foreach(i, ref b; taskPool.parallel(blocks))
    {
        ffunc(range!uint(b.x1, b.x2),
              range!uint(b.y1, b.y2));
    }
}

/*
// Usage:

SuperImage myFilter(SuperImage img)
{
    auto res = img.dup;
    
    img.parallelFilter((PixRange row, PixRange col)
    {
        foreach(x; row)
        foreach(y; col)
        {
            res[x, y] = ... // Set output pixel
        }
    });
    
    return res;
}

*/

