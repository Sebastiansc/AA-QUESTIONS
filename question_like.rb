require_relative 'question_database'
require_relative 'user'
require_relative 'question'
require 'byebug'


class QuestionLike
  def self.likers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        u.*
      FROM
        users u
      JOIN
        question_likes ql
      ON u.id = ql.user_id
      WHERE
        ql.question_id = ?
    SQL

    users.map { |user| User.new(user) }
  end

  def self.num_likes_for_question_id(question_id)
    num = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        questions q
      JOIN
        question_likes ql
      ON q.id = ql.question_id
      WHERE
        q.id = ?
    SQL

    num.first.values.first
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        q.*
      FROM
        questions q
      JOIN
        question_likes ql
      ON q.id = ql.question_id
      WHERE
        ql.user_id = ?
    SQL
    # byebug
    questions.map { |question| Question.new(question) }
end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      q.*
    FROM
      questions q
    JOIN question_likes ql
      ON ql.question_id = q.id
    GROUP BY
      q.id
    ORDER BY
      COUNT(*) DESC LIMIT ?
  SQL

    questions.map { |question| Question.new(question) }
  end

  def initialize(user_id, question_id)
    @user_id = user_id
    @question_id = question_id
  end
end
