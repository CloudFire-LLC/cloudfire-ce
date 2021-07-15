defmodule FzHttp.Users.User do
  @moduledoc """
  Represents a User I guess
  """

  use Ecto.Schema
  import Ecto.Changeset
  import FzHttp.Users.PasswordHelpers

  alias FzCommon.FzMap
  alias FzHttp.Devices.Device

  schema "users" do
    field :email, :string
    field :last_signed_in_at, :utc_datetime_usec
    field :password_hash, :string
    field :sign_in_token, :string
    field :sign_in_token_created_at, :utc_datetime_usec

    # VIRTUAL FIELDS
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :current_password, :string, virtual: true

    has_many :devices, Device, on_delete: :delete_all

    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [
      :sign_in_token,
      :sign_in_token_created_at,
      :email,
      :password_hash,
      :password,
      :password_confirmation
    ])
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_password_equality()
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> put_password_hash()
    |> validate_required([:password_hash])
  end

  # Sign in token
  # XXX: Map keys must be strings for this approach to work. Refactor to something that is key
  # type agnostic.
  def update_changeset(
        user,
        %{"sign_in_token" => _token, "sign_in_token_created_at" => _created_at} = attrs
      ) do
    user
    |> cast(attrs, [:sign_in_token, :sign_in_token_created_at])
    |> validate_required([:sign_in_token, :sign_in_token_created_at])
  end

  # Password updated with user logged in
  def update_changeset(
        user,
        %{
          "password" => nil,
          "password_confirmation" => nil,
          "current_password" => nil
        } = attrs
      ) do
    update_changeset(user, FzMap.compact(attrs))
  end

  def update_changeset(
        user,
        %{"password" => "", "password_confirmation" => "", "current_password" => ""} = attrs
      ) do
    update_changeset(user, FzMap.compact(attrs, ""))
  end

  def update_changeset(
        user,
        %{
          "password" => _password,
          "password_confirmation" => _password_confirmation,
          "current_password" => _current_password
        } = attrs
      ) do
    user
    |> cast(attrs, [:email, :password, :password_confirmation, :current_password])
    |> validate_required([:email, :password, :password_confirmation, :current_password])
    |> validate_format(:email, ~r/@/)
    |> verify_current_password(user)
    |> validate_password_equality()
    |> put_password_hash()
    |> validate_required([:password_hash])
  end

  # Password updated from token
  def update_changeset(
        user,
        %{
          "password" => _password,
          "password_confirmation" => _password_confirmation
        } = attrs
      ) do
    user
    |> cast(attrs, [:email, :password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_password_equality()
    |> put_password_hash()
    |> validate_required([:password_hash])
  end

  # Only email being updated
  def update_changeset(user, %{"email" => _email} = attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
  end

  # XXX: Invalidate password reset when user is updated
  def update_changeset(user, %{} = attrs) do
    changeset(user, attrs)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :last_signed_in_at])
  end

  def authenticate_user(user, password_candidate) do
    Argon2.check_pass(user, password_candidate)
  end

  defp verify_current_password(
         %Ecto.Changeset{
           changes: %{current_password: _}
         } = changeset,
         user
       ) do
    case authenticate_user(user, changeset.changes.current_password) do
      {:ok, _user} -> changeset |> delete_change(:current_password)
      {:error, error_msg} -> changeset |> add_error(:current_password, error_msg)
    end
  end
end
