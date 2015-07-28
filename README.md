# Labby

Labby is a chat bot built on the [Hubot][hubot] framework.

For more information about generic hubot behaviour see [hubot.md](hubot.md).

Labby now runs on Docker!

## Extending Labby

You can extend Labby in a few ways. Once you've done this see the restart instructions below to make the changes take effect.

### hubot-scripts

Labby has the (now depricated) [hubot-scripts][hubot-scripts] package installed. You can add a script from that package by adding the script name to [hubot-scripts.json](hubot-scripts.json).

### External hubot scripts

New Hubot scripts are externally packaged and installed via npm. To add an external package you just add it as a dependency in [package.json](package.json) and include the package name in [external-scripts.json](external-scripts.json).

A full list of external packages can be found in the [hubot-scripts org][scripts-org].

### Custom scripts

You can also add your own scripts by creating a coffee-script file in the `scripts` directory in this repository. Sometimes this is better than using `hubot-scripts` or external scripts as you can customise them for Labby, just copy the contents of the desired script and hack away.

See [example.coffee](scripts/example.coffee) for a ton of good examples to get you started. There are also a ton of tutorials, [this][jonmagic-tutorial] is one of the better ones.

## Reloading Labby

Labby is currently running two scripts which allow you to update him without accessing his server.

First you must make your changes to this repository and make sure they are merged into master. Then open a direct chat with Labby in slack and tell him to `update yourself` and to `reload all scripts`.

Labby should then be good to go with your new functionality.

[hubot-scripts]: https://github.com/github/hubot-scripts
[scripts-org]: https://github.com/hubot-scripts
[hubot]: https://hubot.github.com/
[jonmagic-tutorial]: http://theprogrammingbutler.com/blog/archives/2011/10/28/hubot-scripts-explained/
