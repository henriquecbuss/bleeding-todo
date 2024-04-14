import gleam/erlang/process
import gleam/pgo
import mist
import wisp
import bleeding_todo/web
import bleeding_todo/router
import bleeding_todo/env

pub fn main() {
  wisp.configure_logger()

  let assert Ok(env) = env.load()

  let assert Ok(url_config) = pgo.url_config(env.db_url)

  let db = pgo.connect(pgo.Config(..url_config, pool_size: 15))

  let context = web.Context(db)

  let handler = router.handle_request(_, context)

  let assert Ok(_) =
    wisp.mist_handler(handler, env.secret_key_base)
    |> mist.new
    |> mist.port(env.port)
    |> mist.start_http

  process.sleep_forever()
}
