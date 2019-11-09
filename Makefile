.PHONY: lint

lint:
	@docker run --rm -v `pwd`:/mnt koalaman/shellcheck:stable *.sh .bash_profile