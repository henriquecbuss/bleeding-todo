import birl.{type Time}
import birl/duration
import antigone
import gleam/dynamic
import gleam/result
import gleam/pgo
import gleam/bit_array
import gleam/io
import bleeding_todo/database
import gwt

pub opaque type UserId {
  UserId(String)
}

pub type User {
  User(
    id: UserId,
    email: String,
    encrypted_password: String,
    username: String,
    created_at: Time,
    updated_at: Time,
  )
}

pub opaque type SessionId {
  SessionId(id: String)
}

pub type UserSession {
  UserSession(
    id: SessionId,
    user_id: UserId,
    created_at: Time,
    expires_at: Time,
  )
}

/// 60 * 60 * 24 * 30 * 12 = 360 days
pub const session_length_seconds = 31_104_000

pub fn sign_up(
  email email: String,
  raw_password raw_password: String,
  username username: String,
  db db: pgo.Connection,
) -> Result(gwt.Jwt, database.DbError) {
  use user_id <- result.try(create_user(email, raw_password, username, db))

  use session_id <- result.try(create_session(user_id, db))

  Ok(create_jwt(session_id))
}

fn create_user(
  email: String,
  raw_password: String,
  username: String,
  db: pgo.Connection,
) -> Result(UserId, database.DbError) {
  let encrypted_password =
    antigone.hash(antigone.hasher(), bit_array.from_string(raw_password))

  let sql =
    "
    insert into
        users (email, encrypted_password, username)
    values
        ($1, $2, $3)
    returning id::text"

  let return_type = dynamic.element(0, dynamic.string)

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
  let expires_at =
    birl.utc_now()
    |> birl.add(duration.seconds(session_length_seconds))

  let sql = "
  insert into
    user_sessions (user_id, expires_at)
  values
    ($1, '" <> birl.to_iso8601(expires_at) <> "')
  returning id::text"

  let return_type = dynamic.element(0, dynamic.string)

  let unwrapped_user_id = user_id_to_string(user_id)

  let response =
    database.execute_single(sql, db, [pgo.text(unwrapped_user_id)], return_type)

  result.map(response, SessionId(_))
}

fn user_id_to_string(user_id: UserId) -> String {
  case user_id {
    UserId(id) -> id
  }
}

fn session_id_to_string(session_id: SessionId) -> String {
  case session_id {
    SessionId(id) -> id
  }
}

fn create_jwt(session_id: SessionId) -> gwt.Jwt {
  gwt.new()
  |> gwt.set_payload_subject(session_id_to_string(session_id))
  |> gwt.set_payload_expiration(session_length_seconds)
}

pub fn jwt_to_string(jwt: gwt.Jwt, secret: String) -> String {
  gwt.to_signed_string(jwt, gwt.HS256, secret)
}

pub fn get_session_from_jwt(
  jwt_string: String,
  secret: String,
  db: pgo.Connection,
) -> Result(UserSession, Nil) {
  use jwt <- result.try(get_session_id_from_jwt(jwt_string, secret))

  get_session(jwt, db)
  |> result.map_error(fn(_) { Nil })
}

fn get_session_id_from_jwt(
  jwt_string: String,
  secret: String,
) -> Result(SessionId, Nil) {
  use jwt <- result.try(
    gwt.from_signed_string(jwt_string, secret)
    |> result.map_error(fn(_) { Nil }),
  )

  use session_id_string <- result.try(gwt.get_subject(jwt))

  Ok(SessionId(session_id_string))
}

pub type SessionError {
  DbError(database.DbError)
  TimeParsingError(field: String)
}

fn get_session(
  session_id: SessionId,
  db: pgo.Connection,
) -> Result(UserSession, SessionError) {
  let sql =
    "
  select
    id, user_id, created_at, expires_at
  from
    user_sessions
  where
    id = $1"

  let return_type =
    dynamic.tuple4(
      dynamic.string,
      dynamic.string,
      dynamic.string,
      dynamic.string,
    )

  let response =
    database.execute_single(
      sql,
      db,
      [pgo.text(session_id_to_string(session_id))],
      return_type,
    )

  io.debug(response)

  case response {
    Error(err) -> Error(DbError(err))

    Ok(#(id, user_id, created_at_string, expires_at_string)) -> {
      use created_at <- result.try(
        birl.parse(created_at_string)
        |> result.map_error(fn(_) { TimeParsingError(field: "created_at") }),
      )
      use expires_at <- result.try(
        birl.parse(expires_at_string)
        |> result.map_error(fn(_) { TimeParsingError(field: "expires_at") }),
      )

      Ok(UserSession(
        id: SessionId(id),
        user_id: UserId(user_id),
        created_at: created_at,
        expires_at: expires_at,
      ))
    }
  }
}
