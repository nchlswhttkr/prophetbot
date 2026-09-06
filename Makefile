.PHONY: build
build: build-debug

.PHONY: build-%
build-%:
	@swift build --configuration $*
	@cp $(shell swift build --configuration $* --show-bin-path)/prophetbot-gpg prophetbot-gpg
	@swift run --configuration $* --skip-build SetIcon prophetbot-gpg
	@cp $(shell swift build --configuration $* --show-bin-path)/prophetbot-ssh prophetbot-ssh
	@swift run --configuration $* --skip-build SetIcon prophetbot-ssh

.PHONY: install
install: build-release
	sudo cp prophetbot-gpg /usr/local/bin/prophetbot-gpg
	sudo cp prophetbot-ssh /usr/local/bin/prophetbot-ssh

.PHONY: clean
clean:
	@git clean -d --force --force --quiet -X

.PHONY: format
format:
	@swift format -i $(wildcard Sources/**/*.swift)
