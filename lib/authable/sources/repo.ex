defmodule Authable.Sources.Repo do
  @repo Application.get_env(:authable, :repo)
  @resource_owner Application.get_env(:authable, :resource_owner)
  @token_store Application.get_env(:authable, :token_store)
  
  def get_resource_owner(nil), do: nil
  def get_resource_owner(token) do
    @repo.get(@resource_owner, token.user_id)
  end

  def get_token(token_name, token_value) when is_nil(token_name) or is_nil(token_value), do: nil
  def get_token(token_name, token_value) do
    @repo.get_by(@token_store, value: token_value, name: token_name)
  end
end