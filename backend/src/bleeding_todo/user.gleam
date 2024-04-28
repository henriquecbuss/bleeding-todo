import bleeding_todo/auth
import bleeding_todo/database
import gleam/dynamic
import gleam/json
import gleam/pgo

pub type User {
  User(id: auth.UserId, email: String, username: String)
}

pub fn to_json(user: User) -> json.Json {
  json.object([
    #("id", auth.user_id_to_json(user.id)),
    #("email", json.string(user.email)),
    #("username", json.string(user.username)),
  ])
}

pub fn get_by_id(
  id id: auth.UserId,
  db db: pgo.Connection,
) -> Result(User, database.DbError) {
  let sql =
    "
    select
        id::text, email, username
    from
        users
    where
        id = $1
    "

  let return_type =
    dynamic.tuple3(auth.user_id_decoder, dynamic.string, dynamic.string)

  let response =
    database.execute_single(
      sql,
      db,
      [auth.user_id_to_pgo_value(id)],
      return_type,
    )

  case response {
    Error(err) -> Error(err)
    Ok(#(id, email, username)) -> Ok(User(id, email, username))
  }
}
