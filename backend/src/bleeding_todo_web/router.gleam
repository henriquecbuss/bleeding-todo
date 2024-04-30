import bleeding_todo_web.{type Context}
import bleeding_todo_web/controllers/auth
import bleeding_todo_web/controllers/replicache
import bleeding_todo_web/controllers/replicache_sse
import bleeding_todo_web/controllers/workspace
import gleam/bytes_builder
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/option
import mist
import wisp.{type Request, type Response}

pub fn handle_request(
  req: request.Request(mist.Connection),
  poke_actor: replicache_sse.PokeActor,
  ctx: Context,
) -> response.Response(mist.ResponseData) {
  case request.path_segments(req) {
    ["sse", ..] -> handle_sse_request(req, poke_actor, ctx)

    _ -> {
      let handler =
        wisp.mist_handler(
          handle_rest_request(_, poke_actor, ctx),
          ctx.secret_key,
        )

      handler(req)
    }
  }
}

fn handle_sse_request(
  req: request.Request(mist.Connection),
  poke_actor: replicache_sse.PokeActor,
  ctx: Context,
) -> response.Response(mist.ResponseData) {
  case request.path_segments(req) {
    ["sse", "workspace", workspace_id, "replicache", "poke"] -> {
      let workspace_id = workspace.id_from_string(workspace_id)

      replicache_sse.handle_request(poke_actor, workspace_id, req, ctx)
    }

    _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_builder.new()))
  }
}

fn handle_rest_request(
  req: Request,
  poke_actor: replicache_sse.PokeActor,
  ctx: Context,
) -> Response {
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

    ["workspace", workspace_id, ..rest] -> {
      use req, session <- require_auth(req, session)

      let workspace_id = workspace.id_from_string(workspace_id)

      use _ <- workspace.require_membership(req, session, workspace_id, ctx)

      case rest {
        ["replicache", ..rest] -> {
          case rest {
            ["push"] ->
              replicache.push(session, workspace_id, poke_actor, req, ctx)
            ["pull"] -> replicache.pull(session, workspace_id, req, ctx)
            _ -> wisp.not_found()
          }
        }

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
