class BannedValue < ActiveRecord::Base
  validates_uniqueness_of :name, :scope => [:ban_type], :message => ts("^That tag already seems to be in this set.")
  attr_accessible :name, :ban_type
### Add

  # Public Method, ban username
  # @param [String] username
  def ban_username(username)
    self.add_delete_value('add',username,'username')
  end

  # Public Method, ban email
  # @param [String] email
  def ban_email(email)
    self.add_delete_value('add',email,'email')
  end

  # Public Method, ban pseud
  # @param [String] pseud
  def ban_pseud(pseud)
    self.add_delete_value('add',pseud,'pseud')
  end
### Delete

  #Public Method, unban email
  # @param [String] email
  def unban_email(email)
    self.add_delete_value('delete',email,'email')
  end

  # Public Method, unban username
  # @param [String] username
  def unban_username(username)
    self.add_delete_value('delete',username,'username')
  end

# Public Method, unban pseud
# @param [String] pseud
  def unban_pseud(pseud)
     self.add_delete_value('delete',pseud,'pseud')
  end


  def add_delete_value(action,value,value_type)
    int_ban_type = 0
    case value_type
      when 'email'
        int_ban_type = 1
      when 'username'
        int_ban_type = 2
      when 'pseud'
        int_ban_type = 3
      else
        #todo error
    end
    self.ban_type = int_ban_type
    case action
      when 'add'
        name = value
        save
      when 'delete'
        temp_value = BannedValue.find_by_ban_type_and_name(int_ban_type,value)
        if temp_value != nil
          temp_value.delete
        end
      else
        #todo error
    end
  end
 end