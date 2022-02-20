# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sample, env: Mix.env()

config :sample, :projector_options,
  hydration_delay: System.get_env("PROJECTOR_HYDRATION_DELAY") || 1000,
  hydration_delay_entropy: 100

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
