# Change Author of all Commits

This command uses the `--exec` option to specify a shell command that should be run on every commit. The git commit `--amend` command is used to change the author of the commit with the `--author` option and sign the commit with the `-S` option. The `--no-edit` option tells Git not to change the commit message.

```
git rebase --exec 'git commit --amend --author="Michael Lustig <lustig@knophy.com>" --no-edit -S' --root
```

After running this command, you can force push the changes to the remote repository:

```
git push origin --force-with-lease
```