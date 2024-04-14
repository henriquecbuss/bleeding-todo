import bleeding_todo/web
import gleam/dynamic.{type Dynamic}
import gleam/http.{Post}
import gleam/json
import gleam/result
import wisp.{type Request, type Response}

pub type Person {
  Person(name: String, is_cool: Bool)
}

fn decode_person(json: Dynamic) -> Result(Person, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode2(
      Person,
      dynamic.field("name", dynamic.string),
      dynamic.field("is-cool", dynamic.bool),
    )
  decoder(json)
}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)
  use <- wisp.require_method(req, Post)

  use json <- wisp.require_json(req)

  let result = {
    use person <- result.try(decode_person(json))

    let object =
      json.object([
        #("name", json.string(person.name)),
        #("is-cool", json.bool(person.is_cool)),
        #("saved", json.bool(True)),
      ])
    Ok(json.to_string_builder(object))
  }

  case result {
    Ok(json) -> wisp.json_response(json, 201)

    Error(_) -> wisp.unprocessable_entity()
  }
}
