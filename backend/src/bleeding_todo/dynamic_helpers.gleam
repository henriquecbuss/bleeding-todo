import birl
import gleam/dynamic.{type DecodeErrors, type Decoder, type Dynamic}
import gleam/list
import gleam/result
import gleam/string

pub fn map(decoder decoder: Decoder(a), mapper mapper: fn(a) -> b) -> Decoder(b) {
  fn(data: Dynamic) {
    use original_result <- result.try(decoder(data))

    Ok(mapper(original_result))
  }
}

pub fn map_result(
  decoder decoder: Decoder(a),
  mapper mapper: fn(a) -> Result(b, err),
) -> Decoder(b) {
  fn(data: Dynamic) {
    use original_result <- result.try(decoder(data))

    mapper(original_result)
    |> result.map_error(fn(err) {
      [
        dynamic.DecodeError(
          expected: "original_result: " <> string.inspect(original_result),
          found: "map_result error: " <> string.inspect(err),
          path: [],
        ),
      ]
    })
  }
}

pub fn time(from data: Dynamic) -> Result(birl.Time, DecodeErrors) {
  let decoder = map_result(dynamic.string, birl.parse)

  decoder(data)
}

fn error_to_string(error: dynamic.DecodeError) -> String {
  "DecodeError: expected `"
  <> error.expected
  <> "`, found `"
  <> error.found
  <> "` at `"
  <> string.join(error.path, ".")
  <> "`"
}

pub fn errors_to_string(error_list: dynamic.DecodeErrors) -> String {
  error_list
  |> list.map(error_to_string)
  |> string.join("\n")
}
