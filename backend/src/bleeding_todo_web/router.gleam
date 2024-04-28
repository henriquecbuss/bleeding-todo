import bleeding_todo_web.{type Context}
import bleeding_todo_web/controllers/auth
import gleam/json
import gleam/option
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- bleeding_todo_web.middleware(req, ctx)

  let session = auth.get_session(req, ctx)

  case wisp.path_segments(req) {
    ["auth", ..rest] -> {
      use req <- require_no_auth(req, session)

      case rest {
        ["sign-up"] -> auth.sign_up(req, ctx)
        ["sign-in"] -> auth.sign_in(req, ctx)
        _ -> wisp.not_found()
      }
    }

    ["me"] -> {
      use req, session <- require_auth(req, session)

      auth.me(session, req, ctx)
    }

    ["workspace", ..rest] -> {
      use _req, _session <- require_auth(req, session)

      case rest {
        _ -> wisp.not_found()
      }
    }

    _ -> wisp.not_found()
  }
}

fn require_no_auth(
  req: Request,
  session: option.Option(auth.UserSession),
  handle_request: fn(Request) -> Response,
) -> Response {
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

fn require_auth(
  req: Request,
  session: option.Option(auth.UserSession),
  handle_request: fn(Request, auth.UserSession) -> Response,
) -> Response {
  case session {
    option.None ->
      wisp.json_response(
        json.to_string_builder(
          json.object([#("error", json.string("Not authenticated"))]),
        ),
        401,
      )

    option.Some(session) -> handle_request(req, session)
  }
}
