# Overview

Dependable is a lightweight library for dependency injection in Elixir using Application config. With the goal of making dependency injection
and designing code with behaviours a better developer experience.

If you are unfamiliar with the concepts around dependency injection AppSignal has put together a great [blog post](https://blog.appsignal.com/2024/05/21/using-dependency-injection-in-elixir.html) for getting up to speed on the pattern and how it can be implemented in elixir.

## Benefits
- Leightweight
- Sensible defaults
- Keep IDE features such as auto complete for behaviour callbacks

## Tradeoffs
- Behaviours have to be defined in their own module. Due to how Dependable proxies functions calls the implementation of a behaviour and the behaviour itself cannot reside in the same module.

The remainder of this guide will be an getting started guide with getting dependable installed, configured, and then put to use.

# Installation & Configuration

Dependable is available through hex.pm. You can look up the most up to date version by calling.

```bash
mix hex.search dependable
```

Then adding it to your application dependencies in `mix.exs`.

```elixir
defp deps do
  [
    # ... snip
    {:dependable, "0.1.0"}
    # ... snip
  ]
end
```

Next, Dependable needs a bit of application configuration in order to lookup application config for your implementation modules. Place the name
of your `:otp_app` (`:my_app` in this example) in your `config/config.exs`.

```elixir
config :dependable, :otp_app, :my_app
```

This will be the default application config that will be queried when using Dependable,

## Usage

Dependable works by making defined behaviours callable by name. Dependable will do the lookup of the implementation module for you and invoke it.
This makes it easier to see behaviour in application code as well as getting auto complete of the functions defined in the behaviour. As an
example, say we have the need for sending emails in our application. We might define a behaviour such as:

```elixir
defmodule MyApp.EmailProvider do
  use Dependable

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

Next we can use application environment to configure what email provider is used. For this example we can imagine that in prod envs we would want
the `FancyEmailProvider` but in testing environments we would want to inject a Mox mock. For the key name in configuration we can use the name
of the behaviour itself which is the default lookup key used by Dependable.

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

### Overriding defaults

By default Dependable will look for behaviour in the configured otp application namespace using the name of the behaviour as the lookup key. If
for whatever reason this default doesn't work it can be overriden on a case by case basis in the `use` statement. Such as:

```elixir
defmodule MyApp.EmailProvider do
  use Dependable, otp_app: :other_appliction, key: :email_provider

  # snip...
end
```
