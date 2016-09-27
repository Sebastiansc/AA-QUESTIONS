require_relative 'question_database'
require_relative 'user'
require_relative 'question'

class QuestionFollow
  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
         *
      FROM
        users u
      JOIN question_follows q
      ON u.id = q.user_id
      WHERE
        q.question_id = ?
    SQL

    users.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
         q.*
      FROM
        questions q
      JOIN question_follows qw
        ON qw.question_id = q.id
      WHERE
        qw.user_id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.most_follow_questions(n)
    top_questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        q.*
      FROM
        questions q
      JOIN question_follows qw
        ON qw.question_id = q.id
      GROUP BY
        q.id
      ORDER BY
        COUNT(*) DESC LIMIT ?
    SQL
  end

  def initialize(user_id, question_id)
    @user_id = user_id
    @question_id = question_id
  end

end
