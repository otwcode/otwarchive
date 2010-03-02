class Parent < ActiveRecord::Base
  has_many :some_other_models
  has_many :testies
  accepts_nested_attributes_for :some_other_models,
                                :allow_destroy => true,
                                :reject_if => proc { |attrs| attrs['name'].blank? }
  accepts_nested_attributes_for :testies,
                                :allow_destroy => true,
                                :reject_if => proc { |attrs|
                                  attrs['first_name'].blank? &&
                                  attrs['last_name'].blank? &&
                                  attrs['address'].blank? &&
                                  attrs['some_flag'].blank?
                                }
end
