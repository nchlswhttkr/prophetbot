prophetbot: prophetbot.swift
	@swiftc -parse-as-library prophetbot.swift -o prophetbot

.PHONY: install
install: prophetbot
	@cp prophetbot /usr/local/bin/prophetbot
	@swift set-icon.swift

.PHONY: clean
clean:
	@git clean -d --force --quiet -X

.PHONY: format
format:
	@swift format -i *.swift
