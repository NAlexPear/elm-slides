CREATE SCHEMA api;

CREATE TABLE api.decks (
  id serial primary key,
  title text not null
);

CREATE TABLE api.slides (
  id serial primary key,
  deck_id integer REFERENCES api.decks ON DELETE CASCADE,
  content text
);

INSERT INTO api.decks (title) VALUES
  ('First Deck'),
  ('Second Deck');

INSERT INTO api.slides (deck_id, content) VALUES
  (1, '# First Deck'),
  (2, '# Second Deck');

GRANT usage ON SCHEMA api TO web_anon;
GRANT SELECT ON api.decks TO web_anon;
GRANT SELECT ON api.slides TO web_anon;

