# Binary name
BINARY_NAME = hawkcve

# Installation directories
INSTALL_DIR_LINUX = /usr/local/bin
INSTALL_DIR_WINDOWS = $(shell echo $$USERPROFILE)/bin
INSTALL_DIR_MACOS = /usr/local/bin

# Detect the current operating system
UNAME := $(shell uname)

# Build for Linux
build-linux:
	@echo "Building for Linux..."
	GOOS=linux GOARCH=amd64 go build -o bin/$(BINARY_NAME) ./cli
	@echo "Binary generated at ./bin/$(BINARY_NAME)"
	@echo "Installing to $(INSTALL_DIR_LINUX)..."
	cp bin/$(BINARY_NAME) $(INSTALL_DIR_LINUX)/$(BINARY_NAME)
	chmod +x $(INSTALL_DIR_LINUX)/$(BINARY_NAME)
	@echo "Installation complete. You can now run '$(BINARY_NAME)'."

# Build for Windows
build-windows:
	@echo "Building for Windows..."
	GOOS=windows GOARCH=amd64 go build -o bin/$(BINARY_NAME).exe ./cli
	@echo "Binary generated at ./bin/$(BINARY_NAME).exe"
	@echo "Installing to $(INSTALL_DIR_WINDOWS)..."
	mkdir -p $(INSTALL_DIR_WINDOWS)
	cp bin/$(BINARY_NAME).exe $(INSTALL_DIR_WINDOWS)/$(BINARY_NAME).exe
	@echo "Installation complete. Add $(INSTALL_DIR_WINDOWS) to your PATH to use '$(BINARY_NAME)'."

# Build for macOS
build-macos:
	@echo "Building for macOS..."
	GOOS=darwin GOARCH=amd64 go build -o bin/$(BINARY_NAME) ./cli
	@echo "Binary generated at ./bin/$(BINARY_NAME)"
	@echo "Installing to $(INSTALL_DIR_MACOS)..."
	cp bin/$(BINARY_NAME) $(INSTALL_DIR_MACOS)/$(BINARY_NAME)
	chmod +x $(INSTALL_DIR_MACOS)/$(BINARY_NAME)
	@echo "Installation complete. You can now run '$(BINARY_NAME)'."

# Clean up generated binaries and remove from PATH
clean:
	@echo "Cleaning up binaries and removing from PATH..."
ifeq ($(UNAME), Linux)
	@echo "Removing from Linux..."
	rm -f $(INSTALL_DIR_LINUX)/$(BINARY_NAME)
else ifeq ($(UNAME), Darwin)
	@echo "Removing from macOS..."
	rm -f $(INSTALL_DIR_MACOS)/$(BINARY_NAME)
else
	@echo "Removing from Windows..."
	rm -f $(INSTALL_DIR_WINDOWS)/$(BINARY_NAME).exe
endif
	rm -rf bin/
	@echo "Cleanup complete."
	
# Default task (shows help)
help:
	@echo "Usage:"
	@echo "  make build-linux    - Build and install for Linux"
	@echo "  make build-windows  - Build and install for Windows"
	@echo "  make build-macos    - Build and install for macOS"
	@echo "  make clean          - Remove generated binaries"
	@echo "  make help           - Show this help message"

# Default target
.DEFAULT_GOAL := help