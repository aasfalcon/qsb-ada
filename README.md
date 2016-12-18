SampleBrowser (Ada library)
===========================

Sound sample browser and previewer.

Mainly for linux, but cross-platform code is used as much as possible, so the porting to other operating system shouldn't be hard.

This is a separate experimental Ada sound library project intended to be merged into master, when done.

Build Instructions
------------------

**Warning**: *this is early alpha version*. 

Ada dependencies:

| Library | Package           | Purpose    |
|---------|-------------------|------------|
| AUnit   | libaunit3.7.2-dev | Unit tests |

Install command (Debian):

```
sudo apt-get install libaunit3.7.2-dev
```

### BUILD

```
git clone --depth=1 https://github.com/aasfalcon/qsb-ada
mkdir qsb-ada/build && cd qsb-ada/build
cmake ..
make check
```

### INSTALL
Installation command:

```
sudo make install
```

## Change Log

- 0.2.1 - Ada library subproject started
- 0.2.0 - Started Qt/C++ rewrite
- 0.1.1 - Added waveform image display
- 0.1.0 - Initial [Python-based prototype](https://github.com/aasfalcon/psb) with modified QT file dialog

## License

_Copyright (C) 2016-2017  Andy S._

> *This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.*

> *This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.*

> *You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.*

See [LICENSE.md](LICENSE.md) for full license text.