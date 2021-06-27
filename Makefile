# arduino-cli executable
ARDUINO_CLI := arduino-cli

# screen executable
SCREEN := screen

# Pass extra arguments to compile
CFLAGS ?= --warnings all

# Pass extra arguments to upload
UFLAGS ?= 

# Build paths to the sketch we're working with
sketch_abs := $(shell pwd)
sketch := $(shell basename $(sketch_abs))

# Build paths to this Makefile, the .build directory, the sketchbook directory,
# and the targets directory
this := $(abspath $(lastword $(MAKEFILE_LIST)))
build_dir := $(dir $(this))
sketchbook := $(shell dirname $(build_dir))
targets := $(build_dir)targets

# Target shell script
target := $(targets)/$(TARGET).sh

# Default target
.PHONY: all
.DEFAULT_GOAL := all
all: doc compile upload monitor

# Compile target
.PHONY: compile
compile: validate
	@$(call header,Compiling)
	cd "$(sketchbook)" && \
	source "$(target)" && \
	"$(ARDUINO_CLI)" compile --verbose $(CFLAGS) --fqbn "$$fqbn" "$(sketch)" && \
	cd "$(sketch_abs)"

# Upload target
.PHONY: upload
upload: validate
	@$(call header,Uploading)
	cd "$(sketchbook)" && \
	source "$(target)" && \
	"$(ARDUINO_CLI)" upload $(UFLAGS) -p "$$port" --fqbn "$$fqbn" "$(sketch)" && \
	cd "$(sketch_abs)"

# Monitor target
.PHONY: monitor
monitor: validate
	@$(call header,Starting monitor)
	@echo Use C-a C-\\ y to terminate; $(countdown)
	source "$(target)" && \
	"$(SCREEN)" "$$port" "$$baud_rate"

# Build documentation target
.PHONY: doc
doc:
	@$(call header,Building documentation)
	echo '\./doc/.*' >> .exclude && \
	headerdoc2html -o doc -e .exclude . && \
	rm .exclude && \
	gatherheaderdoc doc

# Clean target
.PHONY: clean
clean:
	rm -r doc

# Print an informational header
header = printf '\n\033[0;94m%s\033[0m...\n' '$(1)'

# Print warning text
warn = printf '\033[0;91m%s\033[0m' '$(1)' 1>&2

# Same as warn, but with a newline
warnln = printf '\033[0;91m%s\n\033[0m' '$(1)' 1>&2

# Use for a comma in warn/warnln
c := ,

# Use for a single quote in warn/warnln
q := '"'"'

# Use for an opening/closing paren in warn/warnln
l := (
r := )

# Print a brief countdown to allow the user to read text
countdown := for i in $$(seq 3 1); do printf "$$i... "; sleep 1; done; echo

# Perform target validation
.PHONY: validate
validate:
	@$(call header,Validating target)
	@# Check for a symbolic link to the Makefile or trying to run it directly
	@fail=0; \
	if [ -L "$(this)" ]; then \
	  $(call warn,Do not make a symbolic link to the Makefile; ); \
	  fail=1; \
	elif [ "$(sketch)" = .build ]; then \
	  $(call warn,Do not run make directly from the .build directory; ); \
	  fail=1; \
	fi; \
	if [ $$fail = 1 ]; then \
	  $(call warnln,instead$c create a Makefile); \
	  $(call warnln,in your sketch directory containing the following line:); \
	  $(call warnln,  include $(this)); \
	  $(call warnln,$lor a relative path to the Makefile$r.); \
	  $(call warnln); \
	  exit 1; \
	fi
	@# Check for no TARGET
	@if [ x$(TARGET) = x ]; then \
	  $(call warnln,No target selected. Use `make target-help$q for more info.); \
	  $(call warnln); \
	  exit 1; \
	fi
	@# Check for nonexistent TARGET
	@if [ ! -f $(target) ]; then \
	  $(call warnln,The specified target does not exist. Use `make target-help$q for more info.); \
	  $(call warnln); \
	  exit 1; \
	fi
	@# List target information
	@grep '\s*[^#]*.*=' $(target) | sed -e 's/\(^[a-z_]*\)=/\[0;92m\1\[0m  /' -e 's/\(^.* \)\(.*$$\)/\1\[0;36m\2\[0m/' -e 's//=/'

# Target help target
.PHONY: target-help
target-help:
	@$(call header,Target help)
	@# Explain how targets work
	@$(call warnln,This Makefile uses the concept of targets $lthese are different than the targets); \
	$(call warnln,make uses.$r Targets are described using shell scripts that set the following); \
	$(call warnln,four variables to describe the Arduino board you are working with:); \
	$(call warnln,  target          The name of the target); \
	$(call warnln,  fqbn            The board$qs Arduino fully qualified board name $lFQBN$r); \
	$(call warnln,  port            The serial device or port the board is connected to); \
	$(call warnln,  baud_rate       The baud rate of the serial device); \
	$(call warnln); \
	$(call warnln,These parameters are passed to arduino_cli for compilation and uploading. Note); \
	$(call warnln,that no validation of these values takes place in the Makefile.); \
	$(call warnln); \
	$(call warnln,The targets directory is located at the following path:); \
	$(call warnln,  $(targets)); \
	$(call warnln); \
	$(call warnln,Specify the target by setting TARGET to the name of the target you want to use); \
	$(call warnln,on the command line. For example:); \
	$(call warnln,  TARGET=uno make [...]); \
	$(call warnln)
	@# Check for no targets
	@if ! find $(targets) -name '*.sh' -mindepth 1 -maxdepth 1 | read; then \
	  $(call warnln,No targets were detected. Create at least one before proceeding. For example$c); \
	  $(call warnln,you could create a file with these contents $lthe header is optional$r:); \
	  $(call warnln,  #!/usr/bin/env zsh); \
	  $(call warnln); \
	  $(call warnln,  target=uno); \
	  $(call warnln,  fqbn=arduino:avr:uno); \
	  $(call warnln,  port=/dev/cu.usbserial-2230); \
	  $(call warnln,  baud_rate=9600); \
	  $(call warnln,at this location:); \
	  $(call warnln,  $(targets)/uno.sh); \
	  $(call warnln,to represent an Arduino Uno connected to /dev/cu.usbserial-2230 at 9600 baud.); \
	  $(call warnln); \
	  exit 1; \
	fi
	@# Describe targets
	@$(call warnln,Available targets:); \
	for i in $(targets)/*.sh; do \
	  source $$i; \
	  printf '\033[0;91m  %s\t%s@%s@%s\n\033[0m' "$$target" "$$fqbn" "$$port" "$$baud_rate" 1>&2; \
	done; \
	$(call warnln); \
	exit 1
