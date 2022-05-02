defmodule Support.ErrorAdapters do
  import Mox

  @errors [:eacces, :enomem, :unknown]

  defp module_name(error) do
    error_module =
      error
      |> to_string()
      |> String.capitalize()

    String.to_atom("#{__MODULE__}.#{error_module}")
  end

  def error_adapter(error) when error in @errors do
    module = module_name(error)
    Mox.defmock(module, for: Q3Reporter.Log)

    module
    |> expect(:read, fn _ -> {:error, error} end)
    |> expect(:mtime, fn _ -> {:error, error} end)
  end
end
