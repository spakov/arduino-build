# arduino-build
A Makefile and very lightweight infrastructure for managing compilation and
uploading to multiple Arduino boards via the command line.

## Overview
The Makefile, along with the `targets` directory and `TARGET` (described
below), is intended to be placed in a `.build` directory in your Arduino
[sketchbook directory](https://www.arduino.cc/en/Guide/Environment#sketchbook).
Within each sketch in your sketchbook that you'd like to use this
infrastructure to manage, create a new Makefile with an `include` directive
pointing to the Makefile located in the `.build` directory. That would
generally look something like this:

```
include ../.build/Makefile
```

## Prerequisites
- A Linux or UNIX-like system (I'm using MacOS) with common core packages
- GNU make
- bash, zsh or similar (I'm using zsh)
- [arduino-cli](https://github.com/arduino/arduino-cli) (for compiling and
  uploading)
- [HeaderDoc](https://developer.apple.com/library/archive/technotes/tn2339/_index.html),
  or a documentation generator of your choice (for documentation generation)
- screen (for monitoring)

## Makefile targets
Makefile targets (not to be confused with `TARGET`, described below) include
the following:

### all
Default target. Does nothing, but is dependent on doc, compile, upload, and
monitor.

### clean
Deletes generated documentation.

### compile
Compiles the program for upload to the Arduino. This uses arduino-cli to
perform the compilation for the selected `TARGET`.

Specify flags to pass to `arduino-cli compile` using `CFLAGS`.

### doc
Generates documentation for your project. By default, it's configured to use
Apple HeaderDoc to do this (which comes with the Xcode Command Line tools for
MacOS), but you can tailor it to use your preferred documentation generator.

### monitor
Monitors the Arduino's serial output, using screen. To exit screen and detach
the serial device nicely, use `C-a C-\ y` (that is, Ctrl-A followed by Ctrl-\\
followed by Y).

### target-help
Prints information about `TARGET`, which is used to specify the target Arduino
device. Also lists detected targets.

### upload
Uploads the compiled program to the Arduino. This uses arduino-cli to perform
the upload to the selected `TARGET`.

Specify flags to pass to `arduino-cli upload` using `UFLAGS`.

### validate
This validates that the Makefile set up correctly and that the `TARGET` is
correctly configured. This target isn't necessarily intended to be used
directly, but instead is dependent on compile, upload, and monitor.

## User-configurable macros
There are a few macros intended to be modified by the user in the Makefile.

### `ARDUINO_CLI`
The name of the arduino-cli executable. If it's installed somewhere not in your
`PATH`, you can use the full path here.

### `CFLAGS`
Any extra flags you'd like to pass to `arduino-cli compile`.

### `SCREEN`
The name of the screen executable. If it's installed somewhere not in your
`PATH`, you can use the full path here.

### `UFLAGS`
Any extra flags you'd like to pass to `arduino-cli upload`.

## Targets
Not to be confused with Makefile targets, the `TARGET` environment variable is
used to identity which Arduino device you are working with.

Targets are very simple shell scripts located in the `targets` directory that
describe an Arduino device and how it connects to your system using four
variables.

I highly recommend referring directly to `make target-help` for more
information about this, including examples and target file syntax. (Possibly
outdated example output is included below as well.)

## End-to-end example
This section describes, from start to finish, a simple example using an Arduino
Uno.

### 1. Identify sketchbook directory
Identify your sketchbook directory. In this example, the sketchbook directory
is `/Users/spakov/git/Arduino`.

### 2. Install Makefile and targets directory
Ensure the `.build` directory containing the Makefile and `targets` directory
is present in your sketchbook directory.

```
spakov@host /Users/spakov/git/Arduino % ls
total 0
drwxr-xr-x   7 spakov  staff  224 Jun 26 11:54 .
drwxr-xr-x   4 spakov  staff  128 Jun 20 14:46 ..
drwxr-xr-x   6 spakov  staff  192 Jun 26 12:28 .build
spakov@host /Users/spakov/git/Arduino % ls -R .build
total 64
drwxr-xr-x  6 spakov  staff    192 Jun 26 12:28 .
drwxr-xr-x  7 spakov  staff    224 Jun 26 11:54 ..
-rw-r--r--  1 spakov  staff   5498 Jun 26 12:18 Makefile
-rw-r--r--  1 spakov  staff   2997 Jun 26 12:28 README.md
drwxr-xr-x  4 spakov  staff    128 Jun 26 11:22 targets

.build/targets:
total 16
drwxr-xr-x  4 spakov  staff  128 Jun 26 11:22 .
drwxr-xr-x  6 spakov  staff  192 Jun 26 12:28 ..
-rwxr-xr-x  1 spakov  staff   95 Jun 25 23:21 uno.sh
spakov@host /Users/spakov/git/Arduino % cat .build/targets/uno.sh
#!/usr/bin/env zsh

target=uno
fqbn=arduino:avr:uno
port=/dev/cu.usbserial-2230
baud_rate=9600
```

You will want to customize the targets as needed for your device(s).

### 3. Create sketch directory
Create a new directory for your sketch. In this example, I'll use
`/Users/spakov/git/Arduino/sketch_jun23a`.

```
spakov@host /Users/spakov/git/Arduino % mkdir sketch_jun23a
spakov@host /Users/spakov/git/Arduino % ls
total 0
drwxr-xr-x   7 spakov  staff  224 Jun 26 11:54 .
drwxr-xr-x   4 spakov  staff  128 Jun 20 14:46 ..
drwxr-xr-x   6 spakov  staff  192 Jun 26 12:28 .build
drwxr-xr-x   6 spakov  staff  192 Jun 26 12:33 sketch_jun23a
spakov@host /Users/spakov/git/Arduino % cd sketch_jun23a
```

### 4. Create a new Makefile
Create a Makefile in your sketch directory that includes the one from the
`.build` directory.

#### `Makefile`
```
include ../.build/Makefile
```

The `include` macro allows the magic to happen. All paths are derived
automatically.

```
spakov@host /Users/spakov/git/Arduino/sketch_jun23a % ls
total 24
drwxr-xr-x  6 spakov  staff  192 Jun 26 12:33 .
drwxr-xr-x  7 spakov  staff  224 Jun 26 11:54 ..
-rw-r--r--  1 spakov  staff   27 Jun 26 12:33 Makefile
```

### 5. View `make target-help` output
If you're working with multiple boards, you may want to view the "Available
targets" section in the output of `make target-help` to remember which is
which.

```
spakov@host /Users/spakov/git/Arduino/sketch_jun23a % make target-help

Target help...
This Makefile uses the concept of targets (these are different than the targets
make uses.) Targets are described using shell scripts that set the following
four variables to describe the Arduino board you are working with:
  target          The name of the target
  fqbn            The board's Arduino fully qualified board name (FQBN)
  port            The serial device or port the board is connected to
  baud_rate       The baud rate of the serial device

These parameters are passed to arduino_cli for compilation and uploading. Note
that no validation of these values takes place in the Makefile.

The targets directory is located at the following path:
  /Users/spakov/git/Arduino/.build/targets

Specify the target by setting TARGET to the name of the target you want to use
on the command line. For example:
  TARGET=uno make [...]

Available targets:
  uno	arduino:avr:uno@/dev/cu.usbserial-2230@9600

make: *** [target-help] Error 1
```

In this example, we want to use an Arduino Uno, which is described by the
target named `uno`. This target specifies that `arduino:avr:uno` is the fully
qualified board name (FQBN) and that the board is connected to
`/dev/cu.usbserial-2230` at 9600 baud.

### 6. Write some code
We'll use a simple example here. This will blink an LED connected to pin 13 of
the Arduino. (If you're brand new to this, don't forget to consider a
[resistor](https://learn.sparkfun.com/tutorials/sparkfun-inventors-kit-experiment-guide---v41/circuit-1a-blink-an-led)
between pin 13 and an LED.)

#### `sketch_jun23a.ino`
```
#include "sketch_jun23a.h"

void setup() {
  pinMode(13, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  while (true) {
    ledOn();
    Serial.println("On");
    delay(1000);
    ledOff();
    Serial.println("Off");
    delay(1000);
  }
}

void ledOn() {
  digitalWrite(13, HIGH);
}

void ledOff() {
  digitalWrite(13, LOW);
}
```

#### `sketch_jun23a.h`
```
/*!
  @header sketch_jun23a.h
  @abstract A simple example program to blink an LED connected to pin 13.
*/

#include <Wire.h>

void setup;
void loop;

/*!
  @function ledOn
  @abstract Turns the LED on.
*/
void ledOn();

/*!
  @function ledOff
  @abstract Turns the LED off.
*/
void ledOff();
```

(Wondering about the comment syntax? This is what's used by HeaderDoc to
generate documentation.)

### 7. Generate documentation
Use the new Makefile to generate documentation. Note that it's not necessary to
specify `TARGET` yet since we are not compiling, uploading, or monitoring.

```
spakov@host /Users/spakov/git/Arduino/sketch_jun23a % ls
total 24
drwxr-xr-x  6 spakov  staff  192 Jun 26 12:33 .
drwxr-xr-x  7 spakov  staff  224 Jun 26 11:54 ..
-rw-r--r--  1 spakov  staff   27 Jun 26 12:33 Makefile
-rw-r--r--  1 spakov  staff  185 Jun 26 12:33 sketch_jun23a.h
-rw-r--r--  1 spakov  staff  255 Jun 26 12:32 sketch_jun23a.ino
spakov@host /Users/spakov/git/Arduino/sketch_jun23a % make doc

Building documentation...
echo '\./doc/.*' >> .exclude && \
	headerdoc2html -o doc -e .exclude . && \
	rm .exclude && \
	gatherheaderdoc doc
EXCLUDE LIST FILE is ".exclude".  CWD is /Users/spakov/git/Arduino/sketch_jun23a

Documentation will be written to doc
HTML output mode.
DIR .
======= Parsing Input Files =======

Processing ./sketch_jun23a.h
...done
Searching for com.apple.headerdoc.exampletocteplate.html
Found at /Library/Developer/CommandLineTools/usr/bin/../share/headerdoc/conf/com.apple.headerdoc.exampletocteplate.html
Processing................
done.
Generating TOCs.
Writing output file for template "com.apple.headerdoc.exampletocteplate.html"
EXECUTING /usr/bin/resolveLinks "/Users/spakov/git/Arduino/sketch_jun23a/doc"
Finding files.
....
Checking for cross-references
...
Writing xref file
Writing cross-references to file /tmp/xref_out

Resolving links (multithreaded)
...
Done
=====================================================================
  Statistics:

         files:   3
     processed:   3
    total reqs:   7
      resolved:   4
    unresolved:   3 (3 machine-generated, 0 explicit)
        broken:   0
         plain:  18
    duplicates:   0
         total:  25
    % resolved: 57.142860

For a detailed resolver report, see /tmp/resolvelinks.linkreport.kUVE0NFROa9VL

spakov@host /Users/spakov/git/Arduino/sketch_jun23a % ls
total 24
drwxr-xr-x  6 spakov  staff  192 Jun 26 12:33 .
drwxr-xr-x  7 spakov  staff  224 Jun 26 11:54 ..
-rw-r--r--  1 spakov  staff   27 Jun 26 12:33 Makefile
drwxr-xr-x  7 spakov  staff  224 Jun 26 12:33 doc
-rw-r--r--  1 spakov  staff  185 Jun 26 12:33 sketch_jun23a.h
-rw-r--r--  1 spakov  staff  255 Jun 26 12:32 sketch_jun23a.ino
```

You can view the documentation (`doc/masterTOC.html`) in a web browser at this
point if you like. Note that, due to the intricacies of the security
configuration of modern web browsers when it comes to local files, the
navigation pane on the left may not populate since it is built via JavaScript.
You can work around this locally by adding the `--tocformat iframes` option to
the headerdoc2html command, or refer to the documentation when it's hosted on
the web.

### 8. Compile
Compile the project. Note that we're now going to specify `TARGET=uno` as part
of the command line to build for the `uno` target.

```
spakov@host /Users/spakov/git/Arduino/sketch_jun23a % TARGET=uno make compile

Validating target...
target = uno
fqbn = arduino:avr:uno
port = /dev/cu.usbserial-2230
baud_rate = 9600

Compiling...
cd "/Users/spakov/git/Arduino" && \
	source "/Users/spakov/git/Arduino/.build/targets/uno.sh" && \
	"arduino-cli" compile --warnings all --fqbn "$fqbn" "sketch_jun23a" && \
	cd "/Users/spakov/git/Arduino/sketch_jun23a"
Sketch uses 1894 bytes (5%) of program storage space. Maximum is 32256 bytes.
Global variables use 122 bytes (5%) of dynamic memory, leaving 1926 bytes for local variables. Maximum is 2048 bytes.

```

(Wondering where the output file goes? By default, like the Arduino GUI
application and Arduino IDE, arduino-cli doesn't produce binary outputs in your
sketch directory; instead, it uses a temporary directory, which it reads from
when uploading. See `arduino-cli help compile` for more on this, or add
`--verbose` to `CFLAGS` in your Makefile to see what it's doing behind the
scenes.)

### 9. Upload
Next, upload the compiled program to your Arduino.

```
spakov@host /Users/spakov/git/Arduino/sketch_jun23a % TARGET=uno make upload

Validating target...
target = uno
fqbn = arduino:avr:uno
port = /dev/cu.usbserial-2230
baud_rate = 9600

Uploading...
cd "/Users/spakov/git/Arduino" && \
	source "/Users/spakov/git/Arduino/.build/targets/uno.sh" && \
	"arduino-cli" upload  -p "$port" --fqbn "$fqbn" "sketch_jun23a" && \
	cd "/Users/spakov/git/Arduino/sketch_jun23a"
```

At this point, you should see the LED connected to pin 13 of your Arduino
blinking.

### 10. Monitor
You will probably want to use serial communication at some point, so let's
monitor the serial port now.

```
spakov@host /Users/spakov/git/Arduino/sketch_jun23a % TARGET=uno make monitor

Validating target...
target = uno
fqbn = arduino:avr:uno
port = /dev/cu.usbserial-2230
baud_rate = 9600

Starting monitor...
Use C-a C-\ y to terminate
3... 2... 1...
source "/Users/spakov/git/Arduino/.build/targets/uno.sh" && \
	"screen" "$port" "$baud_rate"
```

After the countdown, screen starts and establishes a serial connection with
your Arduino. My board automatically resets when the serial connection is
established. You should see "On" and "Off" printed as the LED turns on and off.
When you're done, use `C-a C-\ y` to terminate screen.

```
[screen is terminating]
```

### 11. Doing it all in one shot
Simply run make by itself (with the correct `TARGET`) to invoke the default
target (all), which does all of these steps:

```
spakov@host /Users/spakov/git/Arduino/sketch_jun23a % TARGET=uno make

Building documentation...
echo '\./doc/.*' >> .exclude && \
	headerdoc2html -o doc -e .exclude . && \
	rm .exclude && \
	gatherheaderdoc doc
EXCLUDE LIST FILE is ".exclude".  CWD is /Users/spakov/git/Arduino/sketch_jun23a

Documentation will be written to doc
HTML output mode.
DIR .
skipped ./doc/masterTOC.html (found in exclude list)
skipped ./doc/sketch_jun23a_h/index.html (found in exclude list)
skipped ./doc/sketch_jun23a_h/toc.html (found in exclude list)
======= Parsing Input Files =======

Processing ./sketch_jun23a.h
...done
Searching for com.apple.headerdoc.exampletocteplate.html
Found at /Library/Developer/CommandLineTools/usr/bin/../share/headerdoc/conf/com.apple.headerdoc.exampletocteplate.html
Processing................
done.
Generating TOCs.
Writing output file for template "com.apple.headerdoc.exampletocteplate.html"
EXECUTING /usr/bin/resolveLinks "/Users/spakov/git/Arduino/sketch_jun23a/doc"
Finding files.
....
Checking for cross-references
...
Writing xref file
Writing cross-references to file /tmp/xref_out

Resolving links (multithreaded)
...
Done
=====================================================================
  Statistics:

         files:   3
     processed:   3
    total reqs:   7
      resolved:   4
    unresolved:   3 (3 machine-generated, 0 explicit)
        broken:   0
         plain:  18
    duplicates:   0
         total:  25
    % resolved: 57.142860

For a detailed resolver report, see /tmp/resolvelinks.linkreport.trcvcqazIU2sZ


Validating target...
target = uno
fqbn = arduino:avr:uno
port = /dev/cu.usbserial-2230
baud_rate = 9600

Compiling...
cd "/Users/spakov/git/Arduino" && \
	source "/Users/spakov/git/Arduino/.build/targets/uno.sh" && \
	"arduino-cli" compile --warnings all --fqbn "$fqbn" "sketch_jun23a" && \
	cd "/Users/spakov/git/Arduino/sketch_jun23a"
Sketch uses 2946 bytes (9%) of program storage space. Maximum is 32256 bytes.
Global variables use 307 bytes (14%) of dynamic memory, leaving 1741 bytes for local variables. Maximum is 2048 bytes.


Uploading...
cd "/Users/spakov/git/Arduino" && \
	source "/Users/spakov/git/Arduino/.build/targets/uno.sh" && \
	"arduino-cli" upload  -p "$port" --fqbn "$fqbn" "sketch_jun23a" && \
	cd "/Users/spakov/git/Arduino/sketch_jun23a"

Starting monitor...
Use C-a C-\ y to terminate
3... 2... 1...
source "/Users/spakov/git/Arduino/.build/targets/uno.sh" && \
	"screen" "$port" "$baud_rate"
[screen is terminating]
```
