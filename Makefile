.PHONY: lint

SHELL_FILES = install.sh update.sh adopt.sh system_defaults.sh .bash_profile .bashrc

#Uses the local shellcheck when there is one, Docker otherwise
lint:
	@if command -v shellcheck > /dev/null; then \
		shellcheck --shell=bash $(SHELL_FILES); \
	else \
		docker run --rm -v "$$(pwd)":/mnt koalaman/shellcheck:stable --shell=bash $(SHELL_FILES); \
	fi
	@echo 'shellcheck passed'
