# frozen_string_literal: true

namespace :creatorships do
  desc "Clean up creatorships for deleted chapters"
  task(remove_deleted_chapter_creatorships: :environment) do
    Creatorship.joins("LEFT JOIN chapters ON " \
                      "creatorships.creation_id = chapters.id AND " \
                      "creatorships.creation_type = \"Chapter\"").
      where(chapters: { id: nil }).
      in_batches.delete_all
  end

  desc "Clean up creatorships for deleted series"
  task(remove_deleted_series_creatorships: :environment) do
    Creatorship.joins("LEFT JOIN series ON " \
                      "creatorships.creation_id = series.id AND " \
                      "creatorships.creation_type = \"Series\"").
      where(series: { id: nil }).
      in_batches.delete_all
  end

  desc "Add missing series creatorships"
  task(add_missing_series_creatorships: :environment) do
    SerialWork.includes(:series, work: [creatorships: [:pseud]]).
      find_each(&:update_series_creatorships)
  end

  desc "Remove empty series with no creators"
  task(remove_orphaned_empty_series: :environment) do
    Series.left_joins(:serial_works).where(serial_works: { id: nil }).
      find_each do |series|
      series.destroy unless series.pseuds.exists?
    end
  end
end
