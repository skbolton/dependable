defmodule Dependable.ImplMissingError do
  @moduledoc """
  Raised when an implementor of a behaviour cannot be found.

  Either the application config doesn't contain a entry for setting the
  implmentor for a given env or the lookup key for the implementor is
  incorrect.
  """
  defexception [:message]

  def exception(opts) do
    otp_app = opts[:otp_app]
    lookup = opts[:lookup_key]

    %__MODULE__{
      message: "Implementor not configured for behaviour #{lookup} for application :#{otp_app}"
    }
  end
end

