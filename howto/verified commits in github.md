# Setting Up Verified Commits in Github (using GPG)

[ChatGPT Transcript](https://chat.openai.com/share/e8e3eca0-2cdd-410c-b94e-c0b173eacb61)

1. **Install GPG**

First, ensure GPG is installed on your system. This varies depending on your operating system:

- On Ubuntu (or other Debian-based distros), you can install it via:

```
sudo apt-get install gnupg
```

- On macOS, you can install it via Homebrew:

```
brew install gnupg
```

Check if it's correctly installed with:

```
gpg --version
```


2. **Generate a new GPG key pair**

If you don't already have a GPG key pair, generate one:

```
❯ gpg --full-generate-key

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
  Your selection? 1  # Here we choose 1 for an RSA key

RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096  # Here we choose a stronger 4096 bit key

Requested keysize is 4096 bits

Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0  # Here we choose 0 so the key never expires

Key does not expire at all
Is this correct? (y/N) y  # Confirm the expiration settings

GnuPG needs to construct a user ID to identify your key.

Real name: John Doe  # Enter your real name
Email address: john.doe@example.com  # Enter your email
Comment: My GPG key  # Optionally, enter a comment
You selected this USER-ID:
    "John Doe (My GPG key) <john.doe@example.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O  # Confirm the details

```

Follow the prompts to set your desired key options. When asked for your email, make sure to use the same email as your Git commit email.

```
❯ gpg --list-keys

/Users/username/.gnupg/pubring.kbx
----------------------------------
pub   rsa4096 2023-06-27 [SC]
      ABCD1234EFGH5678IJKL9012MNOP3456QRST6789
uid           [ultimate] John Doe (My GPG key) <john.doe@example.com>
sub   rsa4096 2023-06-27 [E]

```


The line that starts with `pub` is the key information line. The string `ABCD1234EFGH5678IJKL9012MNOP3456QRST6789` (it will look like a random string of numbers and letters in your case) is the key ID. **This is the value you need to use for the `YOUR_SIGNING_KEY`** when you run `git config --global user.signingkey YOUR_SIGNING_KEY`.

In this example, you would run:

```bash
git config --global user.signingkey ABCD1234EFGH5678IJKL9012MNOP3456QRST6789
```

3. **Configure Git to use GPG**

****
Next, tell Git to use GPG for commit signing:

```
git config --global commit.gpgsign true
```

4. **Set up GPG agent to cache your passphrase**

Create a new file at `~/.gnupg/gpg-agent.conf`. If the `.gnupg` directory doesn't exist, create it with `mkdir ~/.gnupg`.

Open the `gpg-agent.conf` file in a text editor and add the following lines:

```
# ~/.gnupg/gpg-agent.conf

# These lines set the cache time to 24 hours (86400 seconds).
# Adjust these values as needed for your preferred cache duration.

default-cache-ttl 86400
max-cache-ttl 86400
```

5. **Restart the GPG agent**

Finally, restart the GPG agent to apply the new cache settings:

```
gpg-connect-agent reloadagent /bye
```

6. **Set up the GPG_TTY environment variable**

For GPG to be able to interact with your terminal (for example, to ask for your passphrase), the `GPG_TTY` environment variable needs to be set. 

Open your shell configuration file (`.bashrc`, `.zshrc`, etc.) in a text editor and add the following line:

```
export GPG_TTY=$(tty)
```

Save and close the file, then source your shell configuration file to apply the changes:

```
source ~/.bashrc # If using bash
```

or

```
source ~/.zshrc # If using zsh
```

After completing these steps, your commits should now be signed with your GPG key, and your passphrase should be cached for the duration you specified.

7. ```gpg --armor --export YOUR_SIGNING_KEY```

```bash
gpg --armor --export ABCD1234EFGH5678IJKL9012MNOP3456QRST6789
```

This will print your GPG public key in the ASCII-armor format. **You will use this output in the next step.**

Copy the GPG key, beginning with **-----BEGIN PGP PUBLIC KEY BLOCK-----** and ending with **-----END PGP PUBLIC KEY BLOCK-----**.




Go to the [Github - Add new GPG key](https://github.com/settings/gpg/new) page on Github

In the "Key" field, paste the GPG key you copied in step 3.

Click Add GPG key.

## Debugging / Issues / Problems

### error: gpg failed to sign the data

#### Issue

```sh
❯ git commit -m "Whatever your commit message is"
error: gpg failed to sign the data
fatal: failed to write commit object

~/Dev/03/A/c/go-gui on main +3 ──  base
at 13:22:03 ❯
```

#### Cause

~~Perhaps Powerlevel10k~~ (ABSOLUTELY Powerlevel10k)
> tty command requires that stdin is attached to a terminal. When using Powerlevel10k, stdin is redirected from /dev/null when Instant Prompt is activated and until Zsh is fully initialized. This is explained in more detail in Powerlevel10k FAQ.

> To solve this problem you can either move export GPG_TTY=$(tty) to the top of ~/.zshrc so that it executes before Instant Prompt is activated, or (better!) use export GPG_TTY=$TTY. The latter version will work anywhere and it's over 1000 times faster. TTY is a special parameter set by Zsh very early during initialization. It gives you access to the terminal even when stdin might be redirected.

- from brilliant Stack post from [Roman Perepelitsa](https://unix.stackexchange.com/a/608921/375676)

[StackOverflow answer reference 1](https://unix.stackexchange.com/a/715310/375676)