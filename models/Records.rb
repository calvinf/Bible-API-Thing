require 'active_record'

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => "bible-verse.db"
)

ActiveRecord::Base.logger = Logger.new(STDERR)
