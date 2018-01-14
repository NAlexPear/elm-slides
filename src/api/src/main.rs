#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate rocket;
extern crate postgres;
extern crate serde_json;

#[macro_use]
extern crate rocket_contrib;

#[macro_use]
extern crate serde_derive;

mod db;

use postgres::{Connection, TlsMode};
use rocket_contrib::{Json, Value};
use db::init_pool;

#[derive(Serialize,Deserialize)]
struct Slide {
    id: i32,
    content: String,
    deck_id: Option<i32>
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
fn get_decks() -> Json<Vec<Deck>> {
    let conn = Connection::connect(DB_CONNECTION, TlsMode::None).unwrap();

    let decks = conn
        .query("SELECT * FROM api.decks", &[])
        .unwrap()
        .iter()
        .map(|row| {
            Deck {
                id: row.get(0),
                title: row.get(1),
            }
        })
        .collect();

    Json(decks)
}

#[get("/decks/<id>")]
fn get_deck(id:i32) -> Json<Presentation> {
    let conn = Connection::connect(DB_CONNECTION, TlsMode::None).unwrap();
    let deck_rows = conn
        .query("SELECT * FROM api.decks WHERE id = $1", &[&id])
        .unwrap();

    let deck_row = deck_rows
        .into_iter()
        .next()
        .unwrap();

    let slides = conn
        .query("SELECT id, content, deck_id FROM api.slides WHERE deck_id = $1", &[&id])
        .unwrap()
        .iter()
        .map(|row| {
            Slide {
                id: row.get(0),
                content: row.get(1),
                deck_id: Some(row.get(2))
            }
        })
        .collect();

    let presentation = Presentation {
        id: deck_row.get(0),
        title: deck_row.get(1),
        slides: Some(slides),
    };

    Json(presentation)
}

#[post("/decks/<id>/slides", format="application/json", data="<slide>")]
fn post_slide(id: i32, slide: Json<Slide>) -> Json<Value> {
    
    Json(json!({
        "status": "OK",
        "reason": "Everything's fine"
    }))
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
        .manage(init_pool())
        .mount("/", routes![get_deck, get_decks, post_slide])
        .catch(errors![not_found])
        .launch();
}
