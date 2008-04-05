require 'pathname'
require 'singleton'

root_path = directory   # this is set in the initializer that calls init.rb
ml_lib_path = "#{root_path}/lib/globalize"

# Load globalize libs
require "globalize/localization/db_view_translator"
require "globalize/localization/rfc_3066"
require "globalize/localization/locale"
require "globalize/localization/supported_locales"
require "globalize/localization/db_translate"
require "globalize/localization/core_ext"
require "globalize/localization/core_ext_hooks"

# Load plugin models
require "globalize/models/translation"
require "globalize/models/model_translation"
require "globalize/models/view_translation"
require "globalize/models/language"
require "globalize/models/country"
require "globalize/models/currency"

# Load overriden Rails modules
require "globalize/rails/active_record"
require "globalize/rails/action_view"
require "globalize/rails/action_mailer"
require "globalize/rails/date_helper"
require "globalize/rails/active_record_helper"
