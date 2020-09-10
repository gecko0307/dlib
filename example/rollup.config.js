import resolve from "rollup-plugin-node-resolve";
import commonjs from "rollup-plugin-commonjs";
import babel from "rollup-plugin-babel";
import cleanup from "rollup-plugin-cleanup";
import serve from "rollup-plugin-serve";

export default {
    input: "js/main.js",
    output: {
        file: "dist/main.js",
        format: "iife",
        name: "main",
        sourcemap: true
    },
    plugins: [
        resolve(),
        commonjs(),
        babel({
            exclude: "node_modules/**"
        }),
        cleanup(),
        serve({
            contentBase: "dist",
            host: "0.0.0.0",
            port: 8000
        })
    ]
};
