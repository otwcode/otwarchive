require 'digest/sha1'


def get_salt(login)
  salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--")  
end

def encrypt_password(salt, password)
  crypted_password = encrypt(password, salt)
  return [crypted_password]
end

def encrypt(password, salt)
  Digest::SHA1.hexdigest("--#{salt}--#{password}--")
end

print "Enter admin email: "
email = gets.chomp

print "Enter admin username: "
login = gets.chomp

print "Enter admin password: "
password = gets.chomp

print "Enter salt: "
salt = gets.chomp

if salt.empty?
  salt = get_salt(login)
end

crypted_password = encrypt_password(salt, password)

@values = [ Time.now.to_s, Time.now.to_s, email, login, crypted_password, salt ]

print "INSERT INTO admins (created_at, updated_at, email, login, crypted_password, salt) "
print 'VALUES ("' + @values.join('", "') + '");'
