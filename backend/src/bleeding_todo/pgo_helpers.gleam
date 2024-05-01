import birl
import gleam/pgo

pub fn time(time: birl.Time) -> pgo.Value {
  pgo.int(birl.to_unix(time))
}
