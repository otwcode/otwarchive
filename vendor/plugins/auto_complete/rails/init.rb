ActionController::Base.send :include, AutoComplete
ActionController::Base.helper AutoCompleteMacrosHelper
ActionView::Helpers::FormBuilder.send :include, AutoCompleteFormBuilderHelper