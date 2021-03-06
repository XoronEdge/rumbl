defmodule RumblWeb.UserController do
  use RumblWeb, :controller
  alias Rumbl.{Accounts, Accounts.User}
  plug :authenticate when action in [:index, :show]

  def index(conn, _) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    render(conn, "show.html", user: user)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> RumblWeb.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def new(conn, _params) do
    changeset = Accounts.change_registration(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  defp authenticate(conn, _opts) do
    if(conn.assigns.current_user) do
      conn
    else
      conn
      |> put_flash(:error, "You must Be Loggin to Access The Page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
