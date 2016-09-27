require_relative 'question_follow'
require 'byebug'
require_relative 'question'
require_relative 'reply'
require_relative 'question_database'

class User
  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ?, lname = ?
    SQL

    User.new(user.first)
  end

  attr_accessor :fname, :lname
  attr_reader :id
  def initialize(options = {})
    byebug
    @fname = options['fname']
    @lname = options['lname']
    @id = options['id']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    average = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      CAST(COUNT(DISTINCT q.id) AS FLOAT) / COUNT(ql.question_id)
    FROM
    questions q
    LEFT OUTER JOIN question_likes ql
    ON q.id = ql.question_id
    WHERE
    q.user_id = 2
    SQL

    average
  end

  def save
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      update
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL

  end

end
