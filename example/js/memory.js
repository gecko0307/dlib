var wasmMemory;

export function memoryInit(mem) 
{
    wasmMemory = mem;
}

const pageSize = (64 * 1024);

function malloc(size)
{
    const offset = wasmMemory.grow(size / pageSize + size % pageSize);
    return offset;
}

function free(buf)
{
    //TODO
}

export function memorySymbols()
{
    return {
        malloc: malloc,
        free: free
    }
}

export default
{
}