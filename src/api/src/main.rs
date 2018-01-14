#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate rocket;
extern crate postgres;
extern crate serde_json;

#[macro_use]
extern crate rocket_contrib;

#[macro_use]
extern crate serde_derive;

use postgres::{Connection, TlsMode};
use rocket_contrib::{Json, Value};

#[derive(Serialize,Deserialize)]
struct Slide {
    id: i32,
    content: String,
}

#[derive(Serialize, Deserialize)]
struct Deck {
    id: i32,
    title: String,
}

#[derive(Serialize, Deserialize)]
struct Presentation {
    id: i32,
    title: String,
    slides: Option<Vec<Slide>>,
}

const DB_CONNECTION: &'static str = "postgres://web_anon:mysecretpassword@localhost:5432/app_db";

#[get("/decks")]
fn decks() -> Json<Vec<Deck>> {

    let mut decks = Vec::new();
    let conn = Connection::connect(DB_CONNECTION, TlsMode::None).unwrap();

    for row in &conn.query("SELECT * FROM api.decks", &[]).unwrap() {
        let deck = Deck {
            id: row.get(0),
            title: row.get(1),
        };

        decks.push(deck);
    }

    Json(decks)
}

#[get("/decks/<id>")]
fn deck(id:i32) -> Json<Presentation> {
    let conn = Connection::connect(DB_CONNECTION, TlsMode::None).unwrap();
    let deck_rows = &conn.query("SELECT * FROM api.decks WHERE id = $1", &[&id]).unwrap();
    let deck_row = deck_rows.into_iter().next().unwrap();
    let mut slides = Vec::new();

    for slide_row in &conn.query("SELECT id, content FROM api.slides WHERE deck_id = $1", &[&id]).unwrap() {
        let slide = Slide {
            id: slide_row.get(0),
            content: slide_row.get(1),
        };

        slides.push(slide);
    }

    let presentation = Presentation {
        id: deck_row.get(0),
        title: deck_row.get(1),
        slides: Some(slides),
    };

    Json(presentation)
}

#[error(404)]
fn not_found() -> Json<Value> {
    Json(json!({
        "status": "error",
        "reason": "The thing ain't here, bruv",
    }))
}

fn main() {
    rocket::ignite()
        .mount("/", routes![deck, decks])
        .catch(errors![not_found])
        .launch();
}
