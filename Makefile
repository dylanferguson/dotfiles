.PHONY: lint

SHELL_FILES = bin/install.sh bin/update.sh macos/system_defaults.sh macos/app_defaults.sh \
	bash/.bash_profile bash/.bashrc

#Uses the local shellcheck when there is one, Docker otherwise
lint:
	@if command -v shellcheck > /dev/null; then \
		shellcheck --shell=bash $(SHELL_FILES); \
	else \
		docker run --rm -v "$$(pwd)":/mnt koalaman/shellcheck:stable --shell=bash $(SHELL_FILES); \
	fi
	@echo 'shellcheck passed'
