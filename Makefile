prophetbot: prophetbot.swift
	@swiftc prophetbot.swift -o prophetbot

.PHONY: install
install: prophetbot
	@cp prophetbot /usr/local/bin/prophetbot
	@./sign-binary.sh
	@swift set-icon.swift

.PHONY: clean
clean:
	@git clean -d --force --quiet -X
