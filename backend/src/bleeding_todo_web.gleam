import gleam/http
import gleam/pgo
import wisp

pub type Context {
  Context(db: pgo.Connection, secret_key: String, frontend_url: String)
}

pub fn middleware(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)

  use <- wisp.log_request(req)

  use <- wisp.rescue_crashes

  use req <- wisp.handle_head(req)

  let response = case req.method {
    http.Options -> wisp.ok()
    _ -> handle_request(req)
  }

  response
  |> set_cors(ctx)
}

fn set_cors(response: wisp.Response, ctx: Context) {
  wisp.set_header(response, "Access-Control-Allow-Origin", ctx.frontend_url)
  |> wisp.set_header("Access-Control-Allow-Methods", "*")
  |> wisp.set_header("Access-Control-Allow-Headers", "*")
}
