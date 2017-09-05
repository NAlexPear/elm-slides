# `elm-slides`
## An interactive slideshow web app

Inspired by `reveal.js`, but re-designed and built from scratch with Elm, this all-in-one slideshow solution is perfect for simple slideshows, talks, and presentations.

All slides are written and styled with Markdown, editable in place from a convenient UI overlay or through hotkeys.

## Installation

1. Clone the repository with `git@github.com:NAlexPear/elm-slides.git`
2. Development services are managed through Dockerized services, so be sure to download and install [Docker Engine](https://docs.docker.com/engine/installation/) and [Docker Compose](https://docs.docker.com/compose/install/) for your OS.
3. To spin up a development environment, run `docker-compose up --build`. You should be able to see a starter slide deck at `localhost:9000`.


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
