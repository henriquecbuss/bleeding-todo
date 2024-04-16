import bleeding_todo_web.{type Context}
import gleam/json
import gleam/result
import gleam/http
import gleam/http/request
import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option}
import wisp.{type Request, type Response}
import bleeding_todo/auth
import bleeding_todo/database

pub type UserSession =
  auth.UserSession

// ------------- Sign Up -------------

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

// ------------- Sign In -------------

type SignInInput {
  SignInInput(email_or_username: String, raw_password: String)
}

fn decode_sign_in_input(
  json: Dynamic,
) -> Result(SignInInput, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode2(
      SignInInput,
      dynamic.field("emailOrUsername", dynamic.string),
      dynamic.field("rawPassword", dynamic.string),
    )

  decoder(json)
}

pub fn sign_in(req: Request, ctx: Context) {
  use <- wisp.require_method(req, http.Post)

  use json <- wisp.require_json(req)

  decode_sign_in_input(json)
  |> result.map_error(fn(_) {
    wisp.log_info("Failed to decode sign in input")
    wisp.unprocessable_entity()
  })
  |> result.map(fn(input) {
    let sign_in_result =
      auth.sign_in(
        email_or_username: input.email_or_username,
        raw_password: input.raw_password,
        db: ctx.db,
      )

    case sign_in_result {
      Ok(jwt) ->
        wisp.json_response(
          json.to_string_builder(
            json.object([
              #("jwt", json.string(auth.jwt_to_string(jwt, ctx.secret_key))),
            ]),
          ),
          201,
        )

      Error(auth.PasswordIncorrect) -> {
        wisp.json_response(
          json.to_string_builder(
            json.object([#("error", json.string("Your password is incorrect"))]),
          ),
          401,
        )
      }

      Error(auth.DbError(db_error)) -> {
        wisp.log_error(database.db_error_to_internal_string(db_error))
        wisp.internal_server_error()
      }
    }
  })
  |> result.unwrap_both()
}

// ------------- Helpers -------------

pub fn get_session(req: Request, ctx: Context) -> Option(auth.UserSession) {
  let auth_header = request.get_header(req, "Authorization")

  let session_result = case auth_header {
    Ok("Bearer " <> jwt_string) -> {
      auth.get_session_from_jwt(jwt_string, ctx.secret_key, ctx.db)
    }

    _ -> Error(Nil)
  }

  session_result
  |> option.from_result
}
