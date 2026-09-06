<img src="./prophetbot.png" alt="" align="right" />

# prophetbot

A GPG pinentry program for my personal use.

Somewhat a fork of [pinentry-tem](https://gitlab.com/notpushkin/pinentry-tem). See [license](./LICENSE.md) for further details.

For further details about pinentry, refer to [the documentation](https://github.com/gpg/pinentry/blob/7f7fd8bcfd74919091cc318b27b8617a9ef2ac82/doc/pinentry.texi).

Prophetbot is property of [Future Cat/OneShot](https://www.oneshot-game.com/). You should play OneShot.

## Usage

Build, sign, set password and configure as pinentry for GPG. Make sure your Xcode installation is up to date.

```sh
# Build and install
make install

# Setup for GPG
prophetbot-gpg --setup
echo "pinentry-program /usr/local/bin/prophetbot-gpg" >> ~/.gnupg/gpg-agent.conf
echo "Hello Prophetbot" | gpg --clearsign

# Setup for SSH
prophetbot-ssh --setup
export SSH_ASKPASS=/usr/local/bin/prophetbot-ssh
export SSH_ASKPASS_REQUIRE=force
echo 'Hello Prophetbot' | ssh-keygen -Y sign -n git -f ~/.ssh/id_ed25519
```

<!-- TODO: Support multiple keys/users, EG SETKEY for GPG -->
