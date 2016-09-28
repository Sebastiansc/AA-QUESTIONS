require_relative 'user'
require_relative 'question'
require_relative 'model_base'
require_relative 'question_database'

class Reply < ModelBase

  def self.table
    'replies'
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ? OR parent_reply = ?
    SQL

    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL

    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    Reply.new(reply.first)
  end

  attr_accessor :body
  attr_reader :parent_reply, :user_id, :id, :question_id
  def initialize(options)
    @body = options['body']
    @user_id = options['user_id']
    @question_id = options['question_id']
    @parent_reply = options['parent_reply']
    @id = options['id']
  end

  def author
    User.new(User.find_by_user_id(@user_id))
  end

  def question
    Question.new(Question.find_by_question_id(@question_id))
  end

  def find_parent_reply
    Reply.new(Reply.find_by_id(@parent_reply ))
  end

  def child_replies
    child = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply = ?
    SQL

    Reply.new(child)
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent_reply, @user_id, @body, @id)
      update
        reply
      SET
        question_id = ?, parent_reply = ?, user_id = ?, parent_reply = ?
      WHERE
        id = ?
    SQL

  end

end
