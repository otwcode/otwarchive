class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.per_page = ArchiveConfig.ITEMS_PER_PAGE

  before_save :update_sanitizer_version

  def update_sanitizer_version
    ArchiveConfig.FIELDS_ALLOWING_HTML.each do |field|
      if self.will_save_change_to_attribute?(field)
        self.send("#{field}_sanitizer_version=", ArchiveConfig.SANITIZER_VERSION)
      end
    end
  end

  def self.random_order
    order(Arel.sql("RAND()"))
  end

  def unmark_for_destruction
    @marked_for_destruction = false
  end

  # Given an association of through records, the name of the "source" field,
  # and a list of values, marks the through records as destroyed or not based
  # on whether their "source" value is included in the list of desired values,
  # and builds new through records when necessary.
  #
  # The optional parameter klass is used to filter the through records -- when
  # it's set, this function won't mark or unmark any through records whose
  # source doesn't have that klass.
  def assign_through_association(through_association, source, values, klass: nil)
    missing = Set.new(values)

    through_association.each do |through_record|
      value = through_record.send(source)
      next if klass && !value.is_a?(klass)

      if missing.delete?(value)
        through_record.unmark_for_destruction
      else
        through_record.mark_for_destruction
      end
    end

    missing.each do |value|
      through_association.build(source => value)
    end
  end
end
