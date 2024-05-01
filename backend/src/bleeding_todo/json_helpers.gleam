import birl
import gleam/json.{type Json}

pub fn time(time: birl.Time) -> Json {
  json.string(birl.to_iso8601(time))
}
