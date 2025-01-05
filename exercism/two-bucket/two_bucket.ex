defmodule TwoBucket do
  defstruct bucket_one: 0, bucket_two: 0, moves: 0
  @type t :: %TwoBucket{bucket_one: integer, bucket_two: integer, moves: integer}

  @doc """
  Find the quickest way to fill a bucket with some amount of water from two buckets of specific sizes.
  """
  @spec measure(
          size_one :: integer,
          size_two :: integer,
          goal :: integer,
          start_bucket :: :one | :two
        ) :: {:ok, TwoBucket.t()} | {:error, :impossible}
  def measure(size_one, size_two, goal, :one) when goal > size_one and goal > size_two do
    {:error, :impossible}
  end

  def measure(size_one, size_two, goal, start_bucket) do
    do_measure(
      %__MODULE__{bucket_one: size_one, bucket_two: size_two},
      start_bucket,
      size_one,
      size_two,
      goal
    )
  end

  defp do_measure(%{moves: moves}, _, max_one, max_two, _) when moves > max_one + max_two do
    {:error, :impossible}
  end

  defp do_measure(%{bucket_one: goal, moves: moves} = bs, _, _, _, goal) when moves > 0 do
    {:ok, bs}
  end

  defp do_measure(%{bucket_two: goal, moves: moves} = bs, _, _, _, goal) when moves > 0 do
    {:ok, bs}
  end

  defp do_measure(%__MODULE__{bucket_two: max_two} = bs, :one, max_one, max_two, goal) do
    do_measure(empty(bs, :two), :one, max_one, max_two, goal)
  end

  defp do_measure(%__MODULE__{bucket_one: max_one} = bs, :two, max_one, max_two, goal) do
    do_measure(empty(bs, :one), :two, max_one, max_two, goal)
  end

  defp do_measure(%__MODULE__{bucket_one: 0} = bs, :one, max_one, max_two, goal) do
    do_measure(fill(bs, :one, max_one), :one, max_one, max_two, goal)
  end

  defp do_measure(%__MODULE__{bucket_two: 0} = bs, :two, max_one, max_two, goal) do
    do_measure(fill(bs, :two, max_two), :two, max_one, max_two, goal)
  end

  defp do_measure(bs, :one, max_one, max_two, goal) do
    do_measure(pour(bs, :one, max_two), :one, max_one, max_two, goal)
  end

  defp do_measure(bs, :two, max_one, max_two, goal) do
    do_measure(pour(bs, :two, max_one), :two, max_one, max_two, goal)
  end

  defp empty(bs, :one), do: %__MODULE__{bs | bucket_one: 0, moves: bs.moves + 1}
  defp empty(bs, :two), do: %__MODULE__{bs | bucket_two: 0, moves: bs.moves + 1}

  defp fill(bs, :one, max), do: %__MODULE__{bs | bucket_one: max, moves: bs.moves + 1}
  defp fill(bs, :two, max), do: %__MODULE__{bs | bucket_two: max, moves: bs.moves + 1}

  defp pour(bs, :one, max) do
    capacity = max - bs.bucket_two
    available = min(bs.bucket_one, capacity)

    %__MODULE__{
      bucket_one: bs.bucket_one - available,
      bucket_two: bs.bucket_two + available,
      moves: bs.moves + 1
    }
  end

  defp pour(bs, :two, max) do
    capacity = max - bs.bucket_one
    available = min(bs.bucket_two, capacity)

    %__MODULE__{
      bucket_one: bs.bucket_one + available,
      bucket_two: bs.bucket_two - available,
      moves: bs.moves + 1
    }
  end
end
