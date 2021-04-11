CONFIG_DIR = $(HOME)/.config
INSTALL_DIR = $(HOME)/.local/bin
CONFIG_FILE = $(CONFIG_DIR)/ricerc
INSTALL_TARGET = $(INSTALL_DIR)/rice

MAKEFILE = $(lastword $(MAKEFILE_LIST))
REPO = $(abspath $(dir $(MAKEFILE)))

VARIANT = $(if $(wildcard $(CONFIG_FILE)),$(shell source $(CONFIG_FILE) && echo $$variant),)

all:
	@echo "To install the reicer issue 'make install',"
	@echo "to uninstall it enter 'make uninstall'."

install: $(INSTALL_TARGET) $(CONFIG_FILE)

uninstall:
	$(RM) $(INSTALL_TARGET)

$(CONFIG_FILE): $(MAKEFILE) | $(CONFIG_DIR)
	@echo "Generating configuration template to $@..."
	@echo "# Default variant" > $@
	@echo "variant=$(VARIANT)" >> $@
	@echo "# Repo containing the rice data" >> $@
	@echo "repo=$(REPO)" >> $@

$(INSTALL_TARGET): $(INSTALL_DIR)
	ln -sf $(realpath rice.sh) $@

$(INSTALL_DIR) $(CONFIG_DIR):
	mkdir -p $@

.PHONY: all install uninstall
