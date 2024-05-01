import birl
import bleeding_todo/auth
import bleeding_todo/database
import bleeding_todo/dynamic_helpers
import bleeding_todo/json_helpers
import bleeding_todo/pgo_helpers
import bleeding_todo/todo_list
import bleeding_todo/workspace
import gleam/dynamic.{type Dynamic}
import gleam/json.{type Json}
import gleam/option.{type Option}
import gleam/pgo
import gleam/result

pub opaque type Id {
  Id(id: String)
}

pub type TodoItem {
  TodoItem(
    title: String,
    description_markdown: Option(String),
    due_date: Option(birl.Time),
    completed_at: Option(birl.Time),
    assignee_id: Option(auth.UserId),
    sorting_order: Int,
    list_id: todo_list.Id,
  )
}

pub type TodoItemWithId {
  TodoItemWithId(
    id: Id,
    title: String,
    description_markdown: Option(String),
    due_date: Option(birl.Time),
    completed_at: Option(birl.Time),
    assignee_id: Option(auth.UserId),
    sorting_order: Int,
    list_id: todo_list.Id,
  )
}

pub fn create(
  todo_item: TodoItemWithId,
  next_version: Int,
  db: pgo.Connection,
) -> Result(Nil, database.DbError) {
  let sql =
    "
    insert into
        list_items (id, list_id, title, description_markdown, due_date, assignee_id, sorting_order, is_deleted, replicache_last_modified_version)
    values
        ($1, $2, $3, $4, TO_TIMESTAMP($5), $6, $7, false, $8)
    "

  let return_type = dynamic.dynamic

  let response =
    database.execute(
      sql,
      db,
      [
        id_to_pgo(todo_item.id),
        todo_list.id_to_pgo(todo_item.list_id),
        pgo.text(todo_item.title),
        pgo.nullable(pgo.text, todo_item.description_markdown),
        pgo.nullable(pgo_helpers.time, todo_item.due_date),
        pgo.nullable(auth.user_id_to_pgo_value, todo_item.assignee_id),
        pgo.int(todo_item.sorting_order),
        pgo.int(next_version),
      ],
      return_type,
    )

  response
  |> result.map(fn(_) { Nil })
}

pub fn decode_with_id(
  json: Dynamic,
) -> Result(TodoItemWithId, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode8(
      TodoItemWithId,
      dynamic.field("id", decode_id),
      dynamic.field("title", dynamic.string),
      dynamic.optional_field("descriptionMarkdown", dynamic.string),
      dynamic.optional_field("dueDate", dynamic_helpers.time),
      dynamic.optional_field("completedAt", dynamic_helpers.time),
      dynamic.optional_field("assigneeId", auth.user_id_decoder),
      dynamic.field("sortingOrder", dynamic.int),
      dynamic.field("listId", todo_list.decode_id),
    )

  decoder(json)
}

pub type FromDb {
  FromDb(
    id: Id,
    title: String,
    description_markdown: Option(String),
    due_date: Option(birl.Time),
    completed_at: Option(birl.Time),
    assignee_id: Option(auth.UserId),
    sorting_order: Int,
    list_id: todo_list.Id,
    is_deleted: Bool,
  )
}

pub fn get_from_workspace(
  workspace_id: workspace.Id,
  prev_version: Int,
  db: pgo.Connection,
) -> Result(List(FromDb), database.DbError) {
  let sql =
    "
    select
        li.id::text,
        li.title,
        li.description_markdown,
        li.due_date::text,
        li.completed_at::text,
        li.assignee_id,
        li.sorting_order,
        li.list_id::text,
        li.is_deleted
    from
        list_items li
    join
      lists on lists.id = li.list_id
    where
        lists.workspace_id = $1
        and li.replicache_last_modified_version > $2
    "

  let return_type =
    dynamic.decode9(
      FromDb,
      dynamic.element(0, decode_id),
      dynamic.element(1, dynamic.string),
      dynamic.element(2, dynamic.optional(dynamic.string)),
      dynamic.element(3, dynamic.optional(dynamic_helpers.time)),
      dynamic.element(4, dynamic.optional(dynamic_helpers.time)),
      dynamic.element(5, dynamic.optional(auth.user_id_decoder)),
      dynamic.element(6, dynamic.int),
      dynamic.element(7, todo_list.decode_id),
      dynamic.element(8, dynamic.bool),
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

    Ok(pgo.Returned(_count, items)) -> Ok(items)
  }
}

pub fn delete(
  id: Id,
  next_version: Int,
  db: pgo.Connection,
) -> Result(Nil, database.DbError) {
  let sql =
    "
    update
      list_items
    set
      is_deleted = true,
      replicache_last_modified_version = $2
    where
      id = $1
    "

  let return_type = dynamic.dynamic

  let response =
    database.execute(
      sql,
      db,
      [id_to_pgo(id), pgo.int(next_version)],
      return_type,
    )

  response
  |> result.map(fn(_) { Nil })
}

pub fn complete(
  id: Id,
  next_version: Int,
  db: pgo.Connection,
) -> Result(Nil, database.DbError) {
  let sql =
    "
    update
      list_items
    set
      completed_at = now() at time zone 'utc',
      replicache_last_modified_version = $2
    where
      id = $1
    "

  let return_type = dynamic.dynamic

  let response =
    database.execute(
      sql,
      db,
      [id_to_pgo(id), pgo.int(next_version)],
      return_type,
    )

  response
  |> result.map(fn(_) { Nil })
}

pub fn remove_id(item: FromDb) -> TodoItem {
  TodoItem(
    title: item.title,
    description_markdown: item.description_markdown,
    due_date: item.due_date,
    completed_at: item.completed_at,
    assignee_id: item.assignee_id,
    sorting_order: item.sorting_order,
    list_id: item.list_id,
  )
}

pub fn to_json(item: TodoItem) -> Json {
  json.object([
    #("title", json.string(item.title)),
    #(
      "descriptionMarkdown",
      json.nullable(item.description_markdown, json.string),
    ),
    #("dueDate", json.nullable(item.due_date, json_helpers.time)),
    #("completedAt", json.nullable(item.completed_at, json_helpers.time)),
    #("assigneeId", json.nullable(item.assignee_id, auth.user_id_to_json)),
    #("sortingOrder", json.int(item.sorting_order)),
    #("listId", todo_list.id_to_json(item.list_id)),
  ])
}

fn id_to_pgo(id: Id) -> pgo.Value {
  pgo.text(id_to_string(id))
}

pub fn id_to_string(id: Id) -> String {
  id.id
}

pub fn decode_id(json: Dynamic) -> Result(Id, dynamic.DecodeErrors) {
  let decoder = dynamic_helpers.map(dynamic.string, Id)

  decoder(json)
}
