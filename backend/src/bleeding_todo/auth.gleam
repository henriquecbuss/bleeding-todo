import birl.{type Time}
import birl/duration
import beecrypt
import gleam/dynamic
import gleam/result
import gleam/pgo
import bleeding_todo/database

pub opaque type UserId {
  UserId(String)
}

pub type User {
  User(
    id: String,
    email: String,
    encrypted_password: String,
    username: String,
    created_at: Time,
    updated_at: Time,
  )
}

pub type UserSession {
  UserSession(
    id: SessionId,
    user_id: UserId,
    created_at: Time,
    updated_at: Time,
  )
}

pub opaque type SessionId {
  SessionId(String)
}

/// 60 * 60 * 24 * 30 * 12 = 360 days
pub const session_length_seconds = 31_104_000

pub fn sign_up(
  email email: String,
  raw_password raw_password: String,
  username username: String,
  db db: pgo.Connection,
) -> Result(SessionId, database.DbError) {
  use user_id <- result.try(create_user(email, raw_password, username, db))

  use session_id <- result.try(create_session(user_id, db))

  Ok(session_id)
}

fn create_user(
  email: String,
  raw_password: String,
  username: String,
  db: pgo.Connection,
) -> Result(UserId, database.DbError) {
  let encrypted_password = beecrypt.hash(raw_password)

  let sql =
    "
    insert into
        users (email, encrypted_password, username)
    values
        ($1, $2, $3, $4)
    returning id"

  let return_type = dynamic.string

  let response =
    database.execute_single(
      sql,
      db,
      [pgo.text(email), pgo.text(encrypted_password), pgo.text(username)],
      return_type,
    )

  result.map(response, UserId(_))
}

fn create_session(
  user_id: UserId,
  db: pgo.Connection,
) -> Result(SessionId, database.DbError) {
  let sql =
    "
  insert into
    user_sessions (user_id, expires_at)
  values
    ($1, $2)
  returning id"

  let return_type = dynamic.string

  let unwrapped_user_id = user_id_to_string(user_id)

  let response =
    database.execute_single(
      sql,
      db,
      [
        pgo.text(unwrapped_user_id),
        pgo.text(
          birl.now()
          |> birl.add(duration.seconds(session_length_seconds))
          |> birl.to_iso8601(),
        ),
      ],
      return_type,
    )

  result.map(response, SessionId(_))
}

fn user_id_to_string(user_id: UserId) -> String {
  case user_id {
    UserId(id) -> id
  }
}

pub fn session_id_to_string(session_id: SessionId) -> String {
  case session_id {
    SessionId(id) -> id
  }
}
