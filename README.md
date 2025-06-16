# Heaps-BMS
_High Performance Game Framework_

[![Build Status](https://travis-ci.org/HeapsIO/heaps.svg?branch=master)](https://travis-ci.org/HeapsIO/heaps)
[![](https://img.shields.io/discord/162395145352904705.svg?logo=discord)](https://discordapp.com/invite/sWCGm33)

[![Heaps.io logo](https://raw.githubusercontent.com/Sethbones/heaps-BMS/refs/heads/master/logo.png)](http://heaps.io)

**Heaps-BMS** is a cross platform graphics engine designed for high performance games. It's designed to leverage modern GPUs that are commonly available on desktop, mobile and consoles.

Heaps-BMS natively works on:
- HTML5 (requires WebGL)
- Desktop with OpenGL (Win/Linux/OSX) or DirectX (Windows/Proton only)

with the following requiring manual implementation
- Mobile (iOS, tvOS and Android)
- Consoles (Nintendo Switch, Sony PS4, XBox One - requires being a registered developer)


Community
---------

Chat about it in the Haxe Discord <https://discord.gg/sWCGm33>

Samples
-------

being reworked
In order to compile the samples, go to the `samples` directory and run `haxe gen.hxml`, this will generate a `build` directory containing project files for all samples.

To compile:
- For JS/WebGL: run `haxe [sample]_js.hxml`, then open `index.html` to run
- For [HashLink](https://hashlink.haxe.org): run `haxe [sample]_hl.hxml` then run `hl <sample>.hl` to run (will use SDL, replace `-lib hlsdl` by `-lib hldx` in hxml to use DirectX)
- For Consoles, contact them: nicolas@haxe.org

Project files for [Visual Studio Code](https://code.visualstudio.com/) are also generated.

Get started!
------------
being reworked
* [Installation](https://heaps.io/documentation/installation.html)
* [Live samples with source code](https://heaps.io/samples/)
* [Documentation](https://heaps.io/documentation/home.html)
* [API documentation](https://heaps.io/api/)
