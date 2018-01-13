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

#[derive(Serialize, Deserialize)]
struct Deck {
    id: i32,
    title: String,
}

#[get("/decks")]
fn decks() -> Json<Vec<Deck>> {
    let mut decks = Vec::new();
    let conn = Connection::connect("postgres://web_anon:mysecretpassword@localhost:5432/app_db", TlsMode::None).unwrap();

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
fn deck(id:i32) -> Json<Deck> {
    let conn = Connection::connect("postgres://web_anon:mysecretpassword@localhost:5432/app_db", TlsMode::None).unwrap();
    let rows = &conn.query("SELECT * FROM api.decks where id = $1", &[&id]).unwrap();
    let row = rows.into_iter().next().unwrap();

    let deck = Deck {
        id: row.get(0),
        title: row.get(1),
    };

    Json(deck)
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
