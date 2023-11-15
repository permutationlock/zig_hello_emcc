# Zig "Hello, emcc!"

A hello world example that will compile to emscripten targets.
Requires that `emcc` is in your path.

To build for native targets and run:

```Shell
> zig build
> ./zig-out/bin/hello_emcc
Hello, emcc!
```

To build for emscripten and host the application:

```Shell
zig build -Dtarget=wasm32-emscripten
go run server.go
```

Then go to [http://127.0.0.1:8083](http://127.0.0.1:8083) in a browser to
see the output.
