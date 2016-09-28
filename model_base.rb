require 'byebug'
require_relative 'question_database'
require_relative 'question'
require_relative 'user'
require_relative 'reply'

class ModelBase

  def self.find_by_id(id)
    table = self.table
    byebug
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
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

  def self.where(options = {})
    table = self.table
    keys = options.keys
    vals = options.values
    sanitizers = keys.map(&:to_s).map.with_index do |key, index|
      if index + 1 == keys.length
        "#{key} = ?"
      else
        "#{key} = ? AND "
      end
    end.join

    byebug
    result = QuestionsDatabase.instance.execute(<<-SQL, *vals)
      SELECT
        *
      FROM
        #{table}
      WHERE
        #{sanitizers}
    SQL

    result.map { |obj| self.new(obj) }
  end

  def self.method_missing(method_name, *args)
    table = self.table
    byebug
    name = method_name.to_s
    of_interest = name[name.index("y")+2..-1].split("_and_")
    sanitizers = of_interest.map.with_index do |key, index|
      if index + 1 == of_interest.length
        "#{key} = ?"
      else
        "#{key} = ? AND "
      end
    end.join
    byebug
    result = QuestionsDatabase.instance.execute(<<-SQL, *args)
      SELECT
        *
      FROM
        #{table}
      WHERE
        #{sanitizers}
    SQL

    result.map { |obj| self.new(obj) }
  end

  def save
    raise "#{self} already in database" if @id
    byebug
    table = self.class.table
    state = self.instance_variables
    columns = state.map(&:to_s).map{ |w| w.nil? ? w : w[1..-1] }.join(", ")
    sanitizers = state.map{ |w| "?" }.join(", ")
    vals =  columns.split(", ").map { |var| self.send(var) }

    QuestionsDatabase.instance.execute(<<-SQL, *vals)
      INSERT INTO
        #{table} (#{columns})
      VALUES
        (#{sanitizers})
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

end
