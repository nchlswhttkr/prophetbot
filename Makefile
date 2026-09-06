.PHONY: prophetbot
prophetbot:
	@swift build
	@cp $(shell swift build --show-bin-path)/prophetbot-gpg prophetbot-gpg
	@cp $(shell swift build --show-bin-path)/prophetbot-ssh prophetbot-ssh

.PHONY: install
install: prophetbot
	@cp prophetbot-gpg /usr/local/bin/prophetbot-gpg
	@cp prophetbot-ssh /usr/local/bin/prophetbot-ssh

.PHONY: clean
clean:
	@git clean -d --force --force --quiet -X

.PHONY: format
format:
	@swift format -i $(wildcard Sources/**/*.swift)
