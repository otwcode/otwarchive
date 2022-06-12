module TagSpecHelper
  def fandom_tag_with_one_work
    tag = FactoryBot.create(:fandom)
    FactoryBot.create(:work, fandom_string: tag.name)
    write_tag_to_database(tag)
    tag
  end

  def write_tag_to_database(tag)
    Tag.write_redis_to_database
    tag.reload
  end
end
