prophetbot: prophetbot.swift
	@swiftc prophetbot.swift -o prophetbot

.PHONY: clean
clean:
	@git clean -d --force --quiet -X
