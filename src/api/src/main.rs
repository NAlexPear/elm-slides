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

use db::{ init_pool, Pool, PooledConnection };
use postgres::{Connection};
use rocket::{Request, State, Outcome};
use rocket::http::Status;
use rocket::request::{self, FromRequest};
use rocket_contrib::{Json, Value};
use std::ops::Deref;

struct DbConn(PooledConnection);

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

impl<'a, 'r> FromRequest<'a, 'r> for DbConn {
    type Error = ();

    fn from_request(request: &'a Request<'r>) -> request::Outcome<DbConn, ()> {
        let pool = request.guard::<State<Pool>>()?;

        match pool.get() {
            Ok(conn) => Outcome::Success(DbConn(conn)),
            Err(_) => Outcome::Failure((Status::ServiceUnavailable, ()))
        }
    }
}

impl Deref for DbConn {
    type Target = Connection;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

#[get("/decks")]
fn get_decks(conn: DbConn) -> Json<Vec<Deck>> {
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

#[post("/decks", format="application/json", data="<deck>")]
fn post_deck(conn: DbConn, deck: Json<Deck>) -> Json<Value> {
    conn
        .query(
            "INSERT INTO api.decks (title) VALUES ($1)",
            &[&deck.0.title]
        )
        .expect("inserted a new deck");

    Json(json!({
        "status": "Ok",
        "reason": "Everything's fine",
    }))
}

#[get("/decks/<id>")]
fn get_deck(conn: DbConn, id:i32) -> Json<Presentation> {
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

#[patch("/decks/<id>", format="application/json", data="<deck>")]
fn patch_deck(conn: DbConn, id:i32, deck: Json<Deck>) -> Json<Value> {
    conn
        .execute(
            "UPDATE api.decks SET title = $1 WHERE id = $2",
            &[&deck.0.title, &id]
        )
        .unwrap();

    Json(json!({
        "status": "OK",
        "reason": "Deck was updated correctly!"
    }))
}

#[post("/decks/<id>/slides", format="application/json", data="<slides>")]
fn post_slide(conn: DbConn, id: i32, slides: Json<Vec<Slide>>) -> Json<Value> {
    for slide in slides.0 {
         conn
            .execute(
                "INSERT INTO api.slides (content, deck_id) VALUES ($1, $2)",
                &[&slide.content, &id]
            )
            .unwrap();
    }

    Json(json!({
        "status": "OK",
        "reason": "Slides were inserted correctly!"
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
        .mount("/", routes![get_deck, post_deck, patch_deck, get_decks, post_slide])
        .catch(errors![not_found])
        .launch();
}
