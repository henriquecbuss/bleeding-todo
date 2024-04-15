import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/pgo

pub type DbError {
  PgoError(pgo.QueryError)
  UnexpectedReturnLength(expected: Int, actual: Int)
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
