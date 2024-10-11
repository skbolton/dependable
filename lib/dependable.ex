defmodule Dependable do
  @moduledoc """
  Lightweight dependency injection using application config.

  Dependable works by making defined behaviours callable by name. Dependable
  will do the lookup of the implementation module for you and invoke it. This
  makes it easier to see behaviour in application code as well as getting auto
  complete of the functions defined in the behaviour.

  As an example, say we have the need for sending emails in our application. We
  might define a behaviour such as:

  ```elixir
  defmodule MyApp.EmailProvider do
    @callback send(MyApp.Email.t()) :: {:ok, MyApp.Email.t()} | {:error, MyApp.EmailSendError.t()}
  end
  ```

  Now we can define an implementation for this module.

  ```elixir
  defmodule Infra.FancyEmailProvider do
    @behaviour MyApp.EmailProvider

    @impl MyApp.EmailProvider
    def send(%MyApp.Email{} = email) do
      # ...implementation details ...
    end
  end
  ```

  Next we can use application environment to configure what email provider is
  used. For this example we can imagine that in prod envs we would want the
  `FancyEmailProvider` but in testing environments we would want to inject a
  Mox mock. For the key name in configuration we can use the name of the
  behaviour itself which is the default lookup key used by Dependable.

  ```elixir
  # in config.exs
  config :my_app, MyApp.EmailProvider, Infra.FancyEmailProvider

  # in test.exs
  # this mock would have to be defined in some tool such Mox
  config :my_app, MyApp.EmailProvider, MyApp.EmailProvider.Mock
  ```

  Lastly, we can now call into the behaviour in our application logic.

  ```elixir
  defmodule MyApp.Onboarding do
    def onboard_customer(params) do
      params
        |> MyApp.Email.new!()
        |> MyApp.EmailProvider.send()
    end
  end
  ```

  """
  defmacro __using__(opts) do
    quote do
      @dependable_otp_app Keyword.get(
                            unquote(opts),
                            :otp_app,
                            Application.compile_env(:dependable, :otp_app)
                          )
      @dependable_lookup Keyword.get(unquote(opts), :key, __MODULE__)
      @before_compile Dependable
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      __MODULE__
      |> Module.get_attribute(:callback)
      |> Enum.each(fn {:callback, {:"::", _, [{fname, _, args_cb_ast}, _]}, _} ->
        arity = length(args_cb_ast)
        args = Macro.generate_arguments(arity, __MODULE__)

        ast =
          quote do
            def unquote(fname)(unquote_splicing(args)) do
              Dependable.impl!(
                @dependable_otp_app,
                @dependable_lookup
              ).unquote(fname)(unquote_splicing(args))
            end
          end

        Code.eval_quoted(ast, [], __ENV__)
      end)
    end
  end

  @doc """
  Lookup the implementor of a given behaviour raising if one cannot be found.
  """
  def impl!(otp_app, lookup_key) do
    case Application.get_env(otp_app, lookup_key) do
      nil -> raise Dependable.ImplMissingError, otp_app: otp_app, lookup_key: lookup_key
      implementor -> implementor
    end
  end
end
