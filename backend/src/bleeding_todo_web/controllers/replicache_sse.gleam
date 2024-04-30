import bleeding_todo/workspace
import bleeding_todo_web.{type Context}
import gleam/dict
import gleam/erlang/process
import gleam/function
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/option
import gleam/otp/actor
import gleam/string_builder
import mist

pub type PokeActor =
  process.Subject(PokeQueueActorMessage)

pub opaque type PokeActorMessage {
  Shutdown(process.ProcessDown)
  SendPoke
}

pub opaque type PokeQueueActorMessage {
  ShutdownQueue
  AddSubActor(workspace.Id, process.Subject(PokeActorMessage))
  PokeWorkspace(id: workspace.Id)
}

pub opaque type PokeQueueActorState {
  PokeQueueActorState(
    sub_actors: dict.Dict(workspace.Id, List(process.Subject(PokeActorMessage))),
  )
}

fn handle_poke_actor_message(
  message: PokeQueueActorMessage,
  state: PokeQueueActorState,
) -> actor.Next(PokeQueueActorMessage, PokeQueueActorState) {
  case message {
    ShutdownQueue -> actor.Stop(process.Normal)

    AddSubActor(workspace_id, subject) ->
      state.sub_actors
      |> dict.update(workspace_id, fn(sub_actors) {
        case sub_actors {
          option.None -> [subject]
          option.Some(actors) -> list.append(actors, [subject])
        }
      })
      |> PokeQueueActorState
      |> actor.continue

    PokeWorkspace(workspace_id) ->
      case dict.get(state.sub_actors, workspace_id) {
        Error(_) | Ok([]) -> actor.continue(state)

        Ok(sub_actors) -> {
          list.each(sub_actors, fn(actor) { actor.send(actor, SendPoke) })

          actor.continue(state)
        }
      }
  }
}

pub fn start_actor() {
  actor.start(
    PokeQueueActorState(sub_actors: dict.new()),
    handle_poke_actor_message,
  )
}

pub fn send_poke(workspace_id: workspace.Id, poke_actor: PokeActor) {
  actor.send(poke_actor, PokeWorkspace(workspace_id))
}

pub fn handle_request(
  poke_actor: PokeActor,
  workspace_id: workspace.Id,
  req: Request(mist.Connection),
  ctx: Context,
) {
  mist.server_sent_events(
    req,
    response.new(200)
      |> response.set_header("Access-Control-Allow-Origin", ctx.frontend_url)
      |> response.set_header("Access-Control-Allow-Methods", "*")
      |> response.set_header("Access-Control-Allow-Headers", "*"),
    init: fn() {
      let subj = process.new_subject()
      actor.send(poke_actor, AddSubActor(workspace_id, subj))
      let monitor = process.monitor_process(process.self())
      let selector =
        process.new_selector()
        |> process.selecting(subj, function.identity)
        |> process.selecting_process_down(monitor, Shutdown)
      actor.Ready(Nil, selector)
    },
    loop: fn(message, conn, _state) {
      case message {
        Shutdown(_process_down) -> actor.Stop(process.Normal)

        SendPoke -> {
          let event = mist.event(string_builder.from_string("poke"))

          case mist.send_event(conn, event) {
            Ok(_) -> {
              actor.continue(Nil)
            }

            Error(_) -> {
              actor.Stop(process.Normal)
            }
          }
        }
      }
    },
  )
}
