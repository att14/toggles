# Toggles

[![Gem Version](https://badge.fury.io/rb/toggles.svg)](https://badge.fury.io/rb/toggles)
[![CI](https://github.com/EasyPost/toggles/workflows/CI/badge.svg)](https://github.com/EasyPost/toggles/actions?query=workflow%3ACI)

YAML backed feature toggles

## Installation

Add the following to your Gemfile:

```ruby
gem "toggles"
```

and run `bundle install` from your shell.

To install the gem manually from your shell, run:

```ruby
gem install toggles
```

## Configuration

Configure `toggles`:

```ruby
Toggles.configure do |config|
  config.features_dir = "features"
end
```

You can now express conditional logic within `features_dir`. The structure of the `features_dir` determines the structure of the classes within the `Feature` module. For example if the `features_dir` has the structure:

```
features
├── thing
|   ├── one.yml
|   └── two.yml
└── test.yml
```

You can call the `Toggles.init` method to force re-parsing the configuration and re-initializing all Features
structures at any time. The `Toggles.reinit_if_necessary` method is a convenience helper which will only
re-initialize of the top-level features directory has changed. Note that, in general, this will only detect
changes if you use a system where you swap out the entire features directory on changes and do not edit
individual files within the directory.

## Usage

Create a file in `features_dir`:

```yaml
user:
  id:
    in:
      - 12345
      - 54321
```

Check if the feature is enabled or disabled:

```ruby
Feature.enabled?(:new_feature, :available_for_presentation, user: OpenStruct.new(id: 12345)) # true
Feature.enabled?(:new_feature, :available_for_presentation, user: OpenStruct.new(id: 54321)) # true
Feature.enabled?(:new_feature, :available_for_presentation, user: OpenStruct.new(id: 7)) # false

Feature.disabled?(:new_feature, :available_for_presentation, user: OpenStruct.new(id: 12345)) # false
Feature.disabled?(:new_feature, :available_for_presentation, user: OpenStruct.new(id: 54321)) # false
Feature.disabled?(:new_feature, :available_for_presentation, user: OpenStruct.new(id: 7)) # true
```

## License

This project is licensed under the ISC License, the contents of which can be found at [LICENSE.txt](LICENSE.txt).
