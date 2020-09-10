import { memoryInit, memorySymbols } from "./memory";
import { glInit, glSymbols } from "./glwrap";

var wasmInstance, wasmMemory;

const canvas = document.getElementById("canv-main");
canvas.width = canvas.clientWidth;
canvas.height = canvas.clientHeight;

const request = new XMLHttpRequest();
request.open('GET', 'main.wasm');
request.responseType = 'arraybuffer';
request.onload = () => {
    const wasmBuffer = request.response;
        
    const importObject = 
    {
        env: {
            consoleLog: console.log,
            ...memorySymbols(),
            ...glSymbols()
        }
    };
    
    WebAssembly.instantiate(wasmBuffer, importObject).then(result => 
    {        
        wasmInstance = result.instance;
        wasmMemory = wasmInstance.exports.memory;
        memoryInit(wasmMemory);
        const gl = glInit(wasmMemory, canvas);
        
        const { exports } = result.instance;
        const ret = exports.test();
        
        console.log(ret);
    });
};

request.send();
