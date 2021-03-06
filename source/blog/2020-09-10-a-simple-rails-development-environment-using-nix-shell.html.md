---
title: A simple Rails development environment using nix-shell
description: This nix-shell environment provides a Ruby environment capable of running a Rails app without a database
created_at: 2020-09-10 18:21:00 +00:00
updated_at: 2020-09-11 09:28:00 +00:00
guid: ba59ac01-51b5-4916-94ea-ebd1d1dec01e
---

This follows on from my previous article about setting up [a simple Ruby development environment using nix-shell][nix-shell-article]. The next thing I wanted to try was to set up a simple Rails development environment. To this end I decided to focus on [the GFR website][] which is a Rails app, but has the advantage that it doesn't use a database.

The `Gemfile` for this project specified Ruby v2.5.7 and so [as before][nix-ruby-env], I [upgraded][ruby-upgrade] it to use the latest v2.5 patch version, v2.5.8, so that I could use the ruby_2_5 package provided by nix.

In a similar vein, the `Gemfile.lock` was `BUNDLED WITH` v1.17.3 of bundler; whereas the bundler version [provided by nixpkgs][nixpkgs-bundler-version] was v2.1.4. The line in `Gemfile.lock` wasn't an enforced constraint and I didn't want to break our Heroku deployment, so I compromised and upgraded to the v2 version of bundler [supported by the Heroku Ruby buildpack][heroku-bundler-version], i.e. v2.0.2.

My `shell.nix` ended up like this:

    with (import <nixpkgs> {});
    let
      env = bundlerEnv {
        name = "site-bundler-env";
        ruby = ruby_2_5;
        gemdir  = ./.;
      };
    in mkShell {
      buildInputs = [ env env.wrappedRuby ];
    }

The full set of changes including the `gemset.nix` generated by bundix are in [this commit][nixify-commit].

At this point I was surprised to discover that I could run `rails server` from within my `nix-shell` and everything worked perfectly! 🚀

    $ nix-shell

    # ...

    $ rails s
    => Booting Puma
    => Rails 5.2.4.3 application starting in development
    => Run `rails server -h` for more startup options

    # ...

    Started GET "/" for ::1 at 2020-09-10 18:05:37 +0100
    Processing by PagesController#show as HTML

    # ...

    Completed 200 OK in 170ms (Views: 23.9ms)

### Observations

It's worth noting that early on in the shenanigans above, I got stuck for a while with the wrong version of Ruby and nothing I did would change it. In the end I deleted a bunch of things in my `/nix/store` directory to fix the problem. While this probably wasn't the _right_ way to fix it, I really appreciated the way it's relatively easy to work out how various executables are being made available to your environment, i.e. via a series of symbolic links.

I also worked out that it's not possible (at least not when using `bundlerEnv`) to specify the version of bundler you want to use - it seems to be [fixed at v2.1.4][bundler-env-bundler-version].

### Next steps

I'm still interested in working out how to have a project use a specific patch version of Ruby and to be able to lockdown the exact version of bundler. I've been reading about [nix flakes][] and although I haven't completely got my head around them, I think they _might_ be what I'm looking for, because they have a "lock file" which I believe can pin your dependencies to ensure reproducibility.

However, I still feel as if that's a bit of a tangent. My main aim is to be able to have multiple Rails projects on the same computer with various flavours and versions of databases, etc. So I think my next step should be to setup a development environment for a Rails project which uses a database.

*Update*: I've belatedly realised that some run-time dependencies (e.g. node.js & yarn) were satisfied by OS packages installed in my OSX environment, i.e. I forgot to isolate the nix shell from this environment like I did when investigating the dependency on node.js in my previous article. I plan to tackle doing this soon.
{: #runtime-dependencies-update}

### Further reading

If you'd like to know more about nix flakes, I can recommend these articles by [Eelco Dolstra][]:

* [Nix Flakes, Part 1: An Introduction and Tutorial](https://www.tweag.io/blog/2020-05-25-flakes/)
* [Nix Flakes, Part 2: Evaluation Caching](https://www.tweag.io/blog/2020-06-25-eval-cache/)
* [Nix Flakes, Part 3: Managing NixOS Systems](https://www.tweag.io/blog/2020-07-31-nixos-flakes/)

[nix-shell-article]: /blog/2020-07-26-a-simple-ruby-development-environment-using-nix-shell
[the GFR website]: https://github.com/freerange/site
[nixpkgs-bundler-version]: https://github.com/NixOS/nixpkgs/blob/b71dc9d264ef0bad32de437ec9105000c952654d/pkgs/development/ruby-modules/bundler/default.nix#L7
[ruby-upgrade]: https://github.com/freerange/site/commit/75ae0e850fd0d8bf9c7abf48a543fdc9607f3dc4#diff-8b7db4d5cc4b8f6dc8feb7030baa2478
[heroku-bundler-version]: https://devcenter.heroku.com/articles/ruby-support#libraries
[nix-ruby-env]: /blog/2020-07-26-a-simple-ruby-development-environment-using-nix-shell#a-ruby-development-environment-using-nix-shell
[nix flakes]: https://github.com/NixOS/rfcs/pull/49
[shell-nix]: https://github.com/freerange/site/commit/8e5f37af715829d27c57e0f5e8a38e6f36b44b01
[bundler-env-bundler-version]: https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/ruby-modules/bundler/default.nix#L7
[Eelco Dolstra]: https://edolstra.github.io/
[nixify-commit]: https://github.com/freerange/site/commit/8e5f37af715829d27c57e0f5e8a38e6f36b44b01
