prophetbot: prophetbot.swift
	@swiftc prophetbot.swift -o prophetbot

.PHONY: install
install: prophetbot
	@cp prophetbot /usr/local/bin/prophetbot

.PHONY: clean
clean:
	@git clean -d --force --quiet -X
