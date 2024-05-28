# Custom Cops

This folder contains custom RuboCop rules (cops) we've writen
to enforce in-house conventions. To add a new rule, create
a Ruby file within the directory that matches the department
(category in RuboCop speak). Custom cops also need tests in `spec/rubocop`.

## cucumber

### regex_step_name
Checks that Cucumber step definitions use Cucumber expressions
instead of Regex. _Note:_ this may not always be possible, and this
cop is not smart enough to detect those cases.

Avoid
```ruby
Given /foobar/ do
  ...
end
When /baz/ do
  ...
end
Then /oops(\w+)/ do |it|
  ...
end
```

Prefer
```ruby
Given "foobar(s)" do
  ...
end
When "baz" do
  ...
end
Then "oops{str}" do |it|
  ...
end

# Exception: sometimes we still need regex
When /^I do the (\d+)(?:st|nd|rd|th) thing$/ do |ordinal| # rubocop:disable Cucumber/RegexStepName
  ...
end
```

## i18n

### default_translation
Checks for uses of the `default` keyword argument within Rails translation helpers.

Avoid
```ruby
t(".translation_key", default: "English text")
```

Prefer
```ruby
# assuming the translation is in a view, the key must be defined in config/locales/views/en.yml
t(".translation_key")
```

### deprecated_helper
Checks for uses of the deprecated helper function, `ts`.
Strings passed to it cannot be translated, and all calls
will need to be replaced with `t` to enable UI translations
in the future.

Avoid
```ruby
ts("This will only be in English :(")
ts("Hello %{name}", name: "world")
```

Prefer
```ruby
t(".relative.path.to.translation")
t(".greeting", name: "world")
```

### deprecated_translation_key
Checks for uses of translation keys that have been superseded
by others or different methods of translation.

Avoid
```ruby
Category.human_attribute_name("name_with_colon", count: 1)
t(".relative.path.name_with_colon", count: 2)
```

Prefer
```ruby
Category.human_attribute_name("name", count: 1) + t("mailer.general.metadata_label_indicator")
metadata_property(t(".relative.path.name", count: 2)) # views only
```

[Deprecated translation keys](https://github.com/otwcode/otwarchive/blob/master/.rubocop.yml#L23)

## migration

### large_table_schema_update
Checks that migrations updating the schema of large tables,
as defined in the configuration, do so safely. As of writing,
this involves utilizing the `uses_departure!` helper.

Avoid
```ruby
class ExampleMigration < ActiveRecord::Migration[6.1]
  add_column :users, :new_field, :integer, nullable: true
end
```

Prefer
```ruby
class ExampleMigration < ActiveRecord::Migration[6.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  add_column :users, :new_field, :integer, nullable: true
end
```

[Tables that require Departure](https://github.com/otwcode/otwarchive/blob/master/.rubocop.yml#L81)
