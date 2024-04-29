import bleeding_todo/auth
import bleeding_todo/database
import bleeding_todo/dynamic_helpers
import bleeding_todo/replicache
import bleeding_todo/todo_list
import bleeding_todo/workspace
import bleeding_todo_web.{type Context}
import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option}
import gleam/result
import wisp.{type Request, type Response}

// PULL

type PullInput {
  PullInput(
    cookie: Option(Int),
    client_group_id: replicache.ClientGroupId,
    profile_id: String,
    pull_version: Int,
    schema_version: String,
  )
}

fn decode_pull_input(json: Dynamic) -> Result(PullInput, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode5(
      PullInput,
      dynamic.field("cookie", dynamic.optional(dynamic.int)),
      dynamic.field("clientGroupID", replicache.decode_client_group_id),
      dynamic.field("profileID", dynamic.string),
      dynamic.field("pullVersion", dynamic.int),
      dynamic.field("schemaVersion", dynamic.string),
    )

  decoder(json)
}

fn replicache_operation_to_json(op: replicache.Operation) -> Json {
  case op {
    replicache.Clear -> json.object([#("op", json.string("clear"))])

    replicache.PutTodoList(key, todo_list) -> {
      json.object([
        #("op", json.string("put")),
        #("key", replicache.todo_list_key_to_json(key)),
        #("value", todo_list.to_json(todo_list)),
      ])
    }
  }
}

fn pull_output_to_json(output: replicache.PullOutput) -> Json {
  let last_mutation_id_changes =
    output.last_mutation_id_changes
    |> dict.to_list()
    |> list.map(fn(data) {
      case data {
        #(client_id, version) -> #(
          replicache.client_id_to_string(client_id),
          json.int(version),
        )
      }
    })
    |> json.object()

  json.object([
    #("lastMutationIDChanges", last_mutation_id_changes),
    #("cookie", json.int(output.cookie)),
    #("patch", json.array(output.patch, replicache_operation_to_json)),
  ])
}

pub fn pull(
  session: auth.UserSession,
  workspace_id: workspace.Id,
  req: Request,
  ctx: Context,
) -> Response {
  use json <- wisp.require_json(req)

  let input = decode_pull_input(json)

  case input {
    Error(_) -> {
      wisp.log_info("Failed to decode pull input")
      wisp.unprocessable_entity()
    }

    Ok(input) -> {
      let output =
        replicache.process_pull(
          option.unwrap(input.cookie, 0),
          input.client_group_id,
          session.user_id,
          workspace_id,
          ctx.db,
        )

      case output {
        Ok(output) ->
          wisp.json_response(
            json.to_string_builder(pull_output_to_json(output)),
            200,
          )

        Error(error) -> {
          wisp.log_error(database.db_error_to_internal_string(error))
          wisp.internal_server_error()
        }
      }
    }
  }
}

// PUSH

type PushInput {
  PushInput(
    push_version: Int,
    client_group_id: replicache.ClientGroupId,
    mutations: List(replicache.MutationObject),
    profile_id: String,
    schema_version: String,
  )
}

fn decode_timestamp(
  json: Dynamic,
) -> Result(replicache.Timestamp, dynamic.DecodeErrors) {
  let decoder =
    dynamic.any([
      dynamic_helpers.map(dynamic.int, replicache.IntTimestamp),
      dynamic_helpers.map(dynamic.float, replicache.FloatTimestamp),
    ])

  decoder(json)
}

fn decode_create_todo_list_mutation(
  json: Dynamic,
) -> Result(replicache.Mutation, dynamic.DecodeErrors) {
  let decoder =
    dynamic_helpers.map(todo_list.decode_with_id, replicache.CreateTodoList)

  decoder(json)
}

fn decode_mutation_object(
  json: Dynamic,
) -> Result(replicache.MutationObject, dynamic.DecodeErrors) {
  use #(client_id, id, timestamp, name, args) <- result.try(dynamic.decode5(
    fn(client_id, id, timestamp, name, args) {
      #(client_id, id, timestamp, name, args)
    },
    dynamic.field("clientID", replicache.decode_client_id),
    dynamic.field("id", dynamic.int),
    dynamic.field("timestamp", decode_timestamp),
    dynamic.field("name", dynamic.string),
    dynamic.field("args", dynamic.dynamic),
  )(json))

  use mutation <- result.try(case name {
    "createList" -> decode_create_todo_list_mutation(args)

    name ->
      Error([dynamic.DecodeError("a valid mutation name", name, ["name"])])
  })

  Ok(replicache.MutationObject(client_id, id, mutation, timestamp))
}

fn decode_push_input(json: Dynamic) -> Result(PushInput, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode5(
      PushInput,
      dynamic.field("pushVersion", dynamic.int),
      dynamic.field("clientGroupID", replicache.decode_client_group_id),
      dynamic.field("mutations", dynamic.list(decode_mutation_object)),
      dynamic.field("profileID", dynamic.string),
      dynamic.field("schemaVersion", dynamic.string),
    )

  decoder(json)
}

pub fn push(
  session: auth.UserSession,
  workspace_id: workspace.Id,
  req: Request,
  ctx: Context,
) -> Response {
  use json <- wisp.require_json(req)

  let input = decode_push_input(json)

  case input {
    Error(_) -> {
      wisp.log_info("Failed to decode push input")
      wisp.unprocessable_entity()
    }

    Ok(input) -> {
      let process_result =
        replicache.process_push(
          input.client_group_id,
          input.mutations,
          session.user_id,
          workspace_id,
          ctx.db,
        )

      case process_result {
        Ok(_) -> wisp.ok()
        Error(error) -> {
          wisp.log_error(database.db_error_to_internal_string(error))
          wisp.internal_server_error()
        }
      }
    }
  }
}
