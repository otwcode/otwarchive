#Used to set the cost of bycpt
# http://www.binarylogic.com/2008/11/22/storing-nuclear-launch-codes-in-your-app-enter-bcrypt-for-authlogic/

Authlogic::CryptoProviders::BCrypt.cost = ArchiveConfig.BCRYPT_COST || 14
