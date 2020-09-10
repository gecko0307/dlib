var gl;
var wasmMemory;

export function glInit(mem, canvas)
{
    wasmMemory = mem;
    gl = canvas.getContext("webgl2");
    return gl;
}

const stringCache = { };
const arrayCache = { };

function getString(bufferOffset, bufferLen)
{
    if (bufferOffset in stringCache)
        return stringCache[bufferOffset];

    const buf = new Uint8Array(wasmMemory.buffer, bufferOffset, bufferLen);
    var s = "";
    for (var i = 0; i < bufferLen; i++) {
        s += String.fromCharCode(buf[i]);
    }
    stringCache[bufferOffset] = s;
    return s;
}

function getFloat32Array(bufferOffset, bufferLen)
{
    if (bufferOffset in arrayCache)
        return arrayCache[bufferOffset];

    const buf = new Float32Array(wasmMemory.buffer, bufferOffset, bufferLen);
    arrayCache[bufferOffset] = buf;
    return buf;
}

const heap = [];
const buffers = [];
const vaos = [];
    
const shaders = [];
const programs = [];
const locations = [];

function glEnable(v)
{
    gl.enable(v);
}

function glDisable(v)
{
    gl.disable(v);
}

function glDepthFunc(f)
{
    gl.depthFunc(f);
}

function glViewport(x, y, w, h)
{
    gl.viewport(x, y, w, h);
}

function glClearColor(r, g, b, a)
{
    gl.clearColor(r, g, b, a);
}

function glClearDepth(d)
{
    gl.clearDepth(d);
}
    
function glClear(mask)
{
    gl.clear(mask); 
}
    
function glCreateBuffer()
{
    buffers.push(gl.createBuffer());
    return buffers.length;
}
    
function glBindBuffer(target, buff)
{
    if (buff == 0)
        gl.bindBuffer(target, null);
    else
        gl.bindBuffer(target, buffers[buff - 1]);
}
    
function glBufferData(target, len, offset, usage)
{
    var buf;
    if (target == gl.ELEMENT_ARRAY_BUFFER)
        buf = new Uint16Array(wasmMemory.buffer, offset, len);
    else
        buf = new Float32Array(wasmMemory.buffer, offset, len);
    gl.bufferData(target, buf, usage);
}
    
function glCreateVertexArray()
{
    vaos.push(gl.createVertexArray());
    return vaos.length;
}
    
function glBindVertexArray(vao)
{        
    if (vao == 0)
        gl.bindVertexArray(null);
    else
        gl.bindVertexArray(buffers[vaos - 1]);
}
    
function glEnableVertexAttribArray(index)
{        
    gl.enableVertexAttribArray(index);
}
    
function glVertexAttribPointer(index, size, type, normalized, stride, offset)
{
    gl.vertexAttribPointer(index, size, type, normalized, stride, offset);
}
    
function glDrawElements(mode, count, type, offset)
{
    gl.drawElements(mode, count, type, offset);
}
    
function glCreateShader(type)
{
    shaders.push(gl.createShader(type));
    return shaders.length;
}
    
function glShaderSource(shader, length, offset)
{
    var code = getString(offset, length);
    gl.shaderSource(shaders[shader - 1], code);
}
    
function glCompileShader(shader)
{
    gl.compileShader(shaders[shader - 1]);
    if (!gl.getShaderParameter(shaders[shader - 1], gl.COMPILE_STATUS))
        console.log(gl.getShaderInfoLog(shaders[shader - 1]));
}
    
function glCreateProgram()
{        
    programs.push(gl.createProgram());
    return programs.length;
}
    
function glAttachShader(program, shader)
{
    gl.attachShader(programs[program - 1], shaders[shader - 1]);
}
    
function glLinkProgram(program)
{
    gl.linkProgram(programs[program - 1]);
}
    
function glUseProgram(program)
{
    if (program == 0)
        gl.useProgram(null);
    else
        gl.useProgram(programs[program - 1])
}
    
function glGetUniformLocation(program, length, offset)
{
    const str = getString(offset, length);
    const loc = gl.getUniformLocation(programs[program - 1], str);
    locations.push(loc);
    return locations.length;
}
    
function glUniformMatrix4fv(location, transpose, offset)
{
    if (location != 0)
    {
        const data = getFloat32Array(offset, 16);
        gl.uniformMatrix4fv(locations[location - 1], transpose, data);
    }
}

export function glSymbols()
{
    return {
        glEnable: glEnable,
        glDisable: glDisable,
        glDepthFunc: glDepthFunc,
        glViewport: glViewport,
        glClearColor: glClearColor,
        glClearDepth: glClearDepth,
        glClear: glClear,
        glCreateBuffer: glCreateBuffer,
        glBindBuffer: glBindBuffer,
        glBufferData: glBufferData,
        glCreateVertexArray: glCreateVertexArray,
        glBindVertexArray: glBindVertexArray,
        glEnableVertexAttribArray: glEnableVertexAttribArray,
        glVertexAttribPointer: glVertexAttribPointer,
        glDrawElements: glDrawElements,
        glCreateShader: glCreateShader,
        glShaderSource: glShaderSource,
        glCompileShader: glCompileShader,
        glCreateProgram: glCreateProgram,
        glAttachShader: glAttachShader,
        glLinkProgram: glLinkProgram,
        glUseProgram: glUseProgram,
        glGetUniformLocation: glGetUniformLocation,
        glUniformMatrix4fv: glUniformMatrix4fv
    }
}

export default
{
}
