extern crate r2d2;
extern crate r2d2_postgres;
extern crate postgres;

use self::r2d2_postgres::{TlsMode, PostgresConnectionManager};

const DB_CONNECTION: &'static str = "postgresql://web_anon:mysecretpassword@postgres:5432/app_db";

pub type Pool = r2d2::Pool<PostgresConnectionManager>;
pub type PooledConnection = r2d2::PooledConnection<PostgresConnectionManager>;

pub fn init_pool() -> Pool {
    let manager = PostgresConnectionManager::new(DB_CONNECTION, TlsMode::None).unwrap();

    r2d2::Pool::new(manager).expect("db_pool")
}
