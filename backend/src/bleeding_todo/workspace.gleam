import birl
import bleeding_todo/auth
import bleeding_todo/database
import bleeding_todo/dynamic_helpers
import bleeding_todo/user
import gleam/dynamic
import gleam/json
import gleam/pgo
import gleam/result

pub opaque type WorkspaceId {
  WorkspaceId(id: String)
}

pub type Workspace {
  Workspace(id: WorkspaceId, name: String, icon: WorkspaceIcon)
}

pub type WorkspaceUser {
  WorkspaceUser(
    user: user.User,
    workspace: Workspace,
    permissions: List(WorkspacePermission),
    created_at: birl.Time,
    updated_at: birl.Time,
  )
}

pub type WorkspacePermission {
  WorkspaceDelete
  WorkspaceInvite
  WorkspaceKick
  WorkspaceEdit
  WorkspaceListCreate
  WorkspaceListDelete
  WorkspaceListEdit
  WorkspaceListItemCreate
  WorkspaceListItemComplete
  WorkspaceListItemDelete
  WorkspaceListItemEdit
}

fn workspace_id_decoder(
  data: dynamic.Dynamic,
) -> Result(WorkspaceId, dynamic.DecodeErrors) {
  let decoder = dynamic_helpers.map(dynamic.string, WorkspaceId)

  decoder(data)
}

pub fn to_json(workspace: Workspace) -> json.Json {
  json.object([
    #("id", id_to_json(workspace.id)),
    #("name", json.string(workspace.name)),
    #("icon", icon_to_json(workspace.icon)),
  ])
}

fn id_to_json(workspace_id: WorkspaceId) -> json.Json {
  json.string(workspace_id.id)
}

pub fn get_user_workspaces(
  user_id: auth.UserId,
  db: pgo.Connection,
) -> Result(List(Workspace), database.DbError) {
  let sql =
    "
    select
        ws.id::text, ws.name, ws.icon
    from
        workspace_users
        join workspaces ws on
            workspace_users.workspace_id = ws.id
            and workspace_users.user_id = $1
    "

  let return_type =
    dynamic.decode3(
      Workspace,
      dynamic.element(0, workspace_id_decoder),
      dynamic.element(1, dynamic.string),
      dynamic.element(2, workspace_icon_decoder),
    )

  let response =
    database.execute(sql, db, [auth.user_id_to_pgo_value(user_id)], return_type)

  result.map(response, fn(r) { r.rows })
}

fn workspace_icon_decoder(
  data: dynamic.Dynamic,
) -> Result(WorkspaceIcon, dynamic.DecodeErrors) {
  let decoder =
    dynamic_helpers.map_result(dynamic.string, fn(icon_string) {
      case icon_string {
        "academic-cap" -> Ok(AcademicCap)
        "archive-box" -> Ok(ArchiveBox)
        "banknotes" -> Ok(Banknotes)
        "beaker" -> Ok(Beaker)
        "bolt" -> Ok(Bolt)
        "book-open" -> Ok(BookOpen)
        "bookmark" -> Ok(Bookmark)
        "briefcase" -> Ok(Briefcase)
        "building-storefront" -> Ok(BuildingStorefront)
        "chart-bar" -> Ok(ChartBar)
        "clock" -> Ok(Clock)
        "command_line" -> Ok(CommandLine)
        "cpu-chip" -> Ok(CpuChip)
        "cube" -> Ok(Cube)
        "currency-dollar" -> Ok(CurrencyDollar)
        "exclamation-circle" -> Ok(ExclamationCircle)
        "fire" -> Ok(Fire)
        "light-bulb" -> Ok(LightBulb)
        "map" -> Ok(Map)
        "paint-brush" -> Ok(PaintBrush)
        "puzzle-piece" -> Ok(PuzzlePiece)
        "rocket-launch" -> Ok(RocketLaunch)
        "sparkles" -> Ok(Sparkles)
        "swatch" -> Ok(Swatch)
        _ -> Error(icon_string)
      }
    })

  decoder(data)
}

fn icon_to_json(icon: WorkspaceIcon) -> json.Json {
  json.string(icon_to_string(icon))
}

fn icon_to_string(icon: WorkspaceIcon) -> String {
  case icon {
    AcademicCap -> "academic-cap"
    ArchiveBox -> "archive-box"
    Banknotes -> "banknotes"
    Beaker -> "beaker"
    Bolt -> "bolt"
    BookOpen -> "book-open"
    Bookmark -> "bookmark"
    Briefcase -> "briefcase"
    BuildingStorefront -> "building-storefront"
    ChartBar -> "chart-bar"
    Clock -> "clock"
    CommandLine -> "command_line"
    CpuChip -> "cpu-chip"
    Cube -> "cube"
    CurrencyDollar -> "currency-dollar"
    ExclamationCircle -> "exclamation-circle"
    Fire -> "fire"
    LightBulb -> "light-bulb"
    Map -> "map"
    PaintBrush -> "paint-brush"
    PuzzlePiece -> "puzzle-piece"
    RocketLaunch -> "rocket-launch"
    Sparkles -> "sparkles"
    Swatch -> "swatch"
  }
}

pub opaque type WorkspaceIcon {
  AcademicCap
  ArchiveBox
  Banknotes
  Beaker
  Bolt
  BookOpen
  Bookmark
  Briefcase
  BuildingStorefront
  ChartBar
  Clock
  CommandLine
  CpuChip
  Cube
  CurrencyDollar
  ExclamationCircle
  Fire
  LightBulb
  Map
  PaintBrush
  PuzzlePiece
  RocketLaunch
  Sparkles
  Swatch
}
