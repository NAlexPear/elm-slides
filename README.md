# `elm-slides`
## An interactive slideshow web app

Inspired by `reveal.js`, but re-designed and built from scratch with Elm, this all-in-one slideshow solution is perfect for simple slideshows, talks, and presentations.

All slides are written and styled with Markdown, editable in place from a convenient UI overlay or through hotkeys.

## Installation

1. Clone the repository with `git@github.com:NAlexPear/elm-slides.git`
2. Make sure you've installed `elm` globally with `npm install -g elm`
3. Install dependencies inside the cloned repo with `npm install`
4. The API is run with `json-server`, a very simple API based on JSON files. To scaffold and run the API, run `npm start`.
5. For development, run `npm run dev`, and navigate to `localhost:8080` to see your first slide.


## Usage

All slides are written in a combination of `YAML` and Markdown. Hit `e` at any time to edit a slide.

An example of a standard slide would look something like this:

```markdown
---
background-color: hotpink;
---

# Slide Title
## Slide Subtitle

`this will be highlighted code`

This will be regular text!

![this is an image](https://placekitten.com/200/300)
```
