  DROP TABLE users;
  DROP TABLE questions;
  DROP TABLE question_follows;
  DROP TABLE replies;
  DROP TABLE question_likes;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY key,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Doctor', 'Zeuz'),
  ('Bob', 'Dylan'),
  ('Simba', 'Lion');

INSERT INTO
  questions (user_id, title, body)
VALUES
(1, "When is lunch", "Never"),
(2, "Why sucky monitors", "Because"),
(3, "How big is the sandwich?", "Yes");


INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (1, 1),
  (2, 2),
  (3, 3);

INSERT INTO
  replies (question_id, parent_reply, user_id, body)
VALUES
  (1, NULL, 1, "some stuff"),
  (2, 1, 2, "garbage reply"),
  (3, 1, 3, "genious reply");

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (1, 1),
  (1, 2),
  (3, 3),
  (2, 1);
