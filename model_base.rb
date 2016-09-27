require 'byebug'
require_relative 'question_database'
require_relative 'question'
require_relative 'user'
require_relative 'reply'

class ModelBase

  def self.find_by_id(id)
    table = self.table
    byebug
    result = QuestionsDatabase.instance.execute(<<-SQL, table, id)
      SELECT
        *
      FROM
         #{table}
      WHERE
        id = ?
    SQL

    self.new(result.first)
  end

  def self.all

  end

end
