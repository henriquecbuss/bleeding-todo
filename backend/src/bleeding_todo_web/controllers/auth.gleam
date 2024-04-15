import bleeding_todo_web.{type Context}
import gleam/json
import gleam/result
import gleam/http
import gleam/http/request
import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option}
import gleam/io
import wisp.{type Request, type Response}
import bleeding_todo/auth
import bleeding_todo/database

pub type UserSession =
  auth.UserSession

type SignUpInput {
  SignUpInput(email: String, raw_password: String, username: String)
}

fn decode_sign_up_input(
  json: Dynamic,
) -> Result(SignUpInput, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode3(
      SignUpInput,
      dynamic.field("email", dynamic.string),
      dynamic.field("rawPassword", dynamic.string),
      dynamic.field("username", dynamic.string),
    )

  decoder(json)
}

pub fn sign_up(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, http.Post)

  use json <- wisp.require_json(req)

  decode_sign_up_input(json)
  |> result.map_error(fn(_) {
    wisp.log_info("Failed to decode sign up input")
    wisp.unprocessable_entity()
  })
  |> result.map(fn(input) {
    let sign_up_result =
      auth.sign_up(
        email: input.email,
        raw_password: input.raw_password,
        username: input.username,
        db: ctx.db,
      )

    case sign_up_result {
      Ok(jwt) ->
        wisp.json_response(
          json.to_string_builder(
            json.object([
              #("jwt", json.string(auth.jwt_to_string(jwt, ctx.secret_key))),
            ]),
          ),
          201,
        )

      Error(error) -> {
        wisp.log_error(database.db_error_to_internal_string(error))
        wisp.internal_server_error()
      }
    }
  })
  |> result.unwrap_both()
}

pub fn get_session(req: Request, ctx: Context) -> Option(auth.UserSession) {
  let auth_header = request.get_header(req, "Authorization")

  let session_result = case auth_header {
    Ok("Bearer " <> jwt_string) -> {
      auth.get_session_from_jwt(jwt_string, ctx.secret_key, ctx.db)
    }

    _ -> Error(Nil)
  }

  io.debug(session_result)

  session_result
  |> option.from_result
}
