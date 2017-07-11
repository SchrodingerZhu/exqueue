defmodule Exqueue.Mixfile do
  use Mix.Project

  def project do
    [app: :exqueue,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     name: "exqueue",
     source_url: "https://github.com/SchrodingerZhu/exqueue",
     description: description(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    []
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:flist, "~> 0.1.0"}, 
     {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end
  defp description() do
    """
     Several simple implements of functional queue data structures in Elixir.
    """
  end
  defp package() do
    [
     name: :exqueue,
     licenses: ["MIT"],
     maintainers: ["SchrodingerZhu(朱一帆)"],
     links: %{"SchrodingerZhu's GitHub" => "https://github.com/SchrodingerZhu"},
     source_url: "https://github.com/SchrodingerZhu/exqueue",
     description: description(),
     deps: deps()
    ]
  end
end
