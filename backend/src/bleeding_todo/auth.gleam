import antigone
import birl.{type Time}
import birl/duration
import bleeding_todo/database
import bleeding_todo/dynamic_helpers
import gleam/bit_array
import gleam/dynamic
import gleam/json
import gleam/order
import gleam/pgo
import gleam/result
import gwt

pub opaque type UserId {
  UserId(String)
}

type User {
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

pub fn session_id_decoder(
  data: dynamic.Dynamic,
) -> Result(SessionId, dynamic.DecodeErrors) {
  let decoder = dynamic_helpers.map(dynamic.string, SessionId)

  decoder(data)
}

pub fn user_id_decoder(
  data: dynamic.Dynamic,
) -> Result(UserId, dynamic.DecodeErrors) {
  let decoder = dynamic_helpers.map(dynamic.string, UserId)

  decoder(data)
}

pub type SignInResult {
  SignInResult(jwt: gwt.Jwt, session: UserSession)
}

pub fn sign_up(
  email email: String,
  raw_password raw_password: String,
  username username: String,
  db db: pgo.Connection,
) -> Result(SignInResult, database.DbError) {
  use user_id <- result.try(create_user(email, raw_password, username, db))

  use session <- result.try(create_session(user_id, db))

  let jwt = create_jwt(session.id)

  Ok(SignInResult(jwt, session))
}

pub type SignInError {
  PasswordIncorrect
  DbError(database.DbError)
}

pub fn sign_in(
  email_or_username email_or_username: String,
  raw_password raw_password: String,
  db db: pgo.Connection,
) -> Result(SignInResult, SignInError) {
  use user <- result.try(
    get_user_by_email_or_username(email_or_username, db)
    |> result.map_error(fn(_) { PasswordIncorrect }),
  )

  case
    antigone.verify(
      bit_array.from_string(raw_password),
      user.encrypted_password,
    )
  {
    False -> Error(PasswordIncorrect)

    True -> {
      use session <- result.try(
        create_session(user.id, db)
        |> result.map_error(DbError),
      )

      let jwt = create_jwt(session.id)

      Ok(SignInResult(jwt, session))
    }
  }
}

fn get_user_by_email_or_username(
  email_or_username email_or_username: String,
  db db: pgo.Connection,
) -> Result(User, database.DbError) {
  let sql =
    "
    select
      id::text, email, encrypted_password, username, created_at::text, updated_at::text
    from
      users
    where
      email = $1 OR username = $1
    "

  let return_type =
    dynamic.tuple6(
      user_id_decoder,
      dynamic.string,
      dynamic.string,
      dynamic.string,
      dynamic_helpers.time,
      dynamic_helpers.time,
    )

  let response =
    database.execute_single(sql, db, [pgo.text(email_or_username)], return_type)

  case response {
    Error(err) -> Error(err)

    Ok(#(id, email, encrypted_password, username, created_at, updated_at)) -> {
      Ok(User(
        id: id,
        email: email,
        encrypted_password: encrypted_password,
        username: username,
        created_at: created_at,
        updated_at: updated_at,
      ))
    }
  }
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

  let return_type = dynamic.element(0, user_id_decoder)

  let response =
    database.execute_single(
      sql,
      db,
      [pgo.text(email), pgo.text(encrypted_password), pgo.text(username)],
      return_type,
    )

  response
}

fn create_session(
  user_id: UserId,
  db: pgo.Connection,
) -> Result(UserSession, database.DbError) {
  let expires_at =
    birl.utc_now()
    |> birl.add(duration.seconds(session_length_seconds))

  let sql = "
  insert into
    user_sessions (user_id, expires_at)
  values
    ($1, '" <> birl.to_iso8601(expires_at) <> "')
  returning id::text, user_id::text, created_at::text, expires_at::text"

  let return_type =
    dynamic.decode4(
      UserSession,
      dynamic.element(0, session_id_decoder),
      dynamic.element(1, user_id_decoder),
      dynamic.element(2, dynamic_helpers.time),
      dynamic.element(3, dynamic_helpers.time),
    )

  let response =
    database.execute_single(
      sql,
      db,
      [user_id_to_pgo_value(user_id)],
      return_type,
    )

  response
}

pub fn user_id_to_pgo_value(user_id: UserId) -> pgo.Value {
  pgo.text(user_id_to_string(user_id))
}

pub fn user_id_to_json(user_id: UserId) -> json.Json {
  json.string(user_id_to_string(user_id))
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
  use session_id <- result.try(get_session_id_from_jwt(jwt_string, secret))

  get_session(session_id, db)
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

fn get_session(
  session_id: SessionId,
  db: pgo.Connection,
) -> Result(UserSession, database.DbError) {
  let sql =
    "
  select
    id::text, user_id::text, created_at::text, expires_at::text
  from
    user_sessions
  where
    id = $1"

  let return_type =
    dynamic.tuple4(
      session_id_decoder,
      user_id_decoder,
      dynamic_helpers.time,
      dynamic_helpers.time,
    )

  let response =
    database.execute_single(
      sql,
      db,
      [pgo.text(session_id_to_string(session_id))],
      return_type,
    )

  case response {
    Error(err) -> Error(err)

    Ok(#(id, user_id, created_at, expires_at)) -> {
      case birl.compare(expires_at, birl.utc_now()) {
        order.Lt | order.Eq -> Error(database.UnexpectedReturnLength(1, 0))

        order.Gt ->
          Ok(UserSession(
            id: id,
            user_id: user_id,
            created_at: created_at,
            expires_at: expires_at,
          ))
      }
    }
  }
}
