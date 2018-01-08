extern crate postgres;

use postgres::{Connection, TlsMode}

let conn = Connection::connect("postgres://web_anon:mysecretpassword@localhost:5432/app_db",
                              TlsMode::None)?;
