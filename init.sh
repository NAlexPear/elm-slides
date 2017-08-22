#bin/bash

if [ ! -d "./db" ]; then
  mkdir db;
  touch db.json;

  echo '{"decks":[{"slides":[{"content":"# First Slide\\nType `e` to edit this slide"}],"title":"First Slide Deck","id":1}]}' >> ./db/db.json;
fi
