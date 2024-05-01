import bleeding_todo/auth
import bleeding_todo/database
import bleeding_todo/dynamic_helpers
import bleeding_todo/todo_item
import bleeding_todo/todo_list
import bleeding_todo/workspace
import gleam/dict
import gleam/dynamic
import gleam/int
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option}
import gleam/order
import gleam/pgo
import gleam/result

pub type MutationObject {
  MutationObject(
    client_id: ClientId,
    id: Int,
    data: Mutation,
    timestamp: Timestamp,
  )
}

pub type Timestamp {
  IntTimestamp(timestamp: Int)
  FloatTimestamp(timestamp: Float)
}

pub type Mutation {
  // TODO: Implement permissions
  CreateTodoList(todo_list.TodoListWithId)
  DeleteTodoList(todo_list.Id)
  EditTodoList(todo_list.Id, name: Option(String), color: Option(String))
  CreateTodoItem(todo_item.TodoItemWithId)
  DeleteTodoItem(todo_item.Id)
  CompleteTodoItem(todo_item.Id)
}

pub opaque type TodoListKey {
  TodoListKey(todo_list_id: todo_list.Id)
}

pub opaque type TodoItemKey {
  TodoItemKey(todo_item_id: todo_item.Id)
}

pub type Operation {
  Clear
  PutTodoList(key: TodoListKey, value: todo_list.TodoList)
  RemoveTodoList(key: TodoListKey)

  PutTodoItem(key: TodoItemKey, value: todo_item.TodoItem)
  RemoveTodoItem(key: TodoItemKey)
}

pub type PullOutput {
  PullOutput(
    last_mutation_id_changes: dict.Dict(ClientId, Int),
    cookie: Int,
    patch: List(Operation),
  )
}

pub fn process_pull(
  prev_version: Int,
  client_group_id: ClientGroupId,
  user_id: auth.UserId,
  workspace_id: workspace.Id,
  db: pgo.Connection,
) -> Result(PullOutput, database.DbError) {
  use client_group <- result.try(get_client_group_or_create(
    client_group_id,
    user_id,
    workspace_id,
    db,
  ))

  use todo_lists <- result.try(todo_list.get_from_workspace(
    workspace_id,
    prev_version,
    db,
  ))

  use todo_items <- result.try(todo_item.get_from_workspace(
    workspace_id,
    prev_version,
    db,
  ))

  use clients <- result.try(get_clients_from_group(
    client_group.id,
    prev_version,
    db,
  ))

  let todo_list_patches =
    list.map(todo_lists, fn(todo_list) {
      case todo_list.is_deleted {
        True -> RemoveTodoList(TodoListKey(todo_list.id))
        False ->
          PutTodoList(TodoListKey(todo_list.id), todo_list.remove_id(todo_list))
      }
    })

  let todo_item_patches =
    list.map(todo_items, fn(todo_item) {
      case todo_item.is_deleted {
        True -> RemoveTodoItem(TodoItemKey(todo_item.id))
        False ->
          PutTodoItem(TodoItemKey(todo_item.id), todo_item.remove_id(todo_item))
      }
    })

  Ok(PullOutput(
    last_mutation_id_changes: dict.from_list(clients),
    cookie: client_group.workspace_replicache_version,
    patch: list.concat([todo_list_patches, todo_item_patches]),
  ))
}

pub fn process_push(
  client_group_id: ClientGroupId,
  mutations: List(MutationObject),
  user_id: auth.UserId,
  workspace_id: workspace.Id,
  db: pgo.Connection,
) -> Result(Nil, database.DbError) {
  // TODO: Put all of this inside a transaction

  use client_group <- result.try(get_client_group_or_create(
    client_group_id,
    user_id,
    workspace_id,
    db,
  ))

  mutations
  |> list.map(fn(mutation) { process_mutation(client_group, mutation, db) })
  |> result.all()
  |> result.map(fn(_) { Nil })
}

