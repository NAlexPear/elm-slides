CREATE SCHEMA api;

CREATE TABLE api.decks (
  id serial primary key,
  title text not null,
  slides json
);

INSERT INTO api.decks (title, slides) values
  ('Slide Deck the First', '[{"content":"# First Deck"}]'), ('Slide Deck the Second', '[{"content":"# Second Deck"}]');

GRANT usage ON SCHEMA api TO web_anon;
GRANT SELECT ON api.decks TO web_anon;
