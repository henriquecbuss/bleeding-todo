import wisp.{type Request, type Response}
import gleam/option
import gleam/json
import bleeding_todo_web.{type Context}
import bleeding_todo_web/controllers/auth

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- bleeding_todo_web.middleware(req)

  case wisp.path_segments(req) {
    ["auth", ..rest] -> {
      use req <- require_no_auth(req)

      case rest {
        ["sign-up"] -> auth.sign_up(req, ctx)
        _ -> wisp.not_found()
      }
    }
    _ -> wisp.not_found()
  }
}

fn require_no_auth(
  req: Request,
  handle_request: fn(Request) -> Response,
) -> Response {
  let session = auth.get_session(req)

  case session {
    option.None -> handle_request(req)

    option.Some(_) ->
      wisp.json_response(
        json.to_string_builder(
          json.object([#("error", json.string("Already authenticated"))]),
        ),
        401,
      )
  }
}