fn process_mutation(
  client_group: ClientGroup,
  mutation: MutationObject,
  db: pgo.Connection,
) -> Result(Nil, database.DbError) {
  let next_version = client_group.workspace_replicache_version + 1

  use client <- result.try(get_replicache_client(mutation.client_id, db))

  let next_mutation_id =
    client
    |> option.map(fn(client) { client.last_mutation_id + 1 })
    |> option.unwrap(1)

  case int.compare(mutation.id, next_mutation_id) {
    order.Lt -> Ok(Nil)

    order.Gt -> {
      panic as {
        "Mutation "
        <> int.to_string(mutation.id)
        <> " is from the future - aborting. This can happen in development if the server restarts. In that case, clear application data in browser and refresh."
      }
    }

    order.Eq -> {
      use _ <- result.try(case mutation.data {
        CreateTodoList(todo_list) ->
          todo_list.create(todo_list, next_version, db)

        DeleteTodoList(todo_list_id) ->
          todo_list.delete(todo_list_id, next_version, db)

        EditTodoList(todo_list_id, name, color) ->
          todo_list.edit(todo_list_id, name, color, next_version, db)

        CreateTodoItem(todo_item) ->
          todo_item.create(todo_item, next_version, db)

        DeleteTodoItem(todo_item_id) ->
          todo_item.delete(todo_item_id, next_version, db)

        CompleteTodoItem(todo_item_id) ->
          todo_item.complete(todo_item_id, next_version, db)
      })

      use _ <- result.try(update_workspace_replicache_version(
        client_group.workspace_id,
        next_version,
        db,
      ))

      use _ <- result.try(update_replicache_client_version(
        mutation.client_id,
        client_group.id,
        next_mutation_id,
        next_version,
        db,
      ))

      Ok(Nil)
    }
  }
}

pub opaque type ClientId {
  ClientId(id: String)
}

fn client_id_to_pgo_value(client_id: ClientId) -> pgo.Value {
  pgo.text(client_id.id)
}

pub fn client_id_to_string(client_id: ClientId) -> String {
  client_id.id
}

pub fn decode_client_id(
  dynamic: dynamic.Dynamic,
) -> Result(ClientId, dynamic.DecodeErrors) {
  let decoder = dynamic_helpers.map(dynamic.string, ClientId)

  decoder(dynamic)
}

pub opaque type ClientGroupId {
  ClientGroupId(id: String)
}

fn client_group_id_to_pgo_value(client_group_id: ClientGroupId) -> pgo.Value {
  pgo.text(client_group_id.id)
}

pub fn decode_client_group_id(
  dynamic: dynamic.Dynamic,
) -> Result(ClientGroupId, dynamic.DecodeErrors) {
  let decoder = dynamic_helpers.map(dynamic.string, ClientGroupId)

  decoder(dynamic)
}

type ClientGroup {
  ClientGroup(
    id: ClientGroupId,
    user_id: auth.UserId,
    workspace_id: workspace.Id,
    workspace_replicache_version: Int,
  )
}

fn create_client_group(
  client_group_id: ClientGroupId,
  user_id: auth.UserId,
  workspace_id: workspace.Id,
  db: pgo.Connection,
) -> Result(Nil, database.DbError) {
  let sql =
    "
    insert into
        replicache_client_groups (id, user_id, workspace_id)
    values
        ($1, $2, $3)
    "

  let return_type = dynamic.dynamic

  let response =
    database.execute(
      sql,
      db,
      [
        client_group_id_to_pgo_value(client_group_id),
        auth.user_id_to_pgo_value(user_id),
        workspace.id_to_pgo_value(workspace_id),
      ],
      return_type,
    )

  response
  |> result.map(fn(_) { Nil })
}

