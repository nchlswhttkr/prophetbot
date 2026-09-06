prophetbot: Package.swift $(wildcard Sources/*)
	@swift build
	@cp $(shell swift build --show-bin-path)/Prophetbot prophetbot

.PHONY: install
install: prophetbot
	@cp prophetbot /usr/local/bin/prophetbot

.PHONY: clean
clean:
	@git clean -d --force --quiet -X

.PHONY: format
format:
	@swift format -i $(wildcard Sources/*.swift)
