module FixtureReplacementController
  # This is here so that if someone (some how) assigns a proc
  # to an accessor on an ActiveRecord object, FixtureReplacement
  # won't get tripped up, and try to evaluate the proc.
  class DelayedEvaluationProc < Proc
    def evaluate(caller)
      default_obj, params = self.call
      return caller.__send__("create_#{default_obj.fixture_name}", params)
    end
  end
end