--- 
permalink: using-mocha-with-rails-3-and-minitest.txt
created_at: 2013-01-24 11:24:00 +00:00
updated_at: 2013-01-24 11:24:00 +00:00
title: Using Mocha with Rails 3 and MiniTest
description: Explains some of the compatibility issues.
categories:
keywords: mocha mock object testing ruby rails minitest compatibility
guid: e007c429-8e44-45e2-9967-d39edafd73c8
---

There's been some confusion recently over which versions of [Mocha](https://github.com/freerange/mocha) are compatible with which versions of [Rails](http://rubyonrails.org/) (or more specifically, ActiveSupport). I've added some extra information to the Mocha [README](https://mocha.jamesmead.org/#Rails), but for extra clarity, I thought I'd post details here.  If you're using Test::Unit instead of MiniTest, please read my [next post](/blog/2013-01-24-using-mocha-with-rails-3-and-testunit).

If you're loading Mocha using [Bundler](http://gembundler.com/) within a Rails application, you should ensure Mocha is not auto-required and load Mocha *manually* e.g. at the bottom of `test/test_helper.rb`.

<pre>
  <code class="prettyprint">
  # Gemfile in Rails app
  gem "mocha", :require => false

  # At bottom of test_helper.rb
  require "mocha/setup"
  </code>
</pre>

Note: Using the latest version of Mocha (0.13.2) with the latest versions of Rails (e.g. 3.2.11, 3.1.10, or 3.0.19), you will see the following Mocha deprecation warning:

<pre>
  <code>
    *** Mocha deprecation warning: Change `require 'mocha'` to `require 'mocha/setup'`.
  </code>
</pre>

This will happen until new versions of Rails are released incorporating the following pull requests:

  * [3-2-stable](https://github.com/rails/rails/pull/8200)
  * [3-1-stable](https://github.com/rails/rails/pull/8871)
  * [3-0-stable](https://github.com/rails/rails/pull/8872)

These pull requests have all been merged, but unfortunately they have not yet been released and may not be for some time.

The Mocha deprecation warning will not cause any problems, but if you don't like seeing then you could do one of the following:

### Option 1 - Disable Mocha deprecation warnings with a Rails initializer

<pre>
  <code class="prettyprint">
    # config/mocha.rb
    if Rails.env.test? || Rails.env.development?
      require "mocha/version"
      require "mocha/deprecation"
      if Mocha::VERSION == "0.13.2" && Rails::VERSION::STRING == "3.2.11"
        Mocha::Deprecation.mode = :disabled
      end
    end
  </code>
</pre>

#### Notes

* I have intentionally tied this initializer to specific patch releases of Mocha and Rails, because this way you are more likely to notice when you no longer need the initializer.
* This will not work with recent versions of the Test::Unit gem (see below).
* The check for the development environment appears to be necessary, because Rails uses some of ActiveSupport's test-related classes in the development environment!

### Option 2 - Use "edge" Rails or one of the relevant "stable" branches of Rails

<pre>
  <code class="prettyprint">
    # Gemfile
    gem "rails", git: "git://github.com/rails/rails.git", branch: "3-2-stable"
    group :test do
      gem "mocha", :require => false
    end

    # test/test_helper.rb
    require "mocha/setup"
  </code>
</pre>

Although obviously it isn't ideal using an _unreleased_ version of Rails. You could always lock things down further by using the Bundler `:ref` option to restrict the version of Rails to a specific `SHA`.

### Option 3 - Downgrade to Mocha 0.12.8

<pre>
  <code class="prettyprint">
    # Gemfile in Rails app
    gem "mocha", "~> 0.12.8", :require => false

    # At bottom of test_helper.rb
    require "mocha"
  </code>
</pre>

Note: This isn't as bad as it sounds, because there aren't many changes in Mocha 0.13.x that are not in 0.12.x. Please [let us know](https://github.com/freerange/mocha/issues) if there are any fixes in 0.13.x that you need in 0.12.x and I will back-port them.
