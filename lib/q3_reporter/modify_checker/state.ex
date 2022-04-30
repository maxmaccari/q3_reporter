defmodule Q3Reporter.ModifyChecker.State do
  @moduledoc false

  @type mtime :: NaiveDateTime.t()
  @type checker ::
          (String.t() -> {:ok, mtime()} | {:error, any()})

  @type t :: %__MODULE__{
          mtime: mtime,
          path: String.t(),
          subscribers: list(pid()),
          checker: checker
        }

  defstruct path: nil, mtime: nil, subscribers: [], checker: &__MODULE__.__default_checker__/1

  @spec new(keyword()) :: t()
  def new(opts) do
    struct!(__MODULE__, opts)
  end

  @spec subscribe(t(), pid()) :: t()
  def subscribe(%__MODULE__{} = state, subscriber) do
    if subscribed?(state, subscriber) do
      state
    else
      %{state | subscribers: [subscriber | state.subscribers]}
    end
  end

  @spec subscribed?(t(), pid()) :: boolean
  def subscribed?(%__MODULE__{} = state, subscriber) do
    Enum.any?(state.subscribers, &(&1 === subscriber))
  end

  @spec unsubscribe(t(), pid()) :: t()
  def unsubscribe(%__MODULE__{} = state, subscriber) do
    unsubscribe_by(state, &(&1 === subscriber))
  end

  @spec unsubscribe_by(t(), (pid() -> boolean())) :: t()
  def unsubscribe_by(%__MODULE__{} = state, fun) do
    subscribers = Enum.reject(state.subscribers, fun)

    %{state | subscribers: subscribers}
  end

  @spec each_subscribers(t(), (pid() -> any())) :: t()
  def each_subscribers(%__MODULE__{} = state, fun) do
    Enum.each(state.subscribers, fun)

    state
  end

  @spec update_mtime(t(), mtime()) :: t()
  def update_mtime(%__MODULE__{} = state, mtime) do
    %{state | mtime: mtime}
  end

  @spec check(t()) :: :not_modified | {:modified, t()} | {:error, any()}
  def check(%__MODULE__{} = state) do
    %{path: path, mtime: mtime, checker: checker} = state

    case checker.(path) do
      {:ok, ^mtime} -> :not_modified
      {:ok, new_mtime} -> {:modified, update_mtime(state, new_mtime)}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec __default_checker__(String.t()) :: {:ok, mtime()}
  def __default_checker__(_path), do: {:ok, NaiveDateTime.utc_now()}
end
