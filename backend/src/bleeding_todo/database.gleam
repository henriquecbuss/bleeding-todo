import gleam/dynamic.{type DecodeError, type Decoder, type Dynamic}
import gleam/pgo
import gleam/int
import gleam/string
import gleam/list
import gleam/result

pub type DbError {
  PgoError(pgo.QueryError)
  UnexpectedReturnLength(expected: Int, actual: Int)
}

pub fn execute(
  query: String,
  db: pgo.Connection,
  values: List(pgo.Value),
  decoder: Decoder(return_type),
) -> Result(pgo.Returned(return_type), DbError) {
  pgo.execute(query, db, values, decoder)
  |> result.map_error(PgoError)
}

pub fn execute_single(
  query: String,
  db: pgo.Connection,
  values: List(pgo.Value),
  decoder: fn(Dynamic) -> Result(return_type, List(DecodeError)),
) -> Result(return_type, DbError) {
  let response = pgo.execute(query, db, values, decoder)

  case response {
    Error(err) -> Error(PgoError(err))
    Ok(pgo.Returned(1, [result])) -> Ok(result)
    Ok(pgo.Returned(count, _)) ->
      Error(UnexpectedReturnLength(expected: 1, actual: count))
  }
}

pub fn db_error_to_internal_string(err: DbError) -> String {
  case err {
    UnexpectedReturnLength(expected, actual) ->
      "Expected exactly "
      <> int.to_string(expected)
      <> " row(s), got "
      <> int.to_string(actual)
      <> " rows"

    PgoError(query_error) -> pgo_error_to_internal_string(query_error)
  }
}

fn pgo_error_to_internal_string(err: pgo.QueryError) {
  case err {
    pgo.ConstraintViolated(message, constraint, detail) ->
      "Constraint violated: "
      <> message
      <> " ("
      <> constraint
      <> "): "
      <> detail

    pgo.PostgresqlError(code, name, message) ->
      "PostgreSQL error: " <> code <> " (" <> name <> "): " <> message

    pgo.UnexpectedArgumentCount(expected, got) ->
      "Unexpected argument count: "
      <> int.to_string(got)
      <> " (expected "
      <> int.to_string(expected)
      <> ")"

    pgo.UnexpectedArgumentType(expected, got) ->
      "Unexpected argument type: " <> got <> " (expected " <> expected <> ")"

    pgo.UnexpectedResultType(decode_errors) ->
      "Unexpected result type: "
      <> string.join(
        list.map(decode_errors, dynamic_error_to_internal_string),
        ", ",
      )

    pgo.ConnectionUnavailable -> "Connection unavailable"
  }
}

fn dynamic_error_to_internal_string(err: DecodeError) {
  "Decode error: expected "
  <> err.expected
  <> ", found "
  <> err.found
  <> " ("
  <> string.join(err.path, ".")
  <> ")"
}
