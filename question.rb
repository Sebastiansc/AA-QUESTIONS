require_relative 'reply'
require_relative 'user'
require_relative 'question_database'
require_relative 'question_follow'
require_relative 'model_base'

class Question < ModelBase

  def self.table
    'questions'
  end

  def self.find_by_author_id(id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL

    questions.map { |user| Question.new(user) }
  end

  def most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  # def self.find_by_id(id)
  #   question = QuestionsDatabase.instance.execute(<<-SQL, id)
  #     SELECT
  #       *
  #     FROM
  #       questions
  #     WHERE
  #       id = ?
  #   SQL
  #
  #   Question.new(question.first)
  # end

  attr_accessor :title, :body
  attr_reader :user_id
  def initialize(options)
    @title = options['title']
    @body = options['body']
    @id = options['id']
    @user_id = options['user_id']
  end

  def save
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @title, @body)
      INSERT INTO
        questions (user_id, title, body)
      VALUES
        (?, ?, ?)
    SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @title, @body, @id)
      update
        questions
      SET
        user_id = ?, title = ?, body = ?
      WHERE
        id = ?
    SQL

  end

  def author
    User.new(User.find_by_user_id(@user_id))
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

end
