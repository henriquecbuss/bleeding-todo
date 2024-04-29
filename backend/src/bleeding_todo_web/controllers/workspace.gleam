import bleeding_todo/auth
import bleeding_todo/workspace.{type Id}
import bleeding_todo_web.{type Context}
import gleam/json
import wisp.{type Request, type Response}

pub fn id_from_string(id: String) -> Id {
  workspace.id_from_string(id)
}

pub fn require_membership(
  req: Request,
  session: auth.UserSession,
  workspace_id: Id,
  ctx: Context,
  handle_request: fn(Request) -> Response,
) -> Response {
  let membership_result =
    workspace.check_membership(session.user_id, workspace_id, ctx.db)

  case membership_result {
    Ok(_) -> handle_request(req)
    Error(_) ->
      wisp.json_response(
        json.to_string_builder(
          json.object([
            #("error", json.string("You're not a member of this workspace")),
          ]),
        ),
        401,
      )
  }
}
