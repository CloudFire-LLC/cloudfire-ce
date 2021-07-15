defmodule FzHttpWeb.Router do
  @moduledoc """
  Main Application Router
  """

  use FzHttpWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {FzHttpWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FzHttpWeb do
    pipe_through :browser

    get "/", DeviceController, :index
    resources "/session", SessionController, only: [:new, :create, :delete]

    live "/account", AccountLive.Show, :show
    live "/account/edit", AccountLive.Show, :edit

    live "/rules", RuleLive.Index, :index

    live "/devices", DeviceLive.Index, :index
    live "/devices/:id", DeviceLive.Show, :show
    live "/devices/:id/edit", DeviceLive.Show, :edit

    get "/sign_in/:token", SessionController, :create
    delete "/user", UserController, :delete
  end
end
