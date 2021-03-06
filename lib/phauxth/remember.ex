defmodule Phauxth.Remember do
  @moduledoc """
  Remember me Plug using Phoenix Token.

  ## Options

  There are two options:

    * context - the context to use when using Phoenix token
      * in most cases, this will be the name of the endpoint you are using
      * see the documentation for Phoenix.Token for more information
    * max_age - the length of the validity of the token
      * the default is four weeks
  """

  @max_age 28 * 24 * 60 * 60

  use Phauxth.Authenticate.Base, max_age: @max_age
  import Plug.Conn
  alias Phoenix.Token

  def call(%Plug.Conn{req_cookies: %{"remember_me" => token}} = conn, {context, max_age}) do
    if conn.assigns[:current_user] do
      conn
    else
      check_token(token, context || conn, max_age) |> log_user(conn) |> set_user(conn)
    end
  end
  def call(conn, _), do: conn

  @doc """
  Add a Phoenix token as a remember me cookie.
  """
  def add_rem_cookie(conn, user_id, max_age \\ @max_age) do
    cookie = Token.sign(conn, "user auth", user_id)
    put_resp_cookie(conn, "remember_me", cookie, [http_only: true, max_age: max_age])
  end

  @doc """
  Delete the remember_me cookie.
  """
  def delete_rem_cookie(conn) do
    register_before_send(conn, &delete_resp_cookie(&1, "remember_me"))
  end

end
