// cellspan: the types every module shares.
type failure = {code: int, message: string}

type outcome = {exit: int, out: string, err: string}

type invocation = {
  options: array<(string, string)>,
  args: array<string>,
  input: string,
}

type command = {
  name: string,
  option: option<string>,
  positional: int,
  needs: string,
  run: invocation => result<string, failure>,
}

exception Stop(failure)

let fail = (code, message) => Error({code, message})
