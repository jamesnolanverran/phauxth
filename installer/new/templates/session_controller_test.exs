defmodule <%= base %>.Web.SessionControllerTest do
  use <%= base %>.Web.ConnCase

  import <%= base %>.Web.AuthCase

  @create_attrs %{email: "robin@mail.com", password: "mangoes&g0oseberries"}
  @invalid_attrs %{email: "robin@mail.com", password: "maaaangoes&g00zeberries"}

  setup %{conn: conn} do<%= if not api do %>
    conn = conn |> bypass_through(<%= base %>.Web.Router, :browser) |> get("/")<% end %>
    user = add_user("robin@mail.com")<%= if api do %>
    conn = conn |> add_token_conn(user)<% end %>
    {:ok, %{conn: conn, user: user}}
  end

  test "login succeeds", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @create_attrs<%= if api do %>
    assert json_response(conn, 200)["info"]["detail"]<% else %>
    assert redirected_to(conn) == user_path(conn, :index)<% end %>
  end

  test "login fails", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @invalid_attrs<%= if api do %>
    assert json_response(conn, 401)["errors"]["detail"] =~ "need to login"
  end<% else %>
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "logout succeeds", %{conn: conn, user: user} do
    conn = conn |> put_session(:user_id, user.id) |> send_resp(:ok, "/")
    conn = delete conn, session_path(conn, :delete, user)
    assert redirected_to(conn) == page_path(conn, :index)
  end<% end %>
end
