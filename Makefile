BUILD_DIR = builddir
PREFIX ?= /usr/local

SETUP_DONE = $(BUILD_DIR)/meson-private

.PHONY: all
all: build

$(SETUP_DONE):
	meson setup $(BUILD_DIR)

.PHONY: build
build: $(SETUP_DONE)
	meson compile -C $(BUILD_DIR)

.PHONY: install
install: build
	cp $(BUILD_DIR)/vala-rofi-polkit $(PREFIX)/bin/
	cp ./rofi-polkit.sh $(PREFIX)/bin/

.PHONY: uninstall
uninstall:
	rm -rf $(PREFIX)/bin/vala-rofi-polkit
	rm -rf $(PREFIX)/bin/rofi-polkit.sh

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
