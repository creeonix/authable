defmodule Authable.Sources.Remote do
  def get_resource_owner(nil), do: nil
  def get_resource_owner(token) do
    Authable.Sources.Remote.HTTP.start()
    case Authable.Sources.Remote.HTTP.me(token.value) do
      %{"user" => user} -> user
      _ -> nil
    end
  end

  def get_token(token_value, _) do
    Authable.Sources.Remote.HTTP.start()
    case Authable.Sources.Remote.HTTP.me(token_value) do
      %{"token" => token} -> token
      _ -> nil
    end
  end

  defmodule HTTP do
    use HTTPoison.Base

    @resource_owner Application.get_env(:authable, :resource_owner)
    @token_store Application.get_env(:authable, :token_store)
    @source Application.get_env(:authable, :source)

    def process_url(url) do
      @source[:url] <> url
    end

    def me(token) do
      case get!("/users/me", api_headers(token)) do
        %HTTPoison.Response{status_code: 200} = resp -> resp.body
        _ -> nil
      end
    end

    defp api_headers(token) do
      [
        "Authorization": "Bearer #{token}",
        "Content-Type": "application/json",
        "Accept": "application/json"
      ]
    end

    def process_response_body(body) do
      body
      |> Poison.decode!(as: %{
          "token" => %@token_store{},
          "user" => %@resource_owner{}
        })
    end
  end
end