fn get_client_group(
  client_group_id: ClientGroupId,
  user_id: auth.UserId,
  db: pgo.Connection,
) -> Result(Option(ClientGroup), database.DbError) {
  let sql =
    "
    select
      cg.id::text, cg.user_id::text, ws.id::text, ws.replicache_version
    from
        replicache_client_groups cg
    join
        workspaces ws ON cg.workspace_id = ws.id
    where
      cg.id = $1 and cg.user_id = $2
    "

  let return_type =
    dynamic.tuple4(
      decode_client_group_id,
      auth.user_id_decoder,
      workspace.id_decoder,
      dynamic.int,
    )

  let response =
    database.execute_maybe_single(
      sql,
      db,
      [pgo.text(client_group_id.id), auth.user_id_to_pgo_value(user_id)],
      return_type,
    )

  case response {
    Error(err) -> Error(err)

    Ok(option.Some(#(client_group_id, user_id, workspace_id, workspace_version))) ->
      Ok(
        option.Some(ClientGroup(
          client_group_id,
          user_id,
          workspace_id,
          workspace_version,
        )),
      )

    Ok(option.None) -> {
      Ok(option.None)
    }
  }
}

fn get_client_group_or_create(
  client_group_id: ClientGroupId,
  user_id: auth.UserId,
  workspace_id: workspace.Id,
  db: pgo.Connection,
) -> Result(ClientGroup, database.DbError) {
  let client_group = get_client_group(client_group_id, user_id, db)

  case client_group {
    Ok(option.Some(client_group)) -> Ok(client_group)

    Ok(option.None) -> {
      use _ <- result.try(create_client_group(
        client_group_id,
        user_id,
        workspace_id,
        db,
      ))

      use client_group <- result.try(get_client_group(
        client_group_id,
        user_id,
        db,
      ))

      case client_group {
        option.None -> Error(database.UnexpectedReturnLength(0, 1))
        option.Some(client_group) -> Ok(client_group)
      }
    }

    Error(error) -> Error(error)
  }
}

fn update_workspace_replicache_version(
  workspace_id: workspace.Id,
  next_version: Int,
  db: pgo.Connection,
) -> Result(Nil, database.DbError) {
  let sql =
    "
    update
        workspaces
    set
        replicache_version = $1
    where
        id = $2
    "

  let return_type = dynamic.dynamic

  let response =
    database.execute(
      sql,
      db,
      [pgo.int(next_version), workspace.id_to_pgo_value(workspace_id)],
      return_type,
    )

  case response {
    Error(err) -> Error(err)
    Ok(_) -> Ok(Nil)
  }
}

type ReplicacheClient {
  ReplicacheClient(
    id: ClientId,
    client_group_id: ClientGroupId,
    last_mutation_id: Int,
    last_modified_version: Int,
  )
}

fn get_replicache_client(
  client_id: ClientId,
  db: pgo.Connection,
) -> Result(Option(ReplicacheClient), database.DbError) {
  let sql =
    "
    select
        id::text, replicache_client_group_id::text, last_mutation_id, last_modified_version
    from
        replicache_clients
    where
        id = $1
    "

  let return_type =
    dynamic.tuple4(
      decode_client_id,
      decode_client_group_id,
      dynamic.int,
      dynamic.int,
    )

  use response <- result.try(database.execute_maybe_single(
    sql,
    db,
    [client_id_to_pgo_value(client_id)],
    return_type,
  ))

  case response {
    option.None -> Ok(option.None)
    option.Some(#(id, group_id, last_mutation_id, last_modified_version)) ->
      Ok(
        option.Some(ReplicacheClient(
          id,
          group_id,
          last_mutation_id,
          last_modified_version,
        )),
      )
  }
}

fn update_replicache_client_version(
  client_id: ClientId,
  client_group_id: ClientGroupId,
  next_mutation_id: Int,
  next_modified_version: Int,
  db: pgo.Connection,
) -> Result(Nil, database.DbError) {
  use client <- result.try(get_replicache_client(client_id, db))

  let response = case client {
    option.None -> {
      let sql =
        "
        insert into
            replicache_clients (id, replicache_client_group_id, last_mutation_id, last_modified_version)
        values
            ($1, $2, $3, $4)
        returning
            id
        "

      let return_type = dynamic.dynamic

      database.execute_single(
        sql,
        db,
        [
          client_id_to_pgo_value(client_id),
          client_group_id_to_pgo_value(client_group_id),
          pgo.int(next_mutation_id),
          pgo.int(next_modified_version),
        ],
        return_type,
      )
    }

    option.Some(_) -> {
      let sql =
        "
        update
            replicache_clients
        set
            last_mutation_id = $1,
            last_modified_version = $2
        where
            id = $3
        returning
            id
        "

      let return_type = dynamic.dynamic

      database.execute_single(
        sql,
        db,
        [
          pgo.int(next_mutation_id),
          pgo.int(next_modified_version),
          client_id_to_pgo_value(client_id),
        ],
        return_type,
      )
    }
  }

  case response {
    Error(err) -> Error(err)
    Ok(_) -> Ok(Nil)
  }
}

fn get_clients_from_group(
  client_group_id: ClientGroupId,
  prev_version: Int,
  db: pgo.Connection,
) -> Result(List(#(ClientId, Int)), database.DbError) {
  let sql =
    "
    select
        id::text, last_mutation_id
    from
        replicache_clients
    where
        replicache_client_group_id = $1
        and last_modified_version > $2
    "

  let return_type = dynamic.tuple2(decode_client_id, dynamic.int)

  let response =
    database.execute(
      sql,
      db,
      [client_group_id_to_pgo_value(client_group_id), pgo.int(prev_version)],
      return_type,
    )

  case response {
    Error(err) -> Error(err)
    Ok(pgo.Returned(_count, ids)) -> Ok(ids)
  }
}

pub fn todo_list_key_to_json(key: TodoListKey) -> Json {
  json.string("list/" <> todo_list.id_to_string(key.todo_list_id))
}

pub fn todo_item_key_to_json(key: TodoItemKey) -> Json {
  json.string("listItem/" <> todo_item.id_to_string(key.todo_item_id))
}
