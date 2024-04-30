import bleeding_todo/env
import bleeding_todo_web
import bleeding_todo_web/controllers/replicache_sse
import bleeding_todo_web/router
import gleam/erlang/process
import gleam/pgo
import mist
import wisp

pub fn main() {
  wisp.configure_logger()

  let assert Ok(env) = env.load()

  let assert Ok(url_config) = pgo.url_config(env.db_url)

  let db =
    pgo.connect(pgo.Config(..url_config, pool_size: 15, ip_version: pgo.Ipv6))

  let context =
    bleeding_todo_web.Context(
      db,
      secret_key: env.secret_key_base,
      frontend_url: env.frontend_url,
    )

  let assert Ok(poke_actor) = replicache_sse.start_actor()

  let handler = router.handle_request(_, poke_actor, context)

  let assert Ok(_) =
    handler
    |> mist.new
    |> mist.port(env.port)
    |> mist.start_http

  process.sleep_forever()
}
