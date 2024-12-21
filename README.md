# Vala Rofi Polkit

![License](https://img.shields.io/badge/license-MIT-blue.svg)

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Overview

A tool crafted to employ Rofi, or any other program executable via a Bash script, as the authentication user interface for Polkit.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/MonadicSpell/vala-rofi-polkit
   ```
2. Navigate into the directory:
   ```bash
   cd vala-rofi-polkit
   ```
3. Build and Install:
   ```bash
   make
   sudo make install # PREFIX=/usr/local
   ```

## Usage

In your .xinitrc, invoke:

```bash
  vala-rofi-polkit bash /usr/local/bin/rofi-polkit.sh &
```

## License

Distributed under the MIT License. See `LICENSE` for more information.
