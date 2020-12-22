defmodule HarFetcher.Mixfile do
  use Mix.Project

  def application do
    [applications: [:jason]]
  end

  def project do
    [app: :har_fetcher,
     version: "1.0.0",
      deps: deps(),
      escript: escript()
    ]
  end

  defp escript do
    [main_module: HarFetcher]
  end

  defp deps do
     [{:jason, "~> 1.2"}]
  end
end
