defmodule RTQueue do
  @moduledoc """
    An elixir realtime queue implement.
  """

  @typedoc """
    The state type in the RTQueue module stands for the reverse state of the queue. 
  """
  @type state :: :Empty 
               | {:Reverse, non_neg_integer, list, list, list, list} 
               | {:Concat, non_neg_integer, list, list}
               | {:Done, list}

  @typedoc """
    The q type stands for the realtime data for a RTQueue.
  """
  @type q :: {list, non_neg_integer, state, list, non_neg_integer}


  defstruct realtime: {[], 0, :Empty, [], 0}
  @typedoc """
    The t type stands for the RTQueue.
  """
  @type t :: %RTQueue{realtime: q} 

  @doc """
    Return an empty queue.
  """
  @spec new() :: t
  def new(), do: %RTQueue{realtime: {[], 0, :Empty, [], 0}}

  @doc """
    Return true when the queue is empty, false when the queue is not empty.
  """
  @spec empty?(t) :: boolean
  def empty?(queue) do
    {_, lenf, _, _, _} = queue.realtime
    lenf == 0
  end

  @spec next(state) :: state
  defp next({:Reverse, n, [x | f], fp, [y | r], rp}) do
    {:Reverse, (n + 1), f, [x | fp], r, [y | rp]}
  end
  defp next({:Reverse, n, [], fp, [y], rp}) do
    {:Concat, n, fp, [y | rp]}
  end
  defp next({:Concat, 0, _, acc}) do
    {:Done, acc}
  end
  defp next({:Concat, n, [x | fp], acc}) do
    {:Concat, (n - 1), fp, [x | acc]}
  end
  defp next(s), do: s

  @spec abort(state) :: state
  defp abort({:Concat, 0, _, [_ | acc]}) do
    {:Done, acc}
  end
  defp abort({:Concat, n, fp, acc}) do
    {:Concat, (n - 1), fp, acc}
  end
  defp abort({:Reverse, n, f, fp, r, rp}) do
    {:Reverse, (n - 1), f, fp, r, rp}
  end
  defp abort(s), do: s

  @spec step(list, non_neg_integer, state, list, non_neg_integer) :: t
  defp step(f, lenf, s, r, lenr) do
    sp = 
    if Enum.empty?(f) do
      s |> next() |> next()
    else
      s |> next()
    end
    case sp do
      {:Done, fp} -> %RTQueue{realtime: {fp, lenf, :Empty, r, lenr}}
      sp -> %RTQueue{realtime: {f, lenf, sp, r, lenr}}
    end
  end

  @spec balance(list, non_neg_integer, state, list, non_neg_integer) :: t
  defp balance(f, lenf, s, r, lenr) do
    cond do
      lenr <= lenf -> step(f, lenf, s, r, lenr)
      true -> step(f, lenf + lenr, {:Reverse, 0, f, [], r, []}, [], 0)
    end
  end

  @doc """
    Push an element to the back of a queue.
  """
  @spec push(t, any) :: t
  def push(queue, x) do
    {f, lenf, s, r, lenr} = queue.realtime
    balance(f, lenf, s, [x | r], (lenr + 1))
  end

  @doc """
    Pop the front element of a queue.
  """
  @spec pop(t) :: t
  def pop(queue) do
    {[_ | f], lenf, s, r, lenr} = queue.realtime
    balance(f, lenf - 1, abort(s), r, lenr)
  end

  @doc """
    Get the front element of a queue.
  """
  @spec front(t) :: any
  def front(queue) do
    {[x | _], _, _, _, _} = queue.realtime
    x
  end

  @doc """
    Return the size of a queue.
  """
  @spec size(t) :: non_neg_integer
  def size(queue) do
    {_, lenf, _, _, lenr} = queue.realtime
    lenf + lenr
  end

  defimpl Inspect do
    def inspect(queue, _opts \\ []) do
      case RTQueue.empty?(queue) do
        false -> Inspect.Algebra.concat([
          "#RTQueue<[",
          "size: " <> to_string(RTQueue.size(queue)),
          ", front: " <> Kernel.inspect(RTQueue.front(queue)),
          "]>"
          ])
        true -> "Empty #RTQueue"
      end
    end
  end

end
defmodule FQueue do
  @moduledoc """
    An elixir queue implement using fingertree.
  """
  require FList.FTree

  defstruct tree: :Empty
  @type t :: %FQueue{tree: FList.FTree.t}

  @doc """
    Return an empty queue.
  """
  @spec new() :: t
  def new(), do: %FQueue{tree: :Empty}

  @doc """
    Return the size of a queue.
  """
  @spec size(t) :: non_neg_integer
  def size(queue), do: FList.FTree.sizeT(queue.tree)
  
  @doc """
    Return true when the queue is empty, false when the queue is not empty.
  """
  @spec empty?(t) :: boolean
  def empty?(queue), do: queue.tree == :Empty

  @doc """
    Get the front element of a queue.
  """
  @spec front(t) :: any
  def front(queue), do: FList.FTree.head(queue.tree)
  
  @doc """
    Get the back element of a queue.
  """
  @spec back(t) :: any
  def back(queue), do: FList.FTree.last(queue.tree)

  @doc """
    Push an element to the back of a queue.
  """
  @spec push(t, any) :: t
  def push(queue, element) do
    %FQueue{queue | tree: queue.tree |> FList.FTree.snoc(element)}
  end

  @doc """
    Pop the front element of a queue.
  """
  @spec pop(t) :: t
  def pop(queue) do
    %FQueue{queue | tree: queue.tree |> FList.FTree.tail()}
  end

  defimpl Inspect do
    def inspect(queue, _opts \\ []) do
      case FQueue.empty?(queue) do
        false -> Inspect.Algebra.concat([
          "#FQueue<[",
          "size: " <> to_string(FQueue.size(queue)),
          ", front: " <> Kernel.inspect(FQueue.front(queue)),
          "]>"
          ])
        true -> "Empty #FQueue"
      end
    end
  end
end
