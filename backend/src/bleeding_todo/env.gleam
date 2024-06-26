import gleam/result.{try}
import glenvy/dotenv
import glenvy/env

pub type Env {
  Env(port: Int, db_url: String, secret_key_base: String, frontend_url: String)
}

pub fn load() -> Result(Env, Nil) {
  let _ = dotenv.load()

  use port <- try(env.get_int("PORT"))

  use db_url <- try(env.get_string("DATABASE_URL"))

  use secret_key_base <- try(env.get_string("SECRET_KEY_BASE"))

  use frontend_url <- try(env.get_string("FRONTEND_URL"))

  Ok(Env(port, db_url, secret_key_base, frontend_url))
}
