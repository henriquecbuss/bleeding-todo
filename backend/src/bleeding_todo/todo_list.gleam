import bleeding_todo/database
import bleeding_todo/dynamic_helpers
import bleeding_todo/workspace
import gleam/dynamic.{type Dynamic}
import gleam/json.{type Json}
import gleam/list
import gleam/pgo
import gleam/result

pub opaque type Id {
  Id(id: String)
}

pub type TodoList {
  TodoList(name: String, color: String, workspace_id: workspace.Id)
}

pub type TodoListWithId {
  TodoListWithId(
    id: Id,
    name: String,
    color: String,
    workspace_id: workspace.Id,
  )
}

pub fn create(
  todo_list: TodoListWithId,
  next_version: Int,
  db: pgo.Connection,
) -> Result(Nil, database.DbError) {
  let sql =
    "
    insert into
        lists (id, name, color, workspace_id, is_deleted, replicache_last_modified_version)
    values
        ($1, $2, $3, $4, false, $5)
    returning
        id
    "

  let return_type = dynamic.dynamic

  let response =
    database.execute_single(
      sql,
      db,
      [
        id_to_pgo(todo_list.id),
        pgo.text(todo_list.name),
        pgo.text(todo_list.color),
        workspace.id_to_pgo_value(todo_list.workspace_id),
        pgo.int(next_version),
      ],
      return_type,
    )

  response
  |> result.map(fn(_) { Nil })
}

pub fn id_to_string(id: Id) -> String {
  id.id
}

fn id_to_pgo(id: Id) -> pgo.Value {
  pgo.text(id_to_string(id))
}

fn decode_id(dynamic: Dynamic) -> Result(Id, dynamic.DecodeErrors) {
  let decoder = dynamic_helpers.map(dynamic.string, Id)

  decoder(dynamic)
}

pub fn decode_with_id(
  dynamic: Dynamic,
) -> Result(TodoListWithId, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode4(
      TodoListWithId,
      decode_id,
      dynamic.string,
      dynamic.string,
      workspace.id_decoder,
    )

  decoder(dynamic)
}

pub fn to_json(todo_list: TodoList) -> Json {
  json.object([
    #("name", json.string(todo_list.name)),
    #("color", json.string(todo_list.color)),
    #("workspace_id", workspace.id_to_json(todo_list.workspace_id)),
  ])
}

pub fn get_from_workspace(
  workspace_id: workspace.Id,
  prev_version: Int,
  db: pgo.Connection,
) -> Result(List(TodoListWithId), database.DbError) {
  let sql =
    "
    select
        id::text, name, color, workspace_id::text
    from
        lists
    where
        workspace_id = $1
        and replicache_last_modified_version > $2
    "

  let return_type =
    dynamic.tuple4(
      decode_id,
      dynamic.string,
      dynamic.string,
      workspace.id_decoder,
    )

  let response =
    database.execute(
      sql,
      db,
      [workspace.id_to_pgo_value(workspace_id), pgo.int(prev_version)],
      return_type,
    )

  case response {
    Error(error) -> Error(error)

    Ok(pgo.Returned(_count, todo_lists)) -> {
      todo_lists
      |> list.map(fn(todo_list) {
        case todo_list {
          #(id, name, color, workspace_id) ->
            TodoListWithId(id, name, color, workspace_id)
        }
      })
      |> Ok
    }
  }
}

pub fn remove_id(todo_list: TodoListWithId) -> TodoList {
  TodoList(todo_list.name, todo_list.color, todo_list.workspace_id)
}
