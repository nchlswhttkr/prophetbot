# prophetbot

<img src="./prophetbot.png" alt="" align="right" />

A GPG pinentry program for my personal use.

Somewhat a fork of [pinentry-tem](https://gitlab.com/notpushkin/pinentry-tem). See [license](./LICENSE.md) for further details.

Prophetbot is property of [Future Cat/OneShot](https://oneshot-game.com/).

## Usage

Build, sign, set password and configure as pinentry for GPG.

```sh
make install
security find-identity -v -p codesigning
codesign -s <identity> /usr/local/bin/prophetbot
prophetbot
echo "pinentry-program /usr/local/bin/prophetbot" >> ~/.gnupg/gpg-agent.conf
```
