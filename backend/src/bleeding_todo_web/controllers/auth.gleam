import bleeding_todo_web.{type Context}
import gleam/result
import gleam/http
import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option}
import wisp.{type Request, type Response}
import bleeding_todo/auth

type SignUpInput {
  SignUpInput(email: String, raw_password: String, username: String)
}

const session_id_cookie = "session_id"

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
  |> result.map_error(fn(_) { wisp.unprocessable_entity() })
  |> result.map(fn(input) {
    let sign_up_result =
      auth.sign_up(
        email: input.email,
        raw_password: input.raw_password,
        username: input.username,
        db: ctx.db,
      )

    case sign_up_result {
      Ok(session_id) ->
        wisp.set_cookie(
          wisp.created(),
          req,
          wisp.Signed,
          name: session_id_cookie,
          value: auth.session_id_to_string(session_id),
          max_age: auth.session_length_seconds,
        )

      Error(_) -> wisp.internal_server_error()
    }
  })
  |> result.unwrap_both()
}

pub fn get_session(req: Request) -> Option(String) {
  wisp.get_cookie(req, session_id_cookie, wisp.Signed)
  |> option.from_result()
}
