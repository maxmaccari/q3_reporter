defmodule Q3Reporter.LogWatcher.State do
  @moduledoc false

  @typep date :: {integer, integer, integer}
  @typep time :: {integer, integer, integer}
  @typep erl_datetime :: {date, time}

  @type t :: %__MODULE__{
          mtime: erl_datetime(),
          path: String.t(),
          subscribers: list(pid()),
          log_adapter: atom() | nil
        }

  defstruct path: nil, mtime: nil, subscribers: [], log_adapter: nil

  @spec new(path: String.t(), mtime: erl_datetime()) :: t()
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

  @spec update_mtime(t(), erl_datetime()) :: t()
  def update_mtime(%__MODULE__{} = state, mtime) do
    %{state | mtime: mtime}
  end
end
